// /app/javascript/components/PersistSection.jsx

import React from "react";
import axios from "axios";

function createSection() {
  const data = {
    name: "New Section Name", // Replace with your fields
    content_type: "article",
    description: "<p>Sample description</p>",
    other_field: "value" // Add other required parameters here
  };

  axios.post("/admin/sections", data, {
    headers: {
      "Content-Type": "application/json", // Ensure JSON content type
      "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content, // Include CSRF token for security
    }
  })
       .then(response => {
         console.log("Section created successfully:", response.data);
       })
       .catch(error => {
         console.error("Error creating section:", error.response || error.message);
       });
}

export default function App() {
  return (
      <button onClick={createSection}>Create Section</button>
  );
}
