import { Controller } from '@hotwired/stimulus';

// The media library's upload area: files dropped on it, or chosen with the
// file picker, go into its file field; Upload sends them in one request.
export default class extends Controller {
  static targets = ['input', 'chosen', 'submit'];

  over(event) {
    if (!event.dataTransfer?.types?.includes('Files')) return;
    event.preventDefault();
    this.element.classList.add('is-over');
  }

  leave(event) {
    if (!this.element.contains(event.relatedTarget)) this.element.classList.remove('is-over');
  }

  drop(event) {
    if (!event.dataTransfer?.files?.length) return;
    event.preventDefault();
    this.element.classList.remove('is-over');
    this.inputTarget.files = event.dataTransfer.files;
    this.chosen();
  }

  chosen() {
    const names = Array.from(this.inputTarget.files, file => file.name);
    this.chosenTarget.textContent = names.length
      ? `${names.length === 1 ? '1 file' : `${names.length} files`} ready: ${names.join(', ')}`
      : '';
    this.submitTarget.disabled = names.length === 0;
  }
}
