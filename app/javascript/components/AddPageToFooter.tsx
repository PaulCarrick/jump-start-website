// app/javascript/components/AddPageToFooter.tsx

import React, { useState }              from "react";
import { FooterItem, SetErrorCallback } from "../types/dataTypes";
import { renderInput, renderSelect }    from "./renderControlFunctions";
import { isPresent }                    from "./utilities";
import { getFooterItems }               from "../services/footerItemService";

interface AddPageToFooterProps {
  pageName: string;
  onChanged: (footerItem: FooterItem | null | undefined, attribute: string) => void;
  pageTitle?: string | null;
  currentFooterItem?: FooterItem | null;
  setError?: SetErrorCallback | null;
}

const AddPageToFooter: React.FC<AddPageToFooterProps> = ({
                                                           pageName,
                                                           onChanged,
                                                           pageTitle = null,
                                                           currentFooterItem = null,
                                                           setError = null
                                                         }) => {
  const [ addToFooter, setAddToFooter ] = useState<boolean>(currentFooterItem !== null);
  const [ footerItem, setFooterItem ]   = useState<FooterItem | null | undefined>(currentFooterItem);

  const populateFooterItems = (): FooterItem[] => {
    const items: FooterItem[] | null = getFooterItems(null, null, setError);

    if (items)
      return items;
    else
      return [];
  };

  const getFooterOptions = (items: FooterItem[]): OptionEntry[] => {
    const footerOptions: OptionEntry[] = [ { label: "Root", value: -1 } ];

    if (items && isPresent(items)) {
      items.forEach((item) => {
        if (item.label && item.id != null) {
          footerOptions.push({ label: item.label, value: item.id });
        }
      });
    }

    return footerOptions;
  };

  const footerItems: FooterItem[]    = populateFooterItems();
  const footerOptions: OptionEntry[] = getFooterOptions(footerItems);

  const createFooterItem = (): FooterItem => {
    return {
      label:        footerItem?.label || pageTitle || pageName,
      link:         footerItem?.link || `/${pageName}`,
      parent_id:    footerItem?.parent_id,
      footer_order: footerItem?.footer_order
    };
  };

  const setValue = (newValue: any, attribute: string) => {
    switch (attribute) {
      case "addToFooter": {
        const add = newValue as boolean;

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

        const item      = footerItems.find(item => item.id === newValue);
        let footerOrder = 1;

        if (item && item?.sub_items)
          footerOrder = item.sub_items.length + 1;

        setFooterItem(prev => {
          const updated = {
            ...prev,
            footer_order: footerOrder,
            [attribute]:  newValue,
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
            [attribute]: newValue as number,
          };

          onChanged(updated, "footer_item");

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
            <label htmlFor="addToFooter" className="form-check-label">
              Add to footer
              <input
                  type="checkbox"
                  id="addToFooter"
                  checked={addToFooter}
                  onChange={(e) => setValue(e.target.checked, "addToFooter")}
                  className="form-check-input ms-2"
                  style={{ position: "relative", top: "2px" }}
              />
            </label>
          </div>
        </div>
        {addToFooter && (
            <div className="mt-2">
              <div className="row mb-2">
                <div className="col-2 d-flex align-items-center">Add to what footer:</div>
                <div className="col-5">
                  <div id="footerItemDiv" className="w-100">
                    {renderSelect(
                        "parent_id",
                        footerItem?.parent_id,
                        footerOptions,
                        setValue,
                        "form-control"
                    )}
                  </div>
                </div>
              </div>
              <div className="row mb-2">
                <div className="col-2 d-flex align-items-center">Footer Order:</div>
                <div className="col-5">
                  {renderInput("footer_order",
                               footerItem?.footer_order,
                               setValue as any,
                               null,
                               {},
                               "Please enter the footer order.",
                               "number")}
                </div>
              </div>
            </div>
        )}
      </>
  );
};

export default AddPageToFooter;
