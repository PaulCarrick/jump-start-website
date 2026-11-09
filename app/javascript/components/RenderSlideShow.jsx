// /app/javascript/components/RenderSlideShow.jsx

// Render a slide show, with the column's own text (if any) above it.

import React from "react";
import PropTypes from 'prop-types';
import SlideShow from "./SlideShow";
import { siteHtml } from "../sitePath";

const hasText = (html) => {
  if (!html) return false;
  const text = new DOMParser().parseFromString(html, "text/html").body.textContent || "";
  return text.trim().length > 0 || /<(img|video|iframe)\b/i.test(html);
};

const RenderSlideShow = ({
                             images = [],
                             captions = "",
                             slideType = "Topic",
                             options = {}
                         }) => {
  return (
    <div className="slideshow-container">
      {hasText(captions) && (
        <div className="slideshow-text text-start mb-3">
          <div className="ql-editor rich-text-content" dangerouslySetInnerHTML={{ __html: siteHtml(captions) }}/>
        </div>
      )}
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
  captions: PropTypes.string,
  slideType: PropTypes.string,
  options: PropTypes.object
};

export default RenderSlideShow;
