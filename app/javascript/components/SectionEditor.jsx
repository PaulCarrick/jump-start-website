// /app/javascript/components/SectionEditor
// noinspection JSUnusedLocalSymbols
// noinspection JSValidateTypes
// noinspection RegExpRedundantEscape

// Component to Edit a section Record

import React, {useState, useEffect, useRef} from "react";
import PropTypes from "prop-types";
import HtmlEditor from "./HtmlEditor";
import {backgroundColors} from "./backgroundColors";
import RenderSection from "./RenderSection";
import StylesEditor from "./StylesEditor";
import {renderComboBox, renderSelect, renderInput} from "./renderControlFunctions.jsx";
import {
  isTextOnly,
  isImageOnly,
  hasSplitSections,
  isPresent,
  getColumWidths, rowStyleOptions, ratioOptions
} from "./getDefaultOptions";
import axios from "axios";

const SectionEditor = ({
                         section = null,
                         availableContentTypes = null,
                         availableImages = null,
                         availableImageGroups = null,
                         availableVideos = null,
                         submitPath = null,
                         successPath = null,
                         cancelPath = null,
                         readOnlyContentType = false,
                         newSection = false,
                       }) => {
  // Assign section Record
  const [sectionData, setSectionData] = useState(section);

  // Handle case where section is not yet loaded
  useEffect(() => {
    if (!sectionData && section) {
      setSectionData(section);
    }
    else if (!sectionData) {
      setTimeout(() => {
        window.location.reload();
      }, 1000);
    }
  }, [section, sectionData]);

  // Assign Section Attributes
  const [contentType, setContentType]                   = useState(sectionData.content_type);
  const [sectionName, setSectionName]                   = useState(sectionData.section_name);
  const [sectionOrder, setSectionOrder]                 = useState(sectionData.section_order);
  const [image, setImage]                               = useState(sectionData.image);
  const [link, setLink]                                 = useState(sectionData.link);
  const [formatting, setFormatting]                     = useState(sectionData.formatting);
  const [rowStyle, setRowStyle]                         = useState(sectionData.row_style);
  const [divRatio, setDivRatio]                         = useState(sectionData.div_ratio);
  const [description, setDescription]                   = useState(sectionData.description);
  const [textMarginTop, setTextmarginTop]               = useState(sectionData.text_attributes.margin_top);
  const [textMarginLeft, setTextmarginLeft]             = useState(sectionData.text_attributes.margin_left);
  const [textMarginBottom, setTextmarginBottom]         = useState(sectionData.text_attributes.margin_bottom);
  const [textMarginRight, setTextmarginRight]           = useState(sectionData.text_attributes.margin_right);
  const [textBackgroundColor, settTextBackgroundColor]  = useState(sectionData.text_attributes.background_color);
  const [imageMarginTop, setImagemarginTop]             = useState(sectionData.image_attributes.margin_top);
  const [imageMarginLeft, setImagemarginLeft]           = useState(sectionData.image_attributes.margin_left);
  const [imageMarginBottom, setImagemarginBottom]       = useState(sectionData.image_attributes.margin_bottom);
  const [imageMarginRight, setImagemarginRight]         = useState(sectionData.image_attributes.margin_right);
  const [imageBackgroundColor, setImageBackgroundColor] = useState(sectionData.image_attributes.background_color);
  const [imageMode, setImageMode]                       = useState("Images");
  const [formattingMode, setFormattingMode]             = useState("safe");
  const [error, setError]                               = useState(null);
  const [submitUrl, setSubmitUrl]                       = useState(submitPath);
  const [successUrl, setSuccessUrl]                     = useState(successPath);
  const [cancelUrl, setCancelUrl]                       = useState(cancelPath);
  const previousFormatting                              = useRef(formatting);
  const previousRowStyle                                = useRef(rowStyle);
  const previousDivRatio                                = useRef(divRatio);
  const previousImageMode                               = useRef(imageMode);
  const lastChange                                      = useRef(null);

  // Assign select lists
  const [availableContentTypesData, setAvailableContentTypesData] = useState(availableContentTypes);
  const [availableImagesData, setAvailableImagesData]             = useState(availableImages);
  const [availableImageGroupsData, setAvailableImageGroupsData]   = useState(availableImageGroups);
  const [availableVideosData, setAvailableVideosData]             = useState(availableVideos);

  // Setup setters for change callback to update the values
  const attributeSetters = {
    contentType:          setContentType,
    sectionName:          setSectionName,
    sectionOrder:         setSectionOrder,
    image:                setImage,
    link:                 setLink,
    formatting:           setFormatting,
    rowStyle:             setRowStyle,
    divRatio:             setDivRatio,
    description:          setDescription,
    textMarginTop:        setTextmarginTop,
    textMarginLeft:       setTextmarginLeft,
    textMarginBottom:     setTextmarginBottom,
    textMarginRight:      setTextmarginRight,
    textBackgroundColor:  settTextBackgroundColor,
    imageMarginTop:       setImagemarginTop,
    imageMarginLeft:      setImagemarginLeft,
    imageMarginBottom:    setImagemarginBottom,
    imageMarginRight:     setImagemarginRight,
    imageBackgroundColor: setImageBackgroundColor,
    imageMode:            setImageMode,
  }

  // Onchange/OnBlur Callback
  const setValue = (newValue, attribute) => {
    const setter = attributeSetters[attribute];

    if (setter) {
      const convertedValue = convertType(newValue, attribute);

      lastChange.current = {
        attribute: attribute,
        value:     convertedValue
      }

      setter(convertedValue);
    }
  }

  useEffect(() => {
    if (((previousRowStyle.current !== "text-right") &&
        (previousRowStyle.current !== "text-left")) &&
        ((rowStyle === 'text-right') ||
         (rowStyle === 'text-left'))) {
      if (isPresent(previousDivRatio.current))
        setDivRatio(previousDivRatio.current);
      else
        setDivRatio("50:50");
    }

    previousRowStyle.current = rowStyle;
  }, [rowStyle]);

  useEffect(() => {
    previousDivRatio.current = divRatio;
  }, [divRatio]);

  useEffect(() => {
    const currentRowStyle = previousFormatting.current.row_style;
    const newRowStyle     = formatting.row_style;
    const currentDivRatio = previousFormatting.current.div_ratio;
    const newDivRatio     = formatting.div_ratio;

    if (currentRowStyle !== newRowStyle) {
      setRowStyle(newRowStyle);
      previousFormatting.current.row_style = newRowStyle;
    }

    if (currentDivRatio !== newDivRatio) {
      setDivRatio(newDivRatio);
      previousFormatting.current.div_ratio = newDivRatio;
    }

    previousFormatting.current = formatting;
  }, [formatting]);

  useEffect(() => {
    if (previousImageMode.current !== imageMode)
      setImage("");

    previousDivRatio.current = imageMode;
  }, [imageMode]);

  const toggleFormatting = () => {
    if (formattingMode === "safe")
      setFormattingMode("danger");
    else
      setFormattingMode("safe");
  };

  const handleSubmit = () => {
    const data = sectionToPostData(sectionData);

    if (isPresent(sectionData?.id) && (sectionData?.id != 0)) { // We are updating
      axios.put(submitUrl, data, {
        headers: {
          "Content-Type": "application/json",
          "Accept":       "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        }
      })
           .then(response => {
             sessionStorage.setItem('flashMessage', 'Section updated successfully!');
             window.location.href = successUrl;
           })
           .catch(error => {
             setError(`Error updating section: ${error.response || error.message}`);
           });
    }
    else { // We are creating
      axios.post(submitUrl, data, {
        headers: {
          "Content-Type": "application/json",
          "Accept":       "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        }
      })
           .then(response => {
             const url = successUrl.replace("ID", response.data.id);

             sessionStorage.setItem('flashMessage', 'Section created successfully!');
             window.location.href = url;
           })
           .catch(error => {
             setError(`Error creating section: ${error.response || error.message}`);
           });
    }
  };

  const handleCancel = () => {
    window.location.href = cancelUrl;
  };

  const splitSection = hasSplitSections(rowStyle)

  if (isPresent(lastChange) && isPresent(lastChange.current)) {
    const extraParameters = {
      rowStyle:  rowStyle,
      divRatio:  divRatio,
      imageMode: imageMode,
    }

    mapReactValuesToSection(
        sectionData,
        lastChange.current.attribute,
        lastChange.current.value,
        extraParameters
    );
  }

  // *** Main method ***/
  return (
      <div>
        {error && (
            <div className="row">
              <div className="error-box">
                {error}
              </div>
            </div>
        )}
        <div className="row mb-2 display-6 center-item text-center">
          <center>Preview</center>
        </div>
        <div className="row mb-2">
          <div id="sectionAttributes" className="w-100 border border-danger border-width-8">
            {!isPresent(image) && !isPresent(description) ? (
                <center><h1>No Contents</h1></center>
            ) : (
                 <RenderSection section={sectionData}/>
             )}
          </div>
        </div>
        {
          renderContentType(contentType, availableContentTypesData, setValue, readOnlyContentType)
        }
        {
          renderSectionName(sectionName, setValue)
        }
        {
          renderSectionOrder(sectionOrder, setValue)
        }
        {
          renderImage(
              image,
              imageMode,
              availableImagesData,
              availableImageGroupsData,
              availableVideosData,
              setValue
          )
        }
        {
          renderLink(link, setValue)
        }
        {
          renderDescription(description, setValue)
        }
        {
          formattingMode === 'danger' ? (
              renderFormatting(formatting, setValue)
          ) : (
              <>
                {renderRowStyle(rowStyle, setValue)}
                {splitSection && renderDivRatio(divRatio, setValue)}
                {renderAllAttributes(
                    rowStyle,
                    textMarginTop,
                    textMarginLeft,
                    textMarginBottom,
                    textMarginRight,
                    textBackgroundColor,
                    imageMarginTop,
                    imageMarginLeft,
                    imageMarginBottom,
                    imageMarginRight,
                    imageBackgroundColor,
                    setValue
                )}
              </>
          )
        }
        <div className="row align-items-center">
          <div className="col-2">
          </div>
          <div className="col-10">
            <div className="flext-container">
              {formattingMode === "danger" ? (
                  <button type="button" onClick={toggleFormatting} className="btn btn-good mb-2">
                    Switch to Normal Mode
                  </button>
              ) : (
                   <button type="button" className="btn btn-bad mb-2 mt-2" onClick={toggleFormatting} >
                     Switch to Formatting Mode **
                   </button>
               )
              }
              <span className="ms-4">
                ** Formatting mode should only be used by users who are familiar with CSS
              </span>
            </div>
          </div>
        </div>
        <div className="row mb-2">
          <div className="col-2" id="promptField">* - Required Fields</div>
          <div className="col-10">
          </div>
        </div>
        <div className="row mb-2">
          <div className="flex-container">
            <button type="button" className="btn btn-primary" onClick={handleSubmit}>
              Save Section
            </button>
            <button type="button" className="btn btn-secondary" onClick={handleCancel}>
              Cancel
            </button>
          </div>
        </div>
      </div>
  )
      ;
}

// *** Render Functions ***/

function renderContentType(contentType, availableContentTypesData, setValue, readOnlyContentType) {
  const optionsHash = availableContentTypesData.map((item) => ({
    label: item,
    value: item,
  }));

  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Content Type:</div>
        <div className="col-10">
          <div id="contentTypeDiv">
            {renderComboBox("contentType", contentType, optionsHash, setValue, readOnlyContentType)}
          </div>
        </div>
      </div>
  );
}

function renderSectionName(sectionName, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Section Name:</div>
        <div className="col-10">
          <div id="sectionNameDiv">
            {
              renderInput(
                  "sectionName",
                  sectionName,
                  setValue,
                  null,
                  "Enter the name for the section (optional; used for section focus)"
              )
            }
          </div>
        </div>
      </div>
  );
}

