import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
// app/javascript/components/SectionEditor.tsx
import RenderSection from "./RenderSection";
import ErrorBoundary from "./ErrorBoundary";
import GenerateCells from "./GenerateCells";
import CellEditor from "./CellEditor";
import { useState, useEffect } from "react";
import { createSection, genericSection, hasCells, updateSection } from "../services/sectionService";
import { renderSectionOrder, renderSectionName } from "./renderUtilities";
import { dupObject } from "./utilities";
import { isPresent } from "./utilities";
const SectionEditor = ({ section = null, contentType = null, options = {}, onFinished = null }) => {
    const [sectionData, setSectionData] = useState(null);
    const [savedSectionData, setSavedSectionData] = useState(null);
    const [editingCell, setEditingCell] = useState(null);
    const [error, setError] = useState(null);
    useEffect(() => {
        if (!sectionData) {
            let newSectionData = null;
            if (section) {
                newSectionData = section;
            }
            else if (options.newSection) {
                if (!contentType)
                    contentType = "new-page";
                newSectionData = genericSection("new-section", contentType);
            }
            if (newSectionData) {
                setSectionData(newSectionData);
                setSavedSectionData(dupObject(newSectionData));
            }
        }
    }, [section]);
    if (!sectionData) {
        if (section)
            setSectionData(section);
        else
            setError("No section exists to edit!");
    }
    // OnChange/OnBlur Callback
    const setValue = (newValue, attribute) => {
        setSectionData(prev => {
            if (!prev)
                return null;
            switch (attribute) {
                case "sectionName":
                    return { ...prev, section_name: newValue };
                case "sectionOrder":
                    return { ...prev, section_order: Number(newValue) };
                default:
                    return prev;
            }
        });
    };
    const cellsGenerated = (cells) => {
        setSectionData(prev => {
            if (!prev)
                return null; // Handle the case where prev is null
            return {
                ...prev,
                cells,
                section_name: prev.section_name ?? "new-section",
            };
        });
    };
    const handleAction = (index, action) => {
        if (sectionData?.cells && sectionData.cells.length > index) {
            if (action === "edit") {
                setEditingCell(index);
            }
            else if (action === "delete") {
                setEditingCell(null);
                setSectionData(prev => {
                    if (!prev)
                        return null;
                    const updatedCells = [...prev.cells];
                    updatedCells.splice(index, 1);
                    return {
                        ...prev,
                        cells: updatedCells,
                        section_name: prev.section_name ?? "new-section",
                    };
                });
            }
        }
    };
    const finishedEditingCell = (cell) => {
        if (editingCell !== null && sectionData?.cells && sectionData.cells.length > editingCell) {
            setSectionData(prev => {
                if (!prev)
                    return null;
                const updatedCells = [...prev.cells];
                updatedCells[editingCell] = cell;
                return {
                    ...prev,
                    cells: updatedCells,
                    section_name: prev.section_name ?? "new-section",
                };
            });
            setEditingCell(null);
        }
    };
    const handleSubmit = () => {
        let result = null;
        if (!sectionData)
            return;
        if (isPresent(sectionData?.cells)) {
            sectionData?.cells.forEach(cell => {
                if (cell.id === -1)
                    cell.id = null;
                if (!cell.section_name || (cell.section_name && cell.section_name.trim() !== ''))
                    cell.section_name = sectionData.section_name;
                if (sectionData.id && !cell.section_id)
                    cell.section_id = sectionData.id;
            });
        }
        else {
            setError("You cannot save a section with no columns!");
            return;
        }
        if (onFinished) {
            onFinished(sectionData);
            return;
        }
        if (isPresent(sectionData?.id))
            result = updateSection(sectionData);
        else
            result = createSection(sectionData);
        if (result && options.returnUrl)
            window.location.href = options.returnUrl;
    };
    const handleCancel = () => {
        if (onFinished) {
            onFinished(savedSectionData);
            return;
        }
        else if (options.cancelUrl) {
            window.location.href = options.cancelUrl;
        }
    };
    if (!hasCells(sectionData)) {
        return (_jsx("div", { children: _jsx(GenerateCells, { sectionName: sectionData?.section_name, options: options, onFinished: cellsGenerated }) }));
    }
    else if (editingCell !== null && sectionData?.cells && sectionData.cells.length > editingCell) {
        return (_jsx("div", { children: _jsx(CellEditor, { cell: sectionData.cells[editingCell], sectionName: sectionData?.section_name, editorOptions: options, onFinished: finishedEditingCell }) }));
    }
    else {
        return (_jsx(ErrorBoundary, { children: _jsxs("div", { children: [error && (_jsx("div", { className: "row", children: _jsx("div", { className: "error-box", children: error }) })), renderSectionName(sectionData?.section_name, options.availableSectionNames, setValue, options.readOnlySectionName), renderSectionOrder(sectionData?.section_order, setValue), _jsx("div", { className: "row mb-2", children: _jsx("div", { id: "sectionPreview", className: "w-100 border border-danger border-width-8", children: !sectionData ? (_jsx("h1", { className: "text-center", children: "No Contents" })) : (_jsx(RenderSection, { section: sectionData, editing: false, noBorder: true, noHidden: false, onChange: handleAction })) }) }), _jsxs("div", { className: "row mb-2", children: [_jsx("div", { className: "col-2", children: _jsx("button", { type: "button", className: "btn btn-primary", onClick: handleSubmit, children: "Save Section" }) }), _jsx("div", { className: "col-2", children: _jsx("button", { type: "button", className: "btn btn-secondary", onClick: handleCancel, children: "Cancel" }) })] })] }) }));
    }
};
export default SectionEditor;
