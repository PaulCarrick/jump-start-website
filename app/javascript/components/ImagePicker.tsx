import NewImageButton from "./NewImageButton";
import { useImageChoices } from "../hooks/useImageChoices";
import React, { useEffect, useState } from "react";
import Select from "react-select";
import { createImageFile } from "../services/imageFileService";
import type { ImageType } from "../types/dataTypes";
import { renderComboBox, renderSelect } from "./renderControlFunctions";

export function savedImageType(image: string | null | undefined): ImageType {
  if (image?.startsWith('ImageGroup:')) return 'Groups';
  if (image?.startsWith('ImageSection:')) return 'Section';
  if (image?.startsWith('VideoImage:')) return 'Videos';
  return 'Images';
}

function imageChoice(image: string | null): string | null {
  if (!image) return null;
  const video = image.match(/^VideoImage:\s*"(.*)"$/);
  return video ? video[1] : image.replace(/^(ImageFile|ImageGroup|ImageSection):\s*/, '');
}


// The column's image field as one of the choices below: "ImageFile:name"
// (a plain name counts as a picture too), "ImageGroup:group" for a slide show
// of a group, or 'VideoImage:"name"' for a video.
export function mediaReference(image: string | null | undefined): string {
  const value = (image || "").trim();
  if (!value) return "";
  const video = value.match(/^VideoImage:\s*(?:"|&quot;)\s*(.+?)\s*(?:"|&quot;)$/);
  if (video) return `VideoImage:"${video[1]}"`;
  const typed = value.match(/^(ImageFile|ImageGroup|ImageSection):\s*(.+)$/);
  if (typed) return `${typed[1]}:${typed[2].trim()}`;
  if (/^(https?:|\/|\[)/.test(value)) return value;
  return `ImageFile:${value}`;
}

type MediaOption = { label: string; value: string };

// One list for everything a column can show: a picture, a slide show of an
// image group, or a video. Choosing one stores the right reference.
function MediaChooser({
  image,
  images,
  groups,
  groupCounts,
  videos,
  onChoose,
}: {
  image: string | null;
  images: string[];
  groups: string[];
  groupCounts: Record<string, number>;
  videos: string[];
  onChoose: (reference: string) => void;
}) {
  const plural = (count: number | undefined) => (count === undefined ? "" : ` (${count} ${count === 1 ? "picture" : "pictures"})`);
  // The short lists first, so slide shows and videos are not buried under
  // every picture; typing searches all three.
  const options = [
    { label: "Slide shows (image groups)", options: groups.map((group) => ({ label: `${group}${plural(groupCounts[group])}`, value: `ImageGroup:${group}` })) },
    { label: "Videos", options: videos.map((name) => ({ label: name, value: `VideoImage:"${name}"` })) },
    { label: "Pictures", options: images.map((name) => ({ label: name, value: `ImageFile:${name}` })) },
  ].filter((group) => group.options.length > 0);
  const reference = mediaReference(image);
  const all: MediaOption[] = options.flatMap((group) => group.options);
  const current = reference ? all.find((option) => option.value === reference) || { label: reference, value: reference } : null;

  let description = "Nothing chosen: the column shows only its text.";
  if (reference.startsWith("ImageGroup:")) {
    const group = reference.slice("ImageGroup:".length);
    description = `A slide show of the group ${group}${plural(groupCounts[group])}, in its slide order.`;
  } else if (reference.startsWith("VideoImage:")) {
    description = `The video ${reference.slice('VideoImage:"'.length, -1)}, with play controls.`;
  } else if (reference.startsWith("ImageSection:")) {
    description = `The pictures of the section ${reference.slice("ImageSection:".length)}.`;
  } else if (reference.startsWith("ImageFile:")) {
    description = `The picture ${reference.slice("ImageFile:".length)}.`;
  } else if (reference) {
    description = `The picture at ${reference}.`;
  }

  return (
    <div className="column-media">
      <label htmlFor="column-media" className="form-label">Picture, slide show or video</label>
      <Select<MediaOption, false>
        inputId="column-media"
        classNamePrefix="column-media"
        value={current}
        options={options}
        onChange={(option) => onChoose(option?.value || "")}
        isClearable
        isSearchable
        placeholder="Type to search pictures, groups and videos…"
        noOptionsMessage={() => "Nothing matches. Upload it with New Image."}
      />
      <div className="form-text">{description}</div>
    </div>
  );
}

const imageTypeOptions = [
  { label: "Image", value: "Images" },
  { label: "Image Section", value: "Section" },
  { label: "Image Group", value: "Groups" },
  { label: "Video", value: "Videos" },
  { label: "Upload", value: "Upload" },
];

export default function ImagePicker({
  image,
  imageType,
  availableImagesData,
  availableImageGroupsData,
  availableVideosData,
  setValue,
  referenceValues = false,
}: {
  referenceValues?: boolean;
  image: string | null;
  imageType: ImageType | null;
  availableImagesData: string[] | null;
  availableImageGroupsData: string[] | null;
  availableVideosData: string[] | null;
  setValue: (value: string, attribute: string) => void;
}) {
  const { choices, reload, error } = useImageChoices();
  // Load the full list (with each group's size) for the column editor.
  useEffect(() => {
    if (referenceValues && !choices) reload();
  }, [referenceValues, choices, reload]);
  availableImagesData = choices?.images ?? availableImagesData;
  availableImageGroupsData = choices?.groups ?? availableImageGroupsData;
  availableVideosData = choices?.videos ?? availableVideosData;
  const [uploadedImage, setUploadedImage] = useState<string | null>(null);
  const [imageName, setImageName] = useState<string>("");
  const [selectedFile, setSelectedFile] = useState<File | null>(null);

  const availableItems =
    imageType === "Groups"
      ? availableImageGroupsData
      : imageType === "Videos"
        ? availableVideosData
        : availableImagesData;
  const optionsHash = (availableItems ?? []).map((value) => ({
    label: value,
    value,
  }));

  const chooseImage = (value: string, attribute: string) => {
    if (attribute !== 'image' || !referenceValues || !value) {
      setValue(value, attribute);
      return;
    }
    const reference = imageType === 'Groups' ? `ImageGroup:${value}`
      : imageType === 'Section' ? `ImageSection:${value}`
      : imageType === 'Videos' ? `VideoImage:"${value}"`
      : /^(https?:|\/|ImageFile:)/.test(value) ? value : `ImageFile:${value}`;
    setValue(reference, attribute);
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file: File | undefined = event.target.files?.[0];

    if (file) {
      setSelectedFile(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setUploadedImage(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleUpload = () => {
    if (!selectedFile || !imageName.trim()) {
      alert("Please select an image and enter a name.");
      return;
    }

    const imageFile = {
      name: imageName.trim(),
      mime_type: selectedFile.type,
    };

    createImageFile(imageFile, selectedFile);

    setValue(imageName.trim(), "image");
    setUploadedImage(null);
    setImageName("");
  };

  if (referenceValues) {
    return (
      <div className="mb-2">
        <MediaChooser
          image={image}
          images={availableImagesData ?? []}
          groups={availableImageGroupsData ?? []}
          groupCounts={choices?.group_counts ?? {}}
          videos={availableVideosData ?? []}
          onChoose={(reference) => setValue(reference, "image")}
        />
        <div className="d-flex flex-wrap align-items-center gap-2 mt-2">
          <NewImageButton onReturn={reload} />
          {image && <button type="button" className="btn btn-secondary" onClick={() => setValue("", "image")}>Remove</button>}
        </div>
        {error && <div role="alert">{error} <button type="button" className="btn btn-link" onClick={reload}>Retry</button></div>}
      </div>
    );
  }

  if (!image && imageType === "Upload") {
    return (
      <div className="row mb-2">
        <div className="col-2 pt-2">Upload Image:</div>
        <div className="col-7">
          <div className="mb-2"><NewImageButton onReturn={reload} /></div>
          {error && <div role="alert">{error}</div>}
          <input
            type="file"
            accept="image/*"
            onChange={handleFileChange}
            className="form-control"
          />

          {uploadedImage && (
            <>
              <div className="mt-2">
                <img
                  src={uploadedImage}
                  alt="Uploaded"
                  className="img-fluid"
                  style={{ maxHeight: "150px" }}
                />
              </div>

              <input
                type="text"
                className="form-control mt-2"
                placeholder="Enter image name"
                value={imageName}
                onChange={(e) => setImageName(e.target.value)}
              />

              <button
                type="button"
                className="btn btn-primary mt-2"
                onClick={handleUpload}
              >
                Upload Image
              </button>
            </>
          )}
        </div>

        <div id="imageTypeDiv" className="col-3">
          {renderSelect("image_type", imageType, imageTypeOptions, setValue)}
        </div>
      </div>
    );
  } else {
    return (
      <div className="row mb-2">
        <div className="col-2 pt-2">Image:</div>
        <div className="col-7">
          <div id="imageDiv">
            {renderComboBox("image", imageChoice(image), optionsHash, chooseImage)}
          </div>
          {image && <div className="form-text mb-1">Current image: {imageChoice(image)}</div>}
          <div className="d-flex flex-wrap align-items-center gap-2 mt-1">
            <NewImageButton onReturn={reload} />
            {image && <button type="button" className="btn btn-secondary" onClick={() => setValue('', 'image')}>Remove Image</button>}
          </div>
          {error && <div role="alert">{error} <button type="button" className="btn btn-link" onClick={reload}>Retry</button></div>}
        </div>
        <div id="imageTypeDiv" className="col-3">
          {renderSelect("image_type", imageType, imageTypeOptions, setValue)}
        </div>
      </div>
    );
  }
}
