// /app/javascript/components/RenderSlideShow.jsx

// Render a slide show

import React from "react";
import PropTypes from 'prop-types';
import SlideShow from "./SlideShow";

const RenderSlideShow = ({
                             images = [],
                             slideType = "Topic",
                             options = {}
                         }) => {
  return (
    <div className="slideshow-container">
      <SlideShow images={images} slideType={slideType || "topic"} options={options}/>
    </div>
  );
};

RenderSlideShow.propTypes = {
  images: PropTypes.arrayOf(
    PropTypes.oneOfType([
                          PropTypes.string,
                          PropTypes.object
                        ])
  ).isRequired,
  slideType: PropTypes.string
};

export default RenderSlideShow;
