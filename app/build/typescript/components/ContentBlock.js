import { jsx as _jsx, Fragment as _Fragment, jsxs as _jsxs } from "react/jsx-runtime";
// /app/javascript/components/ContentBlock.jsx
// Render a content block
import React from "react";
import PropTypes from 'prop-types';
const ContentBlock = ({ content = null, options = {}, toggleId = null, toggleClass = "", onChange = null }) => {
    return (_jsxs(_Fragment, { children: [_jsx("div", { dangerouslySetInnerHTML: { __html: content } }), options.expanding_rows &&
                _jsx("button", { id: toggleId, className: toggleClass, children: "Show More" }), options.expanding_cells &&
                _jsx("button", { id: toggleId, className: toggleClass, children: "Show More" })] }));
};
ContentBlock.propTypes = {
    content: PropTypes.string,
    options: PropTypes.shape({
        expanding_rows: PropTypes.string,
        expanding_cells: PropTypes.string,
    }),
    toggleId: PropTypes.string,
    toggleClass: PropTypes.string,
    onChange: PropTypes.any
};
export default ContentBlock;
