import NewImageButton from "./NewImageButton";
import { useImageChoices } from "../hooks/useImageChoices";
import React, { useState } from "react";
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

  if (!image && imageType === "Upload") {
    return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Upload Image:</div>
        <div className="col-7">
          <NewImageButton onReturn={reload} />
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
        <div className="col-2 d-flex align-items-center">Image:</div>
        <div className="col-7">
          <div id="imageDiv">
            {renderComboBox("image", imageChoice(image), optionsHash, chooseImage)}
          </div>
          {image && <div className="form-text mb-1">Current image: {imageChoice(image)}</div>}
          <div className="d-flex gap-2 mt-1">
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
