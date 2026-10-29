import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
// app/javascript/components/GenerateSections.tsx
import RenderImageControl from "./RenderImageControl";
import { isPresent } from "./utilities";
import { renderSelect } from "./renderControlFunctions";
import { generateSections } from "../services/sectionService";
import { renderContent, renderSectionName } from "./renderUtilities";
import { useEffect, useRef, useState } from "react";
import ErrorBoundary from "./ErrorBoundary";
const GenerateSections = ({ name = null, page = null, options = {}, onFinished = null }) => {
    const [sectionName, setSectionName] = useState(name);
    const [sectionOrder, setSectionOrder] = useState(1);
    const [sectionTemplate, setSectionTemplate] = useState("");
    const [needImage, setNeedImage] = useState(false);
    const [needContent, setNeedContent] = useState(false);
    const [content, setContent] = useState(null);
    const [caption, setCaption] = useState(null);
    const [image, setImage] = useState(null);
    const [imageMode, setImageMode] = useState("Images");
    const [error, setError] = useState(null);
    const textTemplates = [
        "text-single",
        "text-top",
        "text-bottom",
        "text-right",
        "text-left",
        "header-section"
    ];
    const imageTemplates = [
        "image-single",
        "text-top",
        "text-bottom",
        "text-right",
        "text-left",
        "header-section"
    ];
    const previousImageMode = useRef(imageMode);
    useEffect(() => {
        if (previousImageMode.current !== imageMode)
            setImage(null);
    }, [imageMode]);
    // OnChange/OnBlur Callback
    const setValue = (newValue, attribute) => {
        switch (attribute) {
            case "section_name":
                setSectionName(newValue);
                break;
            case "section_order":
                setSectionOrder(Number(newValue));
                break;
            case "section_templates":
                setSectionTemplate(newValue);
                setNeedContent(textTemplates.includes(newValue));
                setNeedImage(imageTemplates.includes(newValue));
                break;
            case "caption":
                setCaption(newValue);
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
    const canGenerate = () => {
        let result = isPresent(sectionTemplate) && isPresent(sectionName);
        if (result && needContent)
            result = isPresent(content);
        if (result && needImage)
            result = isPresent(image);
        return result;
    };
    const handleGenerate = () => {
        if (!sectionName || !isPresent(sectionName)) {
            setError("You cannot save a section without a name");
            return;
        }
        const contentType = page?.section ? page.section : null;
        const sections = isPresent(sectionTemplate) ?
            generateSections(sectionName, contentType, sectionTemplate, content, image, imageMode, sectionOrder, caption || undefined)
            :
                generateSections(sectionName, contentType, "generic-section", content, image, imageMode, sectionOrder, caption || undefined);
        if (onFinished)
            onFinished(sections);
    };
    return (_jsxs(ErrorBoundary, { children: [error && (_jsx("div", { className: "row", children: _jsx("div", { className: "error-box", children: error }) })), _jsxs("div", { id: "GenerateSections", children: [renderSectionName(sectionName, null, setValue), _jsx("div", { className: "row", children: _jsx("div", { className: "col-12", children: selectSectionTemplates(sectionTemplate, setValue) }) }), needContent && renderContent("content", content, setValue), (sectionTemplate === "header-section") && renderContent("caption", caption, setValue), needImage && (_jsx(RenderImageControl, { image: image, imageType: imageMode, availableImagesData: options?.availableImages || [], availableImageGroupsData: options?.availableImageGroups || [], availableVideosData: options?.availableVideos || [], setValue: setValue })), canGenerate() && (_jsx("div", { className: "row", children: _jsx("button", { onClick: handleGenerate, className: "btn btn-primary me-2", style: { maxWidth: "12em" }, children: "Generate Sections" }) }))] })] }));
};
// *** Render Functions ***/
export function selectSectionTemplates(value, setValue) {
    return (_jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2 d-flex align-items-center", children: "Templates:" }), _jsx("div", { className: "col-5", children: renderSelect("section_templates", value, [
                    { label: "Text Only", value: "text-single" },
                    { label: "Image Only", value: "image-single" },
                    { label: "Dual Column - Text Left", value: "text-left" },
                    { label: "Dual Column - Text Right", value: "text-right" },
                    { label: "Three Column", value: "three-column" },
                    { label: "Four Column", value: "four-column" },
                    { label: "Five Column", value: "five-column" },
                    { label: "Dual Row - Text Top", value: "text-top" },
                    { label: "Dual Row - Text Bottom", value: "text-bottom" },
                    { label: "Header Section", value: "header-section" }
                ], setValue) })] }));
}
export default GenerateSections;
