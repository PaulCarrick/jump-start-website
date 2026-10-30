// Captions are plain text at display time; keep stored rich text unchanged.
export function captionText(caption) {
  const template = document.createElement('template');
  template.innerHTML = caption || '';
  template.content.querySelectorAll('script, style').forEach(node => node.remove());
  template.content.querySelectorAll('br').forEach(node => node.replaceWith(' '));
  template.content.querySelectorAll('p, div, li, h1, h2, h3, h4, h5, h6').forEach(node => node.append(' '));
  return (template.content.textContent || '').replace(/\s+/g, ' ').trim();
}
