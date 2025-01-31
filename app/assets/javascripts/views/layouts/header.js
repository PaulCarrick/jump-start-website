/* TO DO:
I have no idea why the link_to is not working.
Everything looks good but something is happening under the covers.
When this is figured out this code should be removed.
*/

document.querySelectorAll('.dropdown-item').forEach(item => {
  item.addEventListener('click', (event) => {
    window.location.href = event.target.href;
  });
});
document.querySelectorAll('.nav-link').forEach(item => {
  item.addEventListener('click', (event) => {
    window.location.href = event.target.href;
  });
});
