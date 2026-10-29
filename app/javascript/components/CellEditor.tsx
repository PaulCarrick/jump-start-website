// app/javascript/components/CellEditor.tsx

import RenderCell from "./RenderCell";
import ErrorBoundary from "./ErrorBoundary";
import { createCell, genericCell, updateCell } from "../services/cellService";
import {
  Cell,
  CellActionCallback,
  CellCallback,
  ImageType,
} from "../types/dataTypes";
import React, { useState } from "react";
import {
  renderContent,
  renderImage,
  renderLink,
  renderCellOrder,
  renderSectionName,
  renderCellName,
} from "./renderUtilities";
import FormattingEditor from "./FormattingEditor";
import { useEditorDraft } from "../hooks/useEditorDraft";

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
  readOnlySectionName?: boolean;
  newCell?: boolean;
}

// Define props for CellEditor
interface CellEditorProps {
  cell?: Cell | null;
  sectionName?: string | null;
  editorOptions?: EditorOptions;
  onFinished?: CellCallback | null;
  onChange?: CellActionCallback | null;
}

const CellEditor: React.FC<CellEditorProps> = ({
  cell = null,
  sectionName = null,
  editorOptions = {},
  onFinished = null,
  onChange = null,
}) => {
  const [cellData, setCellData, savedCellData] = useEditorDraft<Cell>(
    () =>
      cell ??
      (editorOptions.newCell
        ? genericCell(sectionName || "new-section")
        : null),
  );
  const [imageMode, setImageMode] = useState<ImageType>("Images");
  const [error, setError] = useState<string | null>(null);

  // OnChange/OnBlur Callback
  const setValue = (newValue: any, attribute: string) => {
    if (attribute === "image_type") {
      const nextMode = newValue as ImageType;
      if (nextMode !== imageMode) {
        setImageMode(nextMode);
        setCellData((previous) =>
          previous ? { ...previous, image: "" } : null,
        );
      }
    } else {
      setCellData((prev) => {
        if (!prev) return null;

        if (attribute === "useHtmlView") {
          return {
            ...prev,
            options: {
              ...prev.options,
              html_view: Boolean(newValue),
            },
          };
        } else {
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

    if (cellData.id && cellData.id > 0) result = updateCell(cellData, setError);
    else result = createCell(cellData, setError);

    if (result && editorOptions.returnUrl)
      window.location.href = editorOptions.returnUrl;
  };

  const handleCancel = () => {
    if (onFinished) {
      if (savedCellData) onFinished(structuredClone(savedCellData));
      return;
    } else if (editorOptions.cancelUrl) {
      window.location.href = editorOptions.cancelUrl;
    }
  };

  if (!cellData) return <div>No column exists to edit.</div>;

  return (
    <ErrorBoundary>
      <div>
        {error && (
          <div className="row">
            <div className="error-box">{error}</div>
          </div>
        )}
        {renderSectionName(
          cellData?.section_name,
          editorOptions.availableSectionNames,
          setValue,
          editorOptions.readOnlySectionName,
        )}
        {renderCellName(cellData?.cell_name, setValue)}
        <div style={{ minHeight: "10em" }}>
          {renderContent(
            "content",
            cellData?.content || null,
            setValue,
            cellData?.options?.html_view,
          )}
        </div>
        {renderImage(
          cellData?.image || null,
          imageMode,
          editorOptions.availableImages || [],
          editorOptions.availableImageGroups || [],
          editorOptions.availableVideos || [],
          setValue,
        )}
        {renderLink(cellData?.link || null, setValue)}
        {renderCellOrder(cellData?.cell_order, setValue)}
        <FormattingEditor
          formatting={cellData?.formatting || {}}
          onChange={setValue}
        />
        <div className="row mb-2 mt-5">
          <div className="col-4" id="promptField">
            <p>* - Required Fields</p>
          </div>
        </div>
        <div className="row mb-2">
          <div
            id="cellPreview"
            className="w-100 border border-danger border-width-8"
          >
            <RenderCell
              cell={cellData}
              editing={false}
              noBorder={true}
              noHidden={false}
              onChange={onChange}
            />
          </div>
        </div>

        <div className="row mb-2">
          <div className="col-12 d-flex justify-content-start gap-2">
            <button
              type="button"
              className="btn btn-primary"
              onClick={handleSubmit}
            >
              Save Column
            </button>
            <button
              type="button"
              className="btn btn-secondary"
              onClick={handleCancel}
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </ErrorBoundary>
  );
};

export default CellEditor;
