// /app/javascript/components/image{processingUtilities.jsx

import {isPresent} from "./utilities";

export function handleImageGroup(group, formatting) {
  const imageFiles = imageFilesFindByGroup(group)

  if (imageFiles && (imageFiles.length > 0)) {
    const newFormatting = addImagesToFormatting(formatting, imageFiles);

    return [null, newFormatting];
  } else {
    return [missingImageUrl(), formatting];
  }
}

export function handleImageArray(imageList, formatting) {
  const images = imageList.split(",").map(imageName => imageFileFindByName(imageName.trim()));

  return [null, addImagesToFormatting(formatting, images)];
}

export function processVideoImages(contents) {
  contents.forEach(content => {
    if (!isPresent(content?.description)) return;

    const match = content.description.match(/VideoImage:\s*"(.+)"/);

    if (match) replaceVideoImageTag(content, match[1]);
  });
}

export function handleVideoImageTag(description) {
  if (isPresent(description)) {
    const match = description.match(/VideoImage:\s*"(.+)"/);

    if (match) description = processVideoImageTag(description, match[1]);
  }

  return description;
}

function replaceVideoImageTag(content, name) {
  content.description = processVideoImageTag(content.description, name);
}

export function processVideoImageTag(description, name) {
  const imageFile = imageFileFindByName(name)
  const imageUrl = imageFile.image_url;
  let results = description;

  if (imageUrl) {
    let label = imageFile.caption;

    if (!label)
      label = imageFile.name;

    const videoTag = `<a href="#" onclick="showVideoPlayer('${imageUrl}')">${label}</a>`;

    results = results.replace(/VideoImage:\s*"(.+)"/, videoTag);
  }

  return results;
}

export function addImagesToFormatting(formatting, images) {
  formatting.slide_show_images = images.map(image => ({
    image_url: image.image_url,
    caption: image.caption,
    description: image.description
  }));

  return formatting;
}

export function imageFilesFindByGroup(group) {
  const imageData = getImageFiles(`q[group_eq]=${group}`);

  if (imageData && (imageData.length > 0))
    return imageData;
  else
    return missingImageFile();
}

export function imageFileFindByName(name) {
  const imageData = getImageFiles(`q[name_eq]=${name}`);

  if (imageData && (imageData.length > 0))
    return imageData[0];
  else
    return missingImageFile();
}

export function missingImageFile(name = "Unknown") {
  const imageFile = {
    name: "Missing File",
    caption: "Missing File",
    description: `We could not find an image named: ${name}.`,
    mime_type: "image/jpeg",
    group: null,
    image_url: missingImageUrl(),
  }

  return imageFile;
}

export function missingImageUrl() {
  const rootPath = `${location.protocol}//${location.host}`;

  return `${rootPath}/images/missing-image.jpg`;
}

export function getImageFiles(query) {
  try {
    const xhr = new XMLHttpRequest();

    xhr.open("GET", `/api/v1/image_files?${query}`, false);
    xhr.send();

    if (xhr.status === 200)
      return (JSON.parse(xhr.responseText));
    else
      return [missingImageFile("Unknown")];
  } catch (err) {
    return [missingImageFile("Unknown")];
  }
}
