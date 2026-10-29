// Obtain a fresh v3 token when submitting; tokens expire after two minutes.
if (!window.contactRecaptchaListenerInstalled) {
  window.contactRecaptchaListenerInstalled = true;
  document.addEventListener("submit", function (event) {
    const form = event.target;
    if (form.id !== "contact-form") return;
    if (form.dataset.recaptchaVerified === "true") {
      delete form.dataset.recaptchaVerified;
      return;
    }
    event.preventDefault();
    const button = event.submitter;
    const showError = () => {
      if (button) button.disabled = false;
      const area = document.getElementById("error-area");
      if (area) area.textContent = "Unable to verify reCAPTCHA. Please try again.";
    };
    if (!window.grecaptcha || !form.dataset.recaptchaSiteKey) {
      showError();
      return;
    }
    if (button) button.disabled = true;
    window.grecaptcha.ready(function () {
      window.grecaptcha.execute(form.dataset.recaptchaSiteKey, { action: "contact" }).then(function (token) {
        form.querySelector('[name="g-recaptcha-response-data[contact]"]').value = token;
        form.dataset.recaptchaVerified = "true";
        if (button) button.disabled = false;
        form.requestSubmit(button || undefined);
      }).catch(showError);
    });
  }, true);
}
