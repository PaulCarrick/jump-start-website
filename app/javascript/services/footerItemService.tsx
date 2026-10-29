// app/javascript/services/footerItemService.tsx

import { sendRequest }                  from "./utilities";
import { FooterItem, SetErrorCallback } from "../types/dataTypes";

export function getFooterItems(query: string | null, limit: number | null = null, setError: SetErrorCallback | null = null): FooterItem[] | null {
  const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
  const url         = `/api/v1/footer_items${queryString}`;

  return sendRequest(url, setError);
}

export function newFooterItem(params: Partial<FooterItem> = {}): FooterItem {
  return {
    id:           params.id,
    label:        params.label,
    icon:         params.icon,
    options:      params.options,
    link:         params.link,
    access:       params.access,
    footer_order: params.footer_order,
    parent_id:    params.parent_id
  };
}

export function show(id: number | string, setError: SetErrorCallback | null = null): FooterItem | null {
  return sendRequest(`/api/v1/footer_items/${id}`, setError);
}

export function get(id: number, setError: SetErrorCallback | null = null): FooterItem | null {
  return sendRequest(`/api/v1/footer_item/${id}`, setError);
}

export function createFooterItem(footerItem: FooterItem, setError: SetErrorCallback | null = null): FooterItem | null {
  return sendRequest("/api/v1/footer_items/", setError, "POST", { footerItem: footerItem });
}

export function updateFooterItem(footerItem: FooterItem, setError: SetErrorCallback | null = null): FooterItem | null {
  if (!footerItem.id) {
    console.error("Error: FooterItem ID is required for updating.");
    return null;
  }
  return sendRequest(`/api/v1/footer_items/${footerItem.id}`, setError, "PATCH", { footerItem });
}

export function deleteFooterItem(id: number, setError: SetErrorCallback | null = null): FooterItem | null {
  return sendRequest(`/api/v1/footer_items/${id}`, setError, "DELETE");
}

export function genericFooterItem(
    label: string,
    link: string,
    footer_order: number | null = 1,
    parent_id: number | null    = null,
    id: number | null           = null,
    icon: string | null         = null,
    options: string | null      = null,
    access: string | null       = null
): FooterItem {
  return {
    id:           id,
    label:        label,
    icon:         icon,
    options:      options,
    link:         link,
    access:       access,
    footer_order: footer_order,
    parent_id:    parent_id
  };
}

export function generateFooterItem(
    label: string,
    link: string,
    footer_order: number,
    parent_id: number
): FooterItem {
  const results: FooterItem = genericFooterItem(label, link, footer_order, parent_id);

  return results;
}
