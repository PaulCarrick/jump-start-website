// app/javascript/services/footerItemService.tsx
import { sendRequest } from "./utilities";
export function getFooterItems(query, limit = null, setError = null) {
    const queryString = query ? `?${query}&limit=${limit}` : `?limit=${limit}`;
    const url = `/api/v1/footer_items${queryString}`;
    return sendRequest(url, setError);
}
export function newFooterItem(params = {}) {
    return {
        id: params.id,
        label: params.label,
        icon: params.icon,
        options: params.options,
        link: params.link,
        access: params.access,
        footer_order: params.footer_order,
        parent_id: params.parent_id
    };
}
export function show(id, setError = null) {
    return sendRequest(`/api/v1/footer_items/${id}`, setError);
}
export function get(id, setError = null) {
    return sendRequest(`/api/v1/footer_item/${id}`, setError);
}
export function createFooterItem(footerItem, setError = null) {
    return sendRequest("/api/v1/footer_items/", setError, "POST", { footerItem: footerItem });
}
export function updateFooterItem(footerItem, setError = null) {
    if (!footerItem.id) {
        console.error("Error: FooterItem ID is required for updating.");
        return null;
    }
    return sendRequest(`/api/v1/footer_items/${footerItem.id}`, setError, "PATCH", { footerItem });
}
export function deleteFooterItem(id, setError = null) {
    return sendRequest(`/api/v1/footer_items/${id}`, setError, "DELETE");
}
export function genericFooterItem(label, link, footer_order = 1, parent_id = null, id = null, icon = null, options = null, access = null) {
    return {
        id: id,
        label: label,
        icon: icon,
        options: options,
        link: link,
        access: access,
        footer_order: footer_order,
        parent_id: parent_id
    };
}
export function generateFooterItem(label, link, footer_order, parent_id) {
    const results = genericFooterItem(label, link, footer_order, parent_id);
    return results;
}
