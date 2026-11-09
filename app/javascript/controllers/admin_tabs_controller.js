import { Controller } from '@hotwired/stimulus';
import { Tab } from 'bootstrap';

// Tabs on one admin form. A field on a hidden tab cannot show the browser's
// "please fill in this field" message, so when one is invalid this opens its
// tab first. The open tab is kept in the address (?tab=) so a reload returns
// to it.
export default class extends Controller {
  connect() {
    this.showInvalid = this.showInvalid.bind(this);
    this.element.addEventListener('invalid', this.showInvalid, true);
    this.element.querySelectorAll('[data-bs-toggle="tab"]').forEach(trigger => {
      trigger.addEventListener('shown.bs.tab', () => this.remember(trigger));
    });
  }

  disconnect() {
    this.element.removeEventListener('invalid', this.showInvalid, true);
  }

  showInvalid(event) {
    const pane = event.target.closest('.tab-pane');
    if (!pane || pane.classList.contains('active')) return;
    const trigger = this.element.querySelector(`[data-bs-target="#${pane.id}"]`);
    if (trigger) Tab.getOrCreateInstance(trigger).show();
  }

  remember(trigger) {
    const name = trigger.dataset.tabName;
    if (!name) return;
    const url = new URL(window.location.href);
    url.searchParams.set('tab', name);
    window.history.replaceState(window.history.state, '', url);
  }
}
