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
export function newPage(params = {}, options = {}) {
    return {
        name: params.name || options.defaultPageName || "new-page",
        section: params.section || options.defaultSectionName || "new-section",
        title: params.title || "New Page",
        access: params.access || null,
        sections: params.sections || []
    };
}
export function show(id, setError = null) {
    return sendRequest(`/api/v1/pages/${id}`, setError);
}
export function createPage(page, setError = null) {
    const transformedSections = page.sections?.map(section => {
        const sectionWithNestedCells = {
            ...section,
            cells_attributes: section.cells,
        };
        delete sectionWithNestedCells.cells;
        return sectionWithNestedCells;
    });
    const pageWithNestedSections = {
        ...page,
        sections_attributes: transformedSections,
    };
    delete pageWithNestedSections.sections;
    return sendRequest("/api/v1/pages/", setError, "POST", { page: pageWithNestedSections });
}
export function updatePage(page, setError = null) {
    if (!page.id) {
        console.error("Error: Page ID is required for updating.");
        return null;
    }
    return sendRequest(`/api/v1/pages/${page.id}`, setError, "PATCH", { page });
}
export function deletePage(id, setError = null) {
    return sendRequest(`/api/v1/pages/${id}`, setError, "DELETE");
}
export function genericPage(pageName, sections = [], sectionName = null, title = null, access = null) {
    return {
        name: pageName,
        sections: sections,
        access: access,
        section: sectionName ? sectionName : pageName,
        title: title ?
            title
            :
                pageName.toLowerCase()
                    .replace(/\b\w/g, (char) => char.toUpperCase())
    };
}
export function generatePage(pageName, sectionName = null, type = null, title = null, access = null, content = "Replace with your text", image = null, imageType = "Images", extraText = undefined) {
    const sections = generateSections(sectionName ? sectionName : pageName, pageName, type, content, image, imageType, 1, extraText);
    const results = genericPage(pageName, sections, sectionName, title, access);
    return results;
}
