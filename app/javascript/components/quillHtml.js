// /app/javascript/components/quillHtml.js

// Quill 2's clean ("semantic") HTML turns every space into &nbsp;. Pages store
// ordinary spaces (as Quill 1 did), so convert them back before the HTML leaves
// the editor. Only use this on HTML being sent or saved: feeding it back into
// the editor's own value would make the editor reload its content on every key.
export function storableHtml(html) {
  return typeof html === "string" ? html.replace(/&nbsp;/g, " ") : html;
}
