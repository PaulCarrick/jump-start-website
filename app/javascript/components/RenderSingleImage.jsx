// /app/javascript/components/RenderSingleImage.jsx

// Render a single Image

import React from "react";
import PropTypes from 'prop-types';
import {isPresent} from "./getDefaultOptions"

const RenderSingleImage = ({
                             image = "",
                             link = "",
                             options = {}
                           }) => {
  const renderImage = () => {
    if (isPresent(image)) {
      if (link) {
        if (image.includes('.mp4'))  // This is a video
          return (
              <a href={link} target="_blank" rel="noopener noreferrer">
                Click to play video.
              </a>
          )
        else
          return (
              <a href={link} target="_blank" rel="noopener noreferrer">
                <img src={image} alt={image} className="img-fluid"
                     style={options.image_styles}/>
              </a>
          );
      }
      else {
        if (image.includes('.mp4'))  // This is a video
          return (
              <video id="videoElement"
                     controls style="width: 100%;"
                     src={image}>
              </video>
          )
        else
          return (
              <img src={image} alt={image} className="img-fluid"
                   style={options.image_styles}/>
          );
      }
    }
  };

  const renderCaption = (captions) => {
    if (captions)
      return (
          <div className={options.caption_classes}>{options.image_caption}</div>);
  }

  return (
      <div className="image-container d-flex flex-column">
        {options.caption_position === "top" && renderCaption()}
        <div>{renderImage()}</div>
        {options.caption_position !== "top" && renderCaption()}
      </div>
  );
};

RenderSingleImage.propTypes = {
  image:   PropTypes.oneOfType([
                                 PropTypes.string,
                                 PropTypes.object
                               ]),
  link:    PropTypes.string,
  options: PropTypes.shape({
                             image_styles:     PropTypes.object,
                             caption_classes:  PropTypes.string,
                             image_caption:    PropTypes.string,
                             caption_position: PropTypes.oneOf(["top", "bottom", null])
                           }).isRequired
};

export default RenderSingleImage;
