import { jsx as _jsx } from "react/jsx-runtime";
import RenderSection from "./RenderSection";
const RenderPage = ({ page, editing = false, noBorder = true, noHidden = false }) => {
    return (_jsx("div", { className: "RenderPageDiv", children: page.sections && page.sections.length > 0 ? (page.sections.map((section, index) => (_jsx("div", { className: "section", children: _jsx(RenderSection, { section: section, editing: editing, noBorder: noBorder, noHidden: noHidden }) }, index)))) : (_jsx("p", { children: "No sections available" })) }));
};
export default RenderPage;