function renderSectionOrder(sectionOrder, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Section Order:</div>
        <div className="col-10">
          <div id="sectionOrderDiv">
            {
              renderInput(
                  "sectionOrder",
                  sectionOrder,
                  setValue,
                  null,
                  "Enter the order of the section (1 is first)",
                  "number"
              )
            }
          </div>
        </div>
      </div>
  );
}

function renderImage(
    image,
    imageMode,
    availableImagesData,
    availableImageGroupsData,
    availableVideosData,
    setValue
) {
  let optionsHash;

  switch (imageMode) {
    case "Groups":
      optionsHash = availableImageGroupsData.map((item) => ({
        label: item,
        value: item,
      }));
      break;
    case "Videos":
      optionsHash = availableVideosData.map((item) => ({
        label: item,
        value: item,
      }));
      break;
    default:
      optionsHash = availableImagesData.map((item) => ({
        label: item,
        value: item,
      }));
      break;
  }

  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Image:</div>
        <div className="col-7">
          <div id="imageDiv">
            {renderComboBox("image", image, optionsHash, setValue)}
          </div>
        </div>
        <div className="col-3">
          {renderSelect(
              "imageMode",
              imageMode,
              [
                {
                  label: "Images",
                  value: "Images",
                },
                {
                  label: "Image Groups",
                  value: "Groups",
                },
                {
                  label: "Videos",
                  value: "Videos",
                }
              ],
              setValue
          )}
        </div>
      </div>
  );
}

