import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['menu', 'toggle'];

  toggle(event) {
    event.preventDefault();
    const expanded = this.menuTarget.classList.toggle('show');
    this.toggleTarget.setAttribute('aria-expanded', String(expanded));
    this.toggleTarget.classList.toggle('collapsed', !expanded);
  }
}
