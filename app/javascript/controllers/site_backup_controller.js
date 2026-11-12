import { Controller } from "@hotwired/stimulus"

// The Backup and restore page (Admin::BackupsController, SiteBackup).
// Backing up: the server makes the files, the browser saves them (into a folder the
// administrator picks, where the browser allows it), then the server's copies are
// deleted. Restoring: the chosen files are uploaded in parts, then the server restores
// them in the background while this page shows how far it has got.
export default class extends Controller {
  static targets = ["status", "database", "images", "backupButton", "saveAgainButton", "discardButton",
                    "files", "plan", "confirm", "restoreButton"]
  static values = { statusUrl: String, startUrl: String, downloadUrl: String, discardUrl: String,
                    uploadUrl: String, planUrl: String, restoreUrl: String, discardUploadsUrl: String,
                    dismissUrl: String, chunk: Number, status: Object }

  connect() {
    this.folder = null
    this.planIsGood = false
    this.show(this.statusValue)
    if (this.statusValue.state === "running") this.follow()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  // *** Backing up ***

  async backup() {
    const databases = this.databaseTargets.filter((box) => box.checked).map((box) => box.value)
    const images = this.imagesTarget.checked
    if (databases.length === 0 && !images) return this.message("Choose at least one database or the pictures.", "warning")
    if (!(await this.chooseFolder())) return
    const answer = await this.post(this.startUrlValue, { databases, images })
    if (answer.error) return this.message(answer.error, "danger")
    this.show(answer)
    this.follow({ afterBackup: true })
  }

  async saveAgain() {
    if (!(await this.chooseFolder())) return
    await this.saveFiles(this.statusValue.files || [])
  }

  async discard() {
    const answer = await this.post(this.discardUrlValue, {})
    if (answer.error) return this.message(answer.error, "danger")
    this.show(answer)
    this.message("The copy on the server was deleted.", "success")
  }

  // Chrome and Edge can write into a folder; other browsers download as usual.
  async chooseFolder() {
    this.folder = null
    if (!window.showDirectoryPicker) return true
    try {
      this.folder = await window.showDirectoryPicker({ id: "jump-start-backups", mode: "readwrite" })
      return true
    } catch (error) {
      if (error.name === "AbortError") return false
      return true
    }
  }

  async saveFiles(files) {
    if (files.length === 0) return
    if (this.folder) {
      for (const file of files) {
        const saved = await this.saveFile(file)
        if (!saved) return
      }
      await this.discard()
      this.message(`Saved ${files.map((file) => file.name).join(", ")} into the folder ${this.folder.name}, and deleted the copy on the server.`, "success")
    } else {
      for (const file of files) {
        const link = document.createElement("a")
        link.href = this.downloadUrlValue + encodeURIComponent(file.name)
        link.download = file.name
        document.body.appendChild(link)
        link.click()
        link.remove()
        await new Promise((resolve) => setTimeout(resolve, 1500))
      }
      this.message("Your browser is downloading the files. When they have finished, choose Delete the copy on the server. " +
                   "A very large pictures file may not download completely this way: Chrome or Edge saves it reliably.", "info")
    }
  }

  // Fetches the file in pieces and writes them in order into the chosen folder, so a
  // large file never travels as one long response. A piece that fails is tried again.
  async saveFile(file) {
    const piece = 16 * 1024 * 1024
    let writable
    try {
      const handle = await this.folder.getFileHandle(file.name, { create: true })
      writable = await handle.createWritable()
      for (let offset = 0; offset < file.size; offset += piece) {
        this.message(`Saving ${file.name} into the folder ${this.folder.name}: ${this.size(offset)} of ${this.size(file.size)}…`, "info")
        const data = await this.fetchPiece(file.name, offset, Math.min(piece, file.size - offset))
        await writable.write(data)
      }
      await writable.close()
      return true
    } catch (error) {
      if (writable) await writable.abort().catch(() => {})
      this.message(`${file.name} could not be saved: ${error.message}. The backup is still on the server: choose Save the waiting backup to try again.`, "danger")
      return false
    }
  }

  async fetchPiece(name, offset, length) {
    const query = new URLSearchParams({ offset, length })
    let lastError
    for (let attempt = 1; attempt <= 4; attempt += 1) {
      try {
        const response = await fetch(`${this.downloadUrlValue}${encodeURIComponent(name)}?${query}`, { credentials: "same-origin" })
        if (!response.ok) throw new Error(`the server answered ${response.status}`)
        const data = await response.arrayBuffer()
        if (data.byteLength !== length) throw new Error(`a piece was ${data.byteLength} bytes instead of ${length}`)
        return data
      } catch (error) {
        lastError = error
        await new Promise((resolve) => setTimeout(resolve, attempt * 2000))
      }
    }
    throw lastError
  }

  // *** Restoring ***

  async choose() {
    this.planIsGood = false
    this.planTarget.innerHTML = ""
    const names = [...this.filesTarget.files].map((file) => file.name)
    if (names.length) {
      const answer = await this.post(this.planUrlValue, { names })
      if (answer.error) {
        this.message(answer.error, "danger")
      } else {
        this.statusTarget.hidden = true
        for (const item of answer.plan) {
          const line = document.createElement("li")
          if (item.kind === "database") {
            line.append(`${item.file} replaces the database `)
            const choice = document.createElement("select")
            choice.className = "form-select form-select-sm d-inline-block w-auto"
            choice.dataset.file = item.file
            choice.setAttribute("aria-label", `Database that ${item.file} replaces`)
            if (!item.target) choice.append(new Option("Choose a database", ""))
            for (const name of item.choices) choice.append(new Option(name, name, false, name === item.target))
            choice.addEventListener("change", () => this.checkRestore())
            line.append(choice)
          } else {
            line.textContent = `${item.file} replaces the pictures and uploaded files`
          }
          this.planTarget.appendChild(line)
        }
        this.planIsGood = true
      }
    }
    this.checkRestore()
  }

  checkRestore() {
    const chosen = [...this.planTarget.querySelectorAll("select")].every((choice) => choice.value)
    this.restoreButtonTarget.disabled = !(this.planIsGood && chosen && this.confirmTarget.value.trim() === "RESTORE" && this.statusValue.state !== "running")
  }

  async restore() {
    const files = [...this.filesTarget.files]
    this.restoreButtonTarget.disabled = true
    await this.post(this.discardUploadsUrlValue, {})
    for (const file of files) {
      const ok = await this.upload(file)
      if (!ok) { this.checkRestore(); return }
    }
    const targets = Object.fromEntries([...this.planTarget.querySelectorAll("select")].map((choice) => [choice.dataset.file, choice.value]))
    const answer = await this.post(this.restoreUrlValue, { confirm: this.confirmTarget.value.trim(), targets })
    if (answer.error) { this.message(answer.error, "danger"); this.checkRestore(); return }
    this.confirmTarget.value = ""
    this.show(answer)
    this.follow()
  }

  async upload(file) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    let offset = 0
    do {
      const part = file.slice(offset, offset + this.chunkValue)
      const last = offset + part.size >= file.size
      this.message(`Uploading ${file.name}: ${this.size(offset)} of ${this.size(file.size)}…`, "info")
      const query = new URLSearchParams({ name: file.name, offset, last })
      let response
      try {
        response = await fetch(`${this.uploadUrlValue}?${query}`, {
          method: "POST", credentials: "same-origin", body: part,
          headers: { "Content-Type": "application/octet-stream", "X-CSRF-Token": token, Accept: "application/json" }
        })
      } catch (error) {
        this.message(`The upload of ${file.name} stopped: ${error.message}`, "danger")
        return false
      }
      const answer = await response.json().catch(() => ({ error: `The server answered ${response.status}.` }))
      if (!response.ok || answer.error) {
        this.message(answer.error || `The upload of ${file.name} failed.`, "danger")
        return false
      }
      offset += part.size
    } while (offset < file.size)
    return true
  }

