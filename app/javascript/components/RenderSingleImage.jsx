// /app/javascript/components/RenderSingleImage.jsx

// Render a single Image

import React from "react";
import PropTypes from "prop-types";
import {isPresent} from "./getDefaultOptions";

const RenderSingleImage = ({
                             content = "",
                             image = "",
                             link = "",
                             options = {},
                           }) => {
  if (!image) return null; // Can't render image if it's not there.

  const isVideo        = image.includes(".mp4");
  const hasDescription = isPresent(content);
  const hasLink        = isPresent(link);
  const hasCaption     = isPresent(options?.image_caption);
  let contents;

  if (isVideo) contents = renderVideo(image);
  else contents = renderImage(image, options);

  if (hasCaption) contents = addCaption(contents, options.image_caption, options);
  if (hasLink) contents = addLink(contents, link);
  if (hasDescription) contents = addDescription(contents, content, options);

  return contents;
};

function renderVideo(image) {
  return (
      <video id="videoElement" controls style={{ width: "100%" }} src={image}/>
  );
}

function renderImage(image, options) {
  return (
      <img src={image} alt="" className="img-fluid" style={options.image_styles}/>
  );
}

function addLink(content, link) {
  return <a href={link}>{content}</a>;
}

function addDescription(content, description, options) {
  return (
      <div className="image-container d-flex flex-column">
        {options.description_position === "top" && renderDescription(description, options)}
        <div>{content}</div>
        {options.description_position !== "top" && renderDescription(description, options)}
      </div>
  );
}

function renderDescription(description, options) {
  return (
      <>
        <div dangerouslySetInnerHTML={{ __html: description }}/>
        {options.expanding_rows && (
            <div>
              <button id={options.toggleId} className={options.toggleClass}>
                Show More
              </button>
            </div>
        )}
      </>
  );
}

function addCaption(content, caption, options) {
  return (
      <div className="image-container d-flex flex-column">
        {options.caption_position === "top" && renderCaption(caption, options)}
        <div>{content}</div>
        {options.caption_position !== "top" && renderCaption(caption, options)}
      </div>
  );
}

function renderCaption(caption, options) {
  if (caption) {
    return <div className={options.caption_classes}>{caption}</div>;
  }
  return null;
}

RenderSingleImage.propTypes = {
  image:   PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
  link:    PropTypes.string,
  options: PropTypes.shape({
                             image_styles:         PropTypes.object,
                             caption_classes:      PropTypes.string,
                             image_caption:        PropTypes.string,
                             caption_position:     PropTypes.oneOf(["top", "bottom", null]),
                             description_position: PropTypes.oneOf(["top", "bottom", null]),
                             expanding_rows:       PropTypes.bool,
                             toggleId:             PropTypes.string,
                             toggleClass:          PropTypes.string,
                           }),
};

export default RenderSingleImage;
