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

      // Update record via Rails
      await fetch(`/admin/image_files/${imageFileId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        },
        body: JSON.stringify({
          image_file: {
            group: group,
            slide_order: maxSlideOrder + 1,
          },
        }),
      });

      // Reload page to reflect changes
      location.reload();
    }
  } catch (error) {
    console.log("An error occurred: " + error.message);
  }
}