  // *** Progress ***

  follow(options = {}) {
    clearTimeout(this.timer)
    this.timer = setTimeout(async () => {
      let answer = null
      let loggedOut = false
      try {
        const response = await fetch(this.statusUrlValue, { credentials: "same-origin", headers: { Accept: "application/json" } })
        loggedOut = response.redirected || response.status === 401 || response.status === 403
        if (response.ok && !loggedOut) answer = await response.json().catch(() => null)
      } catch (error) {
        answer = null
      }
      // Restoring a database replaces the accounts, so the administrator is logged out.
      if (loggedOut) {
        this.statusTarget.hidden = false
        this.statusTarget.className = "alert alert-warning admin-backup-status"
        this.statusTarget.textContent = "The database was restored, so you were logged out. Log in again with an account and password from the backup, then open Backup and restore to see how the restore ended. "
        const link = document.createElement("a")
        link.href = "/users/sign_in"
        link.textContent = "Log in"
        this.statusTarget.appendChild(link)
        return
      }
      // A restore restarts the site: keep asking until it answers again.
      if (!answer) {
        this.message("Waiting for the site to come back…", "info")
        return this.follow(options)
      }
      this.show(answer)
      if (answer.state === "running") return this.follow(options)
      if (answer.state === "done" && answer.kind === "backup" && options.afterBackup) await this.saveFiles(answer.files || [])
    }, 2000)
  }

