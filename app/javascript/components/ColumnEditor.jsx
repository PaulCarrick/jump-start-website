// /app/javascript/components/ColumnEditor
// noinspection JSUnusedLocalSymbols
// noinspection JSValidateTypes
// noinspection RegExpRedundantEscape

// Component to Edit a column Record

import React, {useState, useEffect, useRef} from "react";
import PropTypes from "prop-types";
import HtmlEditor from "./HtmlEditor";
import {backgroundColors} from "./backgroundColors";
import RenderColumn from "./RenderColumn";
import StylesEditor from "./StylesEditor";
import {renderComboBox, renderSelect, renderInput} from "./renderControlFunctions.jsx";
import {isPresent} from "./getDefaultOptions";
import ErrorBoundary from './ErrorBoundary';
import axios from "axios";

const ColumnEditor = ({
                        column = null,
                        availableSectionNames = null,
                        availableImages = null,
                        availableImageGroups = null,
                        availableVideos = null,
                        submitPath = null,
                        successPath = null,
                        cancelPath = null,
                        readOnlySectionName = false,
                        newColumn = false,
                      }) => {
  // Assign column Record
  const [columnData, setColumnData] = useState(column);

  // Handle case where column is not yet loaded
  useEffect(() => {
    if (!columnData && column) {
      setColumnData(column);
    }
    else if (!columnData) {
      setTimeout(() => {
        window.location.reload();
      }, 1000);
    }
  }, [column, columnData]);

  // Assign Column Attributes
  const [sectionName, setSectionName]          = useState(columnData.section_name);
  const [columnName, setColumnName]            = useState(columnData.column_name);
  const [columnOrder, setColumnOrder]          = useState(columnData.column_order);
  const [content, setContent]                  = useState(columnData.content);
  const [image, setImage]                      = useState(columnData.image);
  const [link, setLink]                        = useState(columnData.link);
  const [options, setOptions]                  = useState(columnData.options ? columnData.options : {});
  const [useHtmlView, setUseHtmlView]          = useState((columnData.options && ('use_html_view' in options)) ? columnData.options.use_html_view : null);
  const [formatting, setFormatting]            = useState(columnData.formatting ? columnData.formatting : {});
  const [marginTop, setMarginTop]              = useState((columnData.formatting && ('margin_top' in formatting)) ? columnData.formatting.margin_top : null);
  const [marginLeft, setMarginLeft]            = useState((columnData.formatting && ('margin_left' in formatting)) ? columnData.formatting.margin_left : null);
  const [marginBottom, setMarginBottom]        = useState((columnData.formatting && ('margin_bottom' in formatting)) ? columnData.formatting.margin_bottom : null);
  const [marginRight, setMarginRight]          = useState((columnData.formatting && ('margin_right' in formatting)) ? columnData.formatting.margin_right : null);
  const [backgroundColor, settBackgroundColor] = useState((columnData.formatting && ('background_color' in formatting)) ? columnData.formatting.background_color : null);
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
    columnName:      setColumnName,
    columnOrder:     setColumnOrder,
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

  const columnToPostData = (columnData, prefix = "column") => {
    const result         = {};
    const skipParameters = ["id", "created_at", "updated_at"];
    result[prefix]       = {};

    for (const key in columnData) {
      if (!skipParameters.includes(key)) {
        if (key === "content") {
          if (window.htmlEditorStates["content"]?.useHtmlView) {
            const textField = document.getElementById("content_text");

            if (columnData.options)
              columnData.options["use_html_view"] = true

            if (textField) {
              const html   = textField.value;
              const parser = new DOMParser();
              const parsed = parser.parseFromString(html, "text/html");

              if (!parsed.querySelector("parsererror")) {
                columnData[key] = html;
              }
              else {
                setError(`Error the content does not contain valid html. Please correct it and try again.`);
                return null;
              }
            }
          }
          else {
            if (columnData.options)
              columnData.options["use_html_view"] = false
          }
        }

        result[prefix][key] = columnData[key];
      }
    }

    return result;
  }

  const handleSubmit = () => {
    const data = columnToPostData(columnData);

    if (data === null)
      return

    if (isPresent(columnData?.id) && (columnData?.id != 0)) { // We are updating
      axios.put(submitUrl, data, {
        headers: {
          "Content-Type": "application/json",
          "Accept":       "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        }
      })
           .then(response => {
             sessionStorage.setItem('flashMessage', 'Column updated successfully!');
             window.location.href = successUrl;
           })
           .catch(error => {
             setError(`Error updating column: ${error.response || error.message}`);
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

             sessionStorage.setItem('flashMessage', 'Column created successfully!');
             window.location.href = url;
           })
           .catch(error => {
             setError(`Error creating column: ${error.message}`);
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

    mapReactValuesToColumn(
        columnData,
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
            renderColumnName(columnName, setValue)
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
            renderColumnOrder(columnOrder, setValue)
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
            <div id="columnAttributes" className="w-100 border border-danger border-width-8">
              {!isPresent(image) && !isPresent(content) ? (
                  <center><h1>No Contents</h1></center>
              ) : (
                   <RenderColumn column={columnData}/>
               )}
            </div>
          </div>
          <div className="row mb-2">
            <div className="flex-container">
              <button type="button" className="btn btn-primary" accessKey="s" onClick={handleSubmit}>
                Save Column
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

function renderColumnName(columnName, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">*Column Name:</div>
        <div className="col-10">
          <div id="columnNameDiv">
            {
              renderInput(
                  "columnName",
                  columnName,
                  setValue,
                  null,
                  { required: true },
                  "Enter the name for the column "
              )
            }
          </div>
        </div>
      </div>
  );
}

function renderColumnOrder(columnOrder, setValue) {
  return (
      <div className="row mb-2">
        <div className="col-2 d-flex align-items-center">Column Order:</div>
        <div className="col-10">
          <div id="columnOrderDiv">
            {
              renderInput(
                  "columnOrder",
                  columnOrder,
                  setValue,
                  null,
                  {},
                  "Enter the order of the column (1 is first)",
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
                placeholder="Enter the contents of the column"
                onChange={(value) => setValue(
                    value,
                    "content"
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

function setFormattingElement(columnData, fieldName, regex, newValue, elementType = "classes") {
  const formatting = columnData.formatting;
  const fieldType  = (elementType === "styles") ? "styles" : "classes"

  if (formatting[fieldType]) {
    formatting[fieldType] = formatting[fieldType].replace(regex, "").trim(); // Strip out old Value
    formatting[fieldType] += " " + newValue; // Add new value in
  }
  else {
    formatting[fieldType] = newValue; // Add new value in
  }
}

function setFormattingClassElement(columnData, fieldName, newValue) {
  switch (true) {
    case /mt\-(\d)/.test(newValue):
      setFormattingElement(columnData, fieldName, /mt\-(\d+)/, newValue);
      break;
    case /mb\-(\d)/.test(newValue):
      setFormattingElement(columnData, fieldName, /mb\-(\d+)/, newValue);
      break;
    case /ms\-(\d)/.test(newValue):
      setFormattingElement(columnData, fieldName, /ms\-(\d+)/, newValue);
      break;
    case /me\-(\d)/.test(newValue):
      setFormattingElement(columnData, fieldName, /me\-(\d+)/, newValue);
      break;
    case /col\-\d{1,2}/.test(newValue):
      setFormattingElement(columnData, fieldName, /col\-\d{1,2}/g, newValue);
      break;
  }
}

function setFormattingStyleElement(columnData, fieldName, newValue) {
  switch (true) {
    case /background\-color:\s*(.+)\s*;?/.test(newValue):
      setFormattingElement(
          columnData,
          fieldName,
          /background\-color:\s*(.+)\s*;?/,
          newValue,
          "styles"
      );
      break;
  }
}

function mapReactValuesToColumn(columnData, attribute, value, extraParameters) {
  switch (attribute) {
    case "sectionName":
      columnData.section_name = value;
      break;
    case "columnName":
      columnData.column_name = value;
      break;
    case "columnOrder":
      columnData.column_order = value;
      break;
    case "image":
      let mode = "Images";

      if (isPresent(extraParameters?.imageMode)) mode = extraParameters?.imageMode;

      switch (mode) {
        case"Groups":
          columnData.image = `ImageGroup:${value}`;
          break;
        case "Column":
          columnData.image = `ImageColumn:"${value}"`;
          break;
        case "Videos":
          columnData.image = `VideoImage:"${value}"`;
          break;
        default:
          columnData.image = `ImageFile:${value}`;
          break;
      }
      break;
    case "link":
      columnData.link = value;
      break;
    case "content":
      columnData.content = value;
      break;
    case "formatting":
      columnData.formatting = value;
      break;
    case 'marginTop':
      setFormattingClassElement(columnData, attribute, value);
      break;
    case 'marginBottom':
      setFormattingClassElement(columnData, attribute, value);
      break;
    case 'marginLeft':
      setFormattingClassElement(columnData, attribute, value);
      break;
    case 'marginRight':
      setFormattingClassElement(columnData, attribute, value);
      break;
    case 'backgroundColor':
      setFormattingStyleElement(columnData, attribute, `background-color: ${value}`);
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
    case "columnName":
      return value;
    case "columnOrder":
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

ColumnEditor.propTypes = {
  column:                PropTypes.shape({
                                           section_name: PropTypes.string,
                                           column_name:  PropTypes.string,
                                           column_order: PropTypes.number,
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
  newColumn:             PropTypes.bool,
}

export default ColumnEditor;
