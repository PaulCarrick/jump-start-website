// /app/javascript/components/FormattingEditor.tsx

// Edit Formatting

import { isPresent }                  from "./utilities";
import { renderSelect }               from "./renderControlFunctions";
import { backgroundColors }           from "./backgroundColors";
import React, { useState, useEffect } from "react";

// Define types
interface FormattingEditorProps {
  formatting: Record<string, any>;
  onChange?: (updatedFormatting: Record<string, any>, category: string) => void;
}

const FormattingEditor: React.FC<FormattingEditorProps> = ({ formatting, onChange }) => {
  const [ formattingData, setFormattingData ] = useState<Record<string, any>>(formatting);
  const [ newKey, setNewKey ]                 = useState<string>("");
  const [ newValue, setNewValue ]             = useState<string>("");
  const [ formattingMode, setFormattingMode ] = useState<string>("safe");

  // Pass changes back to the parent component
  useEffect(() => {
    if (onChange) onChange(formattingData, "formatting");
  }, [ formattingData ]);

  const toggleFormatting = () => {
    setFormattingMode(prev => (prev === "safe" ? "danger" : "safe"));
  };

  // Handle input changes for existing key-value pairs
  const handleChange = (value: string, key: string) => {
    setFormattingData((prev) => ({
      ...prev,
      [key]: value,
    }));
  };

  // Handle deleting a key-value pair
  const handleDelete = (key: string) => {
    setFormattingData((prev) => {
      const updatedStyle = { ...prev };
      delete updatedStyle[key];
      return updatedStyle;
    });
  };

  // Handle adding a new key-value pair
  const handleAdd = (key: string) => {
    if (!isPresent(key)) return;
    if (Object.prototype.hasOwnProperty.call(formattingData, key)) return;

    setFormattingData((prev) => ({
      ...prev,
      [key]: "",
    }));
    setNewKey(key);
    setNewValue("");
  };

  // *** Main Render *** //
  return (
      <>
        {
          (formattingMode === 'danger') ?
          renderFormatting(formatting, handleAdd, handleDelete, handleChange)
                                        :
          renderAttributes(formatting, handleChange)
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
      </>
  );
};

// *** Render Functions *** //
function renderFormatting(formatting: Record<string, any>,
                          handleAdd: (key: string) => void,
                          handleDelete: (key: string) => void,
                          handleChange: (value: string, key: string) => void) {
  return (
      <div className="border border-2 border-dark rounded-2 p-3">
        <h3>Current</h3>
        <pre>{JSON.stringify(formatting, null, 2)}</pre>

        <div>
          {renderFieldData(formatting, handleChange, handleDelete)}
          {renderFieldSelect(formatting, handleAdd)}
        </div>
      </div>
  );
}

function renderFieldSelect(formattingData: Record<string, any>, handleChange: (key: string) => void) {
  return (
      <>
        <h3>Add New Entry</h3>
        <div>{renderSelect("formattingField", null, formattingOptions(formattingData), handleChange, "form-control")}</div>
      </>
  );
}
function renderFieldData(
    formattingData: Record<string, any>,
    onChange: (value: string, key: string) => void,
    deleteStyle: (key: string) => void
) {
  return (
      <div>
        {Object.entries(formattingData).map(([ key, value ]) => (
            <div className="row" key={key}>
              <div className="col-3">{key}</div>
              <div className="col-4">{renderEntry(key, value, onChange)}</div>
              <div className="col-2 mb-2">
                <button className="btn btn-danger" onClick={() => deleteStyle(key)}>
                  Delete
                </button>
              </div>
            </div>
        ))}
      </div>
  );
}

function renderEntry(
    styleName: string,
    value: string,
    onChange: (value: string, key: string) => void
) {
  return (
      <input
          type="text"
          id={styleName}
          value={isPresent(value) ? value : ""}
          placeholder={`Enter value for ${styleName}`}
          className="form-control mb-2"
          onChange={(event) => onChange(event.target.value, styleName)}
      />
  );
}

function renderAttributes(formatting: Record<string, any>,
                          setValue: any) {
  const marginTopOptions                           = getMarginOptions("top");
  const marginLeftOptions                          = getMarginOptions("left");
  const marginBottomOptions                        = getMarginOptions("bottom");
  const marginRightOptions                         = getMarginOptions("right");
  const backgroundColor: string | null | undefined = formatting["background-color"];
  const [
          marginTop,
          marginLeft,
          marginBottom,
          marginRight
        ]                                          = getMarginValues(formatting["classes"])

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

// *** Utility Functions *** //

export function formattingOptions(formattingData: Record<string, any>) {
  const fields = [];

  fields.push({ label: "Select an option to add", value: null });

  if (!isPresent(formattingData?.container_classes))
    fields.push({ label: "Container Classes", value: "container_classes" });

  if (!isPresent(formattingData?.classes))
    fields.push({ label: "Classes", value: "classes" });

  if (!isPresent(formattingData?.formatting))
    fields.push({ label: "Styles", value: "styles" });

  if (!isPresent(formattingData?.image_caption))
    fields.push({ label: "Image Caption", value: "image_caption" });

  if (!isPresent(formattingData?.caption_position))
    fields.push({ label: "Image Caption Position", value: "caption_position" });

  if (!isPresent(formattingData?.caption_classes))
    fields.push({ label: "Caption Classes", value: "caption_classes" });

  if (!isPresent(formattingData?.caption_classes))
    fields.push({ label: "Caption Classes", value: "caption_classes" });

  if (!isPresent(formattingData?.expanding_rows))
    fields.push({ label: "Expanding Rows", value: "expanding_rows" });

  if (!isPresent(formattingData?.expanding_cells))
    fields.push({ label: "Expanding Cells", value: "expanding_cells" });

  if (!isPresent(formattingData?.slide_show_images))
    fields.push({ label: "Slide Show Images", value: "slide_show_images" });

  if (!isPresent(formattingData?.slide_show_type))
    fields.push({ label: "Slide Show Type (Prompt)", value: "slide_show_type" });

  return fields;
}

function extractNumber(text: string | null, expression: RegExp) {
  let result: number = 0;

  if (text) {
    const match: RegExpMatchArray | null = text.match(expression)

    if (match) result = Number(match[1]);
  }

  return result;
}

function getMarginValues(classes: string) {
  const top: number    = extractNumber(classes, /mt-\d/);
  const left: number   = extractNumber(classes, /ms-\d/);
  const bottom: number = extractNumber(classes, /mb-\d/);
  const right: number  = extractNumber(classes, /me-\d/);

  return [ top, left, bottom, right ]
}

function getMarginOptions(marginType: "none" | "top" | "bottom" | "left" | "right") {
  const prefixes: Record<typeof marginType, string> = {
    none:   "",
    top:    "mt-",
    bottom: "mb-",
    left:   "ms-",
    right:  "me-",
  };

  const labelPrefixes: Record<typeof marginType, string> = {
    none:   "",
    top:    "Margin Top",
    bottom: "Margin Bottom",
    left:   "Margin Left",
    right:  "Margin Right",
  };

  const prefix = prefixes[marginType];
  const label  = labelPrefixes[marginType];

  return prefix
         ? Array.from({ length: 6 }, (_, i) => ({
        value: `${prefix}${i}`,
        label: i === 0 ? "None" : `${label} - #${i}`,
      }))
         : [];
}

export default FormattingEditor;
