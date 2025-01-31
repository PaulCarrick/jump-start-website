// app/assets/javascripts/views/contacts/new.js
function submitForm(formId, token) {
  document.getElementById(formId).submit();
}

function recaptchaError(formId) {
  document.getElementById(formId).submit();
}
