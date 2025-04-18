// app/javascript/components/GeneratePage.tsx

import React, { useState } from "react";
import { Page }            from "../types/dataTypes";
import ErrorBoundary       from "./ErrorBoundary";
import {
  renderTitle,
  renderPageName,
  renderSectionName,
  renderAccess
}                          from "./renderUtilities";
import { createPage }      from "../services/pageService";

interface Options {
  defaultPageName?: string | null;
  returnUrl?: string | null;
  cancelUrl?: string | null;

  [key: string]: any;
}

interface GeneratePageProps {
  title?: string | null;
  name?: string | null;
  section?: string | null;
  access?: string | null;
  options?: Options;
  onFinished?: ((page: Page) => void) | null;
}

const GeneratePage: React.FC<GeneratePageProps> = ({
                                                     title = "New Page",
                                                     name = null,
                                                     section = null,
                                                     access = null,
                                                     options = {} as Options,
                                                     onFinished = () => null,
                                                   }) => {
  if (!name && options.defaultPageName) name = options.defaultPageName;
  if (!section && options.defaultPageName) section = options.defaultPageName;

  const [ pageData, setPageData ] = useState<Page>({
                                                     id:       null,
                                                     title:    title || "New Page",
                                                     name:     name || "new-page",
                                                     section:  section || "new-page",
                                                     sections: [],
                                                     access:   access || null
                                                   });
  const [ error, setError ]       = useState<string | null>(null);

  // OnChange/OnBlur Callback
  const setValue = (newValue: any, attribute: string) => {
    setPageData(prev => ({
      ...prev,
      [attribute]: newValue as string
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

  return (
      <div id="GeneratePage">
        <ErrorBoundary>
          {error && (
              <div className="row">
                <div className="error-box">{error}</div>
              </div>
          )}
          <div id="GeneratePage">
            {renderTitle(pageData.title, setValue)}
            {renderPageName(pageData.name, setValue)}
            {renderSectionName(pageData.section, null, setValue, false, 'section')}
            {renderAccess(pageData.access, setValue)}
            <div className="row">
              <div className="col-2">
                <button
                    onClick={handleGenerate}
                    className="btn btn-primary me-2"
                    style={{ maxWidth: "12em" }}
                >
                  Generate Page
                </button>
              </div>
              <div className="col-5">
                {options.cancelUrl && (
                    <a href={options.cancelUrl} className="btn btn-secondary" style={{ maxWidth: "6em" }}>
                      Cancel
                    </a>
                )}
              </div>
            </div>
          </div>
        </ErrorBoundary>
      </div>
  );
};

export default GeneratePage;
