// /app/javascript/components/setupToggle.jsx
import { useEffect } from "react";

// "Show More" / "Show Less" for expandable rows and columns. The content to
// hide is named by a class (for example ".expandableVettaFiCells") and may be
// spread over several sections.
//
// It used to add Bootstrap's "collapse" class to that content once, after the
// page loaded. React owns those elements' classes, so content drawn or redrawn
// after that moment (which reordering sections made more likely) lost the
// class and showed. Now a style rule hides the content until a flag on the
// page says it is open, and one click listener for the whole page handles the
// buttons, so drawing order no longer matters.

const toggleTargets = new Map(); // button id -> class of the content it shows
let listening = false;

const stateKey = (className) => className.replace(/[^A-Za-z0-9_-]/g, "");

const isOpen = (className) =>
  document.documentElement.classList.contains(`expanded-${stateKey(className)}`);

function ensureStyle(className) {
  const key = stateKey(className);
  if (!key || document.querySelector(`style[data-expandable="${key}"]`)) return;
  const style = document.createElement("style");
  style.dataset.expandable = key;
  style.textContent = `html:not(.expanded-${key}) .${key} { display: none !important; }`;
  document.head.append(style);
}

function updateButtons(className) {
  const label = isOpen(className) ? "Show Less" : "Show More";
  toggleTargets.forEach((target, id) => {
    if (target !== className) return;
    const button = document.getElementById(id);
    if (button) button.textContent = label;
  });
}

// While a Show More is open, the box it is in and the boxes it opened (when
// they sit next to each other on the page) look like one box: each gets
// data-box-join="first", "middle" or "last", and the stylesheet squares the
// corners where they meet and removes the gaps. An attribute, not a class,
// because React redraws classes.
function sectionRow(element) {
  return element?.closest?.("[data-section-row]") || null;
}

function joinBoxes(className) {
  const key = stateKey(className);
  if (!key) return;
  const members = new Set();
  toggleTargets.forEach((target, id) => {
    if (target !== className) return;
    const row = sectionRow(document.getElementById(id));
    if (row) members.add(row);
  });
  document.querySelectorAll(`[data-section-row].${key}`).forEach((row) => members.add(row));
  members.forEach((row) => row.removeAttribute("data-box-join"));
  if (!isOpen(className) || members.size < 2) return;

  const shown = Array.from(document.querySelectorAll("[data-section-row]")).filter((row) => row.getClientRects().length > 0);
  let run = [];
  const finish = () => {
    if (run.length > 1) {
      run.forEach((row, index) => {
        const place = index === 0 ? "first" : index === run.length - 1 ? "last" : "middle";
        row.setAttribute("data-box-join", place);
      });
    }
    run = [];
  };
  shown.forEach((row) => {
    if (members.has(row)) run.push(row);
    else finish();
  });
  finish();
}

function listen() {
  if (listening) return;
  listening = true;
  document.addEventListener("click", (event) => {
    const button = event.target.closest?.("button[id]");
    const className = button && toggleTargets.get(button.id);
    if (!className) return;
    event.preventDefault();
    document.documentElement.classList.toggle(`expanded-${stateKey(className)}`);
    updateButtons(className);
    joinBoxes(className);
  });
}

const setupToggle = (elementId = "", className = "") => {
  useEffect(() => {
    if (!elementId || !className) return undefined;
    toggleTargets.set(elementId, className);
    ensureStyle(className);
    listen();
    updateButtons(className);
    joinBoxes(className);
    return () => toggleTargets.delete(elementId);
  }, [elementId, className]);
};

export default setupToggle;
