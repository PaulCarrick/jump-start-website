// /app/javascript/services/cellService.ts
import { sendRequest } from "./utilities";
import { getImageFileByName } from "./imageFileService";
export function generateRandomCellName(base = "new-cell") {
    const suffix = Math.random().toString(36).substring(2, 7);
    return `${base}-${suffix}`;
}
export function generateUniqueCellName(cells, prefix = "new-column_") {
    const regex = new RegExp(`^${prefix}(\\d+)$`);
    const maxNumber = cells
        .map(cell => {
        const match = cell.cell_name?.match(regex);
        return match ? parseInt(match[1], 10) : 0;
    })
        .reduce((max, num) => Math.max(max, num), 0);
    return `${prefix}${maxNumber + 1}`;
}
export function getNextCellOrder(cells) {
    return (cells
        .map(cell => cell.cell_order ?? 0)
        .reduce((max, val) => Math.max(max, val), 0) + 1);
}
export function sortCells(cells) {
    if (cells) {
        cells.sort((a, b) => {
            return (a.cell_order ?? 0) - (b.cell_order ?? 0);
        });
        return cells;
    }
    else {
        return [];
    }
}
export function getCellIndex(sectionData, id) {
    let results = null;
    if (sectionData && sectionData.cells) {
        const cellCount = sectionData.cells.length;
        for (let i = 0; i < cellCount; i++) {
            if (sectionData.cells[i].id === id) {
                results = i;
                break;
            }
        }
        return results;
    }
}
export function getCellsForSection(sectionName, setError = null) {
    const url = `/api/v1/cells/${encodeURIComponent(sectionName)}`;
    return sendRequest(url, setError);
}
export function getCells(query, limit, setError = null) {
    const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
    const url = `/api/v1/cells${queryString}`;
    return sendRequest(url, setError);
}
export function newCell(params = {}) {
    return {
        id: -1,
        cell_name: params.cell_name || "new-cell",
        section_name: params.section_name || "section-name",
        cell_type: params.cell_type || null,
        cell_order: params.cell_order || null,
        content: params.content || null,
        options: params.options || {},
        image: params.image || null,
        link: params.link || null,
        formatting: params.formatting || {},
        width: params.width || null,
    };
}
export function createCell(cell, setError = null) {
    if (cell && cell.id && (cell.id < 0))
        cell.id = null;
    return sendRequest("/api/v1/cells/", setError, "POST", { cell });
}
export function updateCell(cell, setError = null) {
    if (cell && cell.id && (cell.id < 0))
        cell.id = null;
    if (!cell.id) {
        console.error("Error: Cell ID is required for updating.");
        return null;
    }
    return sendRequest(`/api/v1/cells/${cell.id}`, setError, "PATCH", { cell });
}
export function deleteCell(id, setError = null) {
    return sendRequest(`/api/v1/cells/${id}`, setError, "DELETE");
}
export function genericCell(sectionName, cellType = "text", order = 1, width = "auto", content = null, image = null, imageType = null, options = {}) {
    const formatting = {
        classes: "m-3",
    };
    let link = image;
    if (options?.expandingCellsToggle) {
        formatting.expandingCellsToggle = `toggle, ${options.expandingCellsToggle}, btn btn-link p-0 text-dark`;
    }
    if (options?.expandingCell) {
        formatting.classes += ` ${options.expandingCell}`;
    }
    if (options?.hoverClass) {
        formatting.hoverClass = options.hoverClass;
    }
    if (options?.hoverAction) {
        formatting.hoverAction = options.hoverAction;
    }
    if (image) {
        const imageFile = (imageType !== "Groups") ? getImageFileByName(image) : null;
        if (imageFile?.image_url)
            link = imageFile.image_url;
        if (imageType) {
            switch (imageType) {
                case "Groups":
                    image = "ImageGroup:" + image;
                    break;
                case "Images":
                    image = "ImageFile:" + image;
                    break;
                case "Section":
                    image = "ImageSection:" + image;
                    break;
                case "Videos":
                    image = 'VideoImage:"' + image + '"';
                    break;
            }
        }
    }
    return {
        id: -1,
        section_name: sectionName,
        cell_name: `${sectionName}-${order}`,
        cell_type: cellType,
        cell_order: order,
        content: content,
        image: image,
        link: link,
        width: width,
        formatting: formatting,
        options: options,
    };
}
export function blankCell(sectionName, order = 1, width = "auto") {
    return genericCell(sectionName, "blank", order, width);
}
export function textCell(sectionName, content = "Replace with your text", order = 1, width = "auto", options = {}) {
    return genericCell(sectionName, "text", order, width, content, null, null, options);
}
export function imageCell(sectionName, image = "/images/missing-image.jpg", imageType = null, order = 1, width = "auto", options = {}) {
    return genericCell(sectionName, "image", order, width, null, image, imageType, options);
}
export function textTopSection(sectionName, content = "Replace with your text", image = "/images/missing-image.jpg", imageType = null, textOptions = {}, imageOptions = {}) {
    return [textCell(sectionName, content, 1, "auto", textOptions), imageCell(sectionName, image, imageType, 2, "auto", imageOptions)];
}
export function textBottomSection(sectionName, content = "Replace with your text", image = "/images/missing-image.jpg", imageType = null, textOptions = {}, imageOptions = {}) {
    return [imageCell(sectionName, image, imageType, 1, "100%", imageOptions), textCell(sectionName, content, 2, "100%", textOptions)];
}
export function textLeftSection(sectionName, content = "Replace with your text", image = "/images/missing-image.jpg", imageType = null, textWidth = "50%", textOptions = {}, imageWidth = "50%", imageOptions = {}) {
    return [textCell(sectionName, content, 1, textWidth, textOptions), imageCell(sectionName, image, imageType, 2, imageWidth, imageOptions)];
}
export function textRightSection(sectionName, content = "Replace with your text", image = "/images/missing-image.jpg", imageType = null, textWidth = "50%", textOptions = {}, imageWidth = "50%", imageOptions = {}) {
    return [imageCell(sectionName, image, imageType, 1, imageWidth, imageOptions), textCell(sectionName, content, 2, textWidth, textOptions)];
}
export function imageSection(sectionName, content = "Replace with your text", image = "/images/missing-image.jpg", imageType = null, caption = "Replace with your caption", options = {}) {
    return [textCell(sectionName, caption, 1, "100%"), imageCell(sectionName, image, imageType, 2, "100%"), textCell(sectionName, content, 3, "100%", options)];
}
export function headerSection(sectionName, content = "Replace with your text", image = "/images/missing-image.jpg", imageType = null, title = "Replace with your title", leftWidth = "50%", rightWidth = "50%", options = {}) {
    return [
        [textCell(sectionName, title, 1, leftWidth), imageCell(sectionName, image, imageType, 2, rightWidth)],
        [blankCell(sectionName, 3, leftWidth), textCell(sectionName, content, 4, rightWidth, options)],
    ];
}
export function generateCells(sectionName, type = null, text = null, imageName = null, imageType = null) {
    const results = [];
    const content = text || undefined;
    const image = imageName || undefined;
    let cells;
    switch (type) {
        case "generic-cell":
            results.push(genericCell(sectionName));
            break;
        case "text-single":
            results.push(textCell(sectionName, content));
            break;
        case "image-single":
            results.push(imageCell(sectionName, image, imageType));
            break;
        case "text-left":
            cells = textLeftSection(sectionName, content, image, imageType);
            results.push(...cells);
            break;
        case "text-right":
            cells = textRightSection(sectionName, content, image, imageType);
            results.push(...cells);
            break;
        case "three-column":
            cells = [
                textCell(sectionName, "Text for First Cell.", 1, "33%"),
                textCell(sectionName, "Text for Second Cell.", 2, "33%"),
                textCell(sectionName, "Text for Third Cell.", 3, "34%")
            ];
            results.push(...cells);
            break;
        case "four-column":
            cells = [
                textCell(sectionName, "Text for First Cell.", 1, "25%"),
                textCell(sectionName, "Text for Second Cell.", 2, "25%"),
                textCell(sectionName, "Text for Third Cell.", 3, "25%"),
                textCell(sectionName, "Text for Fourth Cell.", 4, "25%")
            ];
            results.push(...cells);
            break;
        case "five-column":
            cells = [
                textCell(sectionName, "Text for First Cell.", 1, "20%"),
                textCell(sectionName, "Text for Second Cell.", 2, "20%"),
                textCell(sectionName, "Text for Third Cell.", 3, "20%"),
                textCell(sectionName, "Text for Fourth Cell.", 4, "20%"),
                textCell(sectionName, "Text for Fifth Cell.", 5, "20%")
            ];
            results.push(...cells);
            break;
    }
    return results;
}
