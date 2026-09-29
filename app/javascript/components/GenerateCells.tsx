// app/javascript/components/GenerateCells.tsx

import { isPresent }                                     from "./utilities";
import { renderSelect }                                  from "./renderControlFunctions";
import { generateCells }                                 from "../services/cellService";
import { renderContent }                                 from "./renderUtilities";
import React, { RefObject, useEffect, useRef, useState } from "react";
import { ImageType, Cell }                               from "../types/dataTypes";
import RenderImageControl                                from "./RenderImageControl";

interface options {
  force?: boolean;
  availableImages?: any[];
  availableImageGroups?: any[];
  availableVideos?: any[];
}

interface GenerateCellsProps {
  sectionName?: string | null;
  options?: options;
  onFinished?: (cells: Cell[]) => void;
  // Pre-fills the Content/Image fields below from a Section's existing
  // (pre-Cell-refactor) description/image, so that generating columns for a
  // legacy section that still has real Section-level content starts from
  // that content instead of blank placeholder text - see SectionEditor.tsx,
  // which is the only caller that passes these.
  initialContent?: string | null;
  initialImage?: string | null;
  initialImageType?: ImageType;
}

const GenerateCells: React.FC<GenerateCellsProps> = ({
                                                       sectionName = null,
                                                       options = {} as options,
                                                       onFinished = null,
                                                       initialContent = null,
                                                       initialImage = null,
                                                       initialImageType = "Images"
                                                     }) => {
  const [ cellTemplate, setCellTemplate ]       = useState<string>("");
  const [ needImage, setNeedImage ]             = useState<boolean>(false);
  const [ needContent, setNeedContent ]         = useState<boolean>(false);
  const [ content, setContent ]                 = useState<string | null>(initialContent);
  const [ image, setImage ]                     = useState<string | null>(initialImage);
  const [ imageMode, setImageMode ]             = useState<ImageType>(initialImageType || "Images");
  const textTemplates: string[]                 =
            [
              "text-single",
              "text-top",
              "text-bottom",
              "text-right",
              "text-left"
            ];
  const imageTemplates: string []               =
            [
              "image-single",
              "text-top",
              "text-bottom",
              "text-right",
              "text-left"
            ];
  const previousImageMode: RefObject<ImageType> = useRef(imageMode);

  useEffect(() => {
    if (previousImageMode.current !== imageMode) setImage(null);
  }, [ imageMode ]);

  // OnChange/OnBlur Callback
  const setValue = (newValue: string | boolean, attribute: string) => {
    switch (attribute) {
      case "cellTemplates":
        setCellTemplate(newValue as string);
        setNeedContent(textTemplates.includes(newValue as string));
        setNeedImage(imageTemplates.includes(newValue as string));
        break;

      case "content":
        setContent(newValue as string);
        break;

      case "image":
        setImage(newValue as string);
        break;

      case "image_type":
        setImageMode(newValue as ImageType);
        break;
    }
  };

  const handleGenerate = () => {
    const name: string  = sectionName ? sectionName : "new-section";
    const cells: Cell[] = isPresent(cellTemplate) ?
                          generateCells(name, cellTemplate, content, image, imageMode)
                                                  :
                          generateCells(name, "generic-cell", content, image, imageMode);

    if (onFinished)
      onFinished(cells);
  };

  return (
      <div id="GenerateCells">
        <div className="row">
          <div className="col-12">{selectCellTemplates(cellTemplate, setValue)}</div>
        </div>
        {needContent && renderContent("content", content, setValue)}
        {needImage && (
            <RenderImageControl
                image={image}
                imageType={imageMode}
                availableImagesData={options?.availableImages || []}
                availableImageGroupsData={options?.availableImageGroups || []}
                availableVideosData={options?.availableVideos || []}
                setValue={setValue}
            />
        )}
        <div className="row">
          <button onClick={handleGenerate} className="btn btn-primary me-2" style={{ maxWidth: "12em" }}>
            Generate Columns
          </button>
        </div>
      </div>
  );
};

// *** Render Functions ***/

export function selectCellTemplates(value: string, setValue: (newValue: string, attribute: string) => void) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Templates:</div>
        <div className="col-5">
          {renderSelect("cellTemplates", value, [
            { label: "Text Only", value: "text-single" },
            { label: "Image Only", value: "image-single" },
            { label: "Dual Column - Text Left", value: "text-left" },
            { label: "Dual Column - Text Right", value: "text-right" },
            { label: "Three Column", value: "three-column" },
            { label: "Four Column", value: "four-column" },
            { label: "Five Column", value: "five-column" },
          ], setValue)}
        </div>
      </div>
  );
}

// *** Utility Functions ***/

export default GenerateCells;
