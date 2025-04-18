import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// /app/javascript/components/RenderContent.jsx
// Render the content of a section
import React from "react";
import PropTypes from 'prop-types';
import ContentBlock from "./ContentBlock";
import RenderImage from "./RenderImage";
const RenderContent = ({ options = {}, content = "", image = "", link = "", sectionId = "", toggleId = "", toggleClass = {}, onChange = null }) => {
    const rowClasses = `row ${options.row_classes}`;
    let text = content;
    let captions = "";
    if (options.slide_show_images) {
        captions = text;
    }
    switch (options.row_style) {
        case "text-left":
            return (_jsx(_Fragment, { children: _jsxs("div", { className: rowClasses, ...(sectionId ? { id: sectionId } : {}), children: [_jsx("div", { className: options.text_classes, style: options.text_styles, children: _jsx(ContentBlock, { content: text, options: options, toggleId: toggleId, toggleClass: toggleClass, onChange: onChange }) }), _jsx("div", { className: options.image_classes, style: options.image_styles, children: _jsx(RenderImage, { content: captions, image: image, link: link, options: options, onChange: onChange }) })] }) }));
        case "text-right":
            return (_jsx(_Fragment, { children: _jsxs("div", { className: rowClasses, ...(sectionId ? { id: sectionId } : {}), children: [_jsx("div", { className: options.image_classes, style: options.image_styles, children: _jsx(RenderImage, { content: captions, image: image, link: link, options: options, onChange: onChange }) }), _jsx("div", { className: options.text_classes, style: options.text_styles, children: _jsx(ContentBlock, { content: text, options: options, toggleId: toggleId, toggleClass: toggleClass, onChange: onChange }) })] }) }));
        case "text-single":
            return (_jsx("div", { className: rowClasses, ...(sectionId ? { id: sectionId } : {}), children: _jsx("div", { className: options.text_classes, style: options.text_styles, children: _jsx(ContentBlock, { content: text, options: options, toggleId: toggleId, toggleClass: toggleClass, onChange: onChange }) }) }));
        case "image-single":
            return (_jsx(_Fragment, { children: _jsx("div", { className: rowClasses, children: _jsx("div", { className: options.image_classes, style: options.image_styles, children: _jsx(RenderImage, { content: captions, image: image, link: link, options: options, onChange: onChange }) }) }) }));
        case "text-top":
            return (_jsxs(_Fragment, { children: [_jsx("div", { className: rowClasses, ...(sectionId ? { id: sectionId } : {}), children: _jsx("div", { className: options.text_classes, style: options.text_styles, children: _jsx(ContentBlock, { content: text, options: options, toggleId: toggleId, toggleClass: toggleClass, onChange: onChange }) }) }), _jsx("div", { className: rowClasses, children: _jsx("div", { className: options.image_classes, style: options.image_styles, children: _jsx(RenderImage, { content: captions, image: image, link: link, options: options, onChange: onChange }) }) })] }));
        case "text-bottom":
            return (_jsxs(_Fragment, { children: [_jsx("div", { className: rowClasses, children: _jsx("div", { className: options.image_classes, style: options.image_styles, children: _jsx(RenderImage, { content: captions, image: image, link: link, options: options, onChange: onChange }) }) }), _jsx("div", { className: rowClasses, children: _jsx("div", { className: options.text_classes, style: options.text_styles, children: _jsx(ContentBlock, { content: text, options: options, toggleId: toggleId, toggleClass: toggleClass, onChange: onChange }) }) })] }));
        default:
            if (image || options.slide_show_images)
                return (_jsx("div", { className: options.classes, style: options.styles, children: _jsx(RenderImage, { content: text, image: image, link: link, options: options, onChange: onChange }) }));
            else
                return (_jsx("div", { className: options.classes, style: options.styles, children: _jsx(ContentBlock, { content: text, options: options, toggleId: toggleId, toggleClass: toggleClass, onChange: onChange }) }));
    }
};
RenderContent.propTypes = {
    options: PropTypes.shape({
        row_classes: PropTypes.string,
        row_style: PropTypes.oneOf([
            "text-left",
            "text-right",
            "text-single",
            "image-single",
            "text-top",
            "text-bottom",
            "cell"
        ]).isRequired,
        classes: PropTypes.string,
        styles: PropTypes.object,
        text_classes: PropTypes.string,
        text_styles: PropTypes.object,
        image_classes: PropTypes.string,
        image_styles: PropTypes.object,
        slide_show_images: PropTypes.any
    }).isRequired,
    content: PropTypes.string,
    image: PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
    link: PropTypes.string,
    sectionId: PropTypes.string,
    toggleId: PropTypes.string,
    toggleClass: PropTypes.string,
    onChange: PropTypes.any
};
export default RenderContent;
