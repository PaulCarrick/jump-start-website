// app/assets/javascript/views/pages/show.js

// Setup for editing pages

setupScroll();

function requestSectionDuplicateName(form) {
  const name = window.prompt("Name for the duplicated section:");
  if (name === null) return false;
  if (!name.trim()) {
    window.alert("Please enter a section name.");
    return false;
  }
  form.elements["section_name"].value = name.trim();
  return true;
}
