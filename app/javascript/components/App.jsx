import React from "react";
import Routes from "../routes";

let defaultRowStyle = "cell";

export function getDefaultRowStyle() {
  return defaultRowStyle;
}

export function setDefaultRowStyle(defaultRowStyle) {
  defaultRowStyle = defaultRowStyle;
}

const AppRoutes = props => <>{Routes}</>;

export default AppRoutes;
