// app/javascript/components/renderUtilities.jsx

// Utilities to render controls

import React from "react";
import HtmlEditor from "./HtmlEditor";
import ImagePicker from "./ImagePicker";
import { ImageType } from "../types/dataTypes";
import {
  renderComboBox,
  renderSelect,
  renderInput,
} from "./renderControlFunctions";

// Function to render description input
export function renderContent(
  attribute: string = "content",
  description: string | null = "",
  setValue: any = null,
  useHtmlView: boolean | null = null,
) {
  return (
    <div className="row mb-2" style={{ minHeight: "15em" }}>
      <div className="col-2 d-flex align-items-center">Content:</div>
      <div className="col-10">
        <div id="contentDiv">
          <HtmlEditor
            id={attribute}
            value={description ?? undefined}
            placeholder="Enter the text to be displayed in the text part of the section"
            onChange={setValue}
            onBlur={setValue}
            useHtmlView={useHtmlView ? useHtmlView : undefined}
          />
        </div>
      </div>
    </div>
  );
}

// Function to render image selection

export function renderImage(
  image: string | null,
  imageType: ImageType | null,
  availableImagesData: string[] | null,
  availableImageGroupsData: string[] | null,
  availableVideosData: string[] | null,
  setValue: any,
) {
  return (
    <ImagePicker
      image={image}
      imageType={imageType}
      availableImagesData={availableImagesData}
      availableImageGroupsData={availableImageGroupsData}
      availableVideosData={availableVideosData}
      setValue={setValue}
    />
  );
}

export function renderContentType(
  contentType: string | null = "",
  availableContentTypesData: string[] = [],
  setValue: any = null,
  readOnlyContentType: boolean | null = false,
) {
  const optionsHash = availableContentTypesData.map((item) => ({
    label: item,
    value: item,
  }));

  return (
    <div className="row mb-2">
      <div className="col-2 d-flex align-items-center">Content Type:</div>
      <div className="col-5">
        <div id="contentTypeDiv">
          {renderComboBox(
            "content_type",
            contentType,
            optionsHash,
            setValue,
            readOnlyContentType ?? false,
          )}
        </div>
      </div>
    </div>
  );
}

export function renderTitle(title: string | null = "", setValue: any = null) {
  return (
    <div className="row mb-2">
      <div className="col-2 d-flex align-items-center">Page Title:</div>
      <div className="col-5">
        <div id="titleDiv">
          {renderInput(
            "title",
            title,
            setValue,
            null,
            {},
            "Enter the title for the page",
          )}
        </div>
      </div>
    </div>
  );
}

export function renderPageName(
  pageName: string | null = "",
  setValue: any = null,
) {
  return (
    <div className="row mb-2">
      <div className="col-2 d-flex align-items-center">Page Name*:</div>
      <div className="col-5">
        <div id="pageNameDiv">
          {renderInput(
            "name",
            pageName,
            setValue,
            null,
            { required: true },
            "Enter the name for the page (required and must be unique)",
          )}
        </div>
      </div>
    </div>
  );
}

export function renderAccess(access: string | null = "", setValue: any = null) {
  return (
    <div className="row mb-2">
      <div className="col-2 d-flex align-items-center">Page Access:</div>
      <div className="col-5">
        <div id="titleDiv">
          {renderInput(
            "access",
            access,
            setValue,
            null,
            {},
            "Enter the access for the page",
          )}
        </div>
      </div>
    </div>
  );
}

export function renderSectionName(
  sectionName: string | null = "",
  availableContentTypesData: string[] | null = [],
  setValue: any = null,
  readOnlySectionName: boolean | null = false,
  attribute = "section_name",
) {
  if (availableContentTypesData) {
    const optionsHash = availableContentTypesData.map((item) => ({
      label: item,
      value: item,
    }));

    return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Content Type:</div>
        <div className="col-5">
          <div id="sectionNameDiv">
            {renderComboBox(
              attribute,
              sectionName,
              optionsHash,
              setValue,
              readOnlySectionName ?? false,
            )}
          </div>
        </div>
      </div>
    );
  } else {
    return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Section Name*:</div>
        <div className="col-5">
          <div id="sectionNameDiv">
            {renderInput(
              attribute,
              sectionName,
              setValue,
              null,
              { required: true },
              "Enter the name for the section (required and must be unique)",
            )}
          </div>
        </div>
      </div>
    );
  }
}

export function renderCellName(
  cellName: string | null = "",
  setValue: any = null,
) {
  return (
    <div className="row mb-2">
      <div className="col-2 d-flex align-items-center">Column Name*:</div>
      <div className="col-5">
        <div id="cellNameDiv">
          {renderInput(
            "cell_name",
            cellName,
            setValue,
            null,
            { required: true },
            "Enter the name for the column (required and must be unique)",
          )}
        </div>
      </div>
    </div>
  );
}

export function renderSectionOrder(
  sectionOrder: number | null = 1,
  setValue: any = null,
) {
  return (
    <div className="row mb-2">
      <div className="col-2 d-flex align-items-center">Section Order:</div>
      <div className="col-5">
        <div id="sectionOrderDiv">
          {renderInput(
            "section_order",
            sectionOrder,
            setValue,
            null,
            {},
            "Enter the order of the section (1 is first)",
            "number",
          )}
        </div>
      </div>
    </div>
  );
}

export function renderCellOrder(
  cellOrder: number | null = 1,
  setValue: any = null,
) {
  return (
    <div className="row mb-2">
      <div className="col-2 d-flex align-items-center">Column Order:</div>
      <div className="col-5">
        <div id="cellOrderDiv">
          {renderInput(
            "cell_order",
            cellOrder,
            setValue,
            null,
            {},
            "Enter the order of the column (1 is first)",
            "number",
          )}
        </div>
      </div>
    </div>
  );
}

export function renderLink(link: string | null, setValue: any = null) {
  return (
    <div className="row mb-2">
      <div className="col-2 d-flex align-items-center">Link (URL):</div>
      <div className="col-5">
        <div id="linkDiv">
          {renderInput(
            "link",
            link,
            setValue,
            null,
            {},
            "Enter the URL to be opened when an image is clicked (optional)",
          )}
        </div>
      </div>
    </div>
  );
}
