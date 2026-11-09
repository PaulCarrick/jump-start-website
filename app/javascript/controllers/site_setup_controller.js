import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { persisted: Boolean };

  connect() {
    // Keep a browser-only snapshot. Do not persist or expose another copy of
    // settings in hidden fields, storage, or URLs.
    this.originalFields = new Map(Array.from(this.element.elements)
      .filter(field => field.name)
      .map(field => [field.name, field.type === 'checkbox' ? field.checked : field.value]));
    this.lastNames = new Map(['site_setup[site_name]', 'site_setup[configuration_name]'].map(field => [field, this.originalFields.get(field) || '']));
    this.originalUrl = this.originalFields.get('site_setup[site_url]') || '';
    this.originalNames = ['site_setup[site_name]', 'site_setup[configuration_name]'].map(field => this.slug(this.originalFields.get(field) || '')).filter(Boolean);
  }

  // Keeps the swatch beside each color list and the small preview in step.
  colorChanged(event) {
    const field = event.target.dataset.colorField;
    const color = event.target.value;
    const swatch = this.element.querySelector(`[data-color-swatch="${field}"]`);
    if (swatch) swatch.style.background = color;
    const [area, part] = field.startsWith('header') ? ['header', field.slice(7)]
      : field.startsWith('footer') ? ['footer', field.slice(7)]
      : ['container', field.slice(10)];
    const preview = this.element.querySelector(`[data-preview="${area}"]`);
    if (!preview) return;
    if (part === 'background') preview.style.background = color;
    else preview.style.color = color;
  }

  slug(value) {
    return value.normalize('NFKD').replace(/[\u0300-\u036f]/g, '')
      .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  }

  normalize(name) {
    return name.split('-').filter(Boolean).map(word => word[0].toUpperCase() + word.slice(1)).join(' ');
  }

  // Suggests the other names from a new configuration or site name. For a new
  // setup every suggestion is filled in. A saved setup is a running site, so
  // a field changes only while it still holds what was derived from the old
  // name; the address changes only by replacing its old name segment, and a
  // managed database is never renamed.
  nameChanged(event) {
    const value = event.target.value;
    const previous = this.lastNames.get(event.target.name) || '';
    if (previous === value) return;
    this.lastNames.set(event.target.name, value);
    const saved = this.persistedValue;
    const name = this.slug(value);
    const normalized = this.normalize(name);
    const oldName = this.slug(previous);
    const derived = (field, fromOld) => !saved || field.value === fromOld;
    if (event.target.name === 'site_setup[configuration_name]') {
      const siteName = this.element.querySelector('[name="site_setup[site_name]"]');
      if (siteName && derived(siteName, this.normalize(oldName))) {
        siteName.value = normalized;
        this.lastNames.set('site_setup[site_name]', normalized);
      }
    }
    const database = this.element.querySelector('[name="site_setup[database]"]');
    const owner = this.element.querySelector('[name="site_setup[owner_name]"]');
    const url = this.element.querySelector('[name="site_setup[site_url]"]');
    if (database && !database.readOnly && derived(database, oldName)) database.value = name;
    if (owner && derived(owner, this.normalize(oldName))) owner.value = normalized;
    if (url) {
      url.value = this.suggestedUrl(name, saved) ?? url.value;
    }
    const preview = this.element.querySelector('[data-site-admin-preview]');
    if (preview && !saved) preview.textContent = name ? `New administrator: ${owner?.value || name} (${name}@example.com). Existing accounts are not renamed.` : '';
  }

  // The site address for a name: the original address with its last segment
  // replaced (or, for a new setup, added). Null leaves the address as it is.
  suggestedUrl(name, saved) {
    if (!this.originalUrl) return null;
    if (!name) return this.originalUrl;
    try {
      const result = new URL(this.originalUrl, window.location.origin);
      let path = result.pathname.replace(/\/+$/, '');
      // Use the original address so typing repeatedly never adds segments.
      const previousName = this.originalNames.find(previous => path.endsWith(`/${previous}`));
      if (previousName) path = path.slice(0, -(previousName.length + 1));
      else if (saved) return this.originalUrl;
      result.pathname = `${path}/${name}`;
      return result.href;
    } catch (_) {
      return saved ? this.originalUrl : `${this.originalUrl.replace(/\/+$/, '')}/${name}`;
    }
  }

}