  show(status) {
    this.statusValue = status
    const waiting = (status.files || []).length > 0
    this.saveAgainButtonTarget.hidden = !waiting || status.state === "running"
    this.discardButtonTarget.hidden = !waiting || status.state === "running"
    this.backupButtonTarget.disabled = status.state === "running" || waiting
    if (status.state === "running") {
      this.message(`${status.kind === "restore" ? "Restoring" : "Backing up"}: ${status.step || "working"}…`, "info")
    } else if (status.state === "failed") {
      this.message(`The ${status.kind || "job"} failed: ${status.error}`, "danger", true)
    } else if (status.state === "done" && status.kind === "restore") {
      const warnings = (status.warnings || []).join(" ")
      this.message(warnings ? `${status.message} Warning: ${warnings}` : status.message, warnings ? "warning" : "success", true)
    } else if (waiting) {
      this.message(`A backup is waiting on the server: ${status.files.map((file) => `${file.name} (${this.size(file.size)})`).join(", ")}. Save it, or delete the copy on the server.`, "warning")
    }
    this.checkRestore()
  }

  async dismiss() {
    const answer = await this.post(this.dismissUrlValue, {})
    if (!answer.error) { this.statusTarget.hidden = true; this.show(answer) }
  }

  message(text, tone, dismissible = false) {
    this.statusTarget.hidden = false
    this.statusTarget.className = `alert alert-${tone} admin-backup-status`
    this.statusTarget.textContent = text
    if (dismissible) {
      const button = document.createElement("button")
      button.type = "button"
      button.className = "btn btn-sm btn-outline-secondary ms-3"
      button.textContent = "OK"
      button.addEventListener("click", () => this.dismiss())
      this.statusTarget.appendChild(button)
    }
  }

  async post(url, body) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      const response = await fetch(url, {
        method: "POST", credentials: "same-origin", body: JSON.stringify(body),
        headers: { "Content-Type": "application/json", Accept: "application/json", "X-CSRF-Token": token }
      })
      return await response.json().catch(() => ({ error: `The server answered ${response.status}.` }))
    } catch (error) {
      return { error: error.message }
    }
  }

  size(bytes) {
    if (bytes >= 1024 * 1024 * 1024) return `${(bytes / 1024 / 1024 / 1024).toFixed(1)} GB`
    if (bytes >= 1024 * 1024) return `${(bytes / 1024 / 1024).toFixed(1)} MB`
    return `${Math.max(1, Math.round(bytes / 1024))} KB`
  }
}
