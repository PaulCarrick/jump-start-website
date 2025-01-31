import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {handleVideoImageTag} from "./imageProcessingUtilities.jsx";

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
    if (images[index].caption) setDropdownValue(images[index].caption);
  };

 const description = handleVideoImageTag(images[currentIndex].description);

  return (
    <div style={{ textAlign: 'left' }}>
      <div
        style={{
          marginBottom: '1em',
          maxWidth: '100%',
          display: 'inline-block',
          textAlign: 'center',
        }}
      >
        {images[currentIndex].caption && (
          <p
            className="display-5 fw-bold mb-1 text-dark"
            style={{
              maxWidth: '100%',
              margin: '0 auto',
              padding: '0.5em 0',
              fontSize: '1.25em',
            }}
          >
            {images[currentIndex].caption}
          </p>
        )}
        <a href={images[currentIndex].image_url} target="_blank" rel="noopener noreferrer">
          <img
            src={images[currentIndex].image_url}
            alt={`Slide ${currentIndex}`}
            style={{ maxWidth: '100%', maxHeight: '640px', height: 'auto' }}
          />
        </a>

        {description && (
          <div className="text-start">
            <div dangerouslySetInnerHTML={{ __html: description }} />
          </div>
        )}
      </div>
      <div>
        {currentIndex + 1} of {images.length} -

        <button className={buttonClass} onClick={handleFirst} disabled={currentIndex === 0}>
          First
        </button>
        <button className={buttonClass} onClick={handlePrev} disabled={currentIndex === 0}>
          Prev
        </button>
        <button className={buttonClass} onClick={handleNext} disabled={currentIndex === images.length - 1}>
          Next
        </button>
        <button className={buttonClass} onClick={handleLast} disabled={currentIndex === images.length - 1}>
          Last
        </button>
        <select
          style={{ marginLeft: '1em' }}
          onChange={handleDropdownChange}
          value={dropdownValue}
        >
          <option value="" disabled>
            Select a {slideType || "topic"}
          </option>
          {uniqueCaptions.map((title, index) => (
            <option key={index} value={title}>
              {title}
            </option>
          ))}
        </select>
      </div>
    </div>
  );
};

SlideShow.propTypes = {
  images: PropTypes.arrayOf(
    PropTypes.oneOfType([
                          PropTypes.string,
                          PropTypes.object
                        ])
  ).isRequired,
  slideType: PropTypes.string
};

export default SlideShow;
