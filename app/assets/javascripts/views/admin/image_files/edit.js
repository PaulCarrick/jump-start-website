// /app/javascript/views/admin/image_files/edit.js

// Fetch groups from the API
async function fetchGroups() {
  const groupSelectContainer = document.getElementById("group-select-container");

  try {
    const response = await fetch("/api/v1/image_files/groups");

    if (!response.ok) {
      throw new Error("Failed to fetch groups");
    }
    const data = await response.json();
    populateGroupSelect(data);

    groupSelectContainer.style.display = 'block';
  }
  catch (error) {
    console.error("Error fetching groups:", error);
  }
}

// Populate the select dropdown with group options
function populateGroupSelect(groups) {
  const groupSelect = document.getElementById("group-select");

  groupSelect.innerHTML = ""; // Clear existing options

  const blankOption                 = document.createElement("option");
  blankOption.value                 = "";
  blankOption.dataset.maxSlideOrder = null;
  blankOption.textContent           = "";
  groupSelect.appendChild(blankOption);

  for (const [group, maxSlideOrder] of Object.entries(groups)) {
    const option                 = document.createElement("option");
    option.value                 = group;
    option.dataset.maxSlideOrder = maxSlideOrder; // Store max slide order as a data attribute
    option.textContent           = `${group} (Max Slide Order: ${maxSlideOrder})`;
    groupSelect.appendChild(option);
  }
}

function groupChanged() {
  const groupSelect     = document.getElementById("group-select");
  const selectedOption  = groupSelect.options[groupSelect.selectedIndex];
  const selectedGroup   = selectedOption.value;
  const maxSlideOrder   = parseInt(selectedOption.dataset.maxSlideOrder, 10);
  const groupField      = document.getElementById("group-field");
  const slideOrderField = document.getElementById("slide-order-field");

  // Set the group field and slide order field
  groupField.value      = selectedGroup;
  slideOrderField.value = maxSlideOrder + 1;
}

function validate(form) {
  const descriptionField = document.getElementById("image_file_description");
  const captionField     = document.getElementById("image_file_caption");
  let isValid            = false;

  if (!descriptionField || !captionField) return isValid;

  isValid = checkHtml(descriptionField);

  if (isValid) isValid = checkHtml(captionField);

  return isValid;
}
