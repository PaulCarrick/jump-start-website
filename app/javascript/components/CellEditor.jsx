// /app/javascript/components/CellEditor
// noinspection JSUnusedLocalSymbols
// noinspection JSValidateTypes
// noinspection RegExpRedundantEscape

// Component to Edit a cell Record

import React, {useState, useEffect, useRef} from "react";
import PropTypes from "prop-types";
import HtmlEditor from "./HtmlEditor";
import {backgroundColors} from "./backgroundColors";
import RenderCell from "./RenderCell.jsx";
import StylesEditor from "./StylesEditor";
import {renderComboBox, renderSelect, renderInput} from "./renderControlFunctions.jsx";
import {isPresent} from "./getDefaultOptions";
import ErrorBoundary from './ErrorBoundary';
import axios from "axios";

const CellEditor = ({
                      cell = null,
                      availableSectionNames = null,
                      availableImages = null,
                      availableImageGroups = null,
                      availableVideos = null,
                      submitPath = null,
                      successPath = null,
                      cancelPath = null,
                      readOnlySectionName = false,
                      newCell = false,
                    }) => {
  // Assign cell Record
  const [cellData, setCellData] = useState(cell);

  // Handle case where cell is not yet loaded
  useEffect(() => {
    if (!cellData && cell) {
      setCellData(cell);
    }
    else if (!cellData) {
      setTimeout(() => {
        window.location.reload();
      }, 1000);
    }
  }, [cell, cellData]);

  // Assign Cell Attributes
  const [sectionName, setSectionName]          = useState(cellData.section_name);
  const [cellName, setCellName]                = useState(cellData.cell_name);
  const [cellOrder, setCellOrder]              = useState(cellData.cell_order);
  const [content, setContent]                  = useState(cellData.content);
  const [image, setImage]                      = useState(cellData.image);
  const [link, setLink]                        = useState(cellData.link);
  const [options, setOptions]                  = useState(cellData.options ? cellData.options : {});
  const [useHtmlView, setUseHtmlView]          = useState((cellData.options && ('use_html_view' in options)) ? cellData.options.use_html_view : false);
  const [formatting, setFormatting]            = useState(cellData.formatting ? cellData.formatting : {});
  const [marginTop, setMarginTop]              = useState((cellData.formatting && ('margin_top' in formatting)) ? cellData.formatting.margin_top : null);
  const [marginLeft, setMarginLeft]            = useState((cellData.formatting && ('margin_left' in formatting)) ? cellData.formatting.margin_left : null);
  const [marginBottom, setMarginBottom]        = useState((cellData.formatting && ('margin_bottom' in formatting)) ? cellData.formatting.margin_bottom : null);
  const [marginRight, setMarginRight]          = useState((cellData.formatting && ('margin_right' in formatting)) ? cellData.formatting.margin_right : null);
  const [backgroundColor, settBackgroundColor] = useState((cellData.formatting && ('background_color' in formatting)) ? cellData.formatting.background_color : null);
  const [imageMode, setImageMode]              = useState("Images");
  const [formattingMode, setFormattingMode]    = useState("safe");
  const [error, setError]                      = useState(null);
  const [submitUrl, setSubmitUrl]              = useState(submitPath);
  const [successUrl, setSuccessUrl]            = useState(successPath);
  const [cancelUrl, setCancelUrl]              = useState(cancelPath);
  const previousFormatting                     = useRef(formatting);
  const previousImageMode                      = useRef(imageMode);
  const lastChange                             = useRef(null);

  // Assign select lists
  const [availableSectionNamesData, setAvailableSectionNamesData] = useState(availableSectionNames);
  const [availableImagesData, setAvailableImagesData]             = useState(availableImages);
  const [availableImageGroupsData, setAvailableImageGroupsData]   = useState(availableImageGroups);
  const [availableVideosData, setAvailableVideosData]             = useState(availableVideos);

  // Setup setters for change callback to update the values
  const attributeSetters = {
    sectionName:     setSectionName,
    cellName:        setCellName,
    cellOrder:       setCellOrder,
    content:         setContent,
    image:           setImage,
    link:            setLink,
    formatting:      setFormatting,
    marginTop:       setMarginTop,
    marginLeft:      setMarginLeft,
    marginBottom:    setMarginBottom,
    marginRight:     setMarginRight,
    backgroundColor: settBackgroundColor,
    imageMode:       setImageMode,
    useHtmlView:     setUseHtmlView
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
    if (previousImageMode.current !== imageMode)
      setImage("");
  }, [imageMode]);

  const toggleFormatting = () => {
    if (formattingMode === "safe")
      setFormattingMode("danger");
    else
      setFormattingMode("safe");
  };

  const cellToPostData = (cellData, prefix = "cell") => {
    const result         = {};
    const skipParameters = ["id", "created_at", "updated_at"];
    result[prefix]       = {};

    for (const key in cellData) {
      if (!skipParameters.includes(key)) {
        if (key === "content") {
          if (useHtmlView) {
            const textField = document.getElementById("content_text");

            if (textField) {
              const html   = textField.value;
              const parser = new DOMParser();
              const parsed = parser.parseFromString(html, "text/html");

              if (!parsed.querySelector("parsererror")) {
                cellData[key] = html;
              }
              else {
                setError(`Error the content does not contain valid html. Please correct it and try again.`);
                return null;
              }
            }
          }
        }
        else if (key === "options") {
          let options = cellData.options;

          if (options)
            options["use_html_view"] = useHtmlView;
          else
            options = { "use_html_view": useHtmlView };

          cellData[key] = options;
        }

        result[prefix][key] = cellData[key];
      }
    }

    return result;
  }

  const handleSubmit = () => {
    const data = cellToPostData(cellData);

    if (data === null)
      return

    if (isPresent(cellData?.id) && (cellData?.id != 0)) { // We are updating
      axios.put(submitUrl, data, {
        headers: {
          "Content-Type": "application/json",
          "Accept":       "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        }
      })
           .then(response => {
             sessionStorage.setItem('flashMessage', 'Cell updated successfully!');
             window.location.href = successUrl;
           })
           .catch(error => {
             setError(`Error updating cell: ${error.response || error.message}`);
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

             sessionStorage.setItem('flashMessage', 'Cell created successfully!');
             window.location.href = url;
           })
           .catch(error => {
             setError(`Error creating cell: ${error.message}`);
           });
    }
  };

  const handleCancel = () => {
    window.location.href = cancelUrl;
  };

  if (isPresent(lastChange) && isPresent(lastChange.current)) {
    const extraParameters = {
      imageMode: imageMode,
    }

    mapReactValuesToCell(
        cellData,
        lastChange.current.attribute,
        lastChange.current.value,
        extraParameters
    );
  }

  // *** Main method ***/
  return (
      <ErrorBoundary>
        <div>
          {error && (
              <div className="row">
                <div className="error-box">
                  {error}
                </div>
              </div>
          )}
          {
            renderSectionName(sectionName, availableSectionNamesData, setValue, readOnlySectionName)
          }
          {
            renderCellName(cellName, setValue)
          }
          {
            renderContent(content, setValue, useHtmlView)
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
            renderCellOrder(cellOrder, setValue)
          }
          {
            formattingMode === 'danger' ? (
                renderFormatting(formatting, setValue)
            ) : (
                <>
                  {renderAttributes(
                      marginTop,
                      marginLeft,
                      marginBottom,
                      marginRight,
                      backgroundColor,
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
                     <button type="button" className="btn btn-bad mb-2 mt-2" onClick={toggleFormatting}>
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
          <div className="row mb-2 mt-5">
            <div className="col-4" id="promptField">
              <p>
                * - Required Fields
              </p>
            </div>
            <div className="col-8">
            </div>
          </div>
          <div className="row mb-2 display-6 center-item text-center">
            <center>Preview</center>
          </div>
          <div className="row mb-2">
            <div id="cellAttributes" className="w-100 border border-danger border-width-8">
              {!isPresent(image) && !isPresent(content) ? (
                  <center><h1>No Contents</h1></center>
              ) : (
                   <RenderCell cell={cellData}/>
               )}
            </div>
          </div>
          <div className="row mb-2">
            <div className="flex-container">
              <button type="button" className="btn btn-primary" accessKey="s" onClick={handleSubmit}>
                Save Cell
              </button>
              <button type="button" className="btn btn-secondary" accessKey="c" onClick={handleCancel}>
                Cancel
              </button>
            </div>
          </div>
        </div>
      </ErrorBoundary>
  );
}

// *** Render Functions ***/

function renderSectionName(sectionName, availableSectionNamesData, setValue, readOnlySectionName) {
  const optionsHash = availableSectionNamesData.map((item) => ({
    label: item,
    value: item,
  }));

  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">*Section Name:</div>
        <div className="col-10">
          <div id="contentTypeDiv">
            {renderSelect("sectionName", sectionName, optionsHash, setValue)}
          </div>
        </div>
      </div>
  );
}

function renderCellName(cellName, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">*Cell Name:</div>
        <div className="col-10">
          <div id="cellNameDiv">
            {
              renderInput(
                  "cellName",
                  cellName,
                  setValue,
                  null,
                  { required: true },
                  "Enter the name for the cell "
              )
            }
          </div>
        </div>
      </div>
  );
}

function renderCellOrder(cellOrder, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Cell Order:</div>
        <div className="col-10">
          <div id="cellOrderDiv">
            {
              renderInput(
                  "cellOrder",
                  cellOrder,
                  setValue,
                  null,
                  {},
                  "Enter the order of the cell (1 is first)",
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
                  label: "Image",
                  value: "Images",
                },
                {
                  label: "Image Group",
                  value: "Groups",
                },
                {
                  label: "Video",
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
                  {},
                  "Enter the URL to be opened when an image is clicked (optional)"
              )
            }
          </div>
        </div>
      </div>
  );
}

function renderContent(content, setValue, useHtmlView = false) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Content:</div>
        <div className="col-10">
          <div id="content">
            <HtmlEditor
                id="content"
                value={content}
                placeholder="Enter the contents of the cell"
                onChange={(value, attribute) => setValue(
                    value,
                    attribute
                )}
                onBlur={(setValue !== null) && ((event) => setValue(event.target.value, id, event.target.dataset.options))}
                useHtmlView={useHtmlView}
                theme="snow"
            />
          </div>
        </div>
      </div>
  );
}

