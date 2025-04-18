import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
// app/javascript/components/RenderImageControl.tsx
import { useState } from "react";
const RenderImageControl = ({ image, imageType, availableImagesData, availableImageGroupsData, availableVideosData, setValue }) => {
    const [uploadedImage, setUploadedImage] = useState(null);
    const [imageName, setImageName] = useState("");
    const [selectedFile, setSelectedFile] = useState(null);
    let optionsHash = [];
    switch (imageType) {
        case "Groups":
            if (availableImageGroupsData)
                optionsHash = availableImageGroupsData.map(item => ({
                    label: item,
                    value: item,
                }));
            break;
        case "Videos":
            if (availableVideosData)
                optionsHash = availableVideosData.map(item => ({
                    label: item,
                    value: item,
                }));
            break;
        default:
            if (availableImagesData)
                optionsHash = availableImagesData.map(item => ({
                    label: item,
                    value: item,
                }));
            break;
    }
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Image:" }), _jsx("div", { className: "col-5", children: _jsxs("select", { className: "form-select", value: image || "", onChange: (e) => setValue(e.target.value, "image"), children: [_jsx("option", { value: "", children: "-- Select an image --" }), optionsHash.map(({ label, value }) => (_jsx("option", { value: value, children: label }, value)))] }) })] }));
};
export default RenderImageControl;
