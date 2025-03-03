// /app/javascripts/components/RenderContent.jsx
// noinspection RegExpRedundantEscape

// Component to Display Cell Records

import React from "react";
import DisplayContent from "./DisplayContent";
import {dupObject, getAdminPaths} from "./getDefaultOptions";
import {
  handleImageGroup,
  handleImageArray,
  imageFileFindByName,
} from "./imageProcessingUtilities.jsx"

const RenderCell = ({
                      cell = null,
                      editing = false,
                      noBorder = true,
                      noHidden = false
                    }) => {
  if (cell === null) return; // We can't render what we don't have

  const cellData      = dupObject(cell);
  const processedCell = processCell(cellData);

  return (renderCell(processedCell, editing, noBorder, noHidden));
}

// Utility Functions

function renderCell(cell, editing = false, noBorder = false, noHidden) {
  if (cell == null)
    return "";

  let divClass;
  let urls;

  if (noBorder)
    divClass = "w-100 m-0 p-3";
  else
    divClass = "w-100 border border-danger border-width-8"

  if (editing)
    urls = getAdminPaths("cells", cell.id)

  if (urls) {
    urls = JSON.parse(urls)

    return (
        <>
          <div className="row mb-2">
            <div className="col-4">
              {urls?.edit?.url && (
                  <a href={urls["edit"]["url"]}>
                    Edit Column
                  </a>)
              }
            </div>
            <div className="col-4">
              {urls?.delete?.url && (
                  <a href={urls["delete"]["url"]} data-confirm="Are you sure?">
                    Delete Column
                  </a>)
              }
            </div>
            <div className="col-4">
            </div>
          </div>
          <div className="row mb-2">
            <div id="cellAttributes" className={divClass}>
              <DisplayContent
                  content={cell.content}
                  image={cell.image}
                  link={cell.link}
                  format={cell.formatting}
                  cellId={cell.cellName}
                  noHidden={noHidden}
              />
            </div>
          </div>
        </>
    );
  }
  else {
    return (
        <div className="row mb-2">
          <div id="cellAttributes" className={divClass}>
            <DisplayContent
                content={cell.content}
                image={cell.image}
                link={cell.link}
                format={cell.formatting}
                cellId={cell.cellName}
                noHidden={noHidden}
            />
          </div>
        </div>
    );
  }
}

function processCell(cell) {
  if ((cell === null) || (cell.image === null))
    return cell;

  const imageGroupRegex = /^\s*ImageGroup:\s*(.+)\s*$/;
  const videoRegex      = /^\s*VideoImage:"(.+)"$/;
  const imageFileRegex  = /^\s*ImageFile:\s*(.+)\s*$/;
  const imageArrayRegex = /^\s*\[\s*(.+?)\s*\]\s*$/m;

  let newImages     = cell.image.slice().trim();
  let newFormatting = dupObject(cell.formatting);
  let match;

  switch (true) {
    case imageGroupRegex.test(newImages):
      match                      = newImages.match(imageGroupRegex);
      [newImages, newFormatting] = handleImageGroup(match[1], cell.formatting);
      break;
    case videoRegex.test(newImages):
      match     = newImages.match(videoRegex);
      newImages = handleVideoFile(cell, match[1]);
      break;
    case imageFileRegex.test(newImages):
      match     = newImages.match(imageFileRegex);
      newImages = handleSingleImageFile(cell, match[1]);
      break;
    case imageArrayRegex.test(newImages):
      match                      = newImages.match(imageArrayRegex);
      [newImages, newFormatting] = handleImageArray(match[1], cell.formatting);
      break;
    default:
      newImages = newImages.image_url;
  }

  cell.image      = newImages;
  cell.formatting = newFormatting;

  return cell
}

function handleVideoFile(cell, name) {
  const imageFile = imageFileFindByName(name);
  const results   = imageFile.image_url

  cell.link = results;

  return results;
}

function handleSingleImageFile(cell, name) {
  if (cell === null)
    return cell;

  const imageFile = imageFileFindByName(name);
  const results   = imageFile.image_url

  cell.link = results;

  return results;
}

import PropTypes from 'prop-types';

RenderCell.propTypes = {
  cell:     PropTypes.shape({
                              section_name: PropTypes.string,
                              cell_name:    PropTypes.string,
                              cell_order:   PropTypes.number,
                              content:      PropTypes.string,
                              image:        PropTypes.string,
                              link:         PropTypes.string,
                              formatting:   PropTypes.any,
                            }).isRequired, // Use `.isRequired` here,
  editing:  PropTypes.bool,
  noBorder: PropTypes.bool,
  noHidden: PropTypes.bool,
};

export default RenderCell;
