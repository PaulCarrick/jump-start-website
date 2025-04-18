import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// /app/javascript/components/FormattingEditor.tsx
// Edit Formatting
import { isPresent } from "./utilities";
import { renderSelect } from "./renderControlFunctions";
import { backgroundColors } from "./backgroundColors";
import { useState, useEffect } from "react";
const FormattingEditor = ({ formatting, onChange }) => {
    const [formattingData, setFormattingData] = useState(formatting);
    const [newKey, setNewKey] = useState("");
    const [newValue, setNewValue] = useState("");
    const [formattingMode, setFormattingMode] = useState("safe");
    // Pass changes back to the parent component
    useEffect(() => {
        if (onChange)
            onChange(formattingData, "formatting");
    }, [formattingData]);
    const toggleFormatting = () => {
        setFormattingMode(prev => (prev === "safe" ? "danger" : "safe"));
    };
    // Handle input changes for existing key-value pairs
    const handleChange = (value, key) => {
        setFormattingData((prev) => ({
            ...prev,
            [key]: value,
        }));
    };
    // Handle deleting a key-value pair
    const handleDelete = (key) => {
        setFormattingData((prev) => {
            const updatedStyle = { ...prev };
            delete updatedStyle[key];
            return updatedStyle;
        });
    };
    // Handle adding a new key-value pair
    const handleAdd = (key) => {
        if (!isPresent(key))
            return;
        if (Object.prototype.hasOwnProperty.call(formattingData, key))
            return;
        setFormattingData((prev) => ({
            ...prev,
            [key]: "",
        }));
        setNewKey(key);
        setNewValue("");
    };
    // *** Main Render *** //
    return (_jsxs(_Fragment, { children: [(formattingMode === 'danger') ?
                renderFormatting(formatting, handleAdd, handleDelete, handleChange)
                :
                    renderAttributes(formatting, handleChange), _jsxs("div", { className: "row align-items-center", children: [_jsx("div", { className: "col-2" }), _jsx("div", { className: "col-10", children: _jsxs("div", { className: "flext-container", children: [formattingMode === "danger" ? (_jsx("button", { type: "button", onClick: toggleFormatting, className: "btn btn-good mb-2", children: "Switch to Normal Mode" })) : (_jsx("button", { type: "button", className: "btn btn-bad mb-2 mt-2", onClick: toggleFormatting, children: "Switch to Formatting Mode **" })), _jsx("span", { className: "ms-4", children: "** Formatting mode should only be used by users who are familiar with CSS" })] }) })] })] }));
};
// *** Render Functions *** //
function renderFormatting(formatting, handleAdd, handleDelete, handleChange) {
    return (_jsxs("div", { className: "border border-2 border-dark rounded-2 p-3", children: [_jsx("h3", { children: "Current" }), _jsx("pre", { children: JSON.stringify(formatting, null, 2) }), _jsxs("div", { children: [renderFieldData(formatting, handleChange, handleDelete), renderFieldSelect(formatting, handleAdd)] })] }));
}
function renderFieldSelect(formattingData, handleChange) {
    return (_jsxs(_Fragment, { children: [_jsx("h3", { children: "Add New Entry" }), _jsx("div", { children: renderSelect("formattingField", null, formattingOptions(formattingData), handleChange, "form-control") })] }));
}
function renderFieldData(formattingData, onChange, deleteStyle) {
    return (_jsx("div", { children: Object.entries(formattingData).map(([key, value]) => (_jsxs("div", { className: "row", children: [_jsx("div", { className: "col-3", children: key }), _jsx("div", { className: "col-4", children: renderEntry(key, value, onChange) }), _jsx("div", { className: "col-2 mb-2", children: _jsx("button", { className: "btn btn-danger", onClick: () => deleteStyle(key), children: "Delete" }) })] }, key))) }));
}
function renderEntry(styleName, value, onChange) {
    return (_jsx("input", { type: "text", id: styleName, value: isPresent(value) ? value : "", placeholder: `Enter value for ${styleName}`, className: "form-control mb-2", onChange: (event) => onChange(event.target.value, styleName) }));
}
function renderAttributes(formatting, setValue) {
    const marginTopOptions = getMarginOptions("top");
    const marginLeftOptions = getMarginOptions("left");
    const marginBottomOptions = getMarginOptions("bottom");
    const marginRightOptions = getMarginOptions("right");
    const backgroundColor = formatting["background-color"];
    const [marginTop, marginLeft, marginBottom, marginRight] = getMarginValues(formatting["classes"]);
    return (_jsxs(_Fragment, { children: [_jsxs("div", { className: "row", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Margin Top:" }), _jsx("div", { className: "col-10", children: renderSelect("marginTop", marginTop, marginTopOptions, setValue) })] }), _jsxs("div", { className: "row", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Margin Left:" }), _jsx("div", { className: "col-10", children: renderSelect("marginLeft", marginLeft, marginLeftOptions, setValue) })] }), _jsxs("div", { className: "row", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Margin Bottom:" }), _jsx("div", { className: "col-10", children: renderSelect("marginBottom", marginBottom, marginBottomOptions, setValue) })] }), _jsxs("div", { className: "row", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Margin Right:" }), _jsx("div", { className: "col-10", children: renderSelect("marginRight", marginRight, marginRightOptions, setValue) })] }), _jsxs("div", { className: "row", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Background Color:" }), _jsx("div", { className: "col-10", children: renderSelect("backgroundColor", backgroundColor, backgroundColors, setValue) })] })] }));
}
// *** Utility Functions *** //
export function formattingOptions(formattingData) {
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
function extractNumber(text, expression) {
    let result = 0;
    if (text) {
        const match = text.match(expression);
        if (match)
            result = Number(match[1]);
    }
    return result;
}
function getMarginValues(classes) {
    const top = extractNumber(classes, /mt-\d/);
    const left = extractNumber(classes, /ms-\d/);
    const bottom = extractNumber(classes, /mb-\d/);
    const right = extractNumber(classes, /me-\d/);
    return [top, left, bottom, right];
}
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
        ? Array.from({ length: 6 }, (_, i) => ({
            value: `${prefix}${i}`,
            label: i === 0 ? "None" : `${label} - #${i}`,
        }))
        : [];
}
export default FormattingEditor;
