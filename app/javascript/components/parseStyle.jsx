// /app/javascripts/components.parseStyle.jsx

// Helper to parse inline styles

const parseStyle = (styleString = "{}") => {
  if (!styleString || typeof styleString !== "string") return {};

  return styleString.split(";").reduce((styleObj, style) => {
    const [key, value] = style.split(":");

    if (!key || !value) return styleObj;

    const camelCaseKey = key.trim().replace(/-([a-z])/g, (_, char) => char.toUpperCase());

    styleObj[camelCaseKey] = value.trim();

    return styleObj;
  }, {});
};

export default parseStyle;
