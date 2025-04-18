// /app/javascript/services/imageFileService.tsx

import { ImageFile, SetErrorCallback } from "../types/dataTypes";
import { sendRequest }                 from "./utilities";

export function getImageFilesForGroup(group: string, setError: SetErrorCallback | null = null): ImageFile[] | null {
  const url = `/api/v1/imageFiles?q[group_cont]=${encodeURIComponent(group)}`;

  return sendRequest(url, setError);
}

export function getImageFileByName(name: string, setError: SetErrorCallback | null = null): ImageFile | null {
  const url = `/api/v1/image_files/${encodeURIComponent(name)}`;

  return sendRequest(url, setError);
}

export function getImageFiles(query: string | null, limit: number, setError: SetErrorCallback | null = null): ImageFile[] | null {
  const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
  const url         = `/api/v1/image_files${queryString}`;

  return sendRequest(url, setError);
}

export function newImageFile(params: Partial<ImageFile> = {}): ImageFile {
  return {
    name:        params.name || "new-imageFile",
    caption:     params.caption || null,
    description: params.description || null,
    mime_type:   params.mime_type || null,
    group:       params.group || null,
    slide_order: params.slide_order || null
  };
}

export function show(id: number | string, setError: SetErrorCallback | null = null): ImageFile | null {
  return sendRequest(`/api/v1/image_files/${id}`, setError);
}

function formDataToJson(formData: FormData): Record<string, any> {
  const jsonObject: Record<string, any> = {};

  formData.forEach((value, key) => {
    if (value instanceof File) {
      jsonObject[key] = { filename: value.name, type: value.type, size: value.size };
    } else {
      jsonObject[key] = value;
    }
  });

  return jsonObject;
}

export function createImageFile(imageFile: Partial<ImageFile>, file: File, setError: SetErrorCallback | null = null){
  const formData = new FormData();

  if (imageFile.name) formData.append("name", imageFile.name);
  if (imageFile.caption) formData.append("caption", imageFile.caption);
  if (imageFile.description) formData.append("description", imageFile.description);
  if (imageFile.mime_type) formData.append("mime_type", imageFile.mime_type);

  formData.append("image", file);

  const image_file:Record<string, any> = formDataToJson(formData);

  return sendRequest("/api/v1/image_files/", setError, "POST", { image_file });
}

export function updateImageFile(imageFile: ImageFile, setError: SetErrorCallback | null = null): ImageFile | null {
  if (!imageFile.id) {
    console.error("Error: ImageFile ID is required for updating.");
    return null;
  }
  return sendRequest(`/api/v1/image_files/${imageFile.id}`, setError, "PATCH", { imageFile });
}

export function deleteImageFile(id: number, setError: SetErrorCallback | null = null): ImageFile | null {
  return sendRequest(`/api/v1/image_files/${id}`, setError, "DELETE");
}

export function genericImageFile(
    name: string,
    caption: string | null,
    description: string | null,
    mimeType: string | null,
    group: string | null,
    slideOrder: number | null,
): ImageFile {
  return {
    name:        name,
    caption:     caption,
    description: description,
    mime_type:   mimeType,
    group:       group,
    slide_order: slideOrder
  };
}
