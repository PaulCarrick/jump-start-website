// /app/javascript/services/cellService.jsx
export function sendRequest(url, setError = null, method = "GET", body = null) {
    let results = null;
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
    const request = new XMLHttpRequest();
    request.open(method, url, false);
    request.setRequestHeader("Content-Type", "application/json");
    if (csrfToken)
        request.setRequestHeader("X-CSRF-Token", csrfToken);
    request.send(body ? JSON.stringify(body) : null);
    if (request.status < 400 && request.responseText) {
        results = JSON.parse(request.responseText);
    }
    else {
        let message = "";
        try {
            message = JSON.parse(request.responseText).errors;
        }
        catch (e) {
            message = "Unknown error.";
        }
        const error = `There was a problem! Problem: ${request.statusText}, Error: ${message}`;
        console.error(error);
        if (setError)
            setError(error);
    }
    return results;
}
export function getAdminPaths(model, id) {
    let results = null;
    if (!id)
        id = "nil";
    const url = `/admin/${model}/${id}/admin_urls`;
    const request = new XMLHttpRequest();
    request.open("GET", url, false);
    request.send(null);
    if (request.status === 200)
        results = JSON.parse(request.responseText);
    return results;
}
