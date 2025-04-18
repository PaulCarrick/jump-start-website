import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { handleVideoImageTag } from "./imageProcessingUtilities.jsx";
const SlideShow = ({ images = [], slideType = "Topic" }) => {
    const [currentIndex, setCurrentIndex] = useState(0);
    const [dropdownValue, setDropdownValue] = useState("");
    const buttonClass = "btn btn-link p-1 text-dark";
    const uniqueCaptions = [...new Set(images.map(image => image.caption))];
    const handleFirst = () => {
        setCurrentIndex(0);
        updateDropdownValue(0);
    };
    const handleNext = () => {
        if (currentIndex < images.length - 1) {
            setCurrentIndex(currentIndex + 1);
            updateDropdownValue(currentIndex + 1);
        }
    };
    const handlePrev = () => {
        if (currentIndex > 0) {
            setCurrentIndex(currentIndex - 1);
            updateDropdownValue(currentIndex - 1);
        }
    };
    const handleLast = () => {
        setCurrentIndex(images.length - 1);
        updateDropdownValue(images.length - 1);
    };
    const handleDropdownChange = (event) => {
        const selectedValue = event.target.value;
        const index = images.findIndex(image => image.caption === selectedValue);
        if (index !== -1) {
            setCurrentIndex(index);
            setDropdownValue(selectedValue);
        }
    };
    const updateDropdownValue = (index) => {
        if (images[index].caption)
            setDropdownValue(images[index].caption);
    };
    const description = handleVideoImageTag(images[currentIndex].description);
    return (_jsxs("div", { style: { textAlign: 'left' }, children: [_jsxs("div", { style: {
                    marginBottom: '1em',
                    maxWidth: '100%',
                    display: 'inline-block',
                    textAlign: 'center',
                }, children: [images[currentIndex].caption && (_jsx("p", { className: "display-5 fw-bold mb-1 text-dark", style: {
                            maxWidth: '100%',
                            margin: '0 auto',
                            padding: '0.5em 0',
                            fontSize: '1.25em',
                        }, children: images[currentIndex].caption })), _jsx("a", { href: images[currentIndex].image_url, target: "_blank", rel: "noopener noreferrer", children: _jsx("img", { src: images[currentIndex].image_url, alt: `Slide ${currentIndex}`, style: { maxWidth: '100%', maxHeight: '640px', height: 'auto' } }) }), description && (_jsx("div", { className: "text-start", children: _jsx("div", { dangerouslySetInnerHTML: { __html: description } }) }))] }), _jsxs("div", { children: [currentIndex + 1, " of ", images.length, " -", _jsx("button", { className: buttonClass, onClick: handleFirst, disabled: currentIndex === 0, children: "First" }), _jsx("button", { className: buttonClass, onClick: handlePrev, disabled: currentIndex === 0, children: "Prev" }), _jsx("button", { className: buttonClass, onClick: handleNext, disabled: currentIndex === images.length - 1, children: "Next" }), _jsx("button", { className: buttonClass, onClick: handleLast, disabled: currentIndex === images.length - 1, children: "Last" }), _jsxs("select", { style: { marginLeft: '1em' }, onChange: handleDropdownChange, value: dropdownValue, children: [_jsxs("option", { value: "", disabled: true, children: ["Select a ", slideType || "topic"] }), uniqueCaptions.map((title, index) => (_jsx("option", { value: title, children: title }, index)))] })] })] }));
};
SlideShow.propTypes = {
    images: PropTypes.arrayOf(PropTypes.oneOfType([
        PropTypes.string,
        PropTypes.object
    ])).isRequired,
    slideType: PropTypes.string
};
export default SlideShow;
