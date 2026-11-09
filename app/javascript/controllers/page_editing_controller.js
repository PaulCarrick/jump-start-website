import { Controller } from '@hotwired/stimulus';

// Editing a page from the public site. Right-clicking shows a small menu with
// "Edit": a picture opens the media library on it, a column opens it in the
// page workspace, the space around a section opens that section, and anywhere
// else (such as beside the buttons) opens the page. Editors open in a new
// tab; coming back to this tab reloads it to show the drafts.
// Shift + right-click gives the browser's own menu.
export default class extends Controller {
  static values = { workspace: String, image: String, sections: String };

  connect() {
    this.addSectionHandles();
    this.close = this.close.bind(this);
    this.returned = this.returned.bind(this);
    this.escape = event => { if (event.key === 'Escape') this.close(); };
    document.addEventListener('click', this.close);
    document.addEventListener('scroll', this.close, true);
    document.addEventListener('keydown', this.escape);
    document.addEventListener('visibilitychange', this.returned);
  }

  disconnect() {
    document.removeEventListener('click', this.close);
    document.removeEventListener('scroll', this.close, true);
    document.removeEventListener('keydown', this.escape);
    document.removeEventListener('visibilitychange', this.returned);
    this.close();
  }

  target(element, y) {
    const image = element.closest('img');
    if (image && element.closest('#contents')) {
      return { label: 'Edit image', url: `${this.imageValue}?src=${encodeURIComponent(image.currentSrc || image.src)}`, outline: image };
    }
    const section = element.closest('[data-section-id]');
    const sectionChoice = section && { label: 'Edit section', url: `${this.workspaceValue}?section=${section.dataset.sectionId}`, outline: section };
    const cell = element.closest('[data-cell-id]');
    if (cell) {
      // Columns stretch to the height of their row, so the white space above
      // and below a row's content lies inside them: that space is the section.
      if (section && this.outsideContent(section, y)) return sectionChoice;
      return { label: 'Edit column', url: `${this.workspaceValue}?cell=${cell.dataset.cellId}`, outline: cell };
    }
    if (sectionChoice) return sectionChoice;
    return { label: 'Edit page', url: this.workspaceValue, outline: null };
  }

  // Whether a point is above the first or below the last content of a row.
  outsideContent(section, y) {
    const boxes = Array.from(section.querySelectorAll('[data-cell-id] *'))
      .filter(node => !node.children.length || /^(IMG|VIDEO|IFRAME|TABLE|UL|OL|P|H[1-6]|BLOCKQUOTE|PRE|FIGURE)$/.test(node.tagName))
      .map(node => node.getBoundingClientRect())
      .filter(box => box.height > 0 && box.width > 0);
    if (!boxes.length) return false;
    const top = Math.min(...boxes.map(box => box.top));
    const bottom = Math.max(...boxes.map(box => box.bottom));
    return y < top || y > bottom;
  }

  open(event) {
    if (event.shiftKey) return;
    // Links and form fields inside the page keep their own menu only with Shift.
    event.preventDefault();
    this.close();
    const choice = this.target(event.target, event.clientY);
    const menu = document.createElement('div');
    menu.className = 'page-edit-menu';
    menu.setAttribute('role', 'menu');
    const item = document.createElement('button');
    item.type = 'button';
    item.className = 'page-edit-menu-item';
    item.setAttribute('role', 'menuitem');
    item.textContent = choice.label;
    item.addEventListener('click', clickEvent => {
      clickEvent.stopPropagation();
      this.opened = true;
      window.open(choice.url, '_blank', 'noopener');
      this.close();
    });
    const hint = document.createElement('div');
    hint.className = 'page-edit-menu-hint';
    hint.textContent = 'Shift + right-click: browser menu';
    menu.append(item, hint);
    document.body.append(menu);
    const width = menu.offsetWidth;
    const height = menu.offsetHeight;
    menu.style.left = `${Math.min(event.clientX, window.innerWidth - width - 8)}px`;
    menu.style.top = `${Math.min(event.clientY, window.innerHeight - height - 8)}px`;
    this.menu = menu;
    if (choice.outline) {
      this.outlined = choice.outline;
      this.outlined.classList.add('page-edit-target');
    }
    item.focus();
  }

  close() {
    this.menu?.remove();
    this.menu = null;
    this.outlined?.classList.remove('page-edit-target');
    this.outlined = null;
  }

  // Moving sections ----------------------------------------------------------
  // Each section gets a handle (shown when pointed at): drag it to move the
  // section up or down, or use its arrows. The new order is saved as drafts
  // and the page reloads to show it.

  // A section can be drawn as more than one block; they move together.
  blocks(id) {
    return Array.from(this.element.querySelectorAll(`[data-section-id="${id}"]`));
  }

  sectionIds() {
    const ids = Array.from(this.element.querySelectorAll('[data-section-id]'), block => block.dataset.sectionId);
    return ids.filter((id, index) => ids.indexOf(id) === index);
  }

  // The sections that move as one (marked by the server): a section with a
  // "Show More" button and the sections it opens, or one section group.
  // Moving one used to split a project from its hidden part, so its Show More
  // ended up far from the heading it belonged to.
  unit(id) {
    const unit = this.blocks(id)[0]?.dataset.sectionUnit;
    if (!unit) return [ id ];
    return this.sectionIds().filter(sectionId => this.blocks(sectionId)[0].dataset.sectionUnit === unit);
  }

