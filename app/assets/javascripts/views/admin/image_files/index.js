// /app/javascript/views/admin/image_files/index.js

async function addToGroup(imageFileId) {
  try {
    // Fetch groups from the API
    const response = await fetch( "/api/v1/image_files/groups");
    if (!response.ok) throw new Error("Failed to fetch groups");
    const groups = await response.json();

    // Show popup and populate select
    const group = prompt(
      `Select a group:\n${Object.entries(groups)
        .map(([group, max]) => `${group} (max: ${max})`)
        .join("\n")}`
    );
    if (group && groups[group] !== undefined) {
      const maxSlideOrder = groups[group];

      // Rails omits CSRF meta tags when forgery protection is disabled (test).
      const headers = { "Content-Type": "application/json" };
      const csrfToken = document.querySelector("[name='csrf-token']")?.content;
      if (csrfToken) headers["X-CSRF-Token"] = csrfToken;

      // Update record via Rails
      const updateResponse = await fetch(`/admin/image_files/${imageFileId}`, {
        method: "PATCH",
        headers,
        body: JSON.stringify({
          image_file: {
            group: group,
            slide_order: maxSlideOrder + 1,
          },
        }),
      });

      if (!updateResponse.ok) throw new Error("Failed to update image group");

      // Reload page to reflect changes
      location.reload();
    }
  } catch (error) {
    console.error("An error occurred: " + error.message);
    alert("Could not update image group: " + error.message);
  }
}
