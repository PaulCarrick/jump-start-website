// app/assets/javascript/views/pages/show.js

// Setup for editing pages

setupScroll();

function requestSectionDuplicateName(form) {
  const grouped = Boolean(form.dataset.sectionGroup);
  const name = window.prompt(grouped ? "Name for the duplicated section group:" : "Name for the duplicated section:");
  if (name === null) return false;
  if (!name.trim()) {
    window.alert(grouped ? "Please enter a section group name." : "Please enter a section name.");
    return false;
  }
  form.elements["section_name"].value = name.trim();
  return true;
}
