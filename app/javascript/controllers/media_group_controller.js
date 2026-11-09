import { Controller } from '@hotwired/stimulus';

// Moving a file into another group puts it at the end of that group's slide
// show, as the old "Add Group" button did.
export default class extends Controller {
  static targets = ['group', 'order'];

  changed() {
    const group = this.groupTarget.value.trim();
    if (this.originalOrder === undefined) this.originalOrder = this.orderTarget.defaultValue;
    if (group === this.groupTarget.dataset.original) {
      this.orderTarget.value = this.originalOrder;
      return;
    }
    const nextOrders = JSON.parse(this.groupTarget.dataset.nextOrders || '{}');
    this.orderTarget.value = group ? (nextOrders[group] || 1) : '';
  }
}
