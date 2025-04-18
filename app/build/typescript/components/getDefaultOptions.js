// /app/javascript/components/getDefaultOptions.jsx
// noinspection JSUnusedGlobalSymbols
// noinspection RegExpRedundantEscape
// Default options for the DisplayContent
import parseStyle from "./parseStyle";
import PropTypes from "prop-types";
import { getDefaultRowStyle } from "./App.jsx";
import { isPresent, dupObject } from "./utilities";
const getDefaultOptions = (format = {}, textAttributes = {}, imageAttributes = {}) => {
    const formatOptions = dupObject(format);
    let options = {
        row_style: getDefaultRowStyle(),
        div_ratio: "",
        row_classes: "align-items-center",
        classes: null,
        styles: {},
        text_classes: null,
        text_styles: {},
        image_classes: null,
        image_styles: { objectFit: "contain" },
        image_caption: null,
        caption_position: "top",
        caption_classes: "caption-default text-center",
        expanding_rows: null,
        expanding_cells: null,
        slide_show_images: null,
        slide_show_type: null,
    };
    if (isPresent(formatOptions)) {
        // Assign options from format
        if (isPresent(formatOptions.row_style))
            options.row_style = formatOptions.row_style;
        if (isPresent(formatOptions.div_ratio))
            options.div_ratio = formatOptions.div_ratio;
        if (isPresent(formatOptions.row_classes))
            options.row_classes = formatOptions.row_classes;
        if (isPresent(formatOptions.classes))
            options.classes = formatOptions.classes;
        if (isPresent(formatOptions.text_classes))
            options.text_classes = formatOptions.text_classes;
        if (isPresent(formatOptions.image_classes))
            options.image_classes = formatOptions.image_classes;
        if (isPresent(formatOptions.image_caption))
            options.image_caption = formatOptions.image_caption;
        if (isPresent(formatOptions.expanding_rows))
            options.expanding_rows = formatOptions.expanding_rows;
        if (isPresent(formatOptions.expanding_cells))
            options.expanding_cells = formatOptions.expanding_cells;
        if (isPresent(formatOptions.slide_show_type))
            options.slide_show_type = formatOptions.slide_show_type;
        if (isPresent(formatOptions.caption_classes))
            options.caption_classes = formatOptions.caption_classes;
        if (isPresent(formatOptions.caption_position))
            options.caption_position = formatOptions.caption_position;
        if (isPresent(formatOptions.slide_show_images))
            options.slide_show_images = formatOptions.slide_show_images;
        if (isPresent(formatOptions.styles)) {
            if (typeof formatOptions.styles === 'string')
                options.styles = parseStyle(formatOptions.styles);
            else
                options.styles = formatOptions.styles;
        }
        if (isPresent(formatOptions.text_styles)) {
            if (typeof formatOptions.text_styles === 'string')
                options.text_styles = parseStyle(formatOptions.text_styles);
            else
                options.text_styles = formatOptions.text_styles;
        }
        if (isPresent(formatOptions.image_styles)) {
            if (typeof formatOptions.image_styles === 'string')
                options.image_styles = parseStyle(formatOptions.image_styles);
            else
                options.image_styles = formatOptions.image_styles;
        }
    }
    else {
        if (isPresent(textAttributes)) {
            if (isPresent(textAttributes.margin_top))
                options.text_classes = textAttributes.margin_top;
            if (isPresent(textAttributes.margin_left))
                options.text_classes = textAttributes.margin_left;
            if (isPresent(textAttributes.margin_bottom))
                options.text_classes = textAttributes.margin_bottom;
            if (isPresent(textAttributes.margin_right))
                options.text_classes = textAttributes.margin_right;
            if (isPresent(textAttributes.background_color))
                options.text_styles = {
                    "background-color": textAttributes.background_color
                };
        }
        if (isPresent(imageAttributes)) {
            if (isPresent(imageAttributes.margin_top))
                options.image_classes = imageAttributes.margin_top;
            if (isPresent(imageAttributes.margin_left))
                options.image_classes = imageAttributes.margin_left;
            if (isPresent(imageAttributes.margin_bottom))
                options.image_classes = imageAttributes.margin_bottom;
            if (isPresent(imageAttributes.margin_right))
                options.image_classes = imageAttributes.margin_right;
            if (isPresent(imageAttributes.background_color))
                options.image_styles = {
                    "background-color": imageAttributes.background_color
                };
        }
    }
    const hasExistingCellDefinitions = /col\-\d{1,2}/.test(options.text_classes) ||
        /col\-\d{1,2}/.test(options.image_classes);
    if (!hasExistingCellDefinitions && hasSplitSections(options.row_style)) {
        const [textCellWidth, imageCellWidth] = getColumWidths(options.div_ratio, options.row_style);
        if (isPresent(textCellWidth) && isPresent(imageCellWidth)) {
            if (isPresent(options.text_classes)) {
                options.text_classes = options.text_classes.replace(/col\-\d{1,2}/g, "").trim();
                options.text_classes += " " + textCellWidth;
            }
            else {
                options.text_classes = textCellWidth;
            }
            if (isPresent(options.image_classes)) {
                options.image_classes = options.image_classes.replace(/col\-\d{1,2}/g, "").trim();
                options.image_classes += " " + imageCellWidth;
            }
            else {
                options.image_classes = `d-flex flex-column ${imageCellWidth}`;
            }
        }
    }
    return new Object(options);
};
export function hasImageSection(rowStyle = getDefaultRowStyle()) {
    return (rowStyle !== "text-single");
}
export function hasTextSection(rowStyle = getDefaultRowStyle()) {
    return (rowStyle !== "image-single");
}
export function hasSplitSections(rowStyle = getDefaultRowStyle()) {
    return (rowStyle === "text-left") || (rowStyle === "text-right");
}
export function isTextOnly(rowStyle = getDefaultRowStyle()) {
    return (!isPresent(rowStyle) || rowStyle === "text-single");
}
export function isImageOnly(rowStyle = getDefaultRowStyle()) {
    return (rowStyle === "image-single");
}
export function hasTextAndImage(rowStyle = getDefaultRowStyle()) {
    return ((rowStyle !== "text-single") && (rowStyle !== "image-single"));
}
export function getColumWidths(divRatio = "50:50", rowStyle = getDefaultRowStyle()) {
    let textCellWidth = "col-12";
    let imageCellWidth = "";
    if (hasSplitSections(rowStyle)) {
        if (divRatio) {
            const match = divRatio.match(/(\d+):(\d+)/);
            if (match) {
                let firstValue = Math.round((parseInt(match[1], 10) / 100.0) * 12);
                let secondValue = 12 - firstValue;
                textCellWidth = `col-${firstValue}`;
                imageCellWidth = `col-${secondValue}`;
            }
            else if (divRatio === "Custom") {
                textCellWidth = "";
                imageCellWidth = "";
            }
        }
        else {
            textCellWidth = "col-6";
            imageCellWidth = "col-6";
        }
    }
    else {
        if (hasImageSection(rowStyle))
            imageCellWidth = "col-12";
    }
    return [textCellWidth, imageCellWidth];
}
export function rowStyleOptions() {
    return ([
        {
            label: "Only Text",
            value: "text-single",
        },
        {
            label: "Only Image",
            value: "image-single",
        },
        {
            label: "Text on the Top",
            value: "text-top",
        },
        {
            label: "Text on the Left",
            value: "text-left",
        },
        {
            label: "Text on the Bottom",
            value: "text-bottom",
        },
        {
            label: "Text on the Right",
            value: "text-right",
        },
        {
            label: "Multicolumn",
            value: "multi-column",
        },
    ]);
}
export function ratioOptions(custom = false) {
    let results = [
        {
            label: "50 percent Text - 50 Percent Image",
            value: "50:50",
        },
        {
            label: "90 Percent Text - 10 Percent Image",
            value: "90:10",
        },
        {
            label: "80 Percent Text - 20 Percent Image",
            value: "80:20",
        },
        {
            label: "70 Percent Text - 30 Percent Image",
            value: "70:30",
        },
        {
            label: "60 Percent Text - 40 Percent Image",
            value: "60:40",
        },
        {
            label: "40 Percent Text - 60 Percent Image",
            value: "40:60",
        },
        {
            label: "30 Percent Text - 70 Percent Image",
            value: "30:70",
        },
        {
            label: "20 Percent Text - 80 Percent Image",
            value: "20:80",
        },
        {
            label: "10 Percent Text - 90 Percent Image",
            value: "10:90",
        },
    ];
    if (custom)
        results.push({
            label: "Custom (set in formatting)",
            value: "Custom",
        });
    return results;
}
export function descriptionOptions() {
    return ([
        {
            label: "Image Description at Top",
            value: "top",
        },
        {
            label: "Image Description at Bottom",
            value: "bottom",
        },
    ]);
}
export function captionOptions() {
    return ([
        {
            label: "Image Captions at Top",
            value: "top",
        },
        {
            label: "Image Captions at Bottom",
            value: "bottom",
        },
    ]);
}
export function formattingOptions(styleData) {
    const fields = [];
    fields.push({ label: "Select an option to add", value: null });
    if (!isPresent(styleData?.row_style))
        fields.push({ label: "Row Style", value: "row_style" });
    if (!isPresent(styleData?.div_ratio))
        fields.push({ label: "Div Ratio", value: "div_ratio" });
    if (!isPresent(styleData?.row_classes))
        fields.push({ label: "Row Classes", value: "row_classes" });
    if (!isPresent(styleData?.classes))
        fields.push({ label: "Classes", value: "classes" });
    if (!isPresent(styleData?.styles))
        fields.push({ label: "Styles", value: "styles" });
    if (!isPresent(styleData?.text_classes))
        fields.push({ label: "Text Classes", value: "text_classes" });
    if (!isPresent(styleData?.text_styles))
        fields.push({ label: "Text Styles", value: "text_styles" });
    if (!isPresent(styleData?.image_classes))
        fields.push({ label: "Image Classes", value: "image_classes" });
    if (!isPresent(styleData?.image_styles))
        fields.push({ label: "Image Styles", value: "image_styles" });
    if (!isPresent(styleData?.image_caption))
        fields.push({ label: "Image Caption", value: "image_caption" });
    if (!isPresent(styleData?.caption_position))
        fields.push({ label: "Image Caption Position", value: "caption_position" });
    if (!isPresent(styleData?.caption_classes))
        fields.push({ label: "Caption Classes", value: "caption_classes" });
    if (!isPresent(styleData?.caption_classes))
        fields.push({ label: "Caption Classes", value: "caption_classes" });
    if (!isPresent(styleData?.expanding_rows))
        fields.push({ label: "Expanding Rows", value: "expanding_rows" });
    if (!isPresent(styleData?.expanding_cells))
        fields.push({ label: "Expanding Cells", value: "expanding_cells" });
    if (!isPresent(styleData?.slide_show_images))
        fields.push({ label: "Slide Show Images", value: "slide_show_images" });
    if (!isPresent(styleData?.slide_show_type))
        fields.push({ label: "Slide Show Type (Prompt)", value: "slide_show_type" });
    return fields;
}
export function getBootstrapOptions() {
    const bootstrapClasses = getBootStrapClasses();
    const options = [];
    bootstrapClasses.forEach(bootstrapClass => {
        bootstrapClass.values.forEach(value => {
            const option = dupObject(bootstrapClass);
            option.label = `${bootstrapClass.label} - ${value}`;
            option.value = bootstrapClass.prefix + value;
            delete option.values;
            delete option.prefix;
            options.push(option);
        });
    });
    return options;
}
export function getBootStrapClasses() {
    return ([
        {
            label: "Width (Percentage)",
            value: null,
            prefix: "w-",
            regex: /w\-(\d{1,3}|auto|min|max)/,
            values: ["none", "25", "50", "75", "100", "auto", "min", "max"]
        },
        {
            label: "Font Size",
            value: null,
            prefix: "fs-",
            regex: /fs\-\d/,
            values: ["none", "1", "2", "3", "4", "5", "6"]
        },
        {
            label: "Font Weight",
            value: null,
            prefix: "fs-",
            regex: /fw\-(bold|bolder|normal|light|lighter)/,
            values: ["none", "bold", "bolder", "normal", "light", "lighter"]
        },
        {
            label: "Opacity (transparency)",
            value: null,
            prefix: "opacity-",
            regex: /opacity\-\d{1,3}/,
            values: ["none", "0", "25", "50", "75", "100"]
        },
        {
            label: "Text",
            value: null,
            prefix: "text-",
            regex: /text\-(primary|secondary|success|danger|warning|info|light|dark|body|muted|white|black\-50|white\-50|start|center|end)/,
            values: ["none", "primary", "secondary", "success", "danger", "warning", "info", "light", "dark", "body", "muted", "white", "black-50", "white-50", "start", "center", "end"]
        },
        {
            label: "Justify Content",
            value: null,
            prefix: "justify-content-",
            regex: /justify\-content\-(start|center|end|between|around|evenly)/,
            values: ["none", "start", "center", "end", "between", "around", "evenly"]
        },
        {
            label: "Borders",
            value: null,
            prefix: "border-",
            regex: /border\-?(\d|top|danger|rounded|rounded\-circle|)/,
            valuePrefix: "border ",
            values: ["none", "0", "1", "2", "3", "4", "5", "top", "rounded", "rounded\\-circle"]
        },
        {
            label: "Padding Top",
            value: null,
            prefix: "pt-",
            regex: /pt\-\d/,
            values: ["none", "0", "1", "2", "3", "4", "5"]
        },
        {
            label: "Padding Left",
            value: null,
            regex: /ps\-\d/,
            values: ["none", "0", "1", "2", "3", "4", "5"]
        },
        {
            label: "Padding Bottom",
            value: null,
            prefix: "pb-",
            regex: /pb\-\d/,
            values: ["none", "0", "1", "2", "3", "4", "5"]
        },
        {
            label: "Padding Right",
            value: null,
            prefix: "pe-",
            regex: /pe\-\d/,
            values: ["none", "0", "1", "2", "3", "4", "5"]
        },
    ]);
}
getDefaultOptions.propTypes = {
    format: PropTypes.shape({
        row_style: PropTypes.string,
        row_classes: PropTypes.string,
        classes: PropTypes.string,
        styles: PropTypes.any,
        text_classes: PropTypes.string,
        text_styles: PropTypes.any,
        image_classes: PropTypes.string,
        image_styles: PropTypes.any,
        image_caption: PropTypes.string,
        caption_position: PropTypes.string,
        caption_classes: PropTypes.string,
        expanding_rows: PropTypes.string,
        expanding_cells: PropTypes.string,
        slide_show_images: PropTypes.any,
        slide_show_type: PropTypes.string,
    }),
    text_attributes: PropTypes.shape({
        margin_top: PropTypes.string,
        margin_left: PropTypes.string,
        margin_right: PropTypes.string,
        margin_bottom: PropTypes.string,
        background_color: PropTypes.string,
    }),
    image_attributes: PropTypes.shape({
        margin_top: PropTypes.string,
        margin_left: PropTypes.string,
        margin_right: PropTypes.string,
        margin_bottom: PropTypes.string,
        background_color: PropTypes.string,
    }),
};
export default getDefaultOptions;
