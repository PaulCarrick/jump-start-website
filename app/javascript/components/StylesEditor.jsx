// /app/javascript/components/StylesEditor

import React, {useState, useEffect} from 'react';
import {isPresent, rowStyleOptions, ratioOptions, formattingOptions} from "./getDefaultOptions";
import {renderInput, renderSelect} from "./renderControlFunctions.jsx";
import PropTypes from "prop-types";

const StylesEditor = ({ styles, onChange }) => {
  const [styleData, setStyleData] = useState(styles);
  const [newKey, setNewKey]       = useState('');
  const [newValue, setNewValue]   = useState('');

  // Pass changes back to caller
  useEffect(() => {
    if (onChange) onChange(styleData, "formatting");
  }, [styleData]);

  // Handle input changes for existing key-value pairs
  const handleChange = (value, key) => {
    setStyleData({
                   ...styleData,
                   [key]: value,
                 });
  };

  // Handle deleting a key-value pair
  const handleDelete = (key) => {
    const updatedStyle = { ...styleData };
    delete updatedStyle[key];
    setStyleData(updatedStyle);
  };

  // Handle adding a new key-value pair
  const handleAdd = (key) => {
    if (!isPresent(key)) return;
    if (styleData.hasOwnProperty(key)) return;

    setStyleData({
                   ...styleData,
                   [key]: "",
                 });
    setNewKey(key);
    setNewValue("");
  };

  return (
      <div className="border border-2 border-dark rounded-2 p-3">
        <h3>Current</h3>
        <pre>{JSON.stringify(styleData, null, 2)}</pre>

        <div>
          {renderFieldData(styleData, handleChange, handleDelete)}
          {renderFieldSelect(styleData, handleAdd)}
        </div>
      </div>
  );
};

function renderFieldData(styleData, onChange, deleteStyle) {
  return (
      <div>
        {Object.entries(styleData).map(([key, value]) => (
            <div className="row" key={key}>
              <div className="col-3">
                {key}
              </div>
              <div className="col-4">
                {renderEntry(styleData, key, value, onChange)}
              </div>
              <div className="col-2 mb-2">
                <button className="btn btn-danger" onClick={() => deleteStyle(key)}>Delete</button>
              </div>
            </div>
        ))}
      </div>
  );
}

function renderEntry(styleData, styleName, value, onChange) {
  switch (styleName) {
    case 'row_style':
      return renderSelect(styleName, value, rowStyleOptions(), onChange, "mb-2 form-control");
    case 'div_ratio':
      return renderSelect(styleName, value, ratioOptions(true), onChange, "mb-2 form-control");
    default:
      return renderInput(styleName, value, onChange, null, `Enter a value for ${styleName}`, "text", "mb-2 form-control");
  }
}

function renderFieldSelect(styleData, handleChange) {
  return (
      <>
        <h3>Add New Entry</h3>
        <div>
          {renderSelect("formattingField", null, formattingOptions(styleData), handleChange, "form-control")}
        </div>
      </>
  );
}

StylesEditor.propTypes = {
  styles: PropTypes.object.isRequired,
  onChange: PropTypes.func,
};

export default StylesEditor;
