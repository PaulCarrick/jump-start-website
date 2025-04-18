// /app/javascript/services/pageService.tsx

import { sendRequest }                                             from "./utilities";
import { ImageType, Page, PageOptions, Section, SetErrorCallback } from "../types/dataTypes";
import { hasCells, generateSections }                              from "./sectionService";

export function hasSections(page: Page | null): boolean {
  let results: boolean = false;

  if (page?.sections)
    results = (page.sections.length > 0);

  return results;
}

export function containsCells(page: Page | null): boolean {
  let results: boolean = false;

  if (page?.sections)
    results = page.sections.some(section => hasCells(section));

  return results;
}

export function getPages(query: string | null, limit: number, setError: SetErrorCallback | null = null): Page[] | null {
  const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
  const url         = `/api/v1/pages${queryString}`;

  return sendRequest(url, setError);
}

export function newPage(params: Partial<Page> = {}, options: PageOptions = {}): Page {
  return {
    name:     params.name || options.defaultPageName || "new-page",
    section:  params.section ||options.defaultSectionName || "new-section",
    title:    params.title || "New Page",
    access:   params.access || null,
    sections: params.sections || []
  };
}

export function show(id: number | string, setError: SetErrorCallback | null = null): Page | null {
  return sendRequest(`/api/v1/pages/${id}`, setError);
}

export function createPage(page: Page, setError: SetErrorCallback | null = null): Page | null {
  const transformedSections = page.sections?.map(section => {
    const sectionWithNestedCells = {
      ...section,
      cells_attributes: section.cells.map(cell =>
                                              cell.id === -1 ? { ...cell, id: null } : cell
      )
    };

    delete (sectionWithNestedCells as any).cells;

    return sectionWithNestedCells;
  });

  const pageWithNestedSections = {
    ...page,
    sections_attributes: transformedSections,
  };

  delete (pageWithNestedSections as any).sections;

  return sendRequest("/api/v1/pages/", setError, "POST", { page: pageWithNestedSections });
}

export function updatePage(page: Page, setError: SetErrorCallback | null = null): Page | null {
  if (!page.id) {
    console.error("Error: Page ID is required for updating.");
    return null;
  }
  return sendRequest(`/api/v1/pages/${page.id}`, setError, "PATCH", { page });
}

export function deletePage(id: number, setError: SetErrorCallback | null = null): Page | null {
  return sendRequest(`/api/v1/pages/${id}`, setError, "DELETE");
}

export function genericPage(
    pageName: string,
    sections: Section[]        = [],
    sectionName: string | null = null,
    title: string | null       = null,
    access: string | null      = null
): Page {
  return {
    name:     pageName,
    sections: sections,
    access:   access,
    section:  sectionName ? sectionName : pageName,
    title:    title ?
              title
                    :
              pageName.toLowerCase()
                      .replace(/\b\w/g, (char) => char.toUpperCase())
  };
}

export function generatePage(
    pageName: string,
    sectionName: string | null    = null,
    type: string | null           = null,
    title: string | null          = null,
    access: string | null         = null,
    content: string | null        = "Replace with your text",
    image: string | null          = null,
    imageType: ImageType | null   = "Images",
    extraText: string | undefined = undefined
): Page {
  const sections: Section[] = generateSections(sectionName ? sectionName : pageName,
                                               pageName,
                                               type,
                                               content,
                                               image,
                                               imageType,
                                               1,
                                               extraText);
  const results: Page       = genericPage(pageName, sections, sectionName, title, access);

  return results;
}
