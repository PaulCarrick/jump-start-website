// app/javascript/services/menuItemService.tsx
import { sendRequest } from "./utilities";
export function getMenuItems(query, limit = null, setError = null) {
    const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
    const url = `/api/v1/menu_items${queryString}`;
    return sendRequest(url, setError);
}
export function newMenuItem(params = {}) {
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
export function show(id, setError = null) {
    return sendRequest(`/api/v1/menu_items/${id}`, setError);
}
export function get(id, setError = null) {
    return sendRequest(`/api/v1/menuItem/${id}`, setError);
}
export function createMenuItem(menuItem, setError = null) {
    return sendRequest("/api/v1/menu_items/", setError, "POST", { menuItem: menuItem });
}
export function updateMenuItem(menuItem, setError = null) {
    if (!menuItem.id) {
        console.error("Error: MenuItem ID is required for updating.");
        return null;
    }
    return sendRequest(`/api/v1/menu_items/${menuItem.id}`, setError, "PATCH", { menuItem });
}
export function deleteMenuItem(id, setError = null) {
    return sendRequest(`/api/v1/menu_items/${id}`, setError, "DELETE");
}
export function genericMenuItem(label, link, menu_order = 1, parent_id = null, menu_type = "Main", id = null, icon = null, options = null, access = null) {
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
export function generateMenuItem(label, link, menu_order, parent_id) {
    const results = genericMenuItem(label, link, menu_order, parent_id);
    return results;
}
