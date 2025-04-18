// /app/javascript/services/sectionService.tsx

import { generateCells }                              from "./cellService"
import { Cell, ImageType, Section, SetErrorCallback } from "../types/dataTypes";
import { sendRequest }                                from "./utilities";

export function hasCells(section: Section | null): boolean {
  let results: boolean = false;

  if (section?.cells)
    results = (section.cells.length > 0);

  return results;
}

export function generateRandomSectionName(base: string = "new-section"): string {
  const suffix = Math.random().toString(36).substring(2, 7);
  return `${base}-${suffix}`;
}

export function generateUniqueSectionName(sections: Section[], prefix = "new-section_"): string {
  const regex = new RegExp(`^${prefix}(\\d+)$`);

  const maxNumber = sections
      .map(section => {
        const match = section.section_name?.match(regex);
        return match ? parseInt(match[1], 10) : 0;
      })
      .reduce((max, num) => Math.max(max, num), 0);

  return `${prefix}${maxNumber + 1}`;
}

export function getNextSectionOrder(sections: Section[]): number {
  return (
      sections
          .map(section => section.section_order ?? 0)
          .reduce((max, val) => Math.max(max, val), 0) + 1
  );
}

export function sortSections(sections: Section[] | null): Section[] {
  if (sections) {
    sections.sort((a, b) => {
      return (a.section_order ?? 0) - (b.section_order ?? 0);
    });

    return sections
  }
  else {
    return [];
  }
}

export function getSectionsForContentType(contentType: string, setError: SetErrorCallback | null = null): Section[] | null {
  const url = `/api/v1/sections/${encodeURIComponent(contentType)}`;

  return sendRequest(url, setError);
}

export function getSections(query: string | null, limit: number, setError: SetErrorCallback | null = null): Section[] | null {
  const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
  const url         = `/api/v1/sections${queryString}`;

  return sendRequest(url, setError);
}

export function newSection(params: Partial<Section> = {}): Section {
  return {
    content_type:     params.content_type || null,
    section_name:     params.section_name || "new-section",
    section_order:    params.section_order || null,
    image:            params.image || null,
    link:             params.link || null,
    description:      params.description || null,
    row_style:        params.row_style || null,
    div_ratio:        params.div_ratio || null,
    image_attributes: params.image_attributes || {},
    text_attributes:  params.text_attributes || {},
    formatting:       params.formatting || {},
    cells:            []
  };
}

export function createSection(section: Section, setError: SetErrorCallback | null = null): Section | null {
  const sectionWithNestedCells = {
    ...section,
    cells_attributes: section.cells.map(cell =>
                                            cell.id === -1 ? { ...cell, id: null } : cell
    )
  };

  delete (sectionWithNestedCells as any).cells;

  return sendRequest("/api/v1/sections/", setError, "POST", { section: sectionWithNestedCells });
}

export function updateSection(section: Section, setError: SetErrorCallback | null = null): Section | null {
  if (!section.id) {
    console.error("Error: Section ID is required for updating.");
    return null;
  }

  const sectionWithNestedCells = {
    ...section,
    cells_attributes: section.cells.map(cell =>
                                            cell.id === -1 ? { ...cell, id: null } : cell
    ),
  };

  delete (sectionWithNestedCells as any).cells;

  return sendRequest(`/api/v1/sections/${section.id}`, setError, "PATCH", { section: sectionWithNestedCells });
}

export function deleteSection(id: number, setError: SetErrorCallback | null = null): Section | null {
  return sendRequest(`/api/v1/sections/${id}`, setError, "DELETE");
}

export function genericSection(
    sectionName: string,
    contentType: string | null,
    cells: Cell[] | null = null,
    order: number | null = 1
): Section {
  const formatting: Record<string, any> = {
    image_classes: "m-3",
    text_classes:  "m-3"
  };

  return {
    content_type:     contentType,
    section_name:     sectionName,
    section_order:    order,
    image:            null,
    link:             null,
    description:      null,
    row_style:        null,
    div_ratio:        null,
    image_attributes: {},
    text_attributes:  {},
    formatting:       formatting,
    cells:            cells ? cells : []
  };
}

export function textSection(
    sectionName: string,
    contentType: string,
    content: string | null = "Replace with your text",
    order: number | null   = 1
): Section {
  const cells: Cell[]    = generateCells(sectionName, contentType, "text-single", content)
  const results: Section = genericSection(sectionName, contentType, cells, order);

  return results;
}

