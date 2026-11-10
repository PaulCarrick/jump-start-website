// /app/javascript/components/RoundedPictureCheckbox.tsx

// "Round the picture corners" on a column's Image tab: adds or removes the
// rounded-3 class in the column's Image Classes, which every picture of the
// column gets (a single picture or each slide of a group's slide show).
// Videos are not rounded, so the box is hidden for them.

import React from "react";
import { hasClass, ROUNDED_IMAGE_CLASS, setClasses } from "./roundedClasses";

interface RoundedPictureCheckboxProps {
  image: string | null;
  formatting: Record<string, any>;
  onChange: (formatting: Record<string, any>, attribute: string) => void;
}

const RoundedPictureCheckbox: React.FC<RoundedPictureCheckboxProps> = ({
  image,
  formatting,
  onChange,
}) => {
  if (!image || image.startsWith("VideoImage:")) return null;

  const isGroup = image.startsWith("ImageGroup:");
  const checked = hasClass(formatting.image_classes, ROUNDED_IMAGE_CLASS);

  const toggle = (include: boolean) => {
    const imageClasses = setClasses(formatting.image_classes, [ROUNDED_IMAGE_CLASS], include);
    onChange({ ...formatting, image_classes: imageClasses }, "formatting");
  };

  return (
    <div className="form-check mt-3 mb-2">
      <input
        id="roundedPicture"
        type="checkbox"
        className="form-check-input"
        checked={checked}
        onChange={(event) => toggle(event.target.checked)}
      />
      <label htmlFor="roundedPicture" className="form-check-label">
        {isGroup ? "Round the corners of the group's pictures" : "Round the picture corners"}
      </label>
    </div>
  );
};

export default RoundedPictureCheckbox;
