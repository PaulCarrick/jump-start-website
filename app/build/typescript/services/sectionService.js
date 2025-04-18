// /app/javascript/services/sectionService.tsx
import { generateCells } from "./cellService";
import { sendRequest } from "./utilities";
export function hasCells(section) {
    let results = false;
    if (section?.cells)
        results = (section.cells.length > 0);
    return results;
}
export function generateRandomSectionName(base = "new-section") {
    const suffix = Math.random().toString(36).substring(2, 7);
    return `${base}-${suffix}`;
}
export function generateUniqueSectionName(sections, prefix = "new-section_") {
    const regex = new RegExp(`^${prefix}(\\d+)$`);
    const maxNumber = sections
        .map(section => {
        const match = section.section_name?.match(regex);
        return match ? parseInt(match[1], 10) : 0;
    })
        .reduce((max, num) => Math.max(max, num), 0);
    return `${prefix}${maxNumber + 1}`;
}
export function getNextSectionOrder(sections) {
    return (sections
        .map(section => section.section_order ?? 0)
        .reduce((max, val) => Math.max(max, val), 0) + 1);
}
export function sortSections(sections) {
    if (sections) {
        sections.sort((a, b) => {
            return (a.section_order ?? 0) - (b.section_order ?? 0);
        });
        return sections;
    }
    else {
        return [];
    }
}
export function getSectionsForContentType(contentType, setError = null) {
    const url = `/api/v1/sections/${encodeURIComponent(contentType)}`;
    return sendRequest(url, setError);
}
export function getSections(query, limit, setError = null) {
    const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
    const url = `/api/v1/sections${queryString}`;
    return sendRequest(url, setError);
}
export function newSection(params = {}) {
    return {
        content_type: params.content_type || null,
        section_name: params.section_name || "new-section",
        section_order: params.section_order || null,
        image: params.image || null,
        link: params.link || null,
        description: params.description || null,
        row_style: params.row_style || null,
        div_ratio: params.div_ratio || null,
        image_attributes: params.image_attributes || {},
        text_attributes: params.text_attributes || {},
        formatting: params.formatting || {},
        cells: []
    };
}
export function createSection(section, setError = null) {
    const sectionWithNestedCells = {
        ...section,
        cells_attributes: section.cells.map(cell => cell.id === -1 ? { ...cell, id: null } : cell),
    };
    delete sectionWithNestedCells.cells;
    return sendRequest("/api/v1/sections/", setError, "POST", { section: sectionWithNestedCells });
}
export function updateSection(section, setError = null) {
    if (!section.id) {
        console.error("Error: Section ID is required for updating.");
        return null;
    }
    const sectionWithNestedCells = {
        ...section,
        cells_attributes: section.cells.map(cell => cell.id === -1 ? { ...cell, id: null } : cell),
    };
    delete sectionWithNestedCells.cells;
    return sendRequest(`/api/v1/sections/${section.id}`, setError, "PATCH", { section: sectionWithNestedCells });
}
export function deleteSection(id, setError = null) {
    return sendRequest(`/api/v1/sections/${id}`, setError, "DELETE");
}
export function genericSection(sectionName, contentType, cells = null, order = 1) {
    const formatting = {
        image_classes: "m-3",
        text_classes: "m-3"
    };
    return {
        content_type: contentType,
        section_name: sectionName,
        section_order: order,
        image: null,
        link: null,
        description: null,
        row_style: null,
        div_ratio: null,
        image_attributes: {},
        text_attributes: {},
        formatting: formatting,
        cells: cells ? cells : []
    };
}
export function textSection(sectionName, contentType, content = "Replace with your text", order = 1) {
    const cells = generateCells(sectionName, contentType, "text-single", content);
    const results = genericSection(sectionName, contentType, cells, order);
    return results;
}
export function imageSection(sectionName, contentType, image, imageType = null, order = 1) {
    const cells = generateCells(sectionName, "image-single", null, image, imageType);
    const results = genericSection(sectionName, contentType, cells, order);
    return results;
}
export function textTopSections(sectionName, contentType = null, content = "Replace with your text", image = null, imageType = null, order = 1) {
    const results = [];
    let cells = generateCells(sectionName, contentType, "text-single", content);
    const textName = sectionName + "_text";
    const imageName = sectionName + "_image";
    if (!order)
        order = 1;
    results.push(genericSection(textName, contentType, cells, order));
    cells = generateCells(textName, "image-single", null, image, imageType);
    results.push(genericSection(imageName, contentType, cells, (order + 1)));
    return results;
}
export function textBottomSections(sectionName, contentType = null, content = "Replace with your text", image = null, imageType = null, order = 1) {
    const results = [];
    const textName = sectionName + "_text";
    const imageName = sectionName + "_image";
    let cells = generateCells(imageName, "image-single", null, image, imageType);
    if (!order)
        order = 1;
    results.push(genericSection(textName, contentType, cells, order));
    cells = generateCells(textName, contentType, "text-single", content);
    results.push(genericSection(imageName, contentType, cells, (order + 1)));
    return results;
}
export function textLeftSection(sectionName, contentType, content = "Replace with your text", image = null, imageType = null, order = 1) {
    const cells = generateCells(sectionName, "text-left", content, image, imageType);
    const results = genericSection(sectionName, contentType, cells, order);
    return results;
}
export function textRightSection(sectionName, contentType, content = "Replace with your text", image = null, imageType = null, order = 1) {
    const cells = generateCells(sectionName, "text-right", content, image, imageType);
    const results = genericSection(sectionName, contentType, cells, order);
    return results;
}
export function headerSections(sectionName, contentType = null, content = "Replace with your text", image = null, imageType = null, order = 1, caption = "Replace with your caption") {
    const results = [];
    const topName = sectionName + "_top";
    const bottomName = sectionName + "_bottom";
    let cells = generateCells(topName, "text-left", caption, image, imageType);
    if (!order)
        order = 1;
    results.push(genericSection(topName, contentType, cells, order));
    cells = generateCells(bottomName, contentType, "text-right", content);
    results.push(genericSection(bottomName, contentType, cells, (order + 1)));
    return results;
}
export function generateSections(name, contentType = null, type = null, text = null, imageName = null, imageType = null, order = 1, extraText = undefined) {
    let results = [];
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
            if (type === "generic-section")
                type = "generic-cell";
            const cells = generateCells(name, type, text, imageName, imageType);
            results = [genericSection(name, contentType, cells, order)];
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
