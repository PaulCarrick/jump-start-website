// /app/javascripts/components/RenderContent.jsx
// noinspection RegExpRedundantEscape

// Component to Display Column Records

import React from "react";
import DisplayContent from "./DisplayContent";
import {dupObject, isPresent} from "./getDefaultOptions";
import {
  handleImageGroup,
  handleImageArray,
  imageFileFindByName,
  missingImageUrl, processVideoImageTag,
} from "./imageProcessingUtilities.jsx"

const RenderColumn = ({
                        column = null,
                        noBorder = false,
                        noHidden = true
                      }) => {
  if (column === null) return; // We can't render what we don't have

  const columnData      = dupObject(column);
  const processedColumn = processColumn(columnData);

  return (renderColumn(processedColumn, noBorder, noHidden));
}

// Utility Functions

function renderColumn(column, noBorder = false, noHidden) {
  if (column == null)
    return "";

  let divClass = "w-100 border border-danger border-width-8";

  if (noBorder) divClass = "w-100 m-0 p-3";

  return (
      <div className="row mb-2">
        <div id="columnAttributes" className={divClass}>
          <DisplayContent
              content={column.content}
              image={column.image}
              link={column.link}
              format={column.formatting}
              columnId={column.columnName}
              noHidden={noHidden}
          />
        </div>
      </div>
  );
}

function processColumn(column) {
  if ((column === null) || (column.image === null))
    return column;

  const imageGroupRegex = /^\s*ImageGroup:\s*(.+)\s*$/;
  const videoRegex      = /^\s*VideoImage:"\s*(.+)\s*"$/;
  const imageFileRegex  = /^\s*ImageFile:\s*(.+)\s*$/;
  const imageArrayRegex = /^\s*\[\s*(.+?)\s*\]\s*$/m;

  let newImages     = column.image.slice().trim();
  let newFormatting = dupObject(column.formatting);
  let match;

  switch (true) {
    case imageGroupRegex.test(newImages):
      match                      = newImages.match(imageGroupRegex);
      [newImages, newFormatting] = handleImageGroup(match[1], column.formatting);
      break;
    case videoRegex.test(newImages):
      match     = newImages.match(videoRegex);
      newImages = handleVideoFile(column, match[1]);
      break;
    case imageFileRegex.test(newImages):
      match     = newImages.match(imageFileRegex);
      newImages = handleSingleImageFile(column, match[1]);
      break;
    case imageArrayRegex.test(newImages):
      match                      = newImages.match(imageArrayRegex);
      [newImages, newFormatting] = handleImageArray(match[1], column.formatting);
      break;
    default:
      newImages = newImages.image_url;
  }

  column.image      = newImages;
  column.formatting = newFormatting;

  return column
}

function handleVideoFile(column, name) {
  const imageFile = imageFileFindByName(name);
  const results   = imageFile.image_url

  column.link = results;

  return results;
}

function handleSingleImageFile(column, name) {
  if (column === null)
    return column;

  const imageFile = imageFileFindByName(name);
  const results   = imageFile.image_url

  column.link = results;

  return results;
}

function handleImageColumn(column, name, formatting) {
  const imageFile = imageFileFindByName(name);

  if (column && imageFile.image_url) {
    let content                     = "";
    const caption                   = imageFile.caption;
    const containsOnlyPTagsOrNoHTML = /^(\s*<p>.*?<\/p>\s*)*$/i.test(caption);

    if (containsOnlyPTagsOrNoHTML)
      content = `<div class='display-4 fw-bold mb-1 text-dark'>${caption}</div>`;
    else
      content = caption;

    column.link = imageFile.image_url;

    return [imageFile.image_url, content, updatedFormatting];
  }
  else {
    return [missingImageUrl(), "", null];
  }
}

import PropTypes from 'prop-types';

RenderColumn.propTypes = {
  column:   PropTypes.shape({
                              section_name: PropTypes.string,
                              column_name:  PropTypes.string,
                              column_order: PropTypes.number,
                              content:      PropTypes.string,
                              image:        PropTypes.string,
                              link:         PropTypes.string,
                              formatting:   PropTypes.any,
                            }).isRequired, // Use `.isRequired` here,
  noBorder: PropTypes.bool,
  noHidden: PropTypes.bool,
};

export default RenderColumn;
