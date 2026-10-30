// /app/javascripts/components/RenderCell.jsx
// noinspection RegExpRedundantEscape

// Component to Display Cell Records

import React from "react";
import { createPortal } from "react-dom";
import DisplayContent from "./DisplayContent";
import { dupObject } from "./utilities";
import { getAdminPaths } from "../services/utilities";

import {
  handleImageGroup,
  handleImageArray,
  imageFileFindByName,
} from "./imageProcessingUtilities.jsx";

/**
 * @param {{ cell?: import('../types/dataTypes').Cell | null,
 * editing?: boolean, noBorder?: boolean, noHidden?: boolean,
 * contentAlignment?: string,
 * onChange?: ((cell: import('../types/dataTypes').Cell, action: import('../types/dataTypes').ActionType) => void) | null }} props
 */
const RenderCell = ({
  cell = null,
  editing = false,
  noBorder = true,
  noHidden = false,
  onChange = null,
  contentAlignment = undefined,
  actionsTargetId = null,
}) => {
  if (cell === null) return null; // We can't render what we don't have

  if (cell.enabled === false && !window.location.pathname.startsWith("/admin/")) return null;
  const cellData = dupObject(cell);
  const processedCell = processCell(cellData);

  return renderCell(processedCell, editing, noBorder, noHidden, onChange, contentAlignment, actionsTargetId);
};

// Keep the existing links and handlers when placing controls in the shared toolbar.
function CellActions({ targetId, children }) {
  const target = targetId ? document.getElementById(targetId) : null;
  const controls = <div className="admin-cell-actions d-flex justify-content-start flex-wrap gap-2">{children}</div>;
  return target ? createPortal(controls, target) : controls;
}

// Utility Functions

function renderCell(
  cell,
  editing = false,
  noBorder = false,
  noHidden = false,
  onChange = null,
  contentAlignment = undefined,
  actionsTargetId = null,
) {
  if (cell == null) return "";

  let divClass;
  let urls;

  if (noBorder) divClass = "w-100 m-0 p-3";
  else divClass = "w-100 border border-danger border-width-8";

  if (editing) {
    urls = getAdminPaths("cells", cell.id);

    if (onChange && cell) {
      return (
        <>
          <CellActions targetId={actionsTargetId}>
            <div>
              <a
                href="#"
                className="btn btn-primary"
                onClick={(e) => {
                  e.preventDefault();

                  if (onChange) onChange(cell, "edit");
                }}
              >
                Edit Column
              </a>
            </div>
            <div>
              <a
                href="#"
                className="btn btn-danger"
                data-confirm="Are you sure?"
                onClick={(e) => {
                  e.preventDefault();

                  if (onChange && window.confirm("Are you sure?"))
                    onChange(cell, "delete");
                }}
              >
                Delete Column
              </a>
            </div>
          </CellActions>
          <div className="row mb-2 flex-grow-1" style={{ alignItems: contentAlignment }}>
            <div key={cell.index} className={divClass}>
              <DisplayContent
                content={cell.content}
                image={cell.image}
                link={cell.link}
                format={cell.formatting}
                cellId={cell.cell_name}
                noHidden={noHidden}
              />
            </div>
          </div>
        </>
      );
    } else if (urls) {
      return (
        <>
          <CellActions targetId={actionsTargetId}>
            <div>
              {urls?.edit?.url && (
                <a
                  href={(() => {
                    const url = new URL(urls.edit.url, window.location.origin);
                    const caller = new URL(window.location.href);
                    if (caller.pathname.startsWith("/admin/pages/")) {
                      caller.searchParams.set("section_name", cell.section_name);
                      const parentReturn = document.querySelector('input[name="return_url"]')?.value;
                      if (parentReturn) caller.searchParams.set("return_url", parentReturn);
                    }
                    url.searchParams.set("return_url", caller.pathname + caller.search + caller.hash);
                    return url.href;
                  })()}
                  className="btn btn-primary"
                  target="_self"
                  data-turbo="false"
                  data-turbolinks="false"
                >
                  Edit Column
                </a>
              )}
            </div>
            <div>
              {urls?.delete?.url && (
                <a
                  href={urls["delete"]["url"]}
                  className="btn btn-danger"
                  data-turbo="false"
                  onClick={(event) => {
                    if (!window.confirm("Are you sure?"))
                      event.preventDefault();
                  }}
                >
                  Delete Column
                </a>
              )}
            </div>
          </CellActions>
          <div className="row mb-2 flex-grow-1" style={{ alignItems: contentAlignment }}>
            <div id="cellAttributes" className={divClass}>
              <DisplayContent
                content={cell.content}
                image={cell.image}
                link={cell.link}
                format={cell.formatting}
                cellId={cell.cell_name}
                noHidden={noHidden}
              />
            </div>
          </div>
        </>
      );
    } else {
      return (
        <div className="row mb-2">
          <div id="cellAttributes" className={divClass}>
            <DisplayContent
              content={cell.content}
              image={cell.image}
              link={cell.link}
              format={cell.formatting}
              cellId={cell.cell_name}
              noHidden={noHidden}
            />
          </div>
        </div>
      );
    }
  } else {
    return (
      <div className="row mb-2">
        <div id="cellAttributes" className={divClass}>
          <DisplayContent
            content={cell.content}
            image={cell.image}
            link={cell.link}
            format={cell.formatting}
            cellId={cell.cell_name}
            noHidden={noHidden}
          />
        </div>
      </div>
    );
  }
}

