import { Fragment as _Fragment, jsx as _jsx } from "react/jsx-runtime";
import React from "react";
import Routes from "../routes";
let defaultRowStyle = "cell";
export function getDefaultRowStyle() {
    return defaultRowStyle;
}
export function setDefaultRowStyle(defaultRowStyle) {
    defaultRowStyle = defaultRowStyle;
}
const AppRoutes = props => _jsx(_Fragment, { children: Routes });
export default AppRoutes;
