// /app/javascript/services/pageService.tsx

import { sendRequest }                                                      from "./utilities";
import { FooterItem, ImageType, MenuItem, Page, Section, SetErrorCallback } from "../types/dataTypes";
import { hasCells, generateSections }                                       from "./sectionService";

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

export function newPage(params: Partial<Page> = {}): Page {
  return {
    name:        params.name,
    section:     params.section,
    title:       params.title,
    access:      params.access || null,
    menu_item:   params.menu_item || null,
    footer_item: params.footer_item || null,
    sections:    params.sections || []
  };
}

export function show(id: number | string, setError: SetErrorCallback | null = null): Page | null {
  return sendRequest(`/api/v1/pages/${id}`, setError);
}

export function createPage(page: Page, setError: SetErrorCallback | null = null): Page | null {
  if (page.menu_item?.parent_id === -1) page.menu_item.parent_id = null;
  if (page.footer_item?.parent_id === -1) page.footer_item.parent_id = null;

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

  const transformedMenuItem =
            page.menu_item && typeof page.menu_item === "object"
            ? {
                  ...page.menu_item,
                  id: page.menu_item.id === -1 ? null : page.menu_item.id,
                }
            : undefined;

  const transformedFooterItem =
            page.footer_item && typeof page.footer_item === "object"
            ? {
                  ...page.footer_item,
                  id: page.footer_item.id === -1 ? null : page.footer_item.id,
                }
            : undefined;

  const pageWithNested = {
    ...page,
    sections_attributes: transformedSections,
    ...(transformedMenuItem && { menu_item_attributes: transformedMenuItem }),
    ...(transformedFooterItem && { footer_item_attributes: transformedFooterItem }),
  };

  delete (pageWithNested as any).sections;
  delete (pageWithNested as any).menu_item;
  delete (pageWithNested as any).footer_item;

  return sendRequest("/api/v1/pages/", setError, "POST", { page: pageWithNested });
}

export function updatePage(page: Page, setError: SetErrorCallback | null = null): Page | null {
  if (!page.id) {
    console.error("Error: Page ID is required for updating.");
    return null;
  }

  if (page.menu_item?.parent_id === -1) page.menu_item.parent_id = null;
  if (page.footer_item?.parent_id === -1) page.footer_item.parent_id = null;

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

  const transformedMenuItem =
            page.menu_item && typeof page.menu_item === "object"
            ? {
                  ...page.menu_item,
                  id: page.menu_item.id === -1 ? null : page.menu_item.id,
                }
            : undefined;

  const transformedFooterItem =
            page.footer_item && typeof page.footer_item === "object"
            ? {
                  ...page.footer_item,
                  id: page.footer_item.id === -1 ? null : page.footer_item.id,
                }
            : undefined;

  const pageWithNested = {
    ...page,
    sections_attributes: transformedSections,
    ...(transformedMenuItem && { menu_item_attributes: transformedMenuItem }),
    ...(transformedFooterItem && { footer_item_attributes: transformedFooterItem }),
  };

  delete (pageWithNested as any).sections;
  delete (pageWithNested as any).menu_item;
  delete (pageWithNested as any).footer_item;

  return sendRequest(`/api/v1/pages/${page.id}`, setError, "PATCH", { pageWithNested });
}

export function deletePage(id: number, setError: SetErrorCallback | null = null): Page | null {
  return sendRequest(`/api/v1/pages/${id}`, setError, "DELETE");
}

export function genericPage(
    pageName: string,
    sections: Section[]           = [],
    sectionName: string | null    = null,
    title: string | null          = null,
    access: string | null         = null,
    menuItem: MenuItem | null     = null,
    footerItem: FooterItem | null = null
): Page {
  return {
    name:        pageName,
    sections:    sections,
    access:      access,
    section:     sectionName ? sectionName : pageName,
    title:       title ?
                 title
                       :
                 pageName.toLowerCase()
                         .replace(/\b\w/g, (char) => char.toUpperCase()),
    menu_item:   menuItem,
    footer_item: footerItem
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
