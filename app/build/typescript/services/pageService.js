// /app/javascript/services/pageService.tsx
import { sendRequest } from "./utilities";
import { hasCells, generateSections } from "./sectionService";
export function hasSections(page) {
    let results = false;
    if (page?.sections)
        results = (page.sections.length > 0);
    return results;
}
export function containsCells(page) {
    let results = false;
    if (page?.sections)
        results = page.sections.some(section => hasCells(section));
    return results;
}
export function getPages(query, limit, setError = null) {
    const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
    const url = `/api/v1/pages${queryString}`;
    return sendRequest(url, setError);
}
export function newPage(params = {}) {
    return {
        name: params.name,
        section: params.section,
        title: params.title,
        access: params.access || null,
        menu_item: params.menu_item || null,
        footer_item: params.footer_item || null,
        sections: params.sections || []
    };
}
export function show(id, setError = null) {
    return sendRequest(`/api/v1/pages/${id}`, setError);
}
export function createPage(page, setError = null) {
    if (page.menu_item?.parent_id === -1)
        page.menu_item.parent_id = null;
    if (page.footer_item?.parent_id === -1)
        page.footer_item.parent_id = null;
    const transformedSections = page.sections?.map(section => {
        const sectionWithNestedCells = {
            ...section,
            cells_attributes: section.cells.map(cell => cell.id === -1 ? { ...cell, id: null } : cell)
        };
        delete sectionWithNestedCells.cells;
        return sectionWithNestedCells;
    });
    const transformedMenuItem = page.menu_item && typeof page.menu_item === "object"
        ? {
            ...page.menu_item,
            id: page.menu_item.id === -1 ? null : page.menu_item.id,
        }
        : undefined;
    const transformedFooterItem = page.footer_item && typeof page.footer_item === "object"
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
    delete pageWithNested.sections;
    delete pageWithNested.menu_item;
    delete pageWithNested.footer_item;
    return sendRequest("/api/v1/pages/", setError, "POST", { page: pageWithNested });
}
export function updatePage(page, setError = null) {
    if (!page.id) {
        console.error("Error: Page ID is required for updating.");
        return null;
    }
    if (page.menu_item?.parent_id === -1)
        page.menu_item.parent_id = null;
    if (page.footer_item?.parent_id === -1)
        page.footer_item.parent_id = null;
    const transformedSections = page.sections?.map(section => {
        const sectionWithNestedCells = {
            ...section,
            cells_attributes: section.cells.map(cell => cell.id === -1 ? { ...cell, id: null } : cell)
        };
        delete sectionWithNestedCells.cells;
        return sectionWithNestedCells;
    });
    const transformedMenuItem = page.menu_item && typeof page.menu_item === "object"
        ? {
            ...page.menu_item,
            id: page.menu_item.id === -1 ? null : page.menu_item.id,
        }
        : undefined;
    const transformedFooterItem = page.footer_item && typeof page.footer_item === "object"
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
    delete pageWithNested.sections;
    delete pageWithNested.menu_item;
    delete pageWithNested.footer_item;
    return sendRequest(`/api/v1/pages/${page.id}`, setError, "PATCH", { pageWithNested });
}
export function deletePage(id, setError = null) {
    return sendRequest(`/api/v1/pages/${id}`, setError, "DELETE");
}
export function genericPage(pageName, sections = [], sectionName = null, title = null, access = null, menuItem = null, footerItem = null) {
    return {
        name: pageName,
        sections: sections,
        access: access,
        section: sectionName ? sectionName : pageName,
        title: title ?
            title
            :
                pageName.toLowerCase()
                    .replace(/\b\w/g, (char) => char.toUpperCase()),
        menu_item: menuItem,
        footer_item: footerItem
    };
}
export function generatePage(pageName, sectionName = null, type = null, title = null, access = null, content = "Replace with your text", image = null, imageType = "Images", extraText = undefined) {
    const sections = generateSections(sectionName ? sectionName : pageName, pageName, type, content, image, imageType, 1, extraText);
    const results = genericPage(pageName, sections, sectionName, title, access);
    return results;
}