function renderLink(link, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Link (URL):</div>
        <div className="col-10">
          <div id="linkDiv">
            {
              renderInput(
                  "link",
                  link,
                  setValue,
                  null,
                  "Enter the URL to be opened when an image is clicked (optional)"
              )
            }
          </div>
        </div>
      </div>
  );
}

function renderDescription(description, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Content:</div>
        <div className="col-10">
          <div id="description">
            <HtmlEditor
                id="description"
                value={description}
                placeholder="Enter the text to be display in the text part of the section"
                onChange={(value) => setValue(
                    value,
                    "description"
                )}
                onBlur={(value) => setValue(
                    value,
                    "description"
                )}
                theme="snow"
            />
          </div>
        </div>
      </div>
  );
}

function renderRowStyle(rowStyle, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Row Style:</div>
        <div className="col-10">
          <div id="rowStyleDiv">
            {renderSelect("rowStyle", rowStyle, rowStyleOptions(), setValue)}
          </div>
        </div>
      </div>
  );
}

function renderDivRatio(divRatio, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Div Ratio:</div>
        <div className="col-10">
          <div id="divRatioDiv">
            {renderSelect("divRatio", divRatio, ratioOptions(), setValue)}
          </div>
        </div>
      </div>
  );
}

function renderAttributes(first, prefix, marginTop, marginLeft, marginBottom, marginRight, backgroundColor, setValue) {
  const marginTopOptions    = getMarginOptions("top");
  const marginLeftOptions   = getMarginOptions("left");
  const marginBottomOptions = getMarginOptions("bottom");
  const marginRightOptions  = getMarginOptions("right");

  if (first) {
    return (
        <>
          <div className="row">
            <div className="col-2 d-flex align-items-center">
              Margin Top:
            </div>
            <div className="col-10">
              {renderSelect(`${prefix}MarginTop`, marginTop, marginTopOptions, setValue)}
            </div>
          </div>
          <div className="row">
            <div className="col-2 d-flex align-items-center">
              Margin Left:
            </div>
            <div className="col-10">
              {renderSelect(`${prefix}MarginLeft`, marginLeft, marginLeftOptions, setValue)}
            </div>
          </div>
          <div className="row">
            <div className="col-2 d-flex align-items-center">
              Margin Bottom:
            </div>
            <div className="col-10">
              {renderSelect(`${prefix}MarginBottom`, marginBottom, marginBottomOptions, setValue)}
            </div>
          </div>
          <div className="row">
            <div className="col-2 d-flex align-items-center">
              Margin Right:
            </div>
            <div className="col-10">
              {renderSelect(`${prefix}MarginRight`, marginRight, marginRightOptions, setValue)}
            </div>
          </div>
          <div className="row">
            <div className="col-2 d-flex align-items-center">
              Background Color:
            </div>
            <div className="col-10">
              {renderSelect(`${prefix}BackgroundColor`, backgroundColor, backgroundColors, setValue)}
            </div>
          </div>
        </>
    );
  }
  else {
    return (
        <>
          <div className="row">
            {renderSelect(`${prefix}MarginTop`, marginTop, marginTopOptions, setValue)}
          </div>
          <div className="row">
            {renderSelect(`${prefix}MarginLeft`, marginLeft, marginLeftOptions, setValue)}
          </div>
          <div className="row">
            {renderSelect(`${prefix}MarginBottom`, marginBottom, marginBottomOptions, setValue)}
          </div>
          <div className="row">
            {renderSelect(`${prefix}MarginRight`, marginRight, marginRightOptions, setValue)}
          </div>
          <div className="row">
            {renderSelect(`${prefix}BackgroundColor`, backgroundColor, backgroundColors, setValue)}
          </div>
        </>
    );
  }
}

