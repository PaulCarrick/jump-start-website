// app/javascript/types/dataTypes.ts

// Types for pages and other data

export type ActionType = "edit" | "delete";
export type CellType = "text" | "image" | "blank" | null;
export type ImageType = "Images" | "Section" | "Groups" | "Videos" | "Upload" | null;
export type SectionTypes = "text-single" | "image-single" | "text-top" | "text-bottom" |
                           "text-right" | "text-left" | "header-section" | "three-column" |
                           "four-column" | "five-column" | null;
export type CellTypes = "text-single" | "image-single" | "text-right" | "text-left" | "three-column" |
                        "four-column" | "five-column" | null;

export type PageOptions = {
  availableImages?: any[];
  availableImageGroups?: any[];
  availableVideos?: any[];
  defaultPageName?: string | null;
  defaultSectionName?: string | null;
  defaultCellName?: string | null;
  returnUrl?: string | null;
  cancelUrl?: string | null;

  [key: string]: any;
}

export type CellFormatting = {
  margin_top?: string;
  margin_left?: string;
  margin_bottom?: string;
  margin_right?: string;
  background_color?: string;
  styles?: string;
  classes?: string;
}

export type Cell = {
  cell_name: string;
  index?: number | null;
  id?: number | null;
  section_id?: number | null;
  section_name?: string | null;
  cell_type?: CellType;
  cell_order?: number | null;
  content?: string | null;
  options?: Record<string, any> | null;
  image?: string | null;
  link?: string | null;
  formatting?: Record<string, any>;
  width?: string | null;
};

export type Section = {
  index?: number | null;
  id?: number | null;
  section_name: string;
  section_order?: number | null;
  content_type?: string | null;
  image?: string | null;
  link?: string | null;
  description?: string | null;
  row_style?: string | null;
  div_ratio?: string | null;
  formatting?: object | null;
  text_attributes?: object | null;
  image_attributes?: object | null;
  cells: Cell[];
};

export type Page = {
  id?: number | null;
  name: string;
  section: string;
  title?: string;
  access?: string | null;
  sections?: Section[];
};

export type ImageFile = {
  index?: number | null;
  id?: number | null;
  name: string;
  caption?: string | null;
  description?: string | null;
  mime_type?: string | null;
  group?: string | null;
  slide_order?: number | null;
  image_url?: string | null;
}

export type SetValueCallback = (newValue: string, attribute: string) => void | null;
export type SetErrorCallback = (error: string) => void;
export type SectionCallback = (section: Section) => void | null;
export type SectionActionCallback = (section: Section, action: ActionType) => void | null;
export type CellCallback = (cell: Cell) => void | null;
export type CellActionCallback = (cell: Cell, action: ActionType) => void | null;
export type GeneratedCellsCallback = (cells: Cell[]) => void | null;