function renderAttributes(marginTop, marginLeft, marginBottom, marginRight, backgroundColor, setValue) {
  const marginTopOptions    = getMarginOptions("top");
  const marginLeftOptions   = getMarginOptions("left");
  const marginBottomOptions = getMarginOptions("bottom");
  const marginRightOptions  = getMarginOptions("right");

  return (
      <>
        <div className="row">
          <div className="col-2 d-flex align-items-center">
            Margin Top:
          </div>
          <div className="col-10">
            {renderSelect("marginTop", marginTop, marginTopOptions, setValue)}
          </div>
        </div>
        <div className="row">
          <div className="col-2 d-flex align-items-center">
            Margin Left:
          </div>
          <div className="col-10">
            {renderSelect("marginLeft", marginLeft, marginLeftOptions, setValue)}
          </div>
        </div>
        <div className="row">
          <div className="col-2 d-flex align-items-center">
            Margin Bottom:
          </div>
          <div className="col-10">
            {renderSelect("marginBottom", marginBottom, marginBottomOptions, setValue)}
          </div>
        </div>
        <div className="row">
          <div className="col-2 d-flex align-items-center">
            Margin Right:
          </div>
          <div className="col-10">
            {renderSelect("marginRight", marginRight, marginRightOptions, setValue)}
          </div>
        </div>
        <div className="row">
          <div className="col-2 d-flex align-items-center">
            Background Color:
          </div>
          <div className="col-10">
            {renderSelect("backgroundColor", backgroundColor, backgroundColors, setValue)}
          </div>
        </div>
      </>
  );
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

function setFormattingElement(cellData, fieldName, regex, newValue, elementType = "classes") {
  const formatting = cellData.formatting;
  const fieldType  = (elementType === "styles") ? "styles" : "classes"

  if (formatting[fieldType]) {
    formatting[fieldType] = formatting[fieldType].replace(regex, "").trim(); // Strip out old Value
    formatting[fieldType] += " " + newValue; // Add new value in
  }
  else {
    formatting[fieldType] = newValue; // Add new value in
  }
}

function setFormattingClassElement(cellData, fieldName, newValue) {
  switch (true) {
    case /mt\-(\d)/.test(newValue):
      setFormattingElement(cellData, fieldName, /mt\-(\d+)/, newValue);
      break;
    case /mb\-(\d)/.test(newValue):
      setFormattingElement(cellData, fieldName, /mb\-(\d+)/, newValue);
      break;
    case /ms\-(\d)/.test(newValue):
      setFormattingElement(cellData, fieldName, /ms\-(\d+)/, newValue);
      break;
    case /me\-(\d)/.test(newValue):
      setFormattingElement(cellData, fieldName, /me\-(\d+)/, newValue);
      break;
    case /col\-\d{1,2}/.test(newValue):
      setFormattingElement(cellData, fieldName, /col\-\d{1,2}/g, newValue);
      break;
  }
}

function setFormattingStyleElement(cellData, fieldName, newValue) {
  switch (true) {
    case /background\-color:\s*(.+)\s*;?/.test(newValue):
      setFormattingElement(
          cellData,
          fieldName,
          /background\-color:\s*(.+)\s*;?/,
          newValue,
          "styles"
      );
      break;
  }
}

function mapReactValuesToCell(cellData, attribute, value, extraParameters) {
  switch (attribute) {
    case "sectionName":
      cellData.section_name = value;
      break;
    case "cellName":
      cellData.cell_name = value;
      break;
    case "cellOrder":
      cellData.cell_order = value;
      break;
    case "image":
      let mode = "Images";

      if (isPresent(extraParameters?.imageMode)) mode = extraParameters?.imageMode;

      switch (mode) {
        case"Groups":
          cellData.image = `ImageGroup:${value}`;
          break;
        case "Cell":
          cellData.image = `ImageCell:"${value}"`;
          break;
        case "Videos":
          cellData.image = `VideoImage:"${value}"`;
          break;
        default:
          cellData.image = `ImageFile:${value}`;
          break;
      }
      break;
    case "link":
      cellData.link = value;
      break;
    case "content":
      cellData.content = value;
      break;
    case "formatting":
      cellData.formatting = value;
      break;
    case 'marginTop':
      setFormattingClassElement(cellData, attribute, value);
      break;
    case 'marginBottom':
      setFormattingClassElement(cellData, attribute, value);
      break;
    case 'marginLeft':
      setFormattingClassElement(cellData, attribute, value);
      break;
    case 'marginRight':
      setFormattingClassElement(cellData, attribute, value);
      break;
    case 'backgroundColor':
      setFormattingStyleElement(cellData, attribute, `background-color: ${value}`);
      break;
    case "useHtmlView":
      let options = cellData.options;

      if (options)
        options["use_html_view"] = value;
      else
        options = { "use_html_view": value };

      cellData.options = options;

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
    case "sectionName":
      return stringOrValue(value);
    case "cellName":
      return value;
    case "cellOrder":
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
    case "content":
      return value;
    case "marginTop":
      return stringOrValue(value);
    case "marginLeft":
      return stringOrValue(value);
    case "marginBottom":
      return stringOrValue(value);
    case "marginRight":
      return stringOrValue(value);
    case "backgroundColor":
      return stringOrValue(value);
    case "useHtmlView":
      return value;
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

CellEditor.propTypes = {
  cell:                  PropTypes.shape({
                                           section_name: PropTypes.string,
                                           cell_name:    PropTypes.string,
                                           cell_order:   PropTypes.number,
                                           content:      PropTypes.string,
                                           image:        PropTypes.string,
                                           link:         PropTypes.string,
                                           formatting:   PropTypes.object,
                                         }),
  availableSectionNames: PropTypes.arrayOf(PropTypes.string),
  availableImages:       PropTypes.arrayOf(PropTypes.string),
  availableImageGroups:  PropTypes.arrayOf(PropTypes.string),
  availableVideos:       PropTypes.arrayOf(PropTypes.string),
  submitPath:            PropTypes.string.isRequired,
  successPath:           PropTypes.string.isRequired,
  cancelPath:            PropTypes.string.isRequired,
  readOnlySectionName:   PropTypes.bool,
  newCell:               PropTypes.bool,
}

export default CellEditor;