function renderTextAttributes(first, marginTop, marginLeft, marginBottom, marginRight, backgroundColor, setValue) {
  return renderAttributes(
      first,
      "text",
      marginTop,
      marginLeft,
      marginBottom,
      marginRight,
      backgroundColor,
      setValue
  );
}

function renderImageAttributes(first, marginTop, marginLeft, marginBottom, marginRight, backgroundColor, setValue) {
  return renderAttributes(
      first,
      "image",
      marginTop,
      marginLeft,
      marginBottom,
      marginRight,
      backgroundColor,
      setValue
  );
}

function renderAllAttributes(
    rowStyle,
    textMarginTop,
    textMarginLeft,
    textMarginBottom,
    textMarginRight,
    textBackgroundColor,
    imageMarginTop,
    imageMarginLeft,
    imageMarginBottom,
    imageMarginRight,
    imageBackgroundColor,
    setValue
) {
  if (isTextOnly(rowStyle)) {
    return (renderTextAttributes(
        true,
        textMarginTop,
        textMarginLeft,
        textMarginBottom,
        textMarginRight,
        textBackgroundColor,
        setValue
    ));
  }
  else if (isImageOnly(rowStyle)) {
    return (renderImageAttributes(
        true,
        imageMarginTop,
        imageMarginLeft,
        imageMarginBottom,
        imageMarginRight,
        imageBackgroundColor,
        setValue
    ));
  }
  else {
    switch (rowStyle) {
      case 'text-left':
      case 'text-top':
        return (
            <>
              <div className="row">
                <div className="col-2">
                  <p className="fs-5 m-0 p-0 fw-bold">
                    Text
                  </p>
                </div>
                <div className="col-10">
                </div>
              </div>
              {
                renderTextAttributes(
                    true,
                    textMarginTop,
                    textMarginLeft,
                    textMarginBottom,
                    textMarginRight,
                    textBackgroundColor,
                    setValue
                )
              }
              <div className="row">
                <div className="col-2">
                  <p className="fs-5 m-0 p-0 fw-bold">
                    Image
                  </p>
                </div>
                <div className="col-10">
                </div>
              </div>
              {
                renderImageAttributes(
                    true,
                    imageMarginTop,
                    imageMarginLeft,
                    imageMarginBottom,
                    imageMarginRight,
                    imageBackgroundColor,
                    setValue
                )
              }
            </>
        );
      case 'text-bottom':
      case 'text-right':
        return (
            <>
              <div className="row">
                <div className="col-2">
                  <p className="fs-5 m-0 p-0 fw-bold">
                    Image
                  </p>
                </div>
                <div className="col-10">
                </div>
              </div>
              {
                renderImageAttributes(
                    true,
                    imageMarginTop,
                    imageMarginLeft,
                    imageMarginBottom,
                    imageMarginRight,
                    imageBackgroundColor,
                    setValue
                )
              }
              <div className="row">
                <div className="col-2">
                  <p className="fs-5 m-0 p-0 fw-bold">
                    Text
                  </p>
                </div>
                <div className="col-10">
                </div>
              </div>
              {
                renderTextAttributes(
                    true,
                    textMarginTop,
                    textMarginLeft,
                    textMarginBottom,
                    textMarginRight,
                    textBackgroundColor,
                    setValue
                )
              }
            </>
        );
    }
  }
}

