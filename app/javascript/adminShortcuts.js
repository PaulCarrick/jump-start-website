// Assign shortcuts only when exactly one visible admin action uses the key.
const keys = { "Clear Sort": "c", View: "v", Edit: "e", First: "f", Previous: "p", Next: "n", Last: "l", Cancel: "Escape" };
let pending = false;

function actionsByKey() {
  const groups = new Map();
  document.querySelectorAll('.admin-main a.btn, .admin-main button.btn, .admin-main input[type="submit"]').forEach(element => {
    if (!element.getClientRects().length || getComputedStyle(element).visibility === "hidden" || element.closest('[inert], [aria-hidden="true"]')) return;
    const label = (element.value || element.textContent).trim().replace(/\s+/g, " ");
    const key = /^Save\b/.test(label) ? "s" : /^New\b/.test(label) ? "n" : keys[label];
    if (!key) return;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(element);
  });
  return groups;
}

function updateShortcuts() {
  pending = false;
  document.querySelectorAll('.admin-main [accesskey]').forEach(element => element.removeAttribute("accesskey"));
  document.querySelectorAll('.admin-main [data-shortcut-hint]').forEach(element => {
    element.removeAttribute("title");
    element.removeAttribute("aria-keyshortcuts");
    element.removeAttribute("data-shortcut-hint");
  });
  const modifier = /Mac|iPhone|iPad/.test(navigator.platform) ? "Control + Option" : "Alt + Shift";
  actionsByKey().forEach((elements, key) => {
    const element = elements[0];
    if (elements.length !== 1 || element.matches(':disabled, .disabled, [aria-disabled="true"]')) return;
    if (key !== "Escape") element.setAttribute("accesskey", key);
    element.setAttribute("aria-keyshortcuts", key === "Escape" ? "Escape" : /Mac/.test(navigator.platform) ? `Control+Alt+${key}` : `Alt+Shift+${key}`);
    element.title = `Shortcut: ${key === "Escape" ? "Escape" : `${modifier} + ${key.toUpperCase()}`}`;
    element.dataset.shortcutHint = "true";
  });
}

function scheduleUpdate() {
  if (pending) return;
  pending = true;
  requestAnimationFrame(updateShortcuts);
}

// React editors and Turbo can replace controls after the initial page load.
new MutationObserver(scheduleUpdate).observe(document.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ["disabled", "hidden", "class"] });
document.addEventListener("turbo:load", scheduleUpdate);
document.addEventListener("DOMContentLoaded", scheduleUpdate);
scheduleUpdate();

document.addEventListener("keydown", event => {
  if (event.key !== "Escape" || event.defaultPrevented || event.repeat || event.isComposing || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
  if (event.target instanceof Element && event.target.closest("select")) return;
  // Let open dialogs, menus and editors consume Escape before leaving a form.
  if (document.querySelector('.modal.show, .offcanvas.show, .dropdown-menu.show, [role="dialog"], [role="listbox"], dialog[open], [aria-expanded="true"]')) return;
  const cancels = actionsByKey().get("Escape") || [];
  if (cancels.length !== 1 || cancels[0].matches(':disabled, .disabled, [aria-disabled="true"]')) return;
  event.preventDefault();
  cancels[0].click();
});
