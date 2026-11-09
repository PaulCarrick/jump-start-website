import { Controller } from '@hotwired/stimulus';

// The Menus screen's tree. Items move by dragging their handle (above, below
// or onto another item to go inside it) or with the arrow buttons. After each
// move the whole order is sent to the server, which saves what changed as
// drafts. If saving fails, the page reloads to show what is stored.
export default class extends Controller {
  static targets = ['root', 'node', 'status'];
  static values = { url: String, kind: String, depth: Number, enabled: Boolean };

  connect() {
    if (!this.enabledValue) return;
    this.dragged = null;
    this.element.addEventListener('dragstart', event => this.dragStart(event));
    this.element.addEventListener('dragover', event => this.dragOver(event));
    this.element.addEventListener('dragleave', event => this.clearMarker(event));
    this.element.addEventListener('drop', event => this.drop(event));
    this.element.addEventListener('dragend', () => this.dragEnd());
  }

  // Dragging --------------------------------------------------------------

  dragStart(event) {
    const handle = event.target.closest?.('.admin-menu-handle');
    if (!handle) return;
    this.dragged = handle.closest('.admin-menu-node');
    this.dragged.classList.add('is-dragging');
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/plain', this.dragged.dataset.id);
    event.dataTransfer.setDragImage(this.dragged.querySelector('.admin-menu-row'), 12, 12);
  }

  dragOver(event) {
    if (!this.dragged) return;
    const row = event.target.closest?.('.admin-menu-row');
    if (!row) return;
    const node = row.closest('.admin-menu-node');
    const place = this.placeFor(event, row, node);
    if (!place) return;
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
    this.showMarker(row, place);
  }

  drop(event) {
    if (!this.dragged) return;
    const row = event.target.closest?.('.admin-menu-row');
    if (!row) return;
    const node = row.closest('.admin-menu-node');
    const place = this.placeFor(event, row, node);
    if (!place) return;
    event.preventDefault();
    if (place === 'inside') node.querySelector(':scope > .admin-menu-children').append(this.dragged);
    else if (place === 'before') node.before(this.dragged);
    else node.after(this.dragged);
    const moved = this.dragged;
    this.dragEnd();
    this.save(moved);
  }

  dragEnd() {
    this.dragged?.classList.remove('is-dragging');
    this.dragged = null;
    this.element.querySelectorAll('.drop-before, .drop-after, .drop-inside')
      .forEach(row => row.classList.remove('drop-before', 'drop-after', 'drop-inside'));
  }

  clearMarker(event) {
    const row = event.target.closest?.('.admin-menu-row');
    if (row && !row.contains(event.relatedTarget)) row.classList.remove('drop-before', 'drop-after', 'drop-inside');
  }

  // Where a drop over this row would put the dragged item, or null when that
  // place is not allowed (inside itself, or deeper than the site can show).
  placeFor(event, row, node) {
    if (node === this.dragged || this.dragged.contains(node)) return null;
    const box = row.getBoundingClientRect();
    const offset = (event.clientY - box.top) / box.height;
    const nodeDepth = this.depthOf(node);
    const draggedHeight = this.heightOf(this.dragged);
    if (offset > 0.3 && offset < 0.7 && nodeDepth + draggedHeight <= this.depthValue) return 'inside';
    if (nodeDepth - 1 + draggedHeight > this.depthValue) return null;
    return offset < 0.5 ? 'before' : 'after';
  }

  showMarker(row, place) {
    this.element.querySelectorAll('.drop-before, .drop-after, .drop-inside').forEach(other => {
      if (other !== row) other.classList.remove('drop-before', 'drop-after', 'drop-inside');
    });
    row.classList.remove('drop-before', 'drop-after', 'drop-inside');
    row.classList.add(`drop-${place}`);
  }

  // Buttons ---------------------------------------------------------------

  moveUp(event) {
    const node = this.nodeFor(event);
    const previous = node.previousElementSibling;
    if (!previous) return this.say('That item is already first.');
    previous.before(node);
    this.save(node, event.currentTarget);
  }

  moveDown(event) {
    const node = this.nodeFor(event);
    const next = node.nextElementSibling;
    if (!next) return this.say('That item is already last.');
    next.after(node);
    this.save(node, event.currentTarget);
  }

  outdent(event) {
    const node = this.nodeFor(event);
    const parent = node.parentElement.closest('.admin-menu-node');
    if (!parent) return this.say('That item is already at the top level.');
    parent.after(node);
    this.save(node, event.currentTarget);
  }

  indent(event) {
    const node = this.nodeFor(event);
    const previous = node.previousElementSibling;
    if (!previous) return this.say('There is no item above to put it inside.');
    if (this.depthOf(previous) + this.heightOf(node) > this.depthValue) {
      return this.say(`Menus can only be ${this.depthValue} levels deep.`);
    }
    previous.querySelector(':scope > .admin-menu-children').append(node);
    this.save(node, event.currentTarget);
  }

  // Helpers ---------------------------------------------------------------

  nodeFor(event) {
    return event.currentTarget.closest('.admin-menu-node');
  }

  // 1 for a top-level item, 2 for an item inside it ...
  depthOf(node) {
    let depth = 0;
    for (let current = node; current; current = current.parentElement.closest('.admin-menu-node')) depth += 1;
    return depth;
  }

  // 1 for an item with nothing inside, 2 when it holds items ...
  heightOf(node) {
    const children = node.querySelectorAll(':scope > .admin-menu-children > .admin-menu-node');
    return 1 + Math.max(0, ...Array.from(children, child => this.heightOf(child)));
  }

  serialize() {
    return this.nodeTargets.map(node => ({
      id: node.dataset.id,
      parent_id: node.parentElement.closest('.admin-menu-node')?.dataset.id || ''
    }));
  }

  say(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message;
  }

  async save(movedNode, focusButton) {
    // Stimulus lists targets in document order, which is the new order.
    const items = this.serialize();
    if (focusButton) focusButton.focus();
    movedNode?.classList.add('is-moved');
    setTimeout(() => movedNode?.classList.remove('is-moved'), 1200);
    this.say('Saving…');
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content;
      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json', 'X-CSRF-Token': token },
        body: JSON.stringify({ kind: this.kindValue, items })
      });
      const result = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(result.error || 'The new order could not be saved.');
      this.say(result.changed ? 'Saved as a draft. Publish to show it on the site.' : 'Nothing changed.');
      this.updatePublishCount(result.pending);
    } catch (error) {
      this.say(`${error.message} Reloading…`);
      setTimeout(() => window.location.reload(), 1800);
    }
  }

  updatePublishCount(count) {
    const button = document.querySelector('.admin-publish-button');
    if (!button || !Number.isInteger(count)) return;
    let badge = button.querySelector('.admin-publish-count');
    if (!badge && count > 0) {
      badge = document.createElement('span');
      badge.className = 'admin-publish-count';
      button.append(badge);
    }
    if (badge) badge.textContent = count;
    button.setAttribute('aria-label', `Publish: ${count} ${count === 1 ? 'change' : 'changes'} waiting`);
  }
}
