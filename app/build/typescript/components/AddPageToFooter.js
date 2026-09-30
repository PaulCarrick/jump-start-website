import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// app/javascript/components/AddPageToFooter.tsx
import { useState } from "react";
import { renderInput, renderSelect } from "./renderControlFunctions";
import { isPresent } from "./utilities";
import { getFooterItems } from "../services/footerItemService";
const AddPageToFooter = ({ pageName, onChanged, pageTitle = null, currentFooterItem = null, setError = null }) => {
    const [addToFooter, setAddToFooter] = useState(currentFooterItem !== null);
    const [footerItem, setFooterItem] = useState(currentFooterItem);
    const populateFooterItems = () => {
        const items = getFooterItems(null, null, setError);
        if (items)
            return items;
        else
            return [];
    };
    const getFooterOptions = (items) => {
        const footerOptions = [{ label: "Root", value: -1 }];
        if (items && isPresent(items)) {
            items.forEach((item) => {
                if (item.label && item.id != null) {
                    footerOptions.push({ label: item.label, value: item.id });
                }
            });
        }
        return footerOptions;
    };
    const footerItems = populateFooterItems();
    const footerOptions = getFooterOptions(footerItems);
    const createFooterItem = () => {
        return {
            label: footerItem?.label || pageTitle || pageName,
            link: footerItem?.link || `/${pageName}`,
            parent_id: footerItem?.parent_id,
            footer_order: footerItem?.footer_order
        };
    };
    const setValue = (newValue, attribute) => {
        switch (attribute) {
            case "addToFooter": {
                const add = newValue;
                setAddToFooter(add);
                if (!add) {
                    onChanged(null, "footer_item");
                }
                else if (!footerItem) {
                    const newItem = createFooterItem();
                    setFooterItem(newItem);
                    onChanged(newItem, "footer_item");
                }
                break;
            }
            case "parent_id": {
                if (newValue === null || newValue === "null" || isNaN(Number(newValue)))
                    newValue = null;
                else
                    newValue = Number(newValue);
                const item = footerItems.find(item => item.id === newValue);
                let footerOrder = 1;
                if (item && item?.sub_items)
                    footerOrder = item.sub_items.length + 1;
                setFooterItem(prev => {
                    const updated = {
                        ...prev,
                        footer_order: footerOrder,
                        [attribute]: newValue,
                    };
                    onChanged(updated, "footer_item");
                    return updated;
                });
                break;
            }
            case "footer_order": {
                if (newValue === null || newValue === "null" || isNaN(Number(newValue)))
                    newValue = null;
                else
                    newValue = Number(newValue);
                setFooterItem(prev => {
                    const updated = {
                        ...prev,
                        [attribute]: newValue,
                    };
                    onChanged(updated, "footer_item");
                    return updated;
                });
                break;
            }
            default: {
                setFooterItem(prev => {
                    const updated = {
                        ...prev,
                        [attribute]: newValue,
                    };
                    onChanged(updated, "footer_item");
                    return updated;
                });
                break;
            }
        }
    };
    //*** Main Render Routine ***//
    return (_jsxs(_Fragment, { children: [_jsx("div", { className: "row mb-2", children: _jsx("div", { className: "col-2", children: _jsxs("label", { htmlFor: "addToFooter", className: "form-check-label", children: ["Add to footer", _jsx("input", { type: "checkbox", id: "addToFooter", checked: addToFooter, onChange: (e) => setValue(e.target.checked, "addToFooter"), className: "form-check-input ms-2", style: { position: "relative", top: "2px" } })] }) }) }), addToFooter && (_jsxs("div", { className: "mt-2", children: [_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Add to what footer:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "footerItemDiv", className: "w-100", children: renderSelect("parent_id", footerItem?.parent_id, footerOptions, setValue, "form-control") }) })] }), _jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Footer Order:" }), _jsx("div", { className: "col-5", children: renderInput("footer_order", footerItem?.footer_order, setValue, null, {}, "Please enter the footer order.", "number") })] })] }))] }));
};
export default AddPageToFooter;
