import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// /app/javascript/components/RenderSingleImage.jsx
// Render a single Image
import React from "react";
import PropTypes from "prop-types";
import { isPresent } from "./utilities";
const RenderSingleImage = ({ content = "", image = "", link = "", options = {}, }) => {
    if (!image)
        return null; // Can't render image if it's not there.
    const isVideo = image.includes(".mp4");
    const hasDescription = isPresent(content);
    const hasLink = isPresent(link);
    const hasCaption = isPresent(options?.image_caption);
    let contents;
    if (isVideo)
        contents = renderVideo(image);
    else
        contents = renderImage(image, options);
    if (hasCaption)
        contents = addCaption(contents, options.image_caption, options);
    if (hasLink)
        contents = addLink(contents, link);
    if (hasDescription)
        contents = addDescription(contents, content, options);
    return contents;
};
function renderVideo(image) {
    return (_jsx("video", { id: "videoElement", controls: true, style: { width: "100%" }, src: image }));
}
function renderImage(image, options) {
    return (_jsx("img", { src: image, alt: "", className: "img-fluid", style: options.image_styles }));
}
function addLink(content, link) {
    return _jsx("a", { href: link, children: content });
}
function addDescription(content, description, options) {
    return (_jsxs("div", { className: "image-container d-flex flex-column", children: [options.description_position === "top" && renderDescription(description, (options.expanding_rows ||
                options.expanding_cells), options.toggleId, options.toggleClass), _jsx("div", { children: content }), options.description_position !== "top" && renderDescription(description, (options.expanding_rows ||
                options.expanding_cells), options.toggleId, options.toggleClass)] }));
}
function renderDescription(description, expandable, toggleId, toggleClass) {
    return (_jsxs(_Fragment, { children: [_jsx("div", { dangerouslySetInnerHTML: { __html: description } }), expandable && (_jsx("div", { children: _jsx("button", { id: toggleId, className: toggleClass, children: "Show More" }) }))] }));
}
function addCaption(content, caption, options) {
    return (_jsxs("div", { className: "image-container d-flex flex-column", children: [options.caption_position === "top" && renderCaption(caption, options), _jsx("div", { children: content }), options.caption_position !== "top" && renderCaption(caption, options)] }));
}
function renderCaption(caption, options) {
    if (caption) {
        return _jsx("div", { className: options.caption_classes, children: caption });
    }
    return null;
}
RenderSingleImage.propTypes = {
    image: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
    link: PropTypes.string,
    options: PropTypes.shape({
        image_styles: PropTypes.object,
        caption_classes: PropTypes.string,
        image_caption: PropTypes.string,
        caption_position: PropTypes.oneOf(["top", "bottom", null]),
        description_position: PropTypes.oneOf(["top", "bottom", null]),
        expanding_rows: PropTypes.bool,
        expanding_cells: PropTypes.string,
        toggleId: PropTypes.string,
        toggleClass: PropTypes.string,
    }),
};
export default RenderSingleImage;
