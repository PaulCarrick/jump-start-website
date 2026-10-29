// app/javascript/components/GeneratePage.tsx

import React, { useState }            from "react";
import { FooterItem, MenuItem, Page } from "../types/dataTypes";
import ErrorBoundary                  from "./ErrorBoundary";
import {
  renderTitle,
  renderPageName,
  renderSectionName,
  renderAccess
}                          from "./renderUtilities";
import { createPage }      from "../services/pageService";
import { isPresent }       from "./utilities";

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
  menuItem?: MenuItem | null;
  footerItem?: FooterItem | null;
}

const GeneratePage: React.FC<GeneratePageProps> = ({
                                                     title = null,
                                                     name = null,
                                                     section = null,
                                                     access = null,
                                                     options = {} as Options,
                                                     onFinished = () => null,
                                                     menuItem = null,
                                                     footerItem = null,
                                                   }) => {
  const [ pageData, setPageData ] = useState<Page>({
                                                     id:          null,
                                                     title:       title,
                                                     name:        name,
                                                     section:     section,
                                                     sections:    [],
                                                     access:      access || null,
                                                     menu_item:   menuItem || null,
                                                     footer_item: footerItem || null,
                                                   });
  const [ error, setError ]       = useState<string | null>(null);

  // OnChange/OnBlur Callback
  const setValue = (newValue: any, attribute: string) => {
    setPageData(prev => ({
      ...prev,
      [attribute]: newValue as string
    }));
  };

  const canGenerate = (): boolean => {
    let result: boolean = isPresent(pageData.name) && isPresent(pageData.section);

    return result;
  }

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
            {canGenerate() ? (
                <>
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
                          <a
                              href={options.cancelUrl}
                              className="btn btn-secondary ms-2"
                              style={{ maxWidth: "6em" }}
                          >
                            Cancel
                          </a>
                      )}
                    </div>
                  </div>
                </>
            ) : (
                 options.cancelUrl && (
                     <div className="row">
                       <div className="col-2">
                         <a
                             href={options.cancelUrl}
                             className="btn btn-secondary"
                             style={{ maxWidth: "6em" }}
                         >
                           Cancel
                         </a>
                       </div>
                     </div>
                 )
             )}
          </div>
        </ErrorBoundary>
      </div>
  )
      ;
};

export default GeneratePage;
