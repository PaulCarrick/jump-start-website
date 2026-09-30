import React, { StrictMode } from "react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  cleanup,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
vi.mock("../../app/javascript/services/utilities", () => ({
  sendRequest: vi.fn(() => ({ id: 10 })),
}));
vi.mock("../../app/javascript/components/RenderCell", () => ({
  default: () => <div>Column preview</div>,
}));
vi.mock("../../app/javascript/components/RenderSection", () => ({
  default: ({ section, onChange }) => (
    <>
      <button onClick={() => onChange(section.cells[0], "edit")}>
        Edit nested column
      </button>
      <button onClick={() => onChange(section.cells[0], "delete")}>
        Delete nested column
      </button>
      {section.cells[1] && (
        <button onClick={() => onChange(section.cells[1], "edit")}>
          Edit second column
        </button>
      )}
    </>
  ),
}));
vi.mock("../../app/javascript/components/GenerateCells", () => ({
  default: () => <div>Generate columns</div>,
}));
vi.mock("../../app/javascript/components/renderUtilities", () => ({
  renderSectionName: (value, _items, setValue) => (
    <input
      aria-label="Section name"
      value={value || ""}
      onChange={(e) => setValue(e.target.value, "sectionName")}
    />
  ),
  renderCellName: (value, setValue) => (
    <input
      aria-label="Column name"
      value={value || ""}
      onChange={(e) => setValue(e.target.value, "cell_name")}
    />
  ),
  renderContent: () => null,
  renderImage: () => null,
  renderLink: () => null,
  renderCellOrder: () => null,
  renderSectionOrder: () => null,
}));
vi.mock("../../app/javascript/services/imageFileService", () => ({
  createImageFile: vi.fn(),
}));
import ImagePicker from "../../app/javascript/components/ImagePicker";
import FormattingEditor from "../../app/javascript/components/FormattingEditor";
import { createImageFile } from "../../app/javascript/services/imageFileService";
import SectionEditor from "../../app/javascript/components/SectionEditor";
import CellEditor from "../../app/javascript/components/CellEditor";
import {
  createCell,
  sortCells,
} from "../../app/javascript/services/cellService";
import { sortSections } from "../../app/javascript/services/sectionService";
import { sendRequest } from "../../app/javascript/services/utilities";
afterEach(cleanup);
beforeEach(() => vi.clearAllMocks());
const makeSection = () => ({
  id: 5,
  section_name: "original",
  cells: [
    { id: -1, cell_name: "column", section_name: "original", formatting: {} },
  ],
});
describe("editor draft ownership", () => {
  it("normalizes nested save data without changing props and restores the original on Cancel", () => {
    const section = makeSection();
    const onFinished = vi.fn();
    render(
      <StrictMode>
        <SectionEditor section={section} onFinished={onFinished} />
      </StrictMode>,
    );
    fireEvent.change(screen.getByLabelText("Section name"), {
      target: { value: "renamed" },
    });
    fireEvent.click(screen.getByText("Save Section"));
    expect(onFinished.mock.calls[0][0]).toMatchObject({
      section_name: "renamed",
      cells: [{ id: null, section_name: "renamed", section_id: 5 }],
    });
    expect(section).toEqual(makeSection());
    fireEvent.click(screen.getByText("Cancel"));
    expect(onFinished.mock.calls[1][0]).toEqual(section);
  });
  it("cancels a nested column independently from its section draft", () => {
    const section = makeSection();
    const onFinished = vi.fn();
    render(<SectionEditor section={section} onFinished={onFinished} />);
    fireEvent.click(screen.getByText("Edit nested column"));
    fireEvent.change(screen.getByLabelText("Column name"), {
      target: { value: "discarded" },
    });
    fireEvent.click(screen.getByText("Cancel"));
    fireEvent.click(screen.getByText("Save Section"));
    expect(onFinished.mock.calls[0][0].cells[0].cell_name).toBe("column");
    expect(section).toEqual(makeSection());
  });
  it("creates a generated column with a temporary ID rather than attempting an update", () => {
    const cell = makeSection().cells[0];
    render(<CellEditor cell={cell} />);
    fireEvent.click(screen.getByText("Save Column"));
    expect(sendRequest).toHaveBeenCalledWith(
      "/api/v1/cells/",
      expect.any(Function),
      "POST",
      { cell: expect.objectContaining({ id: null }) },
    );
    expect(cell.id).toBe(-1);
  });
});
describe("immutable record helpers", () => {
  it("does not modify the input record when creating a column", () => {
    const cell = Object.freeze({ id: -1, cell_name: "new" });
    createCell(cell);
    expect(cell.id).toBe(-1);
    expect(sendRequest.mock.calls[0][3].cell.id).toBeNull();
  });
  it("sorts columns and sections without mutating the caller arrays", () => {
    const cells = Object.freeze([
      { cell_name: "second", cell_order: 2 },
      { cell_name: "first", cell_order: 1 },
    ]);
    const sections = Object.freeze([
      { section_name: "second", section_order: 2 },
      { section_name: "first", section_order: 1 },
    ]);
    expect(sortCells(cells).map((cell) => cell.cell_name)).toEqual([
      "first",
      "second",
    ]);
    expect(
      sortSections(sections).map((section) => section.section_name),
    ).toEqual(["first", "second"]);
    expect(cells[0].cell_name).toBe("second");
    expect(sections[0].section_name).toBe("second");
    expect(sortCells(null)).toEqual([]);
    expect(sortSections(null)).toEqual([]);
  });
});

