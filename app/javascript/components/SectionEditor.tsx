// app/javascript/components/SectionEditor.tsx

import RenderSection                                              from "./RenderSection";
import ErrorBoundary                                              from "./ErrorBoundary";
import GenerateCells                                              from "./GenerateCells";
import CellEditor                                                 from "./CellEditor";
import React, { useState, useEffect }                             from "react";
import { createSection, genericSection, hasCells, updateSection } from "../services/sectionService";
import { Cell, Section }                                          from "../types/dataTypes";
import { renderSectionOrder, renderSectionName }                  from "./renderUtilities";
import { dupObject }                                              from "./utilities";
import { isPresent }                                              from "./utilities";

// Define types for Section and Section
interface Options {
  force?: boolean;
  availableImages?: any[];
  availableImageGroups?: any[];
  availableVideos?: any[];
  availableSectionNames?: any[];
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
  onFinished?: (section: Section) => void;
  onChange?: (section: Section, action: string) => void;
}

const SectionEditor: React.FC<SectionEditorProps> = ({
                                                       section = null,
                                                       contentType = null,
                                                       options = {} as Options,
                                                       onFinished = null
                                                     }) => {
  const [ sectionData, setSectionData ]           = useState<Section | null>(null);
  const [ savedSectionData, setSavedSectionData ] = useState<Section | null>(null);
  const [ editingCell, setEditingCell ]           = useState<number | null>(null);
  const [ error, setError ]                       = useState<string | null>(null);

  useEffect(() => {
    if (!sectionData) {
      let newSectionData: Section | null = null;

      if (section) {
        newSectionData = section as Section;
      }
      else if (options.newSection) {
        if (!contentType)
          contentType = "new-page";

        newSectionData = genericSection("new-section", contentType);
      }

      if (newSectionData) {
        setSectionData(newSectionData);
        setSavedSectionData(dupObject(newSectionData));
      }
    }
  }, [ section ]);

  if (!sectionData) {
    if (section)
      setSectionData(section as Section);
    else
      setError("No section exists to edit!");
  }

  // OnChange/OnBlur Callback
  const setValue = (newValue: any, attribute: string) => {
    setSectionData(prev => {
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
    setSectionData(prev => {
      if (!prev) return null; // Handle the case where prev is null

      return {
        ...prev,
        cells,
        section_name: prev.section_name ?? "new-section",
      };
    });
  };

  const handleAction = (index: number, action: string) => {
    if (sectionData?.cells && sectionData.cells.length > index) {
      if (action === "edit") {
        setEditingCell(index);
      }
      else if (action === "delete") {
        setEditingCell(null);

        setSectionData(prev => {
          if (!prev) return null;

          const updatedCells = [ ...prev.cells ];

          updatedCells.splice(index, 1);

          return {
            ...prev,
            cells:        updatedCells,
            section_name: prev.section_name ?? "new-section",
          };
        });
      }
    }
  };

  const finishedEditingCell = (cell: Cell) => {
    if (editingCell !== null && sectionData?.cells && sectionData.cells.length > editingCell) {
      setSectionData(prev => {
        if (!prev) return null;

        const updatedCells        = [ ...prev.cells ];
        updatedCells[editingCell] = cell;

        return {
          ...prev,
          cells:        updatedCells,
          section_name: prev.section_name ?? "new-section",
        };
      });

      setEditingCell(null);
    }
  };

  const handleSubmit = () => {
    let result = null;

    if (!sectionData) return;

    if (isPresent(sectionData?.cells)) {
      sectionData?.cells.forEach(cell => {
        if (cell.id === -1)
          cell.id = null;

        if (!cell.section_name || (cell.section_name && cell.section_name.trim() !== ''))
          cell.section_name = sectionData.section_name;

        if (sectionData.id && !cell.section_id)
          cell.section_id = sectionData.id;
      });
   }
    else {
      setError("You cannot save a section with no columns!");
      return
    }

    if (onFinished) {
      onFinished(sectionData);
      return;
    }

    if (isPresent(sectionData?.id))
      result = updateSection(sectionData as Section);
    else
      result = createSection(sectionData as Section);

    if (result && options.returnUrl) window.location.href = options.returnUrl;
  };

  const handleCancel = () => {
    if (onFinished) {
      onFinished(savedSectionData as Section);
      return;
    }
    else if (options.cancelUrl) {
      window.location.href = options.cancelUrl;
    }
  };

  if (!hasCells(sectionData)) {
    return (
        <div>
          <GenerateCells sectionName={sectionData?.section_name} options={options} onFinished={cellsGenerated}/>
        </div>
    )
  }
  else if (editingCell !== null && sectionData?.cells && sectionData.cells.length > editingCell) {
    return (
        <div>
          <CellEditor
              cell={sectionData.cells[editingCell]}
              sectionName={sectionData?.section_name}
              editorOptions={options as any}
              onFinished={finishedEditingCell}
          />
        </div>
    )
  }
  else {
    return (
        <ErrorBoundary>
          <div>
            {
                error && (
                          <div className="row">
                            <div className="error-box">{error}</div>
                          </div>)
            }
            {renderSectionName(sectionData?.section_name, options.availableSectionNames, setValue, options.readOnlySectionName)}
            {renderSectionOrder(sectionData?.section_order, setValue)}

            <div className="row mb-2">
              <div id="sectionPreview" className="w-100 border border-danger border-width-8">
                {!sectionData ? (
                    <h1 className="text-center">No Contents</h1>
                ) : (
                     <RenderSection section={sectionData as any} editing={false} noBorder={true} noHidden={false}
                                    onChange={handleAction as any}/>
                 )}
              </div>
            </div>

            <div className="row mb-2">
              <div className="col-2">
                <button type="button" className="btn btn-primary" onClick={handleSubmit}>
                  Save Section
                </button>
              </div>
              <div className="col-2">
                <button type="button" className="btn btn-secondary" onClick={handleCancel}>
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
