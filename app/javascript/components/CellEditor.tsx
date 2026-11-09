import EnabledSwitch from "./EnabledSwitch";
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
import Select from "react-select";
import React, { useState } from "react";
import {
  renderContent,
  renderImage,
  renderLink,
  renderCellOrder,
  renderCellWidth,
  renderCellName,
} from "./renderUtilities";
import FormattingEditor from "./FormattingEditor";
import { savedImageType } from "./ImagePicker";
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
  // The page workspace shows the same fields in tabs inside its side panel.
  tabbed?: boolean;
}

const CELL_EDITOR_TABS = [
  ["content", "Content"],
  ["image", "Image"],
  ["layout", "Layout"],
  ["advanced", "Advanced"],
] as const;
type CellEditorTab = (typeof CELL_EDITOR_TABS)[number][0];

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
  const [imageMode, setImageMode] = useState<ImageType>(() => savedImageType(cellData?.image));
  // The section the column is in now; choosing another one moves the column.
  const [startingSection] = useState<string>(() => (cell?.section_name || "").trim());
  const [error, setError] = useState<string | null>(null);
  // An image column opens on its picture; anything else on its text.
  const [activeTab, setActiveTab] = useState<CellEditorTab>(() =>
    cellData?.image && !cellData?.content ? "image" : "content",
  );

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

        // A slide show's pictures are worked out when the page is drawn; a
        // saved list would keep showing the old slide show after a change.
        if (attribute === "image") {
          const formatting = { ...(prev.formatting || {}) };
          delete formatting.slide_show_images;
          return { ...prev, image: newValue ? (newValue as string) : null, formatting };
        }
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

    const target = (cellData.section_name || "").trim();
    if (startingSection && target && target !== startingSection && cellData.id && cellData.id > 0) {
      const sure = window.confirm(
        `Move this column out of the section “${startingSection}” and into “${target}”?\n\n` +
        "This does not rename the section. To rename a section, change its Section name in the section's panel.",
      );
      if (!sure) return;
    }

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

  // Which section the column is in. Changing it moves the column (it does not
  // rename the section), so the field says so and warns while a move is set.
  const chosenSection = (cellData.section_name || "").trim();
  const moving = Boolean(startingSection && chosenSection && chosenSection !== startingSection);
  const sectionField = (
    <div className="mb-3 cell-section-field">
      <label htmlFor="section_name" className="form-label">Section this column belongs to</label>
      {editorOptions.readOnlySectionName ? (
        <input id="section_name" className="form-control" value={chosenSection} readOnly />
      ) : (
        <Select
          inputId="section_name"
          value={chosenSection ? { label: chosenSection, value: chosenSection } : null}
          options={(editorOptions.availableSectionNames || []).map((name) => ({ label: name, value: name }))}
          onChange={(option) => setValue(option?.value || "", "section_name")}
          isSearchable
          placeholder="Choose a section…"
        />
      )}
      <div className="form-text">
        {editorOptions.readOnlySectionName ? (
          <>To rename this section, change its Section name in the section's panel.</>
        ) : (
          <>
            Choosing another section <strong>moves</strong> this column there. To rename the section, change its
            Section name in the section's panel instead.
          </>
        )}
      </div>
      {moving && (
        <div className="alert alert-warning py-2 mt-2 mb-0" role="alert">
          When you save, this column moves from <strong>{startingSection}</strong> to <strong>{chosenSection}</strong>.{" "}
          <button type="button" className="btn btn-link p-0 align-baseline" onClick={() => setValue(startingSection, "section_name")}>
            Keep it in {startingSection}
          </button>
        </div>
      )}
    </div>
  );

  const actions = (
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
  );

  if (editorOptions.tabbed) {
    // Every tab stays mounted (only hidden), so the text editor keeps its
    // state and nothing typed is lost when switching tabs.
    const pane = (name: CellEditorTab, children: React.ReactNode) => (
      <div
        role="tabpanel"
        id={`cell-tab-${name}`}
        aria-labelledby={`cell-tab-button-${name}`}
        hidden={activeTab !== name}
        className="cell-editor-pane"
      >
        {children}
      </div>
    );

    return (
      <ErrorBoundary>
        <div className="cell-editor-tabbed">
          {error && <div className="error-box">{error}</div>}
          <div className="nav nav-tabs admin-tabs mb-3" role="tablist">
            {CELL_EDITOR_TABS.map(([name, label]) => (
              <button
                key={name}
                type="button"
                role="tab"
                id={`cell-tab-button-${name}`}
                aria-controls={`cell-tab-${name}`}
                aria-selected={activeTab === name}
                className={`nav-link${activeTab === name ? " active" : ""}`}
                onClick={() => setActiveTab(name)}
              >
                {label}
              </button>
            ))}
          </div>
          {pane(
            "content",
            <>
              <div style={{ minHeight: "10em" }}>
                {renderContent(
                  "content",
                  cellData?.content || null,
                  setValue,
                  cellData?.options?.html_view,
                )}
              </div>
              {renderLink(cellData?.link || null, setValue)}
            </>,
          )}
          {pane(
            "image",
            renderImage(
              cellData?.image || null,
              imageMode,
              editorOptions.availableImages || [],
              editorOptions.availableImageGroups || [],
              editorOptions.availableVideos || [],
              setValue,
            ),
          )}
          {pane(
            "layout",
            <FormattingEditor
              formatting={cellData?.formatting || {}}
              onChange={setValue}
            />,
          )}
          {pane(
            "advanced",
            <>
              <EnabledSwitch enabled={cellData?.enabled} onChange={enabled => setCellData(previous => previous ? { ...previous, enabled } : previous)} />
              {sectionField}
              {renderCellName(cellData?.cell_name, setValue)}
              {renderCellOrder(cellData?.cell_order, setValue)}
              {renderCellWidth(cellData?.width || null, setValue)}
            </>,
          )}
          <div className="cell-editor-preview">
            <div className="form-text mb-1">Preview of this column (the page preview updates when you save)</div>
            <div id="cellPreview" className="border rounded p-1">
              <RenderCell
                cell={cellData}
                editing={false}
                noBorder={true}
                noHidden={false}
                onChange={onChange}
              />
            </div>
          </div>
          {actions}
        </div>
      </ErrorBoundary>
    );
  }

  return (
    <ErrorBoundary>
      <div>
        {error && (
          <div className="row">
            <div className="error-box">{error}</div>
          </div>
        )}
        <EnabledSwitch enabled={cellData?.enabled} onChange={enabled => setCellData(previous => previous ? { ...previous, enabled } : previous)} />
        {sectionField}
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
        {renderCellWidth(cellData?.width || null, setValue)}
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

        {actions}
      </div>
    </ErrorBoundary>
  );
};

export default CellEditor;
