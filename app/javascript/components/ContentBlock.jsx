import { siteHtml } from "../sitePath";
// /app/javascript/components/ContentBlock.jsx

// Render a content block

import React from "react";
import PropTypes from 'prop-types';

const ContentBlock = ({
                        content = null,
                        options = {},
                        toggleId = null,
                        toggleClass = "",
                        onChange = null
                      }) => {
  return (
      <>
        <div className="ql-editor rich-text-content" dangerouslySetInnerHTML={{ __html: siteHtml(content) }}/>
        {options.expanding_rows &&
         <button id={toggleId} className={`btn ${toggleClass || ""}`}>Show More</button>}
        {options.expanding_cells &&
         <button id={toggleId} className={`btn ${toggleClass || ""}`}>Show More</button>}
      </>
  );
}

ContentBlock.propTypes = {
  content:     PropTypes.string,
  options:     PropTypes.shape({
                                 expanding_rows:  PropTypes.string,
                                 expanding_cells: PropTypes.string,
                               }),
  toggleId:    PropTypes.string,
  toggleClass: PropTypes.string,
  onChange:    PropTypes.any
};

export default ContentBlock;
