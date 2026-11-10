// /app/javascript/components/roundedClasses.ts

// The classes behind the admin's "Use rounded borders" and "Round the
// picture corners" checkboxes. The box is the rounded white card the site's
// pages use (bg-white rounded-4 shadow-sm p-3 p-lg-4); its spacing below
// comes from the Margin Bottom select.

export const ROUNDED_BOX_CLASSES = ["rounded-4", "shadow-sm", "p-3", "p-lg-4"];
export const ROUNDED_BOX_BACKGROUND = "bg-white";
export const ROUNDED_IMAGE_CLASS = "rounded-3";

function classList(classes: string | null | undefined): string[] {
  return (classes || "").split(/\s+/).filter(Boolean);
}

export function hasClass(classes: string | null | undefined, name: string): boolean {
  return classList(classes).includes(name);
}

// Takes the given classes out, then puts them back at the end when include
// is true. Other classes keep their order.
export function setClasses(
  classes: string | null | undefined,
  names: string[],
  include: boolean,
): string {
  const kept = classList(classes).filter((token) => !names.includes(token));
  return (include ? [...kept, ...names] : kept).join(" ");
}

export function hasRoundedBox(classes: string | null | undefined): boolean {
  return hasClass(classes, "rounded-4");
}

// The white background is left out when the column has its own background
// colour: bg-white is !important and would hide that colour.
export function setRoundedBox(
  classes: string | null | undefined,
  include: boolean,
  hasBackgroundColor: boolean,
): string {
  const withoutBox = setClasses(classes, [...ROUNDED_BOX_CLASSES, ROUNDED_BOX_BACKGROUND], false);
  if (!include) return withoutBox;
  const boxClasses = hasBackgroundColor
    ? ROUNDED_BOX_CLASSES
    : [ROUNDED_BOX_BACKGROUND, ...ROUNDED_BOX_CLASSES];
  return setClasses(withoutBox, boxClasses, true);
}
