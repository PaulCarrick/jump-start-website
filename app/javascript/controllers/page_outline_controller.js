import { Controller } from '@hotwired/stimulus';

// The page workspace's outline. Sections, and the columns inside a section,
// move with the ↑ ↓ buttons or by dragging their handle. Each move sends the
// whole order to the server (saved as drafts) and reloads the page, so the
// preview shows the new order.
export default class extends Controller {
  static targets = ['sections', 'status'];
  static values = { url: String, enabled: Boolean };

  connect() {
    if (!this.enabledValue) return;
    this.dragged = null;
    this.element.addEventListener('dragstart', event => this.dragStart(event));
    this.element.addEventListener('dragover', event => this.dragOver(event));
    this.element.addEventListener('drop', event => this.drop(event));
    this.element.addEventListener('dragend', () => this.clear());
  }

  up(event) {
    const item = event.currentTarget.closest('li');
    const previous = item.previousElementSibling;
    if (!previous) return this.say('It is already first.');
    previous.before(item);
    this.save();
  }

  down(event) {
    const item = event.currentTarget.closest('li');
    const next = item.nextElementSibling;
    if (!next) return this.say('It is already last.');
    next.after(item);
    this.save();
  }

  dragStart(event) {
    const handle = event.target.closest?.('.outline-handle');
    if (!handle) return;
    this.dragged = handle.closest('li');
    this.dragged.classList.add('is-dragging');
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/plain', this.dragged.dataset.id);
  }

  // A section can be dropped beside another section; a column only beside a
  // column of the same section.
  target(event) {
    if (!this.dragged) return null;
    const item = event.target.closest?.('li');
    if (!item || item === this.dragged || item.parentElement !== this.dragged.parentElement) return null;
    const row = item.querySelector(':scope > .outline-row');
    const box = row.getBoundingClientRect();
    return { item, row, before: event.clientY < box.top + box.height / 2 };
  }

  dragOver(event) {
    const place = this.target(event);
    if (!place) return;
    event.preventDefault();
    this.element.querySelectorAll('.drop-before, .drop-after').forEach(row => row.classList.remove('drop-before', 'drop-after'));
    place.row.classList.add(place.before ? 'drop-before' : 'drop-after');
  }

  drop(event) {
    const place = this.target(event);
    if (!place) return;
    event.preventDefault();
    if (place.before) place.item.before(this.dragged);
    else place.item.after(this.dragged);
    this.clear();
    this.save();
  }

  clear() {
    this.dragged?.classList.remove('is-dragging');
    this.dragged = null;
    this.element.querySelectorAll('.drop-before, .drop-after').forEach(row => row.classList.remove('drop-before', 'drop-after'));
  }

  say(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message;
  }

  async save() {
    const sections = Array.from(this.sectionsTarget.children, section => ({
      id: section.dataset.id,
      cells: Array.from(section.querySelectorAll(':scope > .outline-cells > li'), cell => cell.dataset.id)
    }));
    this.say('Saving…');
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content;
      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json', 'X-CSRF-Token': token },
        body: JSON.stringify({ sections })
      });
      const result = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(result.error || 'The new order could not be saved.');
      this.say(result.changed ? 'Saved as a draft. Updating the preview…' : 'Nothing changed.');
    } catch (error) {
      this.say(`${error.message} Reloading…`);
    }
    setTimeout(() => window.location.reload(), 600);
  }
}
