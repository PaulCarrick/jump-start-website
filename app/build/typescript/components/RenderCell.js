import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// /app/javascripts/components/RenderCell.jsx
// noinspection RegExpRedundantEscape
// Component to Display Cell Records
import React from "react";
import DisplayContent from "./DisplayContent";
import { dupObject } from "./utilities";
import { getAdminPaths } from "../services/utilities";
import { handleImageGroup, handleImageArray, imageFileFindByName, } from "./imageProcessingUtilities.jsx";
const RenderCell = ({ cell = null, editing = false, noBorder = true, noHidden = false, onChange = null }) => {
    if (cell === null)
        return; // We can't render what we don't have
    const cellData = dupObject(cell);
    const processedCell = processCell(cellData);
    return (renderCell(processedCell, editing, noBorder, noHidden, onChange));
};
// Utility Functions
function renderCell(cell, editing = false, noBorder = false, noHidden = false, onChange = null) {
    if (cell == null)
        return "";
    let divClass;
    let urls;
    if (noBorder)
        divClass = "w-100 m-0 p-3";
    else
        divClass = "w-100 border border-danger border-width-8";
    if (editing) {
        urls = getAdminPaths("cells", cell.id);
        if (onChange && cell) {
            return (_jsxs(_Fragment, { children: [_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-4", children: _jsx("a", { href: "#", onClick: (e) => {
                                        e.preventDefault();
                                        if (onChange)
                                            onChange(cell, "edit");
                                    }, children: "Edit Column" }) }), _jsx("div", { className: "col-4", children: _jsx("a", { href: "#", "data-confirm": "Are you sure?", onClick: (e) => {
                                        e.preventDefault();
                                        if (onChange)
                                            onChange(cell.index, "delete");
                                    }, children: "Delete Column" }) }), _jsx("div", { className: "col-4" })] }), _jsx("div", { className: "row mb-2", children: _jsx("div", { className: divClass, children: _jsx(DisplayContent, { content: cell.content, image: cell.image, link: cell.link, format: cell.formatting, cellId: cell.cell_name, noHidden: noHidden }) }, cell.index) })] }));
        }
        else if (urls) {
            return (_jsxs(_Fragment, { children: [_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-4", children: urls?.edit?.url && (_jsx("a", { href: urls?.edit?.url, target: "_self", "data-turbo": "false", "data-turbolinks": "false", children: "Edit Column" })) }), _jsx("div", { className: "col-4", children: urls?.delete?.url && (_jsx("a", { href: urls["delete"]["url"], "data-confirm": "Are you sure?", children: "Delete Column" })) }), _jsx("div", { className: "col-4" })] }), _jsx("div", { className: "row mb-2", children: _jsx("div", { id: "cellAttributes", className: divClass, children: _jsx(DisplayContent, { content: cell.content, image: cell.image, link: cell.link, format: cell.formatting, cellId: cell.cell_name, noHidden: noHidden }) }) })] }));
        }
        else {
            return (_jsx("div", { className: "row mb-2", children: _jsx("div", { id: "cellAttributes", className: divClass, children: _jsx(DisplayContent, { content: cell.content, image: cell.image, link: cell.link, format: cell.formatting, cellId: cell.cell_name, noHidden: noHidden }) }) }));
        }
    }
    else {
        return (_jsx("div", { className: "row mb-2", children: _jsx("div", { id: "cellAttributes", className: divClass, children: _jsx(DisplayContent, { content: cell.content, image: cell.image, link: cell.link, format: cell.formatting, cellId: cell.cell_name, noHidden: noHidden }) }) }));
    }
}
function processCell(cell) {
    if ((cell === null) || (cell.image === null))
        return cell;
    const imageGroupRegex = /^\s*ImageGroup:\s*(.+)\s*$/;
    const videoRegex = /^\s*VideoImage:"(.+)"$/;
    const imageFileRegex = /^\s*ImageFile:\s*(.+)\s*$/;
    const imageArrayRegex = /^\s*\[\s*(.+?)\s*\]\s*$/m;
    let newImages = cell.image.slice().trim();
    let newFormatting = dupObject(cell.formatting);
    let match;
    switch (true) {
        case imageGroupRegex.test(newImages):
            match = newImages.match(imageGroupRegex);
            [newImages, newFormatting] = handleImageGroup(match[1], cell.formatting);
            break;
        case videoRegex.test(newImages):
            match = newImages.match(videoRegex);
            newImages = handleVideoFile(cell, match[1]);
            break;
        case imageFileRegex.test(newImages):
            match = newImages.match(imageFileRegex);
            newImages = handleSingleImageFile(cell, match[1]);
            break;
        case imageArrayRegex.test(newImages):
            match = newImages.match(imageArrayRegex);
            [newImages, newFormatting] = handleImageArray(match[1], cell.formatting);
            break;
        default:
            if (typeof newImages === "string")
                newImages = handleSingleImageFile(cell, newImages);
            else
                newImages = newImages.image_url;
    }
    cell.image = newImages;
    cell.formatting = newFormatting;
    return cell;
}
function handleVideoFile(cell, name) {
    const imageFile = imageFileFindByName(name);
    const results = imageFile.image_url;
    cell.link = results;
    return results;
}
function handleSingleImageFile(cell, name) {
    if (cell === null)
        return cell;
    const imageFile = imageFileFindByName(name);
    const results = imageFile.image_url;
    cell.link = results;
    return results;
}
import PropTypes from 'prop-types';
RenderCell.propTypes = {
    cell: PropTypes.shape({
        id: PropTypes.number,
        section_name: PropTypes.string,
        cell_name: PropTypes.string,
        cell_order: PropTypes.number,
        content: PropTypes.string,
        image: PropTypes.string,
        link: PropTypes.string,
        formatting: PropTypes.any,
    }).isRequired, // Use `.isRequired` here,
    editing: PropTypes.bool,
    noBorder: PropTypes.bool,
    noHidden: PropTypes.bool,
    onChange: PropTypes.any
};
export default RenderCell;
