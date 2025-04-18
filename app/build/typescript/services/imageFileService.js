// /app/javascript/services/imageFileService.tsx
import { sendRequest } from "./utilities";
export function getImageFilesForGroup(group, setError = null) {
    const url = `/api/v1/imageFiles?q[group_cont]=${encodeURIComponent(group)}`;
    return sendRequest(url, setError);
}
export function getImageFileByName(name, setError = null) {
    const url = `/api/v1/image_files/${encodeURIComponent(name)}`;
    return sendRequest(url, setError);
}
export function getImageFiles(query, limit, setError = null) {
    const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
    const url = `/api/v1/image_files${queryString}`;
    return sendRequest(url, setError);
}
export function newImageFile(params = {}) {
    return {
        name: params.name || "new-imageFile",
        caption: params.caption || null,
        description: params.description || null,
        mime_type: params.mime_type || null,
        group: params.group || null,
        slide_order: params.slide_order || null
    };
}
export function show(id, setError = null) {
    return sendRequest(`/api/v1/image_files/${id}`, setError);
}
function formDataToJson(formData) {
    const jsonObject = {};
    formData.forEach((value, key) => {
        if (value instanceof File) {
            jsonObject[key] = { filename: value.name, type: value.type, size: value.size };
        }
        else {
            jsonObject[key] = value;
        }
    });
    return jsonObject;
}
export function createImageFile(imageFile, file, setError = null) {
    const formData = new FormData();
    if (imageFile.name)
        formData.append("name", imageFile.name);
    if (imageFile.caption)
        formData.append("caption", imageFile.caption);
    if (imageFile.description)
        formData.append("description", imageFile.description);
    if (imageFile.mime_type)
        formData.append("mime_type", imageFile.mime_type);
    formData.append("image", file);
    const image_file = formDataToJson(formData);
    return sendRequest("/api/v1/image_files/", setError, "POST", { image_file });
}
export function updateImageFile(imageFile, setError = null) {
    if (!imageFile.id) {
        console.error("Error: ImageFile ID is required for updating.");
        return null;
    }
    return sendRequest(`/api/v1/image_files/${imageFile.id}`, setError, "PATCH", { imageFile });
}
export function deleteImageFile(id, setError = null) {
    return sendRequest(`/api/v1/image_files/${id}`, setError, "DELETE");
}
export function genericImageFile(name, caption, description, mimeType, group, slideOrder) {
    return {
        name: name,
        caption: caption,
        description: description,
        mime_type: mimeType,
        group: group,
        slide_order: slideOrder
    };
}
