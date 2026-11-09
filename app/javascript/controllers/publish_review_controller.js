import { Controller } from '@hotwired/stimulus';

// The review page: keeps the count of ticked changes in view and asks for
// confirmation before publishing or discarding them.
export default class extends Controller {
  static targets = ['group', 'status', 'publish', 'discard'];

  connect() {
    this.update();
  }

  all() {
    this.groupTargets.forEach(box => { box.checked = true; });
    this.update();
  }

  none() {
    this.groupTargets.forEach(box => { box.checked = false; });
    this.update();
  }

  chosen() {
    const boxes = this.groupTargets.filter(box => box.checked);
    const changes = boxes.reduce((sum, box) => sum + Number(box.dataset.count || 0), 0);
    return { boxes, changes };
  }

  describe({ boxes, changes }) {
    const changeWords = `${changes} ${changes === 1 ? 'change' : 'changes'}`;
    const groupWords = `${boxes.length} ${boxes.length === 1 ? 'group' : 'groups'}`;
    return `${changeWords} in ${groupWords}`;
  }

  update() {
    const selection = this.chosen();
    const none = selection.boxes.length === 0;
    this.statusTarget.textContent = none ? 'Nothing ticked.' : `Ticked: ${this.describe(selection)}.`;
    this.publishTarget.disabled = none;
    this.discardTarget.disabled = none;
    this.publishTarget.textContent = none ? 'Publish selected' : `Publish ${selection.changes === 1 ? '1 change' : `${selection.changes} changes`}`;
  }

  confirm(event) {
    const selection = this.chosen();
    const titles = selection.boxes.map(box => `• ${box.dataset.title}`).join('\n');
    const discarding = event.submitter === this.discardTarget;
    const question = discarding
      ? `Discard ${this.describe(selection)}? The drafts are deleted; the live site does not change.\n\n${titles}`
      : `Publish ${this.describe(selection)}? Visitors will see them straight away.\n\n${titles}`;
    if (!window.confirm(question)) event.preventDefault();
  }
}
