import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// app/javascript/components/renderUtilities.jsx
// Utilities to render controls
import { useState } from "react";
import HtmlEditor from "./HtmlEditor";
import { createImageFile } from "../services/imageFileService";
import { renderComboBox, renderSelect, renderInput } from "./renderControlFunctions";
// Function to render description input
export function renderContent(attribute = "content", description = "", setValue = null, useHtmlView = null) {
    return (_jsxs("div", { className: "row mb-2", style: { minHeight: "15em" }, children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Content:" }), _jsx("div", { className: "col-10", children: _jsx("div", { id: "contentDiv", children: _jsx(HtmlEditor, { id: attribute, value: description ?? undefined, placeholder: "Enter the text to be displayed in the text part of the section", onChange: setValue, onBlur: setValue, useHtmlView: useHtmlView ? useHtmlView : undefined }) }) })] }));
}
// Function to render image selection
export function renderImage(image, imageType, availableImagesData, availableImageGroupsData, availableVideosData, setValue) {
    const [uploadedImage, setUploadedImage] = useState(null);
    const [imageName, setImageName] = useState(""); // New state for image name
    const [selectedFile, setSelectedFile] = useState(null); // Store file before submission
    let optionsHash = [];
    switch (imageType) {
        case "Groups":
            if (availableImageGroupsData)
                optionsHash = availableImageGroupsData.map((item) => ({
                    label: item,
                    value: item,
                }));
            break;
        case "Videos":
            if (availableVideosData)
                optionsHash = availableVideosData.map((item) => ({
                    label: item,
                    value: item,
                }));
            break;
        default:
            if (availableImagesData)
                optionsHash = availableImagesData.map((item) => ({
                    label: item,
                    value: item,
                }));
            break;
    }
    const handleFileChange = (event) => {
        const file = event.target.files?.[0];
        if (file) {
            setSelectedFile(file); // Store file for later upload
            const reader = new FileReader();
            reader.onloadend = () => {
                setUploadedImage(reader.result);
            };
            reader.readAsDataURL(file);
        }
    };
    const handleUpload = () => {
        if (!selectedFile || !imageName.trim()) {
            alert("Please select an image and enter a name.");
            return;
        }
        const imageFile = {
            name: imageName.trim(),
            mime_type: selectedFile.type,
        };
        createImageFile(imageFile, selectedFile);
        setValue("image", imageName.trim());
        setUploadedImage(null);
        setImageName("");
    };
    if (!image && imageType === "Upload") {
        return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Upload Image:" }), _jsxs("div", { className: "col-7", children: [_jsx("input", { type: "file", accept: "image/*", onChange: handleFileChange, className: "form-control" }), uploadedImage && (_jsxs(_Fragment, { children: [_jsx("div", { className: "mt-2", children: _jsx("img", { src: uploadedImage, alt: "Uploaded", className: "img-fluid", style: { maxHeight: "150px" } }) }), _jsx("input", { type: "text", className: "form-control mt-2", placeholder: "Enter image name", value: imageName, onChange: (e) => setImageName(e.target.value) }), _jsx("button", { type: "button", className: "btn btn-primary mt-2", onClick: handleUpload, children: "Upload Image" })] }))] }), _jsx("div", { id: "imageTypeDiv", className: "col-3", children: renderSelect("image_type", imageType, [
                        { label: "Image", value: "Images" },
                        { label: "Image Section", value: "Section" },
                        { label: "Image Group", value: "Groups" },
                        { label: "Video", value: "Videos" },
                        { label: "Upload", value: "Upload" },
                    ], setValue) })] }));
    }
    else {
        return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Image:" }), _jsx("div", { className: "col-7", children: _jsx("div", { id: "imageDiv", children: renderComboBox("image", image, optionsHash, setValue) }) }), _jsx("div", { id: "imageTypeDiv", className: "col-3", children: renderSelect("image_type", imageType, [
                        { label: "Image", value: "Images" },
                        { label: "Image Section", value: "Section" },
                        { label: "Image Group", value: "Groups" },
                        { label: "Video", value: "Videos" },
                        { label: "Upload", value: "Upload" },
                    ], setValue) })] }));
    }
}
export function renderContentType(contentType = "", availableContentTypesData = [], setValue = null, readOnlyContentType = false) {
    const optionsHash = availableContentTypesData.map((item) => ({
        label: item,
        value: item,
    }));
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Content Type:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "contentTypeDiv", children: renderComboBox("content_type", contentType, optionsHash, setValue, readOnlyContentType ?? false) }) })] }));
}
export function renderTitle(title = "", setValue = null) {
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Page Title:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "titleDiv", children: renderInput("title", title, setValue, null, {}, "Enter the title for the page") }) })] }));
}
export function renderPageName(pageName = "", setValue = null) {
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Page Name*:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "pageNameDiv", children: renderInput("name", pageName, setValue, null, { required: true }, "Enter the name for the page (required and must be unique)") }) })] }));
}
export function renderAccess(access = "", setValue = null) {
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Page Access:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "titleDiv", children: renderInput("access", access, setValue, null, {}, "Enter the access for the page") }) })] }));
}
export function renderSectionName(sectionName = "", availableContentTypesData = [], setValue = null, readOnlySectionName = false, attribute = "section_name") {
    if (availableContentTypesData) {
        const optionsHash = availableContentTypesData.map((item) => ({
            label: item,
            value: item,
        }));
        return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Content Type:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "sectionNameDiv", children: renderComboBox(attribute, sectionName, optionsHash, setValue, readOnlySectionName ?? false) }) })] }));
    }
    else {
        return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Section Name*:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "sectionNameDiv", children: renderInput(attribute, sectionName, setValue, null, { required: true }, "Enter the name for the section (required and must be unique)") }) })] }));
    }
}
export function renderCellName(cellName = "", setValue = null) {
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Column Name*:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "cellNameDiv", children: renderInput("cell_name", cellName, setValue, null, { required: true }, "Enter the name for the column (required and must be unique)") }) })] }));
}
export function renderSectionOrder(sectionOrder = 1, setValue = null) {
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Section Order:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "sectionOrderDiv", children: renderInput("section_order", sectionOrder, setValue, null, {}, "Enter the order of the section (1 is first)", "number") }) })] }));
}
export function renderCellOrder(cellOrder = 1, setValue = null) {
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Column Order:" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "cellOrderDiv", children: renderInput("cell_order", cellOrder, setValue, null, {}, "Enter the order of the column (1 is first)", "number") }) })] }));
}
export function renderLink(link, setValue = null) {
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Link (URL):" }), _jsx("div", { className: "col-5", children: _jsx("div", { id: "linkDiv", children: renderInput("link", link, setValue, null, {}, "Enter the URL to be opened when an image is clicked (optional)") }) })] }));
}
