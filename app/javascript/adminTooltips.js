// Larger tooltips in the admin and in the page editing mode.
//
// The browser draws an element's title text as a tooltip in a small font that
// cannot be styled, so while the pointer (or keyboard focus) is on such an
// element its title is set aside and shown in our own bubble instead. The
// title comes back as soon as the pointer leaves.

const SCOPE = ".admin-shell, .page-editing, .page-edit-bar, .page-edit-menu";
const DELAY = 450;

let bubble = null;
let current = null;
let timer = null;

function bubbleElement() {
  if (!bubble) {
    bubble = document.createElement("div");
    bubble.className = "admin-tooltip";
    bubble.setAttribute("role", "tooltip");
    bubble.id = "admin-tooltip";
    document.body.append(bubble);
  }
  return bubble;
}

function target(node) {
  const element = node?.closest?.("[title], [data-tooltip-title]");
  if (!element || !element.closest(SCOPE)) return null;
  if (element.matches("iframe, svg title")) return null;
  return element;
}

function place(element) {
  const tip = bubbleElement();
  const box = element.getBoundingClientRect();
  tip.style.left = "0px";
  tip.style.top = "0px";
  tip.classList.add("is-visible");
  const width = tip.offsetWidth;
  const height = tip.offsetHeight;
  const gap = 8;
  let top = box.bottom + gap;
  if (top + height > window.innerHeight - 4) top = Math.max(4, box.top - height - gap);
  let left = box.left + box.width / 2 - width / 2;
  left = Math.max(8, Math.min(left, window.innerWidth - width - 8));
  tip.style.left = `${left + window.scrollX}px`;
  tip.style.top = `${top + window.scrollY}px`;
}

function show(element) {
  const text = element.dataset.tooltipTitle ?? element.getAttribute("title");
  if (!text || !text.trim()) return;
  // Keep the browser's own tooltip from appearing as well.
  if (element.hasAttribute("title")) {
    element.dataset.tooltipTitle = text;
    element.removeAttribute("title");
  }
  current = element;
  clearTimeout(timer);
  timer = setTimeout(() => {
    if (current !== element || !element.isConnected) return;
    bubbleElement().textContent = text;
    element.setAttribute("aria-describedby", "admin-tooltip");
    place(element);
  }, DELAY);
}

function hide() {
  clearTimeout(timer);
  if (current) {
    if (current.dataset.tooltipTitle !== undefined && !current.hasAttribute("title")) {
      current.setAttribute("title", current.dataset.tooltipTitle);
    }
    delete current.dataset.tooltipTitle;
    if (current.getAttribute("aria-describedby") === "admin-tooltip") current.removeAttribute("aria-describedby");
  }
  current = null;
  bubble?.classList.remove("is-visible");
}

document.addEventListener("mouseover", event => {
  const element = target(event.target);
  if (element === current) return;
  hide();
  if (element) show(element);
});
document.addEventListener("mouseout", event => {
  if (current && !current.contains(event.relatedTarget)) hide();
});
document.addEventListener("focusin", event => {
  const element = target(event.target);
  if (element && element === event.target && element !== current) {
    hide();
    show(element);
  }
});
document.addEventListener("focusout", event => { if (event.target === current) hide(); });
document.addEventListener("pointerdown", hide, true);
document.addEventListener("keydown", event => { if (event.key === "Escape") hide(); });
// Scrolling keeps the tooltip beside its element (or hides it once the
// element is gone).
window.addEventListener("scroll", () => {
  if (!current || !bubble?.classList.contains("is-visible")) return;
  if (current.isConnected) place(current);
  else hide();
}, true);
document.addEventListener("turbo:before-render", hide);
