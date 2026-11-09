import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['menu', 'toggle'];

  // With the menu as a bar along the bottom, the page keeps room for it at its
  // foot, however tall the bar is (one line, or two when it wraps).
  connect() {
    if (!document.body.classList.contains('site-menu-bottom') || !window.ResizeObserver) return;
    const header = this.element.closest('header') || this.element;
    this.observer = new ResizeObserver(() => {
      document.body.style.setProperty('--site-menu-height', `${header.offsetHeight}px`);
    });
    this.observer.observe(header);
  }

  disconnect() {
    this.observer?.disconnect();
  }

  toggle(event) {
    event.preventDefault();
    const expanded = this.menuTarget.classList.toggle('show');
    this.toggleTarget.setAttribute('aria-expanded', String(expanded));
    this.toggleTarget.classList.toggle('collapsed', !expanded);
  }
}
