// app/javascript/components/SectionEditor.tsx

import RenderSection from "./RenderSection";
import ErrorBoundary from "./ErrorBoundary";
import GenerateCells from "./GenerateCells";
import CellEditor from "./CellEditor";
import React, { useState } from "react";
import {
  createSection,
  genericSection,
  hasCells,
  updateSection,
} from "../services/sectionService";
import { Cell, Section } from "../types/dataTypes";
import { renderSectionOrder, renderSectionName } from "./renderUtilities";
import { useEditorDraft } from "../hooks/useEditorDraft";
import { isPresent } from "./utilities";

// Define types for Section and Section
interface Options {
  force?: boolean;
  availableImages?: string[];
  availableImageGroups?: string[];
  availableVideos?: string[];
  availableSectionNames?: string[];
  defaultSectionName?: string | null;
  defaultCellName?: string | null;
  returnUrl?: string | null;
  cancelUrl?: string | null;
  readOnlySectionName?: boolean;
  newSection?: boolean;
}

// Define props for SectionEditor
interface SectionEditorProps {
  section?: Section | null;
  contentType?: string | null;
  options?: Options;
  onFinished?: ((section: Section) => void) | null;
  onChange?: (section: Section, action: string) => void;
}

const SectionEditor: React.FC<SectionEditorProps> = ({
  section = null,
  contentType = null,
  options = {},
  onFinished = null,
}) => {
  const [sectionData, setSectionData, savedSectionData] =
    useEditorDraft<Section>(
      () =>
        section ??
        (options.newSection
          ? genericSection("new-section", contentType || "new-page")
          : null),
    );
  const [editingCell, setEditingCell] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);

  // OnChange/OnBlur Callback
  const setValue = (newValue: any, attribute: string) => {
    setSectionData((prev) => {
      if (!prev) return null;

      switch (attribute) {
        case "sectionName":
          return { ...prev, section_name: newValue as string };
        case "sectionOrder":
          return { ...prev, section_order: Number(newValue) };
        default:
          return prev;
      }
    });
  };

  const cellsGenerated = (cells: Cell[]) => {
    setSectionData((prev) => {
      if (!prev) return null; // Handle the case where prev is null

      return {
        ...prev,
        cells,
        section_name: prev.section_name ?? "new-section",
      };
    });
  };

  const handleAction = (cellOrIndex: Cell | number, action: string) => {
    if (!sectionData?.cells) return;

    const index =
      typeof cellOrIndex === "number"
        ? cellOrIndex
        : sectionData.cells.findIndex((cell) =>
            cellOrIndex.id && cellOrIndex.id > 0
              ? cell.id === cellOrIndex.id
              : cell.cell_name === cellOrIndex.cell_name &&
                cell.cell_order === cellOrIndex.cell_order,
          );

    if (index < 0 || sectionData.cells.length <= index) return;

    if (action === "edit") {
      setEditingCell(index);
    } else if (action === "delete") {
      setEditingCell(null);

      setSectionData((prev) => {
        if (!prev) return null;

        const updatedCells = [...prev.cells];

        updatedCells.splice(index, 1);

        return {
          ...prev,
          cells: updatedCells,
          section_name: prev.section_name ?? "new-section",
        };
      });
    }
  };

  const finishedEditingCell = (cell: Cell) => {
    if (
      editingCell !== null &&
      sectionData?.cells &&
      sectionData.cells.length > editingCell
    ) {
      setSectionData((prev) => {
        if (!prev) return null;

        const updatedCells = [...prev.cells];
        updatedCells[editingCell] = cell;

        return {
          ...prev,
          cells: updatedCells,
          section_name: prev.section_name ?? "new-section",
        };
      });

      setEditingCell(null);
    }
  };

  const handleSubmit = () => {
    let result = null;

    if (!sectionData) return;

    if (!hasCells(sectionData)) {
      setError("You cannot save a section with no columns!");
      return;
    }

    // Normalize the save payload without altering the draft or caller's data.
    const sectionToSave: Section = {
      ...sectionData,
      cells: sectionData.cells.map((cell) => ({
        ...cell,
        id: cell.id && cell.id < 0 ? null : cell.id,
        section_name: sectionData.section_name,
        section_id: cell.section_id || sectionData.id,
      })),
    };

    if (onFinished) {
      onFinished(sectionToSave);
      return;
    }

    if (isPresent(sectionData?.id))
      result = updateSection(sectionToSave, setError);
    else result = createSection(sectionToSave, setError);

    if (result && options.returnUrl) window.location.href = options.returnUrl;
  };

  const handleCancel = () => {
    if (onFinished) {
      if (savedSectionData) onFinished(structuredClone(savedSectionData));
      return;
    } else if (options.cancelUrl) {
      window.location.href = options.cancelUrl;
    }
  };

  if (!sectionData) return <div>No section exists to edit.</div>;

  if (!hasCells(sectionData)) {
    return (
      <div>
        <GenerateCells
          sectionName={sectionData?.section_name}
          options={options}
          onFinished={cellsGenerated}
        />
      </div>
    );
  } else if (
    editingCell !== null &&
    sectionData?.cells &&
    sectionData.cells.length > editingCell
  ) {
    return (
      <div>
        <CellEditor
          key={sectionData.cells[editingCell].id ?? editingCell}
          cell={sectionData.cells[editingCell]}
          sectionName={sectionData?.section_name}
          editorOptions={options}
          onFinished={finishedEditingCell}
        />
      </div>
    );
  } else {
    return (
      <ErrorBoundary>
        <div>
          {error && (
            <div className="row">
              <div className="error-box">{error}</div>
            </div>
          )}
          {renderSectionName(
            sectionData?.section_name,
            options.availableSectionNames,
            setValue,
            options.readOnlySectionName,
          )}
          {renderSectionOrder(sectionData?.section_order, setValue)}

          <div className="row mb-2">
            <div
              id="sectionPreview"
              className="w-100 border border-danger border-width-8"
            >
              <RenderSection
                section={sectionData}
                editing={true}
                noBorder={true}
                noHidden={false}
                onChange={handleAction}
              />
            </div>
          </div>

          <div className="row mb-2">
            <div className="col-2">
              <button
                type="button"
                className="btn btn-primary"
                onClick={handleSubmit}
              >
                Save Section
              </button>
            </div>
            <div className="col-2">
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
  }
};

export default SectionEditor;
