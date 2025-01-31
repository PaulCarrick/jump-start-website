// /app/javascript/components/SelectControl.jsx

import React from "react";
import PropTypes from "prop-types";

const SelectControl = ({
                         id = "",
                         value = "",
                         optionsHash = {},
                         onChange = null
                       }) => {
  const handleChange = (event) => {
    const selectedValue = event.target.value;

    if (onChange) onChange(selectedValue, id);
  };

  return (
    <select
      id={id}
      value={value}
      onChange={handleChange}
      className="form-control"
    >
      {optionsHash.map((option) => (
        <option key={option.value} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
  );
};

SelectControl.propTypes = {
  id: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]), // Matches optionsHash.value type
  optionsHash: PropTypes.arrayOf(
    PropTypes.shape({
                      value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
                      label: PropTypes.string.isRequired,
                    })

  ).isRequired,
  onChange: PropTypes.func,
};

export default SelectControl;