function processCell(cell) {
  if (cell === null || cell.image === null) return cell;

  const imageGroupRegex = /^\s*ImageGroup:\s*(.+)\s*$/;
  const videoRegex = /^\s*VideoImage:"(.+)"$/;
  const imageFileRegex = /^\s*ImageFile:\s*(.+)\s*$/;
  const imageArrayRegex = /^\s*\[\s*(.+?)\s*\]\s*$/m;

  let newImages = cell.image.slice().trim();
  let newFormatting = dupObject(cell.formatting);
  let match;

  switch (true) {
    case imageGroupRegex.test(newImages):
      match = newImages.match(imageGroupRegex);
      [newImages, newFormatting] = handleImageGroup(match[1], cell.formatting);
      break;
    case videoRegex.test(newImages):
      match = newImages.match(videoRegex);
      newImages = handleVideoFile(cell, match[1]);
      break;
    case imageFileRegex.test(newImages):
      match = newImages.match(imageFileRegex);
      newImages = handleSingleImageFile(cell, match[1]);
      break;
    case imageArrayRegex.test(newImages):
      match = newImages.match(imageArrayRegex);
      [newImages, newFormatting] = handleImageArray(match[1], cell.formatting);
      break;
    default:
      if (typeof newImages === "string")
        newImages = handleSingleImageFile(cell, newImages);
      else newImages = newImages.image_url;
  }

  cell.image = newImages;
  cell.formatting = newFormatting;

  return cell;
}

function handleVideoFile(cell, name) {
  const imageFile = imageFileFindByName(name);
  const results = imageFile.image_url;

  cell.link = results;

  return results;
}

function handleSingleImageFile(cell, name) {
  if (cell === null) return cell;

  const imageFile = imageFileFindByName(name);
  const results = imageFile.image_url;

  cell.link = results;

  return results;
}

import PropTypes from "prop-types";

RenderCell.propTypes = {
  cell: PropTypes.shape({
    id: PropTypes.number,
    section_name: PropTypes.string,
    cell_name: PropTypes.string,
    cell_order: PropTypes.number,
    content: PropTypes.string,
    image: PropTypes.string,
    link: PropTypes.string,
    formatting: PropTypes.any,
  }).isRequired, // Use `.isRequired` here,
  editing: PropTypes.bool,
  noBorder: PropTypes.bool,
  noHidden: PropTypes.bool,
  onChange: PropTypes.any,
  contentAlignment: PropTypes.string,
};

export default RenderCell;
