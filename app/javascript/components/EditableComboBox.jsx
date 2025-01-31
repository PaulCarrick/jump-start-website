// /app/javascript/components/EditableComboBox.jsx

import React, {useState, useEffect} from "react";
import PropTypes from "prop-types";
import Select from "react-select";

const EditableComboBox = ({
                            id = "",
                            value = null,
                            optionsHash = [{}],
                            onChange = null,
                            inputCallback = null
                          }) => {
  const [options, setOptions] = useState([...optionsHash]);

  useEffect(() => {
              let transformedOptions = null;

              if (typeof optionsHash === "string") {
                transformedOptions = JSON.parse(optionsHash);
              }
              else if (Array.isArray(optionsHash) &&
                       (typeof (optionsHash) === "string")) {
                transformedOptions = optionsHash.map((item) => (
                    {
                      label: item,
                      value: item
                    }))
              }
              else if (Array.isArray(optionsHash)) {
                transformedOptions = optionsHash
              }

              setOptions(transformedOptions);
            }
      ,
            [optionsHash]
  );

  const handleInputChange = (inputValue) => {
    if (inputValue && !options.some((opt) => opt.value === inputValue)) {
      setOptions((prevOptions) => [
        ...prevOptions, {
          value: inputValue,
          label: inputValue
        }
      ]);
    }

    if (inputCallback) inputCallback(inputValue, id);
  };

  return (
      <Select
          inputId={id}
          value={options.find((opt) => opt.value === value) || null}
          options={options}
          onChange={(selectedOption) => onChange?.(selectedOption, id)}
          onInputChange={handleInputChange}
          isSearchable
          isClearable
          placeholder="Select or type..."
      />
  );
};

EditableComboBox.propTypes = {
  id:            PropTypes.string.isRequired,
  value:         PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  optionsHash:   PropTypes.any,
  onChange:      PropTypes.func,
  inputCallback: PropTypes.func,
};

export default EditableComboBox;