it("emits formatting changes only for user edits, including in StrictMode", () => {
  const onChange = vi.fn();
  const { container } = render(
    <StrictMode>
      <FormattingEditor formatting={{}} onChange={onChange} />
    </StrictMode>,
  );
  expect(onChange).not.toHaveBeenCalled();
  fireEvent.change(container.querySelector("#marginTop"), {
    target: { value: "mt-3" },
  });
  expect(onChange).toHaveBeenCalledExactlyOnceWith(
    { classes: "mt-3" },
    "formatting",
  );
});

it("passes the uploaded image name as the value and image as the attribute", async () => {
  const setValue = vi.fn();
  const { container } = render(
    <ImagePicker
      image={null}
      imageType="Upload"
      availableImagesData={[]}
      availableImageGroupsData={[]}
      availableVideosData={[]}
      setValue={setValue}
    />,
  );
  const file = new File(["image"], "photo.png", { type: "image/png" });
  fireEvent.change(container.querySelector('input[type="file"]'), {
    target: { files: [file] },
  });
  await waitFor(() =>
    expect(screen.getByPlaceholderText("Enter image name")).toBeTruthy(),
  );
  fireEvent.change(screen.getByPlaceholderText("Enter image name"), {
    target: { value: " photo " },
  });
  fireEvent.click(screen.getByText("Upload Image"));
  expect(createImageFile).toHaveBeenCalledWith(
    { name: "photo", mime_type: "image/png" },
    file,
  );
  expect(setValue).toHaveBeenCalledWith("photo", "image");
});

it("edits the selected generated column when temporary IDs are shared", () => {
  const section = makeSection();
  section.cells.push({
    ...section.cells[0],
    cell_name: "second",
    cell_order: 2,
  });
  const onFinished = vi.fn();
  render(<SectionEditor section={section} onFinished={onFinished} />);
  fireEvent.click(screen.getByText("Edit second column"));
  expect(screen.getByLabelText("Column name").value).toBe("second");
  fireEvent.change(screen.getByLabelText("Column name"), {
    target: { value: "edited second" },
  });
  fireEvent.click(screen.getByText("Save Column"));
  fireEvent.click(screen.getByText("Save Section"));
  expect(
    onFinished.mock.calls[0][0].cells.map((cell) => cell.cell_name),
  ).toEqual(["column", "edited second"]);
  expect(section.cells[1].cell_name).toBe("second");
});
