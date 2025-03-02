// /app/javascripts/components/renderControlFunctions.jsx

import React from "react";
import Select from "react-select";
import {isPresent} from "./getDefaultOptions.jsx";

export function renderComboBox(id, value, optionsHash, setValue, readOnly = false, dataOptions = {}) {
  return (
      <Select
          inputId={id}
          value={
              optionsHash.find((opt) => opt.value === value) ||
              (value ? { label: value, value } : null)
          }
          options={optionsHash}
          disabled={readOnly}
          data-options={dataOptions}
          onChange={(newValue, actionMeta) => {
            if (readOnly) return;

            setValue(newValue?.value || "", id);
          }}
          onInputChange={(newInputValue, actionMeta) => {
            if (readOnly) return;

            if (actionMeta.action === "input-change") {
              setValue(newInputValue, id); // Update the value state with typed input
            }
          }}
          isSearchable={!readOnly}
          isClearable={!readOnly}
          placeholder="Select or type..."
      />
  );
}

export function renderSelect(id, value, options, setValue, controlClass = "form-control", dataOptions = {}) {
  return (
      <select
          id={id}
          value={isPresent(value) ? value : ""}
          className={controlClass}
          data-options={dataOptions}
          onChange={(event) => setValue(event.target.value, id)}
      >
        <option value="">Select an option</option>
        {options.map((option, index) => (
            <option key={index} value={option.value}>
              {option.label}
            </option>
        ))}
      </select>
  );
}

export function renderInput(
    id, value, onChange = null, onBlur = null, options = {}, placeHolder = "Please enter a value", type = "text",
    controlClass                                                                                        = "form-control", dataOptions = {}
) {
  const getBooleanOption = (option) => {
    let result = false;

    if (option && options && options.hasOwnProperty(option))
      result = options[option]

    return result;
  }

  if (onBlur)
    return (
        <input
            type={type}
            id={id}
            value={isPresent(value) ? value : ""}
            placeholder={placeHolder}
            className={controlClass}
            data-options={dataOptions}
            required={getBooleanOption("required")}
            readOnly={getBooleanOption("readOnly")}
            onChange={(event) => onChange(event.target.value, id, event.target.dataset.options)}
            onBlur={(onBlur !== null) && ((event) => onBlur(event.target.value, id, event.target.dataset.options))}
        />
    );
  else
    return (
        <input
            type={type}
            id={id}
            value={isPresent(value) ? value : ""}
            placeholder={placeHolder}
            className={controlClass}
            data-options={dataOptions}
            required={getBooleanOption("required")}
            readOnly={getBooleanOption("readOnly")}
            onChange={(event) => onChange(event.target.value, id, event.target.dataset.options)}
        />
    );
}