function renderFormatting(formatting, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Formatting:</div>
        <div className="col-10">
          <div id="formattingDiv">
            <StylesEditor styles={formatting} onChange={setValue}/>
          </div>
        </div>
      </div>
  );
}

// *** Utility Functions ***/

function sectionToPostData(sectionData, prefix = "section") {
  const result         = {};
  const skipParameters = ["id", "created_at", "updated_at"];

  result[prefix] = {};

  for (const key in sectionData) {
    if (!skipParameters.includes(key))
      result[prefix][key] = sectionData[key];
  }

  return result;
}

function getMarginOptions(marginType) {
  const prefixes = {
    none:   "",
    top:    "mt-",
    bottom: "mb-",
    left:   "ms-",
    right:  "me-",
  }

  const labelPrefixes = {
    none:   "",
    top:    "Margin Top",
    bottom: "Margin Bottom",
    left:   "Margin Left",
    right:  "Margin Right",
  }

  const prefix = prefixes[marginType];
  const label  = labelPrefixes[marginType];

  return prefix
         ? Array.from({ length: 6 }, (_, i) => (
          {
            value: `${prefix}${i}`,
            label: i === 0 ? "None" : `${label} - #${i}`,
          }
      ))
         : [];
}

function setFormattingElement(sectionData, fieldName, regex, newValue, elementType = "classes") {
  const formatting = sectionData.formatting;
  const fieldType  = (elementType === "styles") ?
                     /^image/.test(fieldName) ? "image_styles" : "text_styles"
                                                :
                     /^image/.test(fieldName) ? "image_classes" : "text_classes";

  if (formatting[fieldType]) {
    formatting[fieldType] = formatting[fieldType].replace(regex, "").trim(); // Strip out old Value
    formatting[fieldType] += " " + newValue; // Add new value in
  }
  else {
    formatting[fieldType] = newValue; // Add new value in
  }
}

