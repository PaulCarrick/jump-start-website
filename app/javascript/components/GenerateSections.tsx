// app/javascript/components/GenerateSections.tsx

import RenderImageControl from "./RenderImageControl";
import { isPresent }      from "./utilities";
import { renderSelect }   from "./renderControlFunctions";
import {
  generateSections,
  generateRandomSectionName
}                         from "../services/sectionService";
import {
  renderContent,
  renderSectionName
}                         from "./renderUtilities";
import React, {
  RefObject,
  useEffect,
  useRef,
  useState
}                         from "react";
import {
  ImageType,
  Page, PageOptions,
  Section
}                         from "../types/dataTypes";

interface GenerateSectionsProps {
  name?: string | null;
  page?: Page | null;
  options?: PageOptions;
  onFinished?: (sections: Section[]) => void;
}

const GenerateSections: React.FC<GenerateSectionsProps> = ({
                                                             name = null,
                                                             page = null,
                                                             options = {},
                                                             onFinished = null
                                                           }) => {
  const [ sectionName, setSectionName ]         = useState<string>(name ||
                                                                   generateRandomSectionName);
  const [ sectionOrder, setSectionOrder ]       = useState<number>(1);
  const [ sectionTemplate, setSectionTemplate ] = useState<string>("");
  const [ needImage, setNeedImage ]             = useState<boolean>(false);
  const [ needContent, setNeedContent ]         = useState<boolean>(false);
  const [ content, setContent ]                 = useState<string | null>(null);
  const [ caption, setCaption ]                 = useState<string | null>(null);
  const [ image, setImage ]                     = useState<string | null>(null);
  const [ imageMode, setImageMode ]             = useState<ImageType>("Images");
  const textTemplates: string[]                 = [
    "text-single",
    "text-top",
    "text-bottom",
    "text-right",
    "text-left",
    "header-section"
  ];
  const imageTemplates: string []               = [
    "image-single",
    "text-top",
    "text-bottom",
    "text-right",
    "text-left",
    "header-section"
  ];
  const previousImageMode: RefObject<ImageType> = useRef(imageMode);

  useEffect(() => {
    if (previousImageMode.current !== imageMode) setImage(null);
  }, [ imageMode ]);

  // OnChange/OnBlur Callback
  const setValue = (newValue: string | boolean, attribute: string) => {
    switch (attribute) {
      case "section_name":
        setSectionName(newValue as string);
        break;

      case "section_order":
        setSectionOrder(Number(newValue));
        break;

      case "section_templates":
        setSectionTemplate(newValue as string);
        setNeedContent(textTemplates.includes(newValue as string));
        setNeedImage(imageTemplates.includes(newValue as string));
        break;

      case "caption":
        setCaption(newValue as string);
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

  const canGenerate = (): boolean => {
    let result: boolean = isPresent(sectionTemplate) && isPresent(sectionName);

    if (result && needContent)
      result = isPresent(content);

    if (result && needImage)
      result = isPresent(image);

    return result;
  }

  const handleGenerate = () => {
    const contentType: string | null = page?.section ? page.section : null;
    const sections: Section[]        = isPresent(sectionTemplate) ?
                                       generateSections(sectionName,
                                                        contentType,
                                                        sectionTemplate,
                                                        content,
                                                        image,
                                                        imageMode,
                                                        sectionOrder,
                                                        caption || undefined)
                                                                  :
                                       generateSections(sectionName,
                                                        contentType,
                                                        "generic-section",
                                                        content,
                                                        image,
                                                        imageMode,
                                                        sectionOrder,
                                                        caption || undefined);

    if (onFinished)
      onFinished(sections);
  };

  return (
      <div id="GenerateSections">
        {renderSectionName(sectionName, null, setValue)}
        <div className="row">
          <div className="col-12">{selectSectionTemplates(sectionTemplate, setValue)}</div>
        </div>
        {needContent && renderContent("content", content, setValue)}
        {(sectionTemplate === "header-section") && renderContent("caption", caption, setValue)}
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
        {canGenerate() && (
            <div className="row">
              <button onClick={handleGenerate} className="btn btn-primary me-2" style={{ maxWidth: "12em" }}>
                Generate Sections
              </button>
            </div>
        )}
      </div>
  );
};

// *** Render Functions ***/

export function selectSectionTemplates(value: string, setValue: (newValue: string, attribute: string) => void) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Templates:</div>
        <div className="col-5">
          {renderSelect("section_templates", value, [
            { label: "Text Only", value: "text-single" },
            { label: "Image Only", value: "image-single" },
            { label: "Dual Column - Text Left", value: "text-left" },
            { label: "Dual Column - Text Right", value: "text-right" },
            { label: "Three Column", value: "three-column" },
            { label: "Four Column", value: "four-column" },
            { label: "Five Column", value: "five-column" },
            { label: "Dual Row - Text Top", value: "text-top" },
            { label: "Dual Row - Text Bottom", value: "text--bottom" },
            { label: "Header Section", value: "header-section" }
          ], setValue)}
        </div>
      </div>
  );
}

export default GenerateSections;
