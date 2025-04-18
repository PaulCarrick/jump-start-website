import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// app/javascript/components/PageEditor.tsx
import ErrorBoundary from "./ErrorBoundary";
import SectionEditor from "./SectionEditor";
import GeneratePage from "./GeneratePage";
import RenderSection from "./RenderSection";
import { useState, useCallback } from "react";
import { createPage, hasSections, newPage, updatePage } from "../services/pageService";
import { sortSections } from "../services/sectionService";
import { renderAccess, renderPageName, renderSectionName, renderTitle } from "./renderUtilities";
import GenerateSections from "./GenerateSections";
const PageEditor = ({ page = null, options = {} }) => {
    const [pageData, setPageData] = useState(newPage(page || {}, options));
    const [editingSection, setEditingSection] = useState(null);
    const [needPage, setNeedPage] = useState(page === null);
    const [newSection, setNewSection] = useState(null);
    const [error, setError] = useState(null);
    // OnChange/OnBlur Callback
    // noinspection com.intellij.reactbuddy.ExhaustiveDepsInspection
    const setValue = useCallback((newValue, attribute) => {
        setPageData((prev) => {
            if (!prev)
                prev = newPage({}, options);
            if (attribute === "name") {
                return {
                    ...prev,
                    name: newValue,
                    section: newValue,
                };
            }
            return {
                ...prev,
                [attribute]: newValue,
            };
        });
    }, []);
    const handleGenerate = (page) => {
        setPageData(page);
        setNeedPage(false);
    };
    const createNewSection = () => {
        setNewSection(true);
    };
    const handleAction = (index, action) => {
        if (pageData.sections && pageData.sections.length > index) {
            if (action === "edit") {
                setEditingSection(index);
            }
            else if (action === "delete") {
                setEditingSection(null);
                setPageData(prev => {
                    if (!prev || !prev.sections)
                        return prev;
                    const updatedSections = [...(prev.sections)];
                    updatedSections.splice(index, 1);
                    return {
                        ...prev,
                        sections: sortSections(updatedSections),
                    };
                });
            }
        }
    };
    const finishedNewSection = (sections) => {
        if (sections) {
            setPageData(prev => {
                if (!prev)
                    prev = newPage({}, options);
                let updatedSections = [...(prev.sections ?? [])];
                updatedSections = updatedSections.concat(sections);
                return {
                    ...prev,
                    sections: sortSections(updatedSections),
                };
            });
        }
        setNewSection(false);
    };
    const finishedEditingSection = (section) => {
        if (editingSection !== null && pageData.sections && pageData.sections.length > editingSection) {
            setPageData(prev => {
                if (!prev)
                    prev = newPage({}, options);
                const updatedSections = [...prev.sections];
                updatedSections[editingSection] = section;
                return {
                    ...prev,
                    sections: updatedSections
                };
            });
            setEditingSection(null);
        }
    };
    const handleSubmit = () => {
        let result = null;
        if (!pageData) {
            setError("No page data to save!");
            return;
        }
        if (pageData.id)
            result = updatePage(pageData, setError);
        else
            result = createPage(pageData, setError);
        if (result && options.returnUrl)
            window.location.href = options.returnUrl;
    };
    const handleCancel = () => {
        if (options.cancelUrl)
            window.location.href = options.cancelUrl;
    };
    //*** Main Render Routine ***//
    if (needPage) {
        return (_jsx(ErrorBoundary, { children: _jsx("div", { children: _jsx(GeneratePage, { title: "New Page", name: options.defaultPageName, section: options.defaultPageName, options: options, onFinished: handleGenerate }) }) }));
    }
    else if (newSection) {
        return (_jsx(ErrorBoundary, { children: _jsx("div", { children: _jsx(GenerateSections, { name: options.defaultSectionName, page: pageData, options: options, onFinished: finishedNewSection }) }) }));
    }
    else if (editingSection !== null && pageData.sections && pageData.sections.length > editingSection) {
        return (_jsx(ErrorBoundary, { children: _jsx("div", { children: _jsx(SectionEditor, { section: pageData.sections[editingSection], contentType: pageData.section, options: options, onFinished: finishedEditingSection }) }) }));
    }
    else {
        return (_jsxs(ErrorBoundary, { children: [error && (_jsx("div", { className: "row", children: _jsx("div", { className: "error-box", children: error }) })), renderTitle(pageData.title, setValue), renderPageName(pageData.name, setValue), renderSectionName(pageData.section, null, setValue), renderAccess(pageData.access, setValue), _jsx("div", { className: "row border-bottom border-dark mb-2 ms-1 me-1", children: _jsx("div", { className: "col-12 text-center", children: _jsx("h1", { children: "Preview" }) }) }), _jsx("div", { className: "row mb-2", children: _jsx("div", { className: "col-12", children: _jsx("div", { className: "RenderPageDataDiv", children: pageData.sections && pageData.sections.length > 0 ? (pageData.sections.map((section, index) => (_jsx("div", { className: "section", children: _jsx(RenderSection, { section: section, editing: false, noBorder: true, noHidden: false, onChange: handleAction }) }, index)))) : (_jsx("p", { className: "text-center border-bottom border-dark me-1", children: _jsx("h2", { children: "No Contents" }) })) }) }) }), _jsx("div", { className: "row mb-2", children: hasSections(pageData) ? (_jsxs(_Fragment, { children: [_jsx("div", { className: "col-2", children: _jsx("button", { type: "button", className: "btn btn-primary", style: { minWidth: "8em", maxWidth: "8em" }, onClick: handleSubmit, children: "Save Page" }) }), _jsxs("div", { className: "col-5", children: [_jsx("button", { type: "button", className: "btn btn-secondary", style: { minWidth: "8em", maxWidth: "8em" }, onClick: handleCancel, children: "Cancel" }), _jsx("button", { type: "button", className: "btn btn-secondary ms-2", style: { minWidth: "8em", maxWidth: "8em" }, onClick: createNewSection, children: "New Section" })] })] })) : (_jsxs(_Fragment, { children: [_jsx("div", { className: "col-2", children: _jsx("button", { type: "button", className: "btn btn-primary", style: { minWidth: "8em", maxWidth: "8em" }, onClick: createNewSection, children: "New Section" }) }), _jsx("button", { type: "button", className: "btn btn-secondary ms-2", style: { minWidth: "8em", maxWidth: "8em" }, onClick: handleSubmit, children: "Save Page" }), _jsx("div", { className: "col-5", children: _jsx("button", { type: "button", className: "btn btn-secondary", style: { minWidth: "8em", maxWidth: "8em" }, onClick: handleCancel, children: "Cancel" }) })] })) })] }));
    }
};
export default PageEditor;