function setFormattingClassElement(sectionData, fieldName, newValue) {
  switch (true) {
    case /mt\-(\d)/.test(newValue):
      setFormattingElement(sectionData, fieldName, /mt\-(\d+)/, newValue);
      break;
    case /mb\-(\d)/.test(newValue):
      setFormattingElement(sectionData, fieldName, /mb\-(\d+)/, newValue);
      break;
    case /ms\-(\d)/.test(newValue):
      setFormattingElement(sectionData, fieldName, /ms\-(\d+)/, newValue);
      break;
    case /me\-(\d)/.test(newValue):
      setFormattingElement(sectionData, fieldName, /me\-(\d+)/, newValue);
      break;
    case /col\-\d{1,2}/.test(newValue):
      setFormattingElement(sectionData, fieldName, /col\-\d{1,2}/g, newValue);
      break;
  }
}

function setFormattingStyleElement(sectionData, fieldName, newValue) {
  switch (true) {
    case /background\-color:\s*(.+)\s*;?/.test(newValue):
      setFormattingElement(
          sectionData,
          fieldName,
          /background\-color:\s*(.+)\s*;?/,
          newValue,
          "styles"
      );
      break;
  }
}

function mapReactValuesToSection(sectionData, attribute, value, extraParameters) {
  let textColumnWidth;
  let imageColumnWidth;

  switch (attribute) {
    case "contentType":
      sectionData.content_type = value;
      break;
    case "sectionName":
      sectionData.section_name = value;
      break;
    case "sectionOrder":
      sectionData.section_order = value;
      break;
    case "image":
      let mode = "Images";

      if (isPresent(extraParameters?.imageMode)) mode = extraParameters?.imageMode;

      switch (mode) {
        case"Groups":
          sectionData.image = `ImageGroup:${value}`;
          break;
        case "Videos":
          sectionData.image = `VideoImage:"${value}"`;
          break;
        default:
          sectionData.image = `ImageFile:${value}`;
          break;
      }
      break;
    case "link":
      sectionData.link = value;
      break;
    case "description":
      sectionData.description = value;
      break;
    case "formatting":
      sectionData.formatting = value;
      break;
    case "rowStyle":
      [textColumnWidth, imageColumnWidth] = getColumWidths(sectionData.div_ratio, value)

      if (isPresent(textColumnWidth) && isPresent(imageColumnWidth)) {
        setFormattingClassElement(sectionData, "textColumnWidth", textColumnWidth);
        setFormattingClassElement(sectionData, "imageColumnWidth", imageColumnWidth);
      }

      sectionData.row_style            = value;
      sectionData.formatting.row_style = value;

      break;
    case "divRatio":
      [textColumnWidth, imageColumnWidth] = getColumWidths(value, sectionData.row_style)

      if (isPresent(textColumnWidth) && isPresent(imageColumnWidth)) {
        setFormattingClassElement(sectionData, "textColumnWidth", textColumnWidth);
        setFormattingClassElement(sectionData, "imageColumnWidth", imageColumnWidth);
      }

      sectionData.div_ratio            = value;
      sectionData.formatting.div_ratio = value;

      break;
    case 'textMarginTop':
      sectionData.text_attributes.margin_top = value;
      setFormattingClassElement(sectionData, attribute, value);
      break;
    case 'textMarginBottom':
      sectionData.text_attributes.margin_bottom = value;
      setFormattingClassElement(sectionData, attribute, value);
      break;
    case 'textMarginLeft':
      sectionData.text_attributes.margin_left = value;
      setFormattingClassElement(sectionData, attribute, value);
      break;
    case 'textMarginRight':
      sectionData.text_attributes.margin_right = value;
      setFormattingClassElement(sectionData, attribute, value);
      break;
    case 'imageMarginTop':
      sectionData.image_attributes.margin_top = value;
      setFormattingClassElement(sectionData, attribute, value);
      break;
    case 'imageMarginBottom':
      sectionData.image_attributes.margin_bottom = value;
      setFormattingClassElement(sectionData, attribute, value);
      break;
    case 'imageMarginLeft':
      sectionData.image_attributes.margin_left = value;
      setFormattingClassElement(sectionData, attribute, value);
      break;
    case 'imageMarginRight':
      sectionData.image_attributes.margin_right = value;
      setFormattingClassElement(sectionData, attribute, value);
      break;
    case 'textBackgroundColor':
      sectionData.text_attributes.background_color = value;
      setFormattingStyleElement(sectionData, attribute, `background-color: ${value}`);
      break;
    case 'imageBackgroundColor':
      sectionData.image_attributes.background_color = value;
      setFormattingStyleElement(sectionData, attribute, `background-color: ${value}`);
      break;
  }
}

