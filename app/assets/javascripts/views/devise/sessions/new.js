// /app/assets/javascripts/views/devise/sessions/new.js

function togglePasswordVisibility() {
  const passwordField = document.getElementById("password-field");
  const toggleIcon = document.getElementById("toggle-password-icon");

  if (passwordField.type === "password") {
    passwordField.type = "text";
    toggleIcon.classList.remove("fa-eye");
    toggleIcon.classList.add("fa-eye-slash");
  } else {
    passwordField.type = "password";
    toggleIcon.classList.remove("fa-eye-slash");
    toggleIcon.classList.add("fa-eye");
  }
}
