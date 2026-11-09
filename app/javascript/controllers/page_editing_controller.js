import { Controller } from '@hotwired/stimulus';

// Editing a page from the public site. Right-clicking shows a small menu with
// "Edit": a picture opens the media library on it, a column opens it in the
// page workspace, the space around a section opens that section, and anywhere
// else (such as beside the buttons) opens the page. Editors open in a new
// tab; coming back to this tab reloads it to show the drafts.
// Shift + right-click gives the browser's own menu.
export default class extends Controller {
  static values = { workspace: String, image: String };

  connect() {
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

  // Back from an editor tab: show what was saved there.
  returned() {
    if (document.visibilityState === 'visible' && this.opened) window.location.reload();
  }
}