function stringOrValue(value) {
  if (typeof value === "string")
    return value;
  else
    return value.value;
}

function convertType(value, attribute) {
  switch (attribute) {
    case "contentType":
      return stringOrValue(value);
    case "sectionName":
      return value;
    case "sectionOrder":
      if (value === null)
        return null;
      else
        return parseInt(value, 10);
    case "image":
      return stringOrValue(value);
    case "link":
      return value;
    case "formatting":
      return value;
    case "rowStyle":
      return stringOrValue(value);
    case "divRatio":
      return stringOrValue(value);
    case "description":
      return value;
    case "textMarginTop":
      return stringOrValue(value);
    case "textMarginLeft":
      return stringOrValue(value);
    case "textMarginBottom":
      return stringOrValue(value);
    case "textMarginRight":
      return stringOrValue(value);
    case "textBackgroundColor":
      return stringOrValue(value);
    case "imageMarginTop":
      return stringOrValue(value);
    case "imageMarginLeft":
      return stringOrValue(value);
    case "imageMarginBottom":
      return stringOrValue(value);
    case "imageMarginRight":
      return stringOrValue(value);
    case "imageBackgroundColor":
      return stringOrValue(value);
    case "imageMode":
      return stringOrValue(value);
    default:
      return null;
  }
}

function arrayToOptions(stringArray) {
  let options = []

  for (const text of stringArray) {
    options.push({
                   label: text,
                   value: text,
                 });
  }

  return options;
}

SectionEditor.propTypes = {
  section:             PropTypes.shape({
                                         content_type:     PropTypes.string,
                                         section_name:     PropTypes.string,
                                         section_order:    PropTypes.number,
                                         image:            PropTypes.string,
                                         link:             PropTypes.string,
                                         description:      PropTypes.string,
                                         row_style:        PropTypes.string,
                                         text_attributes:  PropTypes.shape({
                                                                             margin_top:       PropTypes.string,
                                                                             margin_left:      PropTypes.string,
                                                                             margin_right:     PropTypes.string,
                                                                             margin_bottom:    PropTypes.string,
                                                                             background_color: PropTypes.string,
                                                                           }),
                                         image_attributes: PropTypes.shape({
                                                                             margin_top:       PropTypes.string,
                                                                             margin_left:      PropTypes.string,
                                                                             margin_right:     PropTypes.string,
                                                                             margin_bottom:    PropTypes.string,
                                                                             background_color: PropTypes.string,
                                                                           }),
                                       }),
  availableContentTypes:
                       PropTypes.arrayOf(PropTypes.string),
  availableImages:
                       PropTypes.arrayOf(PropTypes.string),
  availableImageGroups:
                       PropTypes.arrayOf(PropTypes.string),
  availableVideos:
                       PropTypes.arrayOf(PropTypes.string),
  submitPath:          PropTypes.string.required,
  successPath:         PropTypes.string.required,
  cancelPath:          PropTypes.string.required,
  readOnlyContentType: PropTypes.bool,
  newSection:          PropTypes.bool,
}

export default SectionEditor;
