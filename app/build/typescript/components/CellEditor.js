import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
// app/javascript/components/CellEditor.tsx
import RenderCell from "./RenderCell";
import ErrorBoundary from "./ErrorBoundary";
import { createCell, genericCell, updateCell } from "../services/cellService";
import { useState, useEffect, useRef } from "react";
import { renderContent, renderImage, renderLink, renderCellOrder, renderSectionName, renderCellName } from "./renderUtilities";
import FormattingEditor from "./FormattingEditor";
import { dupObject } from "./utilities";
const CellEditor = ({ cell = null, sectionName = null, editorOptions = {}, onFinished = null, onChange = null }) => {
    const [cellData, setCellData] = useState(null);
    const [savedCellData, setSavedCellData] = useState(null);
    const [imageMode, setImageMode] = useState("Images");
    const [error, setError] = useState(null);
    const previousImageMode = useRef(imageMode);
    useEffect(() => {
        if (previousImageMode.current !== imageMode) {
            setCellData(prev => {
                if (!prev)
                    return null;
                return { ...prev, image: "" };
            });
            previousImageMode.current = imageMode;
        }
    }, [imageMode]);
    useEffect(() => {
        if (!cellData) {
            let newCellData = null;
            if (cell)
                newCellData = cell;
            else if (editorOptions.newCell)
                newCellData = genericCell(sectionName || "new-section");
            if (newCellData) {
                setCellData(newCellData);
                setSavedCellData(dupObject(newCellData));
            }
        }
    }, [cell]);
    if (!cellData) {
        if (cell) {
            setCellData(cell);
        }
        else {
            if (!editorOptions?.newCell)
                setError("No cell exists to edit!");
            setCellData(genericCell("new-section"));
        }
    }
    // OnChange/OnBlur Callback
    const setValue = (newValue, attribute) => {
        if (attribute === "image_type") {
            setImageMode(newValue);
        }
        else {
            setCellData(prev => {
                if (!prev)
                    return null;
                if (attribute === "useHtmlView") {
                    return {
                        ...prev,
                        options: {
                            ...prev.options,
                            html_view: Boolean(newValue)
                        }
                    };
                }
                else {
                    return { ...prev, [attribute]: newValue };
                }
            });
        }
    };
    const handleSubmit = () => {
        let result = null;
        if (!cellData)
            return;
        if (onFinished) {
            onFinished(cellData);
            return;
        }
        if (cellData?.id)
            result = updateCell(cellData, setError);
        else if (cellData?.id)
            result = updateCell(cellData, setError);
        else
            result = createCell(cellData, setError);
        if (result && editorOptions.returnUrl)
            window.location.href = editorOptions.returnUrl;
    };
    const handleCancel = () => {
        if (onFinished) {
            onFinished(savedCellData);
            return;
        }
        else if (editorOptions.cancelUrl) {
            window.location.href = editorOptions.cancelUrl;
        }
    };
    return (_jsx(ErrorBoundary, { children: _jsxs("div", { children: [error && (_jsx("div", { className: "row", children: _jsx("div", { className: "error-box", children: error }) })), renderSectionName(cellData?.section_name, editorOptions.availableSectionNames, setValue, editorOptions.readOnlySectionName), renderCellName(cellData?.cell_name, setValue), _jsx("div", { style: { minHeight: "10em" }, children: renderContent("content", cellData?.content || null, setValue, cellData?.options?.html_view) }), renderImage(cellData?.image || null, imageMode, editorOptions.availableImages || [], editorOptions.availableImageGroups || [], editorOptions.availableVideos || [], setValue), renderLink(cellData?.link || null, setValue), renderCellOrder(cellData?.cell_order, setValue), _jsx(FormattingEditor, { formatting: cellData?.formatting || {}, onChange: setValue }), _jsx("div", { className: "row mb-2 mt-5", children: _jsx("div", { className: "col-4", id: "promptField", children: _jsx("p", { children: "* - Required Fields" }) }) }), _jsx("div", { className: "row mb-2", children: _jsx("div", { id: "cellPreview", className: "w-100 border border-danger border-width-8", children: !cellData ? (_jsx("h1", { className: "text-center", children: "No Contents" })) : (_jsx(RenderCell, { cell: cellData, editing: false, noBorder: true, noHidden: false, onChange: onChange })) }) }), _jsx("div", { className: "row mb-2", children: _jsxs("div", { className: "col-12 d-flex justify-content-start gap-2", children: [_jsx("button", { type: "button", className: "btn btn-primary", onClick: handleSubmit, children: "Save Column" }), _jsx("button", { type: "button", className: "btn btn-secondary", onClick: handleCancel, children: "Cancel" })] }) })] }) }));
};
export default CellEditor;
