/* TO DO:
I have no idea why the link_to is not working.
Everything looks good but something is happening under the covers.
When this is figured out this code should be removed.
*/

// Follows a header link in this tab. A click can land on a picture inside the
// link (the search, admin and login icons), so the link is the closest <a>.
// Links that open a new tab (the admin), dropdown toggles and clicks with a
// modifier key are left to the browser.
function followHeaderLink(event) {
  const link = event.target.closest('a');
  if (!link || !link.getAttribute('href') || link.getAttribute('href') === '#') return;
  if (link.target === '_blank' || link.dataset.bsToggle) return;
  if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
  window.location.href = link.href;
}

document.querySelectorAll('.dropdown-item, .nav-link').forEach(item => {
  item.addEventListener('click', followHeaderLink);
});
