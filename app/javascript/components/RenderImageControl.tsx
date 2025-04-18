// app/javascript/components/RenderImageControl.tsx

import React, { useState } from "react";
import { ImageType } from "../types/dataTypes";

interface RenderImageControlProps {
  image: string | null;
  imageType: ImageType | null;
  availableImagesData: string[] | null;
  availableImageGroupsData: string[] | null;
  availableVideosData: string[] | null;
  setValue: (newValue: string, attribute: string) => void;
}

const RenderImageControl: React.FC<RenderImageControlProps> = ({
                                                   image,
                                                   imageType,
                                                   availableImagesData,
                                                   availableImageGroupsData,
                                                   availableVideosData,
                                                   setValue
                                                 }) => {
  const [uploadedImage, setUploadedImage] = useState<string | null>(null);
  const [imageName, setImageName] = useState<string>("");
  const [selectedFile, setSelectedFile] = useState<File | null>(null);

  let optionsHash: { label: string; value: string }[] = [];

  switch (imageType) {
    case "Groups":
      if (availableImageGroupsData)
        optionsHash = availableImageGroupsData.map(item => ({
          label: item,
          value: item,
        }));
      break;
    case "Videos":
      if (availableVideosData)
        optionsHash = availableVideosData.map(item => ({
          label: item,
          value: item,
        }));
      break;
    default:
      if (availableImagesData)
        optionsHash = availableImagesData.map(item => ({
          label: item,
          value: item,
        }));
      break;
  }

  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Image:</div>
        <div className="col-5">
          <select
              className="form-select"
              value={image || ""}
              onChange={(e) => setValue(e.target.value, "image")}
          >
            <option value="">-- Select an image --</option>
            {optionsHash.map(({ label, value }) => (
                <option key={value} value={value}>{label}</option>
            ))}
          </select>
        </div>
      </div>
  );
};

export default RenderImageControl;