  unitBlocks(id) {
    return this.unit(id).flatMap(sectionId => this.blocks(sectionId));
  }

  // The units in page order, each named by its first section.
  units() {
    const seen = new Set();
    return this.sectionIds().filter(id => {
      if (seen.has(id)) return false;
      this.unit(id).forEach(member => seen.add(member));
      return true;
    });
  }

  addSectionHandles() {
    if (!this.sectionsValue) return;
    const seen = new Set();
    this.element.querySelectorAll('[data-section-id]').forEach(block => {
      const id = block.dataset.sectionId;
      if (seen.has(id)) return;
      seen.add(id);
      const together = this.unit(id).length > 1 ? ' with its Show More group' : '';
      const handle = document.createElement('div');
      handle.className = 'page-edit-section-handle';
      handle.innerHTML = `
        <span class="page-edit-drag" draggable="true" title="Drag to move this section${together}" aria-hidden="true">⠿ Move</span>
        <button type="button" data-move="up" title="Move this section up${together}" aria-label="Move this section up${together}">↑</button>
        <button type="button" data-move="down" title="Move this section down${together}" aria-label="Move this section down${together}">↓</button>`;
      handle.querySelector('[data-move="up"]').addEventListener('click', event => { event.stopPropagation(); this.step(id, -1); });
      handle.querySelector('[data-move="down"]').addEventListener('click', event => { event.stopPropagation(); this.step(id, 1); });
      const grip = handle.querySelector('.page-edit-drag');
      grip.addEventListener('dragstart', event => this.dragStart(event, id));
      grip.addEventListener('dragend', () => this.dragEnd());
      block.prepend(handle);
    });
    this.element.addEventListener('dragover', event => this.dragOver(event));
    this.element.addEventListener('drop', event => this.drop(event));
  }

  step(id, direction) {
    const units = this.units();
    const own = this.unit(id)[0];
    const other = units[units.indexOf(own) + direction];
    if (!other) return this.flash(direction < 0 ? 'This section is already first.' : 'This section is already last.');
    this.place(id, other, direction > 0);
    this.saveOrder();
  }

  // Puts the moving group's blocks before or after another group's.
  place(id, targetId, after) {
    const moving = this.unitBlocks(id);
    const target = this.unitBlocks(targetId);
    if (after) target[target.length - 1].after(...moving);
    else target[0].before(...moving);
  }

  dragStart(event, id) {
    this.draggedSection = id;
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/plain', id);
    this.unitBlocks(id).forEach(block => block.classList.add('page-edit-dragging'));
  }

  dropPlace(event) {
    if (!this.draggedSection) return null;
    const block = event.target.closest?.('[data-section-id]');
    if (!block || this.unit(this.draggedSection).includes(block.dataset.sectionId)) return null;
    const blocks = this.unitBlocks(block.dataset.sectionId);
    const top = blocks[0].getBoundingClientRect().top;
    const bottom = blocks[blocks.length - 1].getBoundingClientRect().bottom;
    return { id: block.dataset.sectionId, after: event.clientY > (top + bottom) / 2, blocks };
  }

  dragOver(event) {
    const place = this.dropPlace(event);
    if (!place) return;
    event.preventDefault();
    this.clearMarkers();
    if (place.after) place.blocks[place.blocks.length - 1].classList.add('page-edit-drop-after');
    else place.blocks[0].classList.add('page-edit-drop-before');
  }

  drop(event) {
    const place = this.dropPlace(event);
    if (!place) return;
    event.preventDefault();
    const id = this.draggedSection;
    this.dragEnd();
    this.place(id, place.id, place.after);
    this.saveOrder();
  }

  dragEnd() {
    this.element.querySelectorAll('.page-edit-dragging').forEach(block => block.classList.remove('page-edit-dragging'));
    this.clearMarkers();
    this.draggedSection = null;
  }

  clearMarkers() {
    this.element.querySelectorAll('.page-edit-drop-before, .page-edit-drop-after')
      .forEach(block => block.classList.remove('page-edit-drop-before', 'page-edit-drop-after'));
  }

  flash(message) {
    let note = document.querySelector('.page-edit-moving');
    if (!note) {
      note = document.createElement('div');
      note.className = 'page-edit-moving';
      note.setAttribute('role', 'status');
      document.body.append(note);
    }
    note.textContent = message;
    clearTimeout(this.flashTimer);
    this.flashTimer = setTimeout(() => note.remove(), 2500);
  }

  async saveOrder() {
    this.flash('Saving the new order…');
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content;
      const response = await fetch(this.sectionsValue, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json', 'X-CSRF-Token': token },
        body: JSON.stringify({ sections: this.sectionIds() })
      });
      const result = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(result.error || 'The new order could not be saved.');
      this.flash('Saved as a draft.');
    } catch (error) {
      this.flash(`${error.message} Reloading…`);
    }
    setTimeout(() => window.location.reload(), 500);
  }

  // Back from an editor tab: show what was saved there.
  returned() {
    if (document.visibilityState === 'visible' && this.opened) window.location.reload();
  }
}