export function imageSection(
    sectionName: string,
    contentType: string,
    image: string | null,
    imageType: ImageType | null = null,
    order: number | null        = 1
): Section {
  const cells: Cell[]    = generateCells(sectionName, "image-single", null, image, imageType)
  const results: Section = genericSection(sectionName, contentType, cells, order);

  return results;
}

export function textTopSections(
    sectionName: string,
    contentType: string | null  = null,
    content: string | null      = "Replace with your text",
    image: string | null        = null,
    imageType: ImageType | null = null,
    order: number | null        = 1,
): Section[] {
  const results: Section[] = [];
  let cells: Cell[]        = generateCells(sectionName, contentType, "text-single", content);
  const textName           = sectionName + "_text";
  const imageName          = sectionName + "_image";

  if (!order) order = 1;

  results.push(genericSection(textName, contentType, cells, order));

  cells = generateCells(textName, "image-single", null, image, imageType);

  results.push(genericSection(imageName, contentType, cells, (order + 1)));

  return results;
}

export function textBottomSections(
    sectionName: string,
    contentType: string | null  = null,
    content: string | null      = "Replace with your text",
    image: string | null        = null,
    imageType: ImageType | null = null,
    order: number | null        = 1,
): Section[] {
  const results: Section[] = [];
  const textName           = sectionName + "_text";
  const imageName          = sectionName + "_image";
  let cells: Cell[]        = generateCells(imageName, "image-single", null, image, imageType);

  if (!order) order = 1;

  results.push(genericSection(textName, contentType, cells, order));

  cells = generateCells(textName, contentType, "text-single", content);

  results.push(genericSection(imageName, contentType, cells, (order + 1)));

  return results;
}

export function textLeftSection(
    sectionName: string,
    contentType: string,
    content: string | null      = "Replace with your text",
    image: string | null        = null,
    imageType: ImageType | null = null,
    order: number | null        = 1,
): Section {
  const cells: Cell[]    = generateCells(sectionName, "text-left", content, image, imageType)
  const results: Section = genericSection(sectionName, contentType, cells, order);

  return results;
}

export function textRightSection(
    sectionName: string,
    contentType: string,
    content: string | null      = "Replace with your text",
    image: string | null        = null,
    imageType: ImageType | null = null,
    order: number | null        = 1,
): Section {
  const cells: Cell[]    = generateCells(sectionName, "text-right", content, image, imageType)
  const results: Section = genericSection(sectionName, contentType, cells, order);

  return results;
}

export function headerSections(
    sectionName: string,
    contentType: string | null  = null,
    content: string | null      = "Replace with your text",
    image: string | null        = null,
    imageType: ImageType | null = null,
    order: number | null        = 1,
    caption: string             = "Replace with your caption",
): Section[] {
  const results: Section[] = [];
  const topName            = sectionName + "_top";
  const bottomName         = sectionName + "_bottom";
  let cells: Cell[]        = generateCells(topName, "text-left", caption, image, imageType)

  if (!order) order = 1;

  results.push(genericSection(topName, contentType, cells, order));

  cells = generateCells(bottomName, contentType, "text-right", content);

  results.push(genericSection(bottomName, contentType, cells, (order + 1)));

  return results;
}

export function generateSections(name: string,
                                 contentType: string | null    = null,
                                 type: string | null           = null,
                                 text: string | null           = null,
                                 imageName: string | null      = null,
                                 imageType: ImageType | null   = null,
                                 order: number | null          = 1,
                                 extraText: string | undefined = undefined) {
  let results: Section[] = [];

  switch (type) {
    case "generic-section":
    case "generic-cell":
    case "text-single":
    case "image-single":
    case "text-left":
    case "text-right":
    case "three-column":
    case "four-column":
    case "five-column":
      if (type === "generic-section") type = "generic-cell";

      const cells: Cell[] = generateCells(name, type, text, imageName, imageType);

      results = [ genericSection(name, contentType, cells, order) ];
      break;
    case "text-top":
      results = textTopSections(name, contentType, text, imageName, imageType, order);
      break;

    case "text-bottom":
      results = textBottomSections(name, contentType, text, imageName, imageType, order);
      break;

    case "header-section":
      results = headerSections(name, contentType, text, imageName, imageType, order, extraText);
      break;
  }

  return results;
}
