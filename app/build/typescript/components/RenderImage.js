import { jsx as _jsx } from "react/jsx-runtime";
// /app/javascript/components/RenderImage.jsx
// Render an Image
import React from "react";
import PropTypes from 'prop-types';
import RenderSlideShow from "./RenderSlideShow";
import RenderSingleImage from "./RenderSingleImage";
const RenderImage = ({ content = "", image = "", link = "", options = {}, onChange = null }) => {
    if (options.slide_show_images) {
        return (_jsx(RenderSlideShow, { images: options.slide_show_images, captions: content, slideType: options.slide_show_type }));
    }
    else {
        return (_jsx(RenderSingleImage, { content: content, image: image, link: link, options: options }));
    }
};
RenderImage.propTypes = {
    content: PropTypes.string,
    image: PropTypes.oneOfType([
        PropTypes.string,
        PropTypes.object,
    ]),
    link: PropTypes.string,
    options: PropTypes.shape({
        slide_show_images: PropTypes.arrayOf(PropTypes.oneOfType([
            PropTypes.string,
            PropTypes.object,
        ])),
        slide_show_type: PropTypes.string
    }).isRequired,
    onChange: PropTypes.any
};
export default RenderImage;
