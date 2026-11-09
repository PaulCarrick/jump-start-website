import { Controller } from '@hotwired/stimulus';

// The page workspace's preview. Clicking a section (or pressing Enter or
// Space on it) selects it for editing; links inside the preview do not
// navigate away.
export default class extends Controller {
  select(event) {
    const block = event.currentTarget;
    event.preventDefault();
    if (block.classList.contains('is-selected')) return;
    window.location.href = block.dataset.selectUrl;
  }

  key(event) {
    if (event.target !== event.currentTarget) return;
    if (event.key !== 'Enter' && event.key !== ' ') return;
    this.select(event);
  }
}
