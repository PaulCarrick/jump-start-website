// /app/javascript/components/RenderControl.jsx
// noinspection JSUnusedLocalSymbols

import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import EditableComboBox from "./EditableComboBox";
import SelectControl from "./SelectControl";
import HtmlEditor from "./HtmlEditor";

const RenderControl = ({
                         controlType = "textField",
                         options = {},
                       }) => {
  const [fieldOptions, setFieldOptions] = useState([]);

  const onChange = options.onChange;
  const onBlur = options.onBlur;

  // Update fieldOptions whenever options or controlType changes
  useEffect(() => {
    setFieldOptions(setupOptions(options, controlType));
  }, [options, controlType]);

  const handleChange = (value) => {
    if (onChange) onChange(value, options.id);
  };

  const handleBlur = (value) => {
    if (onBlur) onBlur(value, options.id);
  };

  switch (controlType) {
    case "textField":
      return renderTextField(fieldOptions, handleChange, handleBlur);
    case "numericField":
      return renderNumericField(fieldOptions, handleChange, handleBlur);
    case "textAreaField":
      return renderTextAreaField(fieldOptions, handleChange, handleBlur);
    case "editorField":
      return renderEditorField(fieldOptions, handleChange, handleBlur);
    case "comboBoxField":
      return renderComboBoxField(fieldOptions, handleChange, handleBlur);
    case "selectField":
      return renderSelectField(fieldOptions, handleChange, handleBlur);
    case "checkBoxField":
      return renderCheckboxField(fieldOptions, handleChange, handleBlur);
    default:
      return null;
  }
};

function renderTextField(options, handleChange, handleBlur) {
  return (
      <input
          type="text"
          id={options.id}
          value={options.value}
          required={options.required}
          readOnly={options.readOnly}
          disabled={options.disabled}
          placeholder={options.placeholder}
          className={options.class}
          onChange={(e) => handleChange(e.target.value)}
          onBlur={(handleBlur !== null) && ((e) => handleBlur(e.target.value))}
          minLength={options.minLength}
          maxLength={options.maxLength}
          pattern={options.pattern}
      />
  );
}

function renderNumericField(options, handleChange, handleBlur) {
  return (
      <input
          type="number"
          id={options.id}
          value={options.value}
          required={options.required}
          readOnly={options.readOnly}
          disabled={options.disabled}
          placeholder={options.placeholder}
          className={options.class}
          onChange={(e) => handleChange(e.target.value)}
          onBlur={(e) => handleBlur(e.target.value)}
          min={options.min}
          max={options.max}
          step={options.step}
      />
  );
}

function renderTextAreaField(options, handleChange, handleBlur) {
  return (
      <textarea
          id={options.id}
          value={options.value}
          required={options.required}
          readOnly={options.readOnly}
          disabled={options.disabled}
          placeholder={options.placeholder}
          className={options.class}
          onChange={(e) => handleChange(e.target.value)}
          onBlur={(e) => handleBlur(e.target.value)}
          minLength={options.minLength}
          maxLength={options.maxLength}
          rows={options.rows}
          cols={options.cols}
      />
  );
}

function renderEditorField(options, handleChange, handleBlur) {
  return (
      <HtmlEditor
          id={options.id}
          value={options.value}
          required={options.required}
          readOnly={options.readOnly}
          disabled={options.disabled}
          placeholder={options.placeholder}
          className={options.class}
          onChange={(e) => handleChange(e.target.value)}
          onBlur={(e) => handleBlur(e.target.value)}
          theme={options.theme}
      />
  );
}

function renderComboBoxField(options, handleChange, handleBlur) {
  return (
      <EditableComboBox
          id={options.id}
          value={options.value}
          className={options.class}
          optionsHash={options.options}
          onChange={(option) => handleChange(option)}
          onBlur={(e) => handleBlur(e.target.value)}
      />
  );
}

function renderSelectField(options, handleChange, handleBlur) {
  return (
      <SelectControl
          id={options.id}
          value={options.value}
          className={options.class}
          optionsHash={options.options}
          onChange={(option) => handleChange(option)}
          onBlur={(option) => handleBlur(option)}
      />
  );
}

function renderCheckboxField(options, handleChange, handleBlur) {
  return (
      <input
          type="checkbox"
          id={options.id}
          value={options.value}
          readOnly={options.readOnly}
          className={options.class}
          onChange={(e) => handleChange(e.target.value)}
          onBlur={(e) => handleBlur(e.target.value)}
      />
  );
}

function setupOptions(options, controlType) {
  let results = {};

  switch (controlType) {
    case "textField":
      results = setupTextOptions(options);
      break;
    case "numericField":
      results = setupNumericOptions(options);
      break;
    case "textAreaField":
      results = setupTextAreaOptions(options);
      break;
    case "editorField":
      results = setupEditorOptions(options);
      break;
    case "comboBoxField":
    case "selectField":
      results = setupSelectOptions(options);
      break;
    case "checkBoxField":
      results = setupCheckboxOptions(options);
      break;
    default:
      break;
  }

  return results;
}

function setupTextOptions(options) {
  return {
    id: options.id,
    value: options.value,
    class: options.class,
    required: !!options.required,
    readOnly: !!options.readOnly,
    disabled: !!options.disabled,
    placeholder: options.placeholder || null,
    minLength: options.minLength || 0,
    maxLength: options.maxLength || 999999,
    pattern: options.pattern || null,
  };
}

function setupNumericOptions(options) {
  return {
    id: options.id,
    value: options.value,
    class: options.class,
    required: !!options.required,
    readOnly: !!options.readOnly,
    disabled: !!options.disabled,
    placeholder: options.placeholder || null,
    min: options.min || 0,
    max: options.max || 999999,
    step: options.step || 1,
  };
}

function setupTextAreaOptions(options) {
  return {
    id: options.id,
    value: options.value,
    class: options.class,
    required: !!options.required,
    readOnly: !!options.readOnly,
    placeholder: options.placeholder || null,
    disabled: !!options.disabled,
    minLength: options.minLength || null,
    maxLength: options.maxLength || null,
    rows: options.rows || 5,
    cols: options.cols || null,
    resize: options.resize || null,
  };
}

function setupEditorOptions(options) {
  return {
    id: options.id,
    value: options.value,
    class: options.class,
    required: !!options.required,
    readOnly: !!options.readOnly,
    disabled: !!options.disabled,
    placeholder: options.placeholder || null,
    theme: options.theme || "snow",
  };
}

function setupSelectOptions(options) {
  return {
    id: options.id,
    value: options.value,
    class: options.class,
    required: !!options.required,
    disabled: !!options.disabled,
    autofocus: !!options.autofocus,
    multiple: !!options.multiple,
    size: options.size || null,
    options: options.options,
  };
}

function setupCheckboxOptions(options) {
  return {
    id: options.id,
    value: options.value,
    class: options.class,
    checked: !!options.checked,
    disabled: !!options.disabled,
    readOnly: !!options.readOnly,
  };
}

RenderControl.propTypes = {
  controlType: PropTypes.oneOf([
    "textField",
    "numericField",
    "textAreaField",
    "editorField",
    "comboBoxField",
    "selectField",
    "checkBoxField",
  ]).isRequired,
  options: PropTypes.object.isRequired,
};

export default RenderControl;
