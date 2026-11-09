import { Controller } from "@hotwired/stimulus"

// The media library's "Slide show order" strip: a group's pictures as rounded
// boxes. Drag one (mouse, pen or finger) to a new place, or focus one and use
// the left and right arrow keys. The new order is saved as drafts.
export default class extends Controller {
  static targets = ["list", "status"];
  static values = { url: String, group: String };

  connect() {
    this.original = this.ids().join(",");
  }

  items() {
    return Array.from(this.listTarget.querySelectorAll("[data-id]"));
  }

  ids() {
    return this.items().map(item => item.dataset.id);
  }

  // Dragging -----------------------------------------------------------------

  grab(event) {
    if (event.button !== 0) return;
    const item = event.currentTarget;
    event.preventDefault();
    item.focus({ preventScroll: true });
    item.setPointerCapture(event.pointerId);
    this.dragged = item;
    this.startX = event.clientX;
    this.startY = event.clientY;
    this.moved = false;
  }

  drag(event) {
    const item = this.dragged;
    if (!item || event.currentTarget !== item) return;
    if (!this.moved && Math.hypot(event.clientX - this.startX, event.clientY - this.startY) < 5) return;
    if (!this.moved) {
      this.moved = true;
      item.classList.add("is-dragging");
      this.listTarget.classList.add("is-sorting");
    }
    const target = this.items().find(other => {
      if (other === item) return false;
      const box = other.getBoundingClientRect();
      return event.clientX >= box.left && event.clientX <= box.right && event.clientY >= box.top && event.clientY <= box.bottom;
    });
    if (!target) return;
    const box = target.getBoundingClientRect();
    if (event.clientX > box.left + box.width / 2) target.after(item);
    else target.before(item);
    this.renumber();
  }

  drop(event) {
    const item = this.dragged;
    if (!item || event.currentTarget !== item) return;
    this.dragged = null;
    item.classList.remove("is-dragging");
    this.listTarget.classList.remove("is-sorting");
    if (item.hasPointerCapture?.(event.pointerId)) item.releasePointerCapture(event.pointerId);
    if (this.moved) this.save();
  }

  // Keyboard -----------------------------------------------------------------

  key(event) {
    const item = event.currentTarget;
    let moved = false;
    if (event.key === "ArrowLeft" && item.previousElementSibling) {
      item.previousElementSibling.before(item);
      moved = true;
    } else if (event.key === "ArrowRight" && item.nextElementSibling) {
      item.nextElementSibling.after(item);
      moved = true;
    } else if (event.key === "Home" && item !== this.items()[0]) {
      this.listTarget.prepend(item);
      moved = true;
    } else if (event.key === "End" && item !== this.items().at(-1)) {
      this.listTarget.append(item);
      moved = true;
    }
    if (!moved) return;
    event.preventDefault();
    item.focus();
    this.renumber();
    clearTimeout(this.saveTimer);
    this.saveTimer = setTimeout(() => this.save(), 700);
  }

  // Saving -------------------------------------------------------------------

  renumber() {
    const items = this.items();
    items.forEach((item, index) => {
      item.querySelector(".admin-slide-number").textContent = index + 1;
      item.setAttribute("aria-label", `${item.dataset.name}, slide ${index + 1} of ${items.length}`);
    });
  }

  async save() {
    const ids = this.ids();
    if (ids.join(",") === this.original) return this.say("");
    this.say("Saving…");
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content;
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", Accept: "application/json", "X-CSRF-Token": token },
        body: JSON.stringify({ group: this.groupValue, ids })
      });
      const result = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(result.error || "The new order could not be saved.");
      this.original = ids.join(",");
      this.say("Saved as a draft. Publish to show it on the site.");
      this.refreshPublishCount();
    } catch (error) {
      this.say(`${error.message} Reloading…`);
      setTimeout(() => window.location.reload(), 1500);
    }
  }

  say(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message;
  }

  // The top bar's Publish count and the grid (shown in slide order): reload
  // them from this page, quietly.
  async refreshPublishCount() {
    try {
      const response = await fetch(window.location.href, { headers: { Accept: "text/html" } });
      const page = new DOMParser().parseFromString(await response.text(), "text/html");
      const fresh = page.querySelector(".admin-publish-button");
      const current = document.querySelector(".admin-publish-button");
      if (fresh && current) current.replaceWith(fresh);
      const grid = page.querySelector(".admin-media-grid");
      const currentGrid = document.querySelector(".admin-media-grid");
      if (grid && currentGrid) currentGrid.replaceWith(grid);
    } catch (_error) {
      // The count catches up on the next page anyway.
    }
  }
}
