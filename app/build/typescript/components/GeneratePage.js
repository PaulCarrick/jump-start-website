import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// app/javascript/components/GeneratePage.tsx
import { useState } from "react";
import ErrorBoundary from "./ErrorBoundary";
import { renderTitle, renderPageName, renderSectionName, renderAccess } from "./renderUtilities";
import { createPage } from "../services/pageService";
import { isPresent } from "./utilities";
const GeneratePage = ({ title = null, name = null, section = null, access = null, options = {}, onFinished = () => null, menuItem = null, footerItem = null, }) => {
    const [pageData, setPageData] = useState({
        id: null,
        title: title,
        name: name,
        section: section,
        sections: [],
        access: access || null,
        menu_item: menuItem || null,
        footer_item: footerItem || null,
    });
    const [error, setError] = useState(null);
    // OnChange/OnBlur Callback
    const setValue = (newValue, attribute) => {
        setPageData(prev => ({
            ...prev,
            [attribute]: newValue
        }));
    };
    const canGenerate = () => {
        let result = isPresent(pageData.name) && isPresent(pageData.section);
        return result;
    };
    const handleGenerate = () => {
        if (onFinished)
            onFinished(pageData);
        else if (!createPage(pageData))
            setError("Cannot create page!");
        else if (options.returnUrl)
            window.location.href = options.returnUrl;
    };
    return (_jsx("div", { id: "GeneratePage", children: _jsxs(ErrorBoundary, { children: [error && (_jsx("div", { className: "row", children: _jsx("div", { className: "error-box", children: error }) })), _jsxs("div", { id: "GeneratePage", children: [renderTitle(pageData.title, setValue), renderPageName(pageData.name, setValue), renderSectionName(pageData.section, null, setValue, false, 'section'), renderAccess(pageData.access, setValue), canGenerate() ? (_jsx(_Fragment, { children: _jsxs("div", { className: "row", children: [_jsx("div", { className: "col-2", children: _jsx("button", { onClick: handleGenerate, className: "btn btn-primary me-2", style: { maxWidth: "12em" }, children: "Generate Page" }) }), _jsx("div", { className: "col-5", children: options.cancelUrl && (_jsx("a", { href: options.cancelUrl, className: "btn btn-secondary ms-2", style: { maxWidth: "6em" }, children: "Cancel" })) })] }) })) : (options.cancelUrl && (_jsx("div", { className: "row", children: _jsx("div", { className: "col-2", children: _jsx("a", { href: options.cancelUrl, className: "btn btn-secondary", style: { maxWidth: "6em" }, children: "Cancel" }) }) })))] })] }) }));
};
export default GeneratePage;
