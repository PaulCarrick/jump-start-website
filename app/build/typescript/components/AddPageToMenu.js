import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// app/javascript/components/AddPageToMenu.tsx
import { useState } from "react";
import { renderInput, renderSelect } from "./renderControlFunctions";
import { isPresent } from "./utilities";
import { getMenuItems } from "../services/menuItemService";
const AddPageToMenu = ({ pageName, onChanged, pageTitle = null, currentMenuItem = null, setError = null }) => {
    const [addToMenu, setAddToMenu] = useState(currentMenuItem !== null);
    const [menuItem, setMenuItem] = useState(currentMenuItem);
    const populateMenuItems = () => {
        const items = getMenuItems(null, null, setError);
        if (items)
            return items;
        else
            return [];
    };
    const getMenuOptions = (items) => {
        const menuOptions = [{ label: "Root", value: -1 }];
        if (items && isPresent(items)) {
            items.forEach((item) => {
                if (item.label && item.id != null) {
                    menuOptions.push({ label: item.label, value: item.id });
                }
            });
        }
        return menuOptions;
    };
    const menuItems = populateMenuItems();
    const menuOptions = getMenuOptions(menuItems);
    const createMenuItem = () => {
        return {
            label: menuItem?.label || pageTitle || pageName,
            menu_type: menuItem?.menu_type || "Main",
            link: menuItem?.link || `/${pageName}`,
            parent_id: menuItem?.parent_id,
            menu_order: menuItem?.menu_order
        };
    };
    const setValue = (newValue, attribute) => {
        switch (attribute) {
            case "addToMenu": {
                const add = newValue;
                setAddToMenu(add);
                if (!add) {
                    onChanged(null, "menu_item");
                }
                else if (!menuItem) {
                    const newItem = createMenuItem();
                    setMenuItem(newItem);
                    onChanged(newItem, "menu_item");
                }
                break;
            }
            case "parent_id": {
                if (newValue === null || newValue === "null" || isNaN(Number(newValue)))
                    newValue = null;
                else
                    newValue = Number(newValue);
                const item = menuItems.find(item => item.id === newValue);
                let menuOrder = 1;
                if (item && item?.sub_items)
                    menuOrder = item.sub_items.length + 1;
                setMenuItem(prev => {
                    const updated = {
                        ...prev,
                        menu_order: menuOrder,
                        [attribute]: newValue,
                    };
                    onChanged(updated, "menu_item");
                    return updated;
                });
                break;
            }
            case "menu_order": {
                if (newValue === null || newValue === "null" || isNaN(Number(newValue)))
                    newValue = null;
                else
                    newValue = Number(newValue);
                setMenuItem(prev => {
                    const updated = {
                        ...prev,
                        [attribute]: newValue,
                    };
                    onChanged(updated, "menu_item");
                    return updated;
                });
                break;
            }
            default: {
                setMenuItem(prev => {
                    const updated = {
                        ...prev,
                        [attribute]: newValue,
                    };
                    onChanged(updated, "menu_item");
                    return updated;
                });
                break;
            }
        }
    };
    //*** Main Render Routine ***//
    return (_jsxs(_Fragment, { children: [_jsx("div", { className: "row mb-2", children: _jsx("div", { className: "col-2", children: _jsxs("label", { htmlFor: "addToMenu", className: "form-check-label", children: ["Add to menu", _jsx("input", { type: "checkbox", id: "addToMenu", checked: addToMenu, onChange: (e) => setValue(e.target.checked, "addToMenu"), className: "form-check-input ms-2", style: { position: "relative", top: "2px" } })] }) }) }), addToMenu && (_jsxs("div", { className: "mt-2", children: [_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Add to what menu:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "menuItemDiv", className: "w-100", children: renderSelect("parent_id", menuItem?.parent_id, menuOptions, setValue, "form-control") }) })] }), _jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Menu Order:" }), _jsx("div", { className: "col-5", children: renderInput("menu_order", menuItem?.menu_order, setValue, null, {}, "Please enter the menu order.", "number") })] })] }))] }));
};
export default AddPageToMenu;
