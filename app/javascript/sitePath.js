export function siteMount() {
  return document.querySelector('meta[name="site-mount"]')?.content || '';
}

export function sitePath(url) {
  if (typeof url !== 'string') return url;
  const mount = siteMount();
  if (!mount || !url.startsWith('/') || url.startsWith('//') || /^\/(assets|images|packs)\//.test(url)) return url;
  if (url === mount || url.startsWith(`${mount}/`) || url.startsWith(`${mount}?`)) return url;
  return mount + url;
}

export function sitePathname() {
  const mount = siteMount();
  return (mount && window.location.pathname.startsWith(mount) ? window.location.pathname.slice(mount.length) : window.location.pathname) || '/';
}

export function siteFetch(url, options) {
  return fetch(sitePath(url), options);
}

export function siteHtml(html) {
  if (!siteMount() || !html) return html;
  const template = document.createElement('template');
  template.innerHTML = html;
  template.content.querySelectorAll('[href], [src], [action]').forEach(element => {
    ['href', 'src', 'action'].forEach(attribute => {
      const value = element.getAttribute(attribute);
      if (value) element.setAttribute(attribute, sitePath(value));
    });
  });
  return template.innerHTML;
}
