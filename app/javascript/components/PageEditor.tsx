// app/javascript/components/PageEditor.tsx

import ErrorBoundary      from "./ErrorBoundary";
import SectionEditor      from "./SectionEditor";
import GeneratePage       from "./GeneratePage";
import RenderSection      from "./RenderSection";
import GenerateSections   from "./GenerateSections";
import AddPageToMenu      from "./AddPageToMenu";
import { renderInput }    from "./renderControlFunctions";
import { isPresent }      from "./utilities";
import { sortSections }   from "../services/sectionService";
import { deleteMenuItem } from "../services/menuItemService";
import { deleteFooterItem } from "../services/footerItemService";
import React, {
  useState,
  useCallback
}                         from "react";
import {
  createPage,
  hasSections,
  newPage,
  updatePage
}                         from "../services/pageService";
import {
  Page,
  PageOptions,
  Section,
  MenuItem,
  FooterItem
}                         from "../types/dataTypes";
import {
  renderAccess,
  renderPageName,
  renderTitle
}                         from "./renderUtilities";
import AddPageToFooter    from "./AddPageToFooter";

interface PageEditorProps {
  page?: Page | null;
  options?: PageOptions;
}

const PageEditor: React.FC<PageEditorProps> = ({ page = null, options = {} }) => {
  const [ pageData, setPageData ]                         = useState<Page>(newPage(page || {}));
  const [ originalMenuItemId, setOriginalMenuItemId ]     = useState<number | null | undefined>(page?.menu_item?.id);
  const [ originalFooterItemId, setOriginalFooterItemId ] = useState<number | null | undefined>(page?.footer_item?.id);
  const [ editingSection, setEditingSection ]             = useState<number | null>(null);
  const [ needPage, setNeedPage ]                         = useState<boolean>(page === null);
  const [ newSection, setNewSection ]                     = useState<boolean | null>(null);
  const [ error, setError ]                               = useState<string | null>(null);

  // OnChange/OnBlur Callback
  // noinspection com.intellij.reactbuddy.ExhaustiveDepsInspection
  const setValue = useCallback((newValue: any, attribute: string) => {
    switch (attribute) {
      case "menu_item":
        setPageData(prev => ({
          ...prev,
          menu_item:    newValue as MenuItem | null,
        }));

        break;

      case "footer_item":
        setPageData(prev => ({
          ...prev,
          footer_item:    newValue as FooterItem | null,
        }));

        break;

      case "name":
        setPageData(prev => ({
          ...prev,
          name:    newValue,
          section: newValue,
        }));

        break;

      default:
        setPageData(prev => ({
          ...prev,
          [attribute]: newValue as string
        }));
    }
  }, []);

  const canSave = (): boolean => {
    let result: boolean = isPresent(pageData.name) && isPresent(pageData.section);

    return result;
  }

  const handleGenerate = (page: Page) => {
    setPageData(page);
    setNeedPage(false);
  };

  const createNewSection = () => {
    setNewSection(true);
  };

  const handleAction = (index: number, action: string) => {
    if (pageData.sections && pageData.sections.length > index) {
      if (action === "edit") {
        setEditingSection(index);
      }
      else if (action === "delete") {
        setEditingSection(null);

        setPageData(prev => {
          if (!prev || !prev.sections) return prev;

          const updatedSections = [ ...(prev.sections) ];

          updatedSections.splice(index, 1);

          return {
            ...prev,
            sections: sortSections(updatedSections),
          };
        });
      }
    }
  };

  const finishedNewSection = (sections: Section[]) => {
    if (sections) {
      setPageData(prev => {
        if (!prev) prev = newPage({});

        let updatedSections: Section[] = [ ...(prev.sections ?? []) ];

        updatedSections = updatedSections.concat(sections);

        return {
          ...prev,
          sections: sortSections(updatedSections),
        };
      });
    }

    setNewSection(false);
  };

  const finishedEditingSection = (section: Section) => {
    if (editingSection !== null && pageData.sections && pageData.sections.length > editingSection) {
      setPageData(prev => {
        if (!prev) prev = newPage({});

        const updatedSections: Section[] = [ ...prev.sections as Section[] ];

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
    let result: Page | null = null;

    if (!pageData) {
      setError("No page data to save!");
      return;
    }

    if (!pageData.menu_item && originalMenuItemId) {
      if (deleteMenuItem(originalMenuItemId, setError))
        pageData.menu_item = null;
      else
        return;
    }

    if (!pageData.footer_item && originalFooterItemId) {
      if (deleteFooterItem(originalFooterItemId, setError))
        pageData.footer_item = null;
      else
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
    if (options.cancelUrl) window.location.href = options.cancelUrl;
  };

  //*** Main Render Routine ***//

  if (needPage) {
    return (
        <ErrorBoundary>
          <div>
            <GeneratePage
                title="New Page"
                name={options.defaultPageName}
                section={options.defaultPageName}
                options={options}
                onFinished={handleGenerate}
            />
          </div>
        </ErrorBoundary>
    );
  }
  else if (newSection) {
    return (
        <ErrorBoundary>
          {error && (
              <div className="row">
                <div className="error-box">{error}</div>
              </div>
          )}
          <div>
            <GenerateSections
                name={null}
                page={pageData}
                options={options}
                onFinished={finishedNewSection}
            />
          </div>
        </ErrorBoundary>
    )
  }
  else if (editingSection !== null && pageData.sections && pageData.sections.length > editingSection) {
    return (
        <ErrorBoundary>
          {error && (
              <div className="row">
                <div className="error-box">{error}</div>
              </div>
          )}
          <div>
            <SectionEditor
                section={pageData.sections[editingSection]}
                contentType={pageData.section}
                options={options}
                onFinished={finishedEditingSection}
            />
          </div>
        </ErrorBoundary>
    )
  }
  else {
    return (
        <ErrorBoundary>
          {error && (
              <div className="row">
                <div className="error-box">{error}</div>
              </div>
          )}
          {renderTitle(pageData.title, setValue)}
          {renderPageName(pageData.name, setValue)}
          <div className="row mb-2">
            <div className="col-2 d-flex align-items-center">Section Group*:</div>
            <div className="col-5">
              <div id="sectionDiv">
                {
                  renderInput(
                      "section",
                      pageData.section,
                      setValue as any,
                      null,
                      {},
                      "Enter the section group for the page"
                  )
                }
              </div>
            </div>
          </div>
          {renderAccess(pageData.access, setValue)}
          {(pageData.name && canSave()) && (
              <>
              <AddPageToMenu
                  pageName={pageData.name}
                  onChanged={setValue}
                  pageTitle={pageData.title}
                  currentMenuItem={pageData.menu_item}
                  setError={setError}
              />
              <AddPageToFooter
                  pageName={pageData.name}
                  onChanged={setValue}
                  pageTitle={pageData.title}
                  currentFooterItem={pageData.footer_item}
                  setError={setError}
              />
              </>)}
          <div className="row border-bottom border-dark mb-2 ms-1 me-1">
            <div className="col-12 text-center">
              <h1>Preview</h1>
            </div>
          </div>
          <div className="row mb-2">
            <div className="col-12">
              <div className="RenderPageDataDiv">
                {pageData.sections && pageData.sections.length > 0 ? (
                    pageData.sections.map((section: Section, index: number) => (
                        <div key={index} className="section">
                          <RenderSection
                              section={section as any}
                              editing={false}
                              noBorder={true}
                              noHidden={false}
                              onChange={handleAction as any}
                          />
                        </div>
                    ))
                ) : (
                     <p className="text-center border-bottom border-dark me-1">
                       <h2>No Contents</h2>
                     </p>
                 )}
              </div>
            </div>
          </div>
          {canSave() && (
              <div className="row mb-2">
                {hasSections(pageData) ? (
                    <>
                      <div className="col-2">
                        <button
                            type="button"
                            className="btn btn-primary"
                            style={{ minWidth: "8em", maxWidth: "8em" }}
                            onClick={handleSubmit}
                        >
                          Save Page
                        </button>
                      </div>
                      <div className="col-5">
                        {options.cancelUrl && (
                            <button
                                type="button"
                                className="btn btn-secondary"
                                style={{ minWidth: "8em", maxWidth: "8em" }}
                                onClick={handleCancel}
                            >
                              Cancel
                            </button>
                        )}
                        <button
                            type="button"
                            className="btn btn-secondary ms-2"
                            style={{ minWidth: "8em", maxWidth: "8em" }}
                            onClick={createNewSection}
                        >
                          New Section
                        </button>
                      </div>
                    </>
                ) : (
                     <>
                       <div className="col-2">
                         <button
                             type="button"
                             className="btn btn-primary"
                             style={{ minWidth: "8em", maxWidth: "8em" }}
                             onClick={createNewSection}
                         >
                           New Section
                         </button>
                       </div>
                       <button
                           type="button"
                           className="btn btn-secondary ms-2"
                           style={{ minWidth: "8em", maxWidth: "8em" }}
                           onClick={handleSubmit}
                       >
                         Save Page
                       </button>
                       <div className="col-5">
                         {options.cancelUrl && (
                             <button
                                 type="button"
                                 className="btn btn-secondary"
                                 style={{ minWidth: "8em", maxWidth: "8em" }}
                                 onClick={handleCancel}
                             >
                               Cancel
                             </button>
                         )}
                       </div>
                     </>
                 )}
              </div>
          )}
        </ErrorBoundary>);
  }
};

export default PageEditor;
