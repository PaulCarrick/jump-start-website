import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
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

  slug(value) {
    return value.normalize('NFKD').replace(/[\u0300-\u036f]/g, '')
      .toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  }

  nameChanged(event) {
    const value = event.target.value;
    if (this.lastNames.get(event.target.name) === value) return;
    this.lastNames.set(event.target.name, value);
    const name = this.slug(value);
    const normalized = name.split('-').filter(Boolean).map(word => word[0].toUpperCase() + word.slice(1)).join(' ');
    if (event.target.name === 'site_setup[configuration_name]') {
      const siteName = this.element.querySelector('[name="site_setup[site_name]"]');
      if (siteName) siteName.value = normalized;
      this.lastNames.set('site_setup[site_name]', normalized);
    }
    const database = this.element.querySelector('[name="site_setup[database]"]');
    const owner = this.element.querySelector('[name="site_setup[owner_name]"]');
    const url = this.element.querySelector('[name="site_setup[site_url]"]');
    if (database && !database.readOnly) database.value = name;
    if (owner) owner.value = normalized;
    if (url) {
      url.value = this.originalUrl;
      if (name && this.originalUrl) {
        try {
          const result = new URL(this.originalUrl, window.location.origin);
          let path = result.pathname.replace(/\/+$/, '');
          // Renaming a saved setup replaces its old name segment. Always use
          // the original URL so typing repeatedly never accumulates segments.
          const previousName = this.originalNames.find(previous => path.endsWith(`/${previous}`));
          if (previousName) path = path.slice(0, -(previousName.length + 1));
          result.pathname = `${path}/${name}`;
          url.value = result.href;
        } catch (_) {
          url.value = `${this.originalUrl.replace(/\/+$/, '')}/${name}`;
        }
      }
    }
    const preview = this.element.querySelector('[data-site-admin-preview]');
    if (preview) preview.textContent = name ? `New administrator: ${owner?.value || name} (${name}@example.com). Existing accounts are not renamed.` : '';
  }
}
