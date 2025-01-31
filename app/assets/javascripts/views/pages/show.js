window.addEventListener("load", () => {
  document.body.classList.add("loaded");

  const params = new URLSearchParams(window.location.search);
  const sectionName = params.get("section_name");

  if (sectionName) {
    setTimeout(() => {
      const sectionElement = document.getElementById(sectionName);

      if (sectionElement)
        sectionElement.scrollIntoView({behavior: "smooth", block: "start"});
    }, 750); // Delay in milliseconds
  }
});
