// /app/javascript/services/cellService.jsx

// Utility functions

import { SetErrorCallback } from "../types/dataTypes";

export function sendRequest(url: string, setError: SetErrorCallback | null = null, method: string = "GET", body: any = null): any {
  let results: any = null;
  const csrfToken  = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");
  const request    = new XMLHttpRequest();

  request.open(method, url, false);
  request.setRequestHeader("Content-Type", "application/json");

  if (csrfToken)
    request.setRequestHeader("X-CSRF-Token", csrfToken);

  request.send(body ? JSON.stringify(body) : null);

  if (request.status < 400 && request.responseText) {
    results = JSON.parse(request.responseText);
  }
  else {
    let message: string = "";

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

export function getAdminPaths(model: string, id: string | number) {
  let results = null;

  if (!id)
    id = "nil";

  const url     =
            `/admin/${model}/${id}/admin_urls`
  ;
  const request = new XMLHttpRequest();

  request.open("GET", url, false);
  request.send(null);

  if (request.status === 200)
    results = JSON.parse(request.responseText)

  return results;
}
