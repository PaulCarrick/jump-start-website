// app/javascript/components/CellEditor.tsx

import  RenderCell                                            from "./RenderCell";
import ErrorBoundary                                         from "./ErrorBoundary";
import { createCell, genericCell, updateCell }               from "../services/cellService";
import { Cell, CellActionCallback, CellCallback, ImageType } from "../types/dataTypes";
import React, { useState, useEffect, useRef }                from "react";
import {
  renderContent,
  renderImage,
  renderLink,
  renderCellOrder,
  renderSectionName,
  renderCellName
}                                                            from "./renderUtilities";
import FormattingEditor                                      from "./FormattingEditor";
import { dupObject }                                         from "./utilities";

// Define types for Cell and Section
interface EditorOptions {
  force?: boolean;
  availableSectionNames?: string[] | null;
  availableImages?: string[] | null;
  availableImageGroups?: string[] | null;
  availableVideos?: string[] | null;
  defaultCellName?: string | null;
  returnUrl?: string | null;
  cancelUrl?: string | null;
  readOnlySectionName: boolean;
  newCell?: boolean;
}

// Define props for CellEditor
interface CellEditorProps {
  cell?: Cell | string | null;
  sectionName?: string | null;
  editorOptions?: EditorOptions;
  onFinished?: CellCallback | null;
  onChange?: CellActionCallback | null;
}

const CellEditor: React.FC<CellEditorProps> = ({
                                                 cell = null,
                                                 sectionName = null,
                                                 editorOptions = {} as EditorOptions,
                                                 onFinished = null,
                                                 onChange = null
                                               }) => {
  const [ cellData, setCellData ]           = useState<Cell | null>(null);
  const [ savedCellData, setSavedCellData ] = useState<Cell | null>(null);
  const [ imageMode, setImageMode ]         = useState<ImageType>("Images");
  const [ error, setError ]                 = useState<string | null>(null);
  const previousImageMode                   = useRef<ImageType>(imageMode);

  useEffect(() => {
    if (previousImageMode.current !== imageMode) {
      setCellData(prev => {
        if (!prev) return null;

        return { ...prev, image: "" };
      });

      previousImageMode.current = imageMode;
    }
  }, [ imageMode ]);

  useEffect(() => {
    if (!cellData) {
      let newCellData: Cell | null = null;

      if (cell)
        newCellData = cell as Cell;
      else if (editorOptions.newCell)
        newCellData = genericCell(sectionName || "new-section");

      if (newCellData) {
        setCellData(newCellData);
        setSavedCellData(dupObject(newCellData));
      }
    }
  }, [ cell ]);

  if (!cellData) {
    if (cell) {
      setCellData(cell as Cell);
    }
    else {
      if (!editorOptions?.newCell)
        setError("No cell exists to edit!");

      setCellData(genericCell("new-section"));
    }
  }

  // OnChange/OnBlur Callback
  const setValue = (newValue: any, attribute: string) => {
    if (attribute === "image_type") {
      setImageMode(newValue as ImageType);
    }
    else {
      setCellData(prev => {
        if (!prev) return null;

        if (attribute === "useHtmlView") {
          return {
            ...prev,
            options: {
              ...prev.options,
              html_view: Boolean(newValue)
            }
          };
        }
        else {
          return { ...prev, [attribute]: newValue as string };
        }
      });
    }
  };

  const handleSubmit = () => {
    let result = null;

    if (!cellData) return;

    if (onFinished) {
      onFinished(cellData);
      return;
    }

    if (cellData?.id)
      result = updateCell(cellData as Cell, setError);
    else if (cellData?.id)
      result = updateCell(cellData as Cell, setError);
    else
      result = createCell(cellData as Cell, setError);

    if (result && editorOptions.returnUrl) window.location.href = editorOptions.returnUrl;
  };

  const handleCancel = () => {
    if (onFinished) {
      onFinished(savedCellData as Cell);
      return;
    }
    else if (editorOptions.cancelUrl) {
      window.location.href = editorOptions.cancelUrl;
    }
  };

  return (
      <ErrorBoundary>
        <div>
          {error && (
              <div className="row">
                <div className="error-box">{error}</div>
              </div>
          )}
          {renderSectionName(cellData?.section_name, editorOptions.availableSectionNames, setValue, editorOptions.readOnlySectionName)}
          {renderCellName(cellData?.cell_name, setValue)}
          <div style={{ minHeight: "10em" }}>
            {renderContent("content", cellData?.content || null, setValue, cellData?.options?.html_view)}
          </div>
          {
            renderImage(
                cellData?.image || null,
                imageMode,
                editorOptions.availableImages || [],
                editorOptions.availableImageGroups || [],
                editorOptions.availableVideos || [],
                setValue)
          }
          {renderLink(cellData?.link || null, setValue)}
          {renderCellOrder(cellData?.cell_order, setValue)}
          <FormattingEditor formatting={cellData?.formatting || {}} onChange={setValue}/>
          <div className="row mb-2 mt-5">
            <div className="col-4" id="promptField">
              <p>* - Required Fields</p>
            </div>
          </div>
          <div className="row mb-2">
            <div id="cellPreview" className="w-100 border border-danger border-width-8">
              {!cellData ? (
                  <h1 className="text-center">No Contents</h1>
              ) : (
                   <RenderCell cell={cellData as any} editing={false} noBorder={true} noHidden={false}
                               onChange={onChange as any}/>
               )}
            </div>
          </div>

          <div className="row mb-2">
            <div className="col-12 d-flex justify-content-start gap-2">
              <button type="button" className="btn btn-primary" onClick={handleSubmit}>
                Save Column
              </button>
              <button type="button" className="btn btn-secondary" onClick={handleCancel}>
                Cancel
              </button>
            </div>
          </div>
        </div>
      </ErrorBoundary>
  );
};

export default CellEditor;
