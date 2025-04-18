// /app/javascript/components/RenderContent.jsx

// Render the content of a section

import React from "react";
import PropTypes from 'prop-types';
import ContentBlock from "./ContentBlock";
import RenderImage from "./RenderImage";

const RenderContent = ({
                         options = {},
                         content = "",
                         image = "",
                         link = "",
                         sectionId = "",
                         toggleId = "",
                         toggleClass = {},
                         onChange = null
                       }) => {
  const rowClasses = `row ${options.row_classes}`;
  let text         = content;
  let captions     = "";

  if (options.slide_show_images) {
    captions = text;
  }

  switch (options.row_style) {
    case "text-left":
      return (
          <>
            <div className={rowClasses} {...(sectionId ? { id: sectionId } : {})}>
              <div className={options.text_classes} style={options.text_styles}>
                <ContentBlock content={text}
                              options={options}
                              toggleId={toggleId}
                              toggleClass={toggleClass}
                              onChange={onChange}
                />
              </div>
              <div className={options.image_classes} style={options.image_styles}>
                <RenderImage
                    content={captions}
                    image={image}
                    link={link}
                    options={options}
                    onChange={onChange}
                />
              </div>
            </div>
          </>
      );
    case "text-right":
      return (
          <>
            <div className={rowClasses} {...(sectionId ? { id: sectionId } : {})}>
              <div className={options.image_classes} style={options.image_styles}>
                <RenderImage
                    content={captions}
                    image={image}
                    link={link}
                    options={options}
                    onChange={onChange}
                />
              </div>
              <div className={options.text_classes} style={options.text_styles}>
                <ContentBlock content={text}
                              options={options}
                              toggleId={toggleId}
                              toggleClass={toggleClass}
                              onChange={onChange}
                />
              </div>
            </div>
          </>
      );
    case "text-single":
      return (
          <div className={rowClasses} {...(sectionId ? { id: sectionId } : {})}>
            <div className={options.text_classes} style={options.text_styles}>
              <ContentBlock content={text}
                            options={options}
                            toggleId={toggleId}
                            toggleClass={toggleClass}
                            onChange={onChange}
              />
            </div>
          </div>
      );
    case "image-single":
      return (
          <>
            <div className={rowClasses}>
              <div className={options.image_classes} style={options.image_styles}>
                <RenderImage content={captions}
                             image={image}
                             link={link}
                             options={options}
                             onChange={onChange}
                />
              </div>
            </div>
          </>
      );
    case "text-top":
      return (
          <>
            <div className={rowClasses} {...(sectionId ? { id: sectionId } : {})}>
              <div className={options.text_classes} style={options.text_styles}>
                <ContentBlock content={text}
                              options={options}
                              toggleId={toggleId}
                              toggleClass={toggleClass}
                              onChange={onChange}
                />
              </div>
            </div>
            <div className={rowClasses}>
              <div className={options.image_classes} style={options.image_styles}>
                <RenderImage content={captions}
                             image={image}
                             link={link}
                             options={options}
                             onChange={onChange}
                />
              </div>
            </div>
          </>
      );
    case "text-bottom":
      return (
          <>
            <div className={rowClasses}>
              <div className={options.image_classes} style={options.image_styles}>
                <RenderImage content={captions}
                             image={image}
                             link={link}
                             options={options}
                             onChange={onChange}
                />
              </div>
            </div>
            <div className={rowClasses}>
              <div className={options.text_classes} style={options.text_styles}>
                <ContentBlock content={text}
                              options={options}
                              toggleId={toggleId}
                              toggleClass={toggleClass}
                              onChange={onChange}
                />
              </div>
            </div>
          </>
      );
    default:
      if (image || options.slide_show_images)
        return (
            <div className={options.classes} style={options.styles}>
              <RenderImage content={text}
                           image={image}
                           link={link}
                           options={options}
                           onChange={onChange}
              />
            </div>)
      else
        return (
            <div className={options.classes} style={options.styles}>
              <ContentBlock content={text}
                            options={options}
                            toggleId={toggleId}
                            toggleClass={toggleClass}
                            onChange={onChange}
              />
            </div>
        );
  }
};

RenderContent.propTypes = {
  options:     PropTypes.shape({
                                 row_classes:       PropTypes.string,
                                 row_style:         PropTypes.oneOf([
                                                                      "text-left",
                                                                      "text-right",
                                                                      "text-single",
                                                                      "image-single",
                                                                      "text-top",
                                                                      "text-bottom",
                                                                      "cell"
                                                                    ]).isRequired,
                                 classes:           PropTypes.string,
                                 styles:            PropTypes.object,
                                 text_classes:      PropTypes.string,
                                 text_styles:       PropTypes.object,
                                 image_classes:     PropTypes.string,
                                 image_styles:      PropTypes.object,
                                 slide_show_images: PropTypes.any
                               }).isRequired,
  content:     PropTypes.string,
  image:       PropTypes.oneOfType([PropTypes.string, PropTypes.object]),
  link:        PropTypes.string,
  sectionId:   PropTypes.string,
  toggleId:    PropTypes.string,
  toggleClass: PropTypes.string,
  onChange:    PropTypes.any
};

export default RenderContent;
