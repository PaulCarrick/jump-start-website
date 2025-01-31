import { Controller } from "@hotwired/stimulus";
import React from "react";
import { createRoot } from "react-dom/client";
import NavMenu from "../components/NavMenu";

export default class extends Controller {
  static values = { apiEndpoint: String };

  async connect() {
    const rootElement = document.createElement("div");
    this.element.appendChild(rootElement);

    const root = createRoot(rootElement);

    try {
      const response = await fetch(this.apiEndpointValue);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      root.render(<NavMenu menuItems={data} />);
    } catch (error) {
      console.error("Error fetching menu items:", error);
    }
  }

  disconnect() {
    this.element.innerHTML = "";
  }
}
