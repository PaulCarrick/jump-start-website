import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
// app/javascript/components/GeneratePage.tsx
import { useState } from "react";
import ErrorBoundary from "./ErrorBoundary";
import { renderTitle, renderPageName, renderSectionName, renderAccess } from "./renderUtilities";
import { createPage } from "../services/pageService";
const GeneratePage = ({ title = "New Page", name = null, section = null, access = null, options = {}, onFinished = () => null, }) => {
    if (!name && options.defaultPageName)
        name = options.defaultPageName;
    if (!section && options.defaultPageName)
        section = options.defaultPageName;
    const [pageData, setPageData] = useState({
        id: null,
        title: title || "New Page",
        name: name || "new-page",
        section: section || "new-page",
        sections: [],
        access: access || null
    });
    const [error, setError] = useState(null);
    // OnChange/OnBlur Callback
    const setValue = (newValue, attribute) => {
        setPageData(prev => ({
            ...prev,
            [attribute]: newValue
        }));
    };
    const handleGenerate = () => {
        if (onFinished)
            onFinished(pageData);
        else if (!createPage(pageData))
            setError("Cannot create page!");
        else if (options.returnUrl)
            window.location.href = options.returnUrl;
    };
    return (_jsx("div", { id: "GeneratePage", children: _jsxs(ErrorBoundary, { children: [error && (_jsx("div", { className: "row", children: _jsx("div", { className: "error-box", children: error }) })), _jsxs("div", { id: "GeneratePage", children: [renderTitle(pageData.title, setValue), renderPageName(pageData.name, setValue), renderSectionName(pageData.section, null, setValue, false, 'section'), renderAccess(pageData.access, setValue), _jsxs("div", { className: "row", children: [_jsx("div", { className: "col-2", children: _jsx("button", { onClick: handleGenerate, className: "btn btn-primary me-2", style: { maxWidth: "12em" }, children: "Generate Page" }) }), _jsx("div", { className: "col-5", children: options.cancelUrl && (_jsx("a", { href: options.cancelUrl, className: "btn btn-secondary", style: { maxWidth: "6em" }, children: "Cancel" })) })] })] })] }) }));
};
export default GeneratePage;
