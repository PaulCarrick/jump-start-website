import { jsx as _jsx } from "react/jsx-runtime";
// /app/javascripts/components/RenderContent.jsx
// noinspection RegExpRedundantEscape
// Component to Display Section Records
import React from "react";
import DisplayContent from "./DisplayContent";
import RenderCell from "./RenderCell.jsx";
import { isTextOnly } from "./getDefaultOptions";
import { dupObject, isPresent } from "./utilities";
import PropTypes from 'prop-types';
import { handleImageGroup, handleImageArray, processVideoImages, processVideoImageTag, imageFileFindByName, missingImageUrl, } from "./imageProcessingUtilities.jsx";
const RenderSection = ({ section = null, editing = false, noBorder = true, noHidden = false, onChange = null }) => {
    if (section === null)
        return; // We can't render what we don't have
    const sectionData = dupObject(section);
    if (sectionData.cells) {
        return processCells(sectionData.cells, editing, noBorder, noHidden, onChange);
    }
    else {
        const contents = buildContents(sectionData);
        const sections = [];
        processVideoImages(contents);
        contents.forEach(content => {
            sections.push(renderSection(content, noBorder, noHidden));
        });
        return (sections);
    }
};
// Utility Functions
function renderSection(content, noBorder = false, noHidden) {
    let divClass = "w-100 border border-danger border-width-8";
    if (noBorder)
        divClass = "w-100 m-0 p-3";
    return (_jsx("div", { className: "row mb-2", children: _jsx("div", { id: "sectionAttributes", className: divClass, children: _jsx(DisplayContent, { content: content.description, image: content.image, link: content.link, format: content.formatting, sectionId: content.sectionName, textAttributes: content.text_attributes, imageAttributes: content.image_attributes, noHidden: noHidden, onChange: onChange }) }) }));
}
function buildContents(section) {
    const sections = processSection(section);
    return sections;
}
const processCells = (cells, editing = false, noBorder = false, noHidden = true, onChange = null) => {
    if (!cells || cells.length === 0)
        return null;
    let containerClasses = "row";
    let containerId = "";
    cells.forEach(cell => {
        containerId = cell.section_name;
        if (cell.formatting) {
            const cellContainerClasses = cell.formatting["container_classes"];
            if (cellContainerClasses && !containerClasses.includes(cellContainerClasses))
                containerClasses = containerClasses + " " + cellContainerClasses;
        }
        processCell(cell);
    });
    return (_jsx("div", { className: containerClasses, id: containerId, children: cells.map((cell, index) => (_jsx("div", { className: cell.container_class || '', style: {
                ...(cell.width === 'auto' ? { flex: 1 } : { width: `${cell.width}` }),
            }, children: _jsx(RenderCell, { cell: cell, editing: editing, noBorder: noBorder, noHidden: noHidden, onChange: onChange }) }, index))) }));
};
function processCell(cell) {
    if (!cell)
        return;
    if (cell.content) {
        const match = cell.content.match(/VideoImage:\s*"(.+)"/);
        if (match)
            cell.content = processVideoImageTag(cell.content, match[1]);
    }
    if (cell.formatting && cell.formatting["classes"]) {
        let classes = cell.formatting["classes"];
        const match = classes.match(/col(?:-(xs|sm|md|lg|xl|xxl))?-(\d{1,2})/);
        if (match) {
            cell.container_class = match[0];
            // Remove the matched string from the classes field
            cell.formatting["classes"] = classes.replace(match[0], "").trim();
        }
    }
}
function processSection(section) {
    const rowStyle = isPresent(section.row_style) ? section.row_style : section.formatting.row_style;
    if (isTextOnly(rowStyle) || !section.image) // Nothing to do
        return [section];
    const imageGroupRegex = /^\s*ImageGroup:\s*(.+)\s*$/;
    const videoRegex = /^\s*VideoImage:"\s*(.+)\s*"$/;
    const imageFileRegex = /^\s*ImageFile:\s*(.+)\s*$/;
    const imageSectionRegex = /^\s*ImageSection:\s*(.+)\s*$/;
    const imageArrayRegex = /^\s*\[\s*(.+?)\s*\]\s*$/m;
    let isImageSection = false;
    let newImages = section.image.slice().trim();
    let newDescription = section.description;
    let newFormatting = dupObject(section.formatting);
    let subsection = null;
    let match;
    switch (true) {
        case imageGroupRegex.test(newImages):
            match = newImages.match(imageGroupRegex);
            [newImages, newFormatting] = handleImageGroup(match[1], section.formatting);
            break;
        case videoRegex.test(newImages):
            match = newImages.match(videoRegex);
            newImages = handleVideoFile(section, match[1]);
            break;
        case imageFileRegex.test(newImages):
            match = newImages.match(imageFileRegex);
            newImages = handleSingleImageFile(section, match[1]);
            break;
        case imageSectionRegex.test(newImages):
            isImageSection = true;
            match = newImages.match(imageSectionRegex);
            [newImages, newDescription, subsection, newFormatting] = handleImageSection(section, match[1], section.formatting);
            break;
        case imageArrayRegex.test(newImages):
            match = newImages.match(imageArrayRegex);
            [newImages, newFormatting] = handleImageArray(match[1], section.formatting);
            break;
        default:
            newImages = newImages.image_url;
    }
    if (isImageSection && isPresent(subsection)) {
        section.image = newImages;
        section.description = newDescription;
        section.formatting = newFormatting;
        return [section, subsection];
    }
    else {
        section.image = newImages;
        section.description = newDescription;
        section.formatting = newFormatting;
        return [section];
    }
}
function handleVideoFile(section, name) {
    const imageFile = imageFileFindByName(name);
    const results = imageFile.image_url;
    section.link = results;
    return results;
}
function handleSingleImageFile(section, name) {
    const imageFile = imageFileFindByName(name);
    const results = imageFile.image_url;
    section.link = results;
    return results;
}
function handleImageSection(section, name, formatting) {
    const imageFile = imageFileFindByName(name);
    if (imageFile.image_url) {
        const caption = imageFile.caption;
        const containsOnlyPTagsOrNoHTML = /^(\s*<p>.*?<\/p>\s*)*$/i.test(caption);
        let description;
        if (containsOnlyPTagsOrNoHTML)
            description = `<div class='display-4 fw-bold mb-1 text-dark'>${caption}</div>`;
        else
            description = caption;
        section.link = imageFile.image_url;
        const [subsection, updatedFormatting] = buildSubsection(section, imageFile, formatting);
        return [imageFile.image_url, description, subsection, updatedFormatting];
    }
    else {
        return [missingImageUrl(), "", null, null];
    }
}
function buildSubsection(section, imageFile, formatting) {
    const subsection = JSON.parse(JSON.stringify(section));
    subsection.link = null;
    subsection.image = null;
    subsection.formatting = flipFormattingSide(formatting);
    subsection.description = imageFile.description;
    if (formatting && 'expanding_rows' in formatting)
        delete formatting.expanding_rows;
    return [subsection, formatting];
}
function swapClasses(formatting) {
    if (formatting.text_classes && formatting.image_classes) {
        formatting.image_classes = formatting.image_classes.replace(/w-\d{2,3}/g, "");
        const temp = formatting.image_classes;
        formatting.image_classes = formatting.text_classes;
        formatting.text_classes = temp;
    }
    if (formatting.row_classes) {
        formatting.row_classes = formatting.row_classes.replace(/mt-\d|pt-\d/g, "");
    }
    return formatting;
}
function flipFormattingSide(formatting) {
    let newFormatting = JSON.parse(JSON.stringify(formatting));
    if (!formatting || Object.keys(formatting).length === 0) {
        return { row_style: "text-right" };
    }
    if (newFormatting.row_style === "text-left") {
        newFormatting.row_style = "text-right";
        swapClasses(newFormatting);
    }
    else {
        newFormatting.row_style = "text-left";
        swapClasses(newFormatting);
    }
    return newFormatting;
}
RenderSection.propTypes = {
    section: PropTypes.shape({
        content_type: PropTypes.string,
        section_name: PropTypes.string,
        section_order: PropTypes.number,
        image: PropTypes.string,
        link: PropTypes.string,
        formatting: PropTypes.any,
        description: PropTypes.string,
        row_style: PropTypes.string,
        text_margin_top: PropTypes.string,
        text_margin_left: PropTypes.string,
        text_margin_right: PropTypes.string,
        text_margin_bottom: PropTypes.string,
        text_background_color: PropTypes.string,
        image_margin_top: PropTypes.string,
        image_margin_left: PropTypes.string,
        image_margin_right: PropTypes.string,
        image_margin_bottom: PropTypes.string,
        image_background_color: PropTypes.string,
    }).isRequired, // Use `.isRequired` here,
    editing: PropTypes.bool,
    noBorder: PropTypes.bool,
    noHidden: PropTypes.bool,
    onChange: PropTypes.any
};
export default RenderSection;
