function setRequiredByOtherField(firstFieldName, secondFieldName) {
  const firstField = document.getElementById(firstFieldName);
  const secondField = document.getElementById(secondFieldName);

  if (secondField.value.trim() !== "") {
    firstField.removeAttribute("required");
  } else {
    firstField.setAttribute("required", "required");
  }
}

function validate(form) {
  setRequiredByOtherField("menu_item_label", "menu_item_icon")
}
