// app/javascript/services/menuItemService.tsx

import { sendRequest }                from "./utilities";
import { MenuItem, SetErrorCallback } from "../types/dataTypes";

export function getMenuItems(query: string | null, limit: number | null = null, setError: SetErrorCallback | null = null): MenuItem[] | null {
  const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
  const url         = `/api/v1/menu_items${queryString}`;

  return sendRequest(url, setError);
}

export function newMenuItem(params: Partial<MenuItem> = {}): MenuItem {
  return {
    id: params.id,
    label: params.label,
    menu_type: params.menu_type,
    icon: params.icon,
    options: params.options,
    link: params.link,
    access: params.access,
    menu_order: params.menu_order,
    parent_id: params.parent_id
  };
}

export function show(id: number | string, setError: SetErrorCallback | null = null): MenuItem | null {
  return sendRequest(`/api/v1/menu_items/${id}`, setError);
}

export function get(id: number, setError: SetErrorCallback | null = null): MenuItem | null {
  return sendRequest(`/api/v1/menuItem/${id}`, setError);
}

export function createMenuItem(menuItem: MenuItem, setError: SetErrorCallback | null = null): MenuItem | null {
  return sendRequest("/api/v1/menu_items/", setError, "POST", { menuItem: menuItem });
}

export function updateMenuItem(menuItem: MenuItem, setError: SetErrorCallback | null = null): MenuItem | null {
  if (!menuItem.id) {
    console.error("Error: MenuItem ID is required for updating.");
    return null;
  }
  return sendRequest(`/api/v1/menu_items/${menuItem.id}`, setError, "PATCH", { menuItem });
}

export function deleteMenuItem(id: number, setError: SetErrorCallback | null = null): MenuItem | null {
  return sendRequest(`/api/v1/menu_items/${id}`, setError, "DELETE");
}

export function genericMenuItem(
    label: string,
    link: string,
    menu_order: number | null = 1,
    parent_id: number | null = null,
    menu_type: string | null = "Main",
    id: number | null = null,
    icon: string | null = null,
    options: string | null = null,
    access: string | null = null
): MenuItem {
  return {
    id: id,
    label: label,
    menu_type: menu_type,
    icon: icon,
    options: options,
    link: link,
    access: access,
    menu_order: menu_order,
    parent_id: parent_id
  };
}

export function generateMenuItem(
    label: string,
    link: string,
    menu_order: number,
    parent_id: number
): MenuItem {
  const results: MenuItem   = genericMenuItem(label, link, menu_order, parent_id);

  return results;
}
