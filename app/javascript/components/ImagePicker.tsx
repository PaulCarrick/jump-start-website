import React, { useState } from "react";
import { createImageFile } from "../services/imageFileService";
import type { ImageType } from "../types/dataTypes";
import { renderComboBox, renderSelect } from "./renderControlFunctions";

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
}: {
  image: string | null;
  imageType: ImageType | null;
  availableImagesData: string[] | null;
  availableImageGroupsData: string[] | null;
  availableVideosData: string[] | null;
  setValue: (value: string, attribute: string) => void;
}) {
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
            {renderComboBox("image", image, optionsHash, setValue)}
          </div>
        </div>
        <div id="imageTypeDiv" className="col-3">
          {renderSelect("image_type", imageType, imageTypeOptions, setValue)}
        </div>
      </div>
    );
  }
}
