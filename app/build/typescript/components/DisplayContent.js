import { jsx as _jsx } from "react/jsx-runtime";
// /app/javascript/components.DisplayContent.jsx
// noinspection JSValidateTypes
// Displays the contents of a section
import React from "react";
import PropTypes from 'prop-types';
import RenderContent from "./RenderContent";
import getDefaultOptions from "./getDefaultOptions";
import setupToggle from "./setupToggle";
import ErrorBoundary from "./ErrorBoundary";
const DisplayContent = ({ content = "", image = null, link = "", format = {}, sectionId = "", imageAttributes = {}, textAttributes = {}, noHidden = false, onChange = null }) => {
    let options = getDefaultOptions(format, textAttributes, imageAttributes);
    let toggleId = null;
    let toggleClass = null;
    if (options.expanding_rows) {
        // noinspection JSDeprecatedSymbols
        toggleId = options.expanding_rows
            ? `toggle-${Math.random().toString(36).substr(2, 9)}`
            : null;
        const [_, className, tglClass] = options.expanding_rows
            .split(",")
            .map((s) => s.trim());
        toggleClass = tglClass;
        if (!noHidden) {
            options.toggleId = toggleId;
            options.toggleClass = toggleClass;
            setupToggle(toggleId, className);
        }
    }
    if (options.expanding_cells) {
        // noinspection JSDeprecatedSymbols
        toggleId = options.expanding_cells
            ? `toggle-${Math.random().toString(36).substr(2, 9)}`
            : null;
        let [_, className, tglClass] = options.expanding_cells
            .split(",")
            .map((s) => s.trim());
        toggleClass = tglClass;
        if (!noHidden) {
            options.toggleId = toggleId;
            options.toggleClass = toggleClass;
            setupToggle(toggleId, className);
        }
    }
    return (_jsx(ErrorBoundary, { children: _jsx("div", { id: "contents", children: _jsx(RenderContent, { options: options, content: content, image: image, link: link, sectionId: sectionId, toggleId: toggleId, toggleClass: toggleClass, onChange: onChange }) }) }));
};
DisplayContent.propTypes = {
    content: PropTypes.string,
    image: PropTypes.oneOfType([PropTypes.string, PropTypes.null]),
    link: PropTypes.string,
    format: PropTypes.shape({
        row_style: PropTypes.string,
        row_classes: PropTypes.string,
        classes: PropTypes.string,
        styles: PropTypes.any,
        text_classes: PropTypes.string,
        text_styles: PropTypes.any,
        image_classes: PropTypes.string,
        image_styles: PropTypes.any,
        image_caption: PropTypes.string,
        caption_position: PropTypes.string,
        caption_classes: PropTypes.string,
        expanding_rows: PropTypes.string,
        slide_show_images: PropTypes.any,
        slide_show_type: PropTypes.string,
    }),
    sectionId: PropTypes.string,
    textAttributes: PropTypes.shape({
        margin_top: PropTypes.string,
        margin_left: PropTypes.string,
        margin_right: PropTypes.string,
        margin_bottom: PropTypes.string,
        background_color: PropTypes.string,
    }),
    imageAttributes: PropTypes.shape({
        margin_top: PropTypes.string,
        margin_left: PropTypes.string,
        margin_right: PropTypes.string,
        margin_bottom: PropTypes.string,
        background_color: PropTypes.string,
    }),
    noHidden: PropTypes.bool,
    onChange: PropTypes.any
};
export default DisplayContent;
