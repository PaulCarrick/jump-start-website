// app/javascript/components/AddPageToMenu.tsx

import React, { useState }            from "react";
import { MenuItem, SetErrorCallback } from "../types/dataTypes";
import { renderInput, renderSelect }  from "./renderControlFunctions";
import { isPresent }                  from "./utilities";
import { getMenuItems }               from "../services/menuItemService";

interface AddPageToMenuProps {
  pageName: string;
  onChanged: (menuItem: MenuItem | null | undefined, attribute: string) => void;
  pageTitle?: string | null;
  currentMenuItem?: MenuItem | null;
  setError?: SetErrorCallback | null;
}

const AddPageToMenu: React.FC<AddPageToMenuProps> = ({
                                                       pageName,
                                                       onChanged,
                                                       pageTitle = null,
                                                       currentMenuItem = null,
                                                       setError = null
                                                     }) => {
  const [ addToMenu, setAddToMenu ] = useState<boolean>(currentMenuItem !== null);
  const [ menuItem, setMenuItem ]   = useState<MenuItem | null | undefined>(currentMenuItem);

  const populateMenuItems = (): MenuItem[] => {
    const items: MenuItem[] | null = getMenuItems(null, null, setError);

    if (items)
      return items;
    else
      return [];
  };

  const getMenuOptions = (items: MenuItem[]): OptionEntry[] => {
    const menuOptions: OptionEntry[] = [ { label: "Root", value: -1 } ];

    if (items && isPresent(items)) {
      items.forEach((item) => {
        if (item.label && item.id != null) {
          menuOptions.push({ label: item.label, value: item.id });
        }
      });
    }

    return menuOptions;
  };

  const menuItems: MenuItem[]      = populateMenuItems();
  const menuOptions: OptionEntry[] = getMenuOptions(menuItems);

  const createMenuItem = (): MenuItem => {
    return {
      label:      menuItem?.label || pageTitle || pageName,
      menu_type:  menuItem?.menu_type || "Main",
      link:       menuItem?.link || `/${pageName}`,
      parent_id:  menuItem?.parent_id,
      menu_order: menuItem?.menu_order
    };
  };

  const setValue = (newValue: any, attribute: string) => {
    switch (attribute) {
      case "addToMenu": {
        const add = newValue as boolean;

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

        const item    = menuItems.find(item => item.id === newValue);
        let menuOrder = 1;

        if (item && item?.sub_items)
          menuOrder = item.sub_items.length + 1;

        setMenuItem(prev => {
          const updated = {
            ...prev,
            menu_order:  menuOrder,
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
            [attribute]: newValue as number,
          };

          onChanged(updated, "menu_item");

          return updated;
        });

        break;
      }
    }
  };

  //*** Main Render Routine ***//
  return (
      <>
        <div className="row mb-2">
          <div className="col-2">
            <label htmlFor="addToMenu" className="form-check-label">
              Add to menu
              <input
                  type="checkbox"
                  id="addToMenu"
                  checked={addToMenu}
                  onChange={(e) => setValue(e.target.checked, "addToMenu")}
                  className="form-check-input ms-2"
                  style={{ position: "relative", top: "2px" }}
              />
            </label>
          </div>
        </div>
        {addToMenu && (
            <div className="mt-2">
              <div className="row mb-2">
                <div className="col-2 d-flex align-items-center">Add to what menu:</div>
                <div className="col-5">
                  <div id="menuItemDiv" className="w-100">
                    {renderSelect(
                        "parent_id",
                        menuItem?.parent_id,
                        menuOptions,
                        setValue,
                        "form-control"
                    )}
                  </div>
                </div>
              </div>
              <div className="row mb-2">
                <div className="col-2 d-flex align-items-center">Menu Order:</div>
                <div className="col-5">
                  {renderInput("menu_order",
                               menuItem?.menu_order,
                               setValue as any,
                               null,
                               {},
                               "Please enter the menu order.",
                               "number")}
                </div>
              </div>
            </div>
        )}
      </>
  );
};

export default AddPageToMenu;
