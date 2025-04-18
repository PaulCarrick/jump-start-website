// /app/javascripts/components/index.js
// noinspection JSUnresolvedFunction

import React from "react";
import {createRoot} from "react-dom/client";
import App from "./App";

const ReactRailsUJS = require("react_ujs");

import NavMenu from "./NavMenu";
import DisplayContent from "./DisplayContent";
import SlideShow from "./SlideShow";
import PostList from "./PostList";
import PostEditor from "./PostEditor";
import CommentEditor from "./CommentEditor";
import PostDetail from "./PostDetail";
import RenderContent from "./RenderContent";
import ContentBlock from "./ContentBlock";
import RenderImage from "./RenderImage";
import RenderSingleImage from "./RenderSingleImage";
import RenderSlideShow from "./RenderSlideShow";
import EditableComboBox from "./EditableComboBox";
import SelectControl from "./SelectControl";
import SectionAttributes from "./SectionAttributes";
import SectionEditor from "./SectionEditor";
import HtmlEditor from "./HtmlEditor";
import RenderControl from "./RenderControl";
import RenderSection from "./RenderSection";
import RenderCell from "./RenderCell";
import FormattingEditor from "./FormattingEditor";
import ErrorBoundary from "./ErrorBoundary";
import CellEditor from "./CellEditor";
import GenerateCells from "./GenerateCells";
import RenderPage from "./RenderPage";
import PageEditor from "./PageEditor";
import RenderImageControl from "./RenderImageControl";

try {
  ReactRailsUJS.register({
                           NavMenu,
                           DisplayContent,
                           SlideShow,
                           PostList,
                           PostEditor,
                           CommentEditor,
                           PostDetail,
                           RenderContent,
                           ContentBlock,
                           RenderImage,
                           RenderSingleImage,
                           RenderSlideShow,
                           EditableComboBox,
                           SelectControl,
                           SectionAttributes,
                           SectionEditor,
                           HtmlEditor,
                           RenderControl,
                           RenderSection,
                           RenderCell,
                           FormattingEditor,
                           ErrorBoundary,
                           CellEditor,
                           GenerateCells,
                           RenderPage,
                           PageEditor,
                           RenderImageControl
                         });
}
catch (error) {
  if (!(error instanceof TypeError))
    throw error;
}

document.addEventListener("turbo:load", () => {
  const root = createRoot(
      document.body.appendChild(document.createElement("div"))
  );
  root.render(<App/>);
});
