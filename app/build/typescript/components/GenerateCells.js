import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
// app/javascript/components/GenerateCells.tsx
import { isPresent } from "./utilities";
import { renderSelect } from "./renderControlFunctions";
import { generateCells } from "../services/cellService";
import { renderContent } from "./renderUtilities";
import { useEffect, useRef, useState } from "react";
import RenderImageControl from "./RenderImageControl";
const GenerateCells = ({ sectionName = null, options = {}, onFinished = null }) => {
    const [cellTemplate, setCellTemplate] = useState("");
    const [needImage, setNeedImage] = useState(false);
    const [needContent, setNeedContent] = useState(false);
    const [content, setContent] = useState(null);
    const [image, setImage] = useState(null);
    const [imageMode, setImageMode] = useState("Images");
    const textTemplates = [
        "text-single",
        "text-top",
        "text-bottom",
        "text-right",
        "text-left"
    ];
    const imageTemplates = [
        "image-single",
        "text-top",
        "text-bottom",
        "text-right",
        "text-left"
    ];
    const previousImageMode = useRef(imageMode);
    useEffect(() => {
        if (previousImageMode.current !== imageMode)
            setImage(null);
    }, [imageMode]);
    // OnChange/OnBlur Callback
    const setValue = (newValue, attribute) => {
        switch (attribute) {
            case "cellTemplates":
                setCellTemplate(newValue);
                setNeedContent(textTemplates.includes(newValue));
                setNeedImage(imageTemplates.includes(newValue));
                break;
            case "content":
                setContent(newValue);
                break;
            case "image":
                setImage(newValue);
                break;
            case "image_type":
                setImageMode(newValue);
                break;
        }
    };
    const handleGenerate = () => {
        const name = sectionName ? sectionName : "new-section";
        const cells = isPresent(cellTemplate) ?
            generateCells(name, cellTemplate, content, image, imageMode)
            :
                generateCells(name, "generic-cell", content, image, imageMode);
        if (onFinished)
            onFinished(cells);
    };
    return (_jsxs("div", { id: "GenerateCells", children: [_jsx("div", { className: "row", children: _jsx("div", { className: "col-12", children: selectCellTemplates(cellTemplate, setValue) }) }), needContent && renderContent("content", content, setValue), needImage && (_jsx(RenderImageControl, { image: image, imageType: imageMode, availableImagesData: options?.availableImages || [], availableImageGroupsData: options?.availableImageGroups || [], availableVideosData: options?.availableVideos || [], setValue: setValue })), _jsx("div", { className: "row", children: _jsx("button", { onClick: handleGenerate, className: "btn btn-primary me-2", style: { maxWidth: "12em" }, children: "Generate Columns" }) })] }));
};
// *** Render Functions ***/
export function selectCellTemplates(value, setValue) {
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Templates:" }), _jsx("div", { className: "col-5", children: renderSelect("cellTemplates", value, [
                    { label: "Text Only", value: "text-single" },
                    { label: "Image Only", value: "image-single" },
                    { label: "Dual Column - Text Left", value: "text-left" },
                    { label: "Dual Column - Text Right", value: "text-right" },
                    { label: "Three Column", value: "three-column" },
                    { label: "Four Column", value: "four-column" },
                    { label: "Five Column", value: "five-column" },
                ], setValue) })] }));
}
// *** Utility Functions ***/
export default GenerateCells;
