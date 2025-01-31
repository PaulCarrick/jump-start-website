// /app/javascript/components/SectionAttributes.jsx

import React, {useState, useEffect} from "react";
import PropTypes from "prop-types";
import SelectControl from "./SelectControl";
import EditableComboBox from "./EditableComboBox";
import {backgroundColors} from "./backgroundColors";

const SectionAttributes = ({
                               attributes = {},
                               onAttributesChange = null}) => {
  const [ marginTop, setMarginTop ] = useState(attributes.marginTop || "");
  const [ marginLeft, setMarginLeft ] = useState(attributes.marginLeft || "");
  const [ marginRight, setMarginRight ] = useState(attributes.marginRight || "");
  const [ marginBottom, setMarginBottom ] = useState(attributes.marginBottom || "");
  const [ backgroundColor, setBackgroundColor ] = useState(attributes.backgroundColor || "");

  const marginTopOptions = getMarginOptions("top");
  const marginBottomOptions = getMarginOptions("bottom");
  const marginLeftOptions = getMarginOptions("left");
  const marginRightOptions = getMarginOptions("right");

  const attributeSetters = {
    marginTop: setMarginTop,
    marginLeft: setMarginLeft,
    marginRight: setMarginRight,
    marginBottom: setMarginBottom,
    backgroundColor: setBackgroundColor,
  };

  const setValue = (newValue, attribute) => {
    const setter = attributeSetters[attribute];

    if (setter) {
      if (typeof (newValue) === 'string')
        setter(newValue);
      else
        setter(newValue.value);
    }
  };

  // Notify parent of attribute changes
  useEffect(() => {
    onAttributesChange?.({
                           marginTop,
                           marginLeft,
                           marginRight,
                           marginBottom,
                           backgroundColor,
                         });
  }, [ marginTop, marginLeft, marginRight, marginBottom, backgroundColor, onAttributesChange ]);

  const renderControl = (label,
                         id,
                         value,
                         options,
                         controlType) => {
    if (controlType === 'combobox') {
      return (
        <div className="d-flex align-items-center">
          <label htmlFor={id} className="me-2 mb-0 text-nowrap">{label}:</label>
          <EditableComboBox
            id={id}
            value={value}
            optionsHash={options}
            onChange={(value, attribute) => setValue(value, attribute)}
            onInput={(value, attribute) => setValue(value, attribute)}
          />
        </div>
      );
    }
    else {
      return (
        <div className="d-flex align-items-center">
          <label htmlFor={id} className="me-2 mb-0 text-nowrap">{label}:</label>
          <SelectControl
            id={id}
            value={value}
            optionsHash={options}
            onChange={(value, attribute) => setValue(value, attribute)}
          />
        </div>
      );
    }
  };

  const margins = `border border-danger border-width-8 ${marginTop} ${marginLeft} ${marginRight} ${marginBottom}`;

  return (
    <div className="border border-dark border-width-8"
         style={{minWidth: "100%", backgroundColor: "white"}}>
      <div className={`${margins}`} style={{backgroundColor}}>
        <div className="row align-items-center justify-content-center mb-3"
             style={{whiteSpace: "nowrap"}}>
          <div className="col-auto">
            {
              renderControl("Top Margin",
                            "marginTop",
                            marginTop,
                            marginTopOptions,
                            'select')
            }
          </div>
        </div>
        <div className="distributed-row mb-3">
          <div
            style={{whiteSpace: "nowrap", marginLeft: "5px", maxWidth: "17em"}}>
            {
              renderControl("Left Margin",
                            "marginLeft",
                            marginLeft,
                            marginLeftOptions,
                            'select')
            }
          </div>
          <div>
            {
              renderControl("Background Color",
                            "backgroundColor",
                            backgroundColor,
                            backgroundColors,
                            'combobox')
            }
          </div>
          <div style={{whiteSpace: "nowrap", maxWidth: "18em"}}>
            {
              renderControl("Right Margin",
                            "marginRight",
                            marginRight,
                            marginRightOptions,
                            'select')
            }
          </div>
        </div>
        <div className="row align-items-center justify-content-center"
             style={{whiteSpace: "nowrap"}}>
          <div className="col-auto">
            {
              renderControl("Bottom Margin",
                            "marginBottom",
                            marginBottom,
                            marginBottomOptions,
                            'select')
            }
          </div>
        </div>
      </div>
    </div>
  );
};

function getMarginOptions(marginType) {
  const prefixes = {
    none: "",
    top: "mt-",
    bottom: "mb-",
    left: "ms-",
    right: "me-",
  };

  const labelPrefixes = {
    none: "",
    top: "Margin Top",
    bottom: "Margin Bottom",
    left: "Margin Left",
    right: "Margin Right",
  };

  const prefix = prefixes[marginType];
  const label = labelPrefixes[marginType];

  return prefix
         ? Array.from({length: 5}, (_, i) => ({
      value: `${prefix}${i + 1}`,
      label: `${label} - #${i + 1}`,
    }))
         : [];
}

SectionAttributes.propTypes = {
  attributes: PropTypes.shape({
                                marginTop: PropTypes.string,
                                marginLeft: PropTypes.string,
                                marginRight: PropTypes.string,
                                marginBottom: PropTypes.string,
                                backgroundColor: PropTypes.string,
                              }).isRequired,
  onAttributesChange: PropTypes.func,
};

export default SectionAttributes;
