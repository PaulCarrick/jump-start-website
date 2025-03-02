// /app/javascript/components
import React, {useEffect} from "react";

// Helper to set up toggle functionality
const setupToggle = (elementId = "", className = "") => {
  useEffect(() => {
    const setupLogic = () => {
      const toggleButton = document.getElementById(elementId);
      const elements = document.querySelectorAll(className);

      if (toggleButton && elements.length > 0) {
        elements.forEach((element) => {
          element.classList.add("collapse");
        });

        toggleButton.textContent = "Show More";

        elements.forEach((element) => {
          element.addEventListener("show.bs.collapse", () => {
            toggleButton.textContent = "Show Less";
          });

          element.addEventListener("hide.bs.collapse", () => {
            toggleButton.textContent = "Show More";
          });
        });

        toggleButton.addEventListener("click", () => {
          elements.forEach((element) => {
            element.classList.toggle("show");
            const isShown = element.classList.contains("show");
            toggleButton.textContent = isShown ? "Show Less" : "Show More";
          });
        });
      }
    };

    const handleLoad = () => {
      setTimeout(setupLogic, 0);
    };

    if (document.readyState === "complete") {
      handleLoad();
    } else {
      window.addEventListener("load", handleLoad);
    }

    return () => {
      window.removeEventListener("load", handleLoad);
    };
  }, [elementId, className]);
};

export default setupToggle;
