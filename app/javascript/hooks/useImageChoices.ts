import { useCallback, useEffect, useState } from "react";

type Choices = { images: string[]; videos: string[]; groups: string[] };
let cached: { location: string; choices: Choices } | null = null;
const changedEvent = "jumpstart:image-choices-changed";

/** Refresh the complete catalog without remounting the editor or changing its draft. */
export function useImageChoices() {
  const [choices, setChoices] = useState<Choices | null>(() => cached?.location === window.location.href ? cached.choices : null);
  const [error, setError] = useState("");
  useEffect(() => {
    const changed = (event: Event) => {
      setChoices((event as CustomEvent<Choices>).detail);
      setError("");
    };
    window.addEventListener(changedEvent, changed);
    return () => window.removeEventListener(changedEvent, changed);
  }, []);
  const reload = useCallback(async () => {
    try {
      const response = await fetch("/admin/image_files?image_picker_choices=true", { headers: { Accept: "application/json" } });
      if (!response.ok) throw new Error("Image choices could not be refreshed. Please try again.");
      const catalog: Choices = await response.json();
      cached = { location: window.location.href, choices: catalog };
      setChoices(catalog);
      window.dispatchEvent(new CustomEvent(changedEvent, { detail: catalog }));
      setError("");
    } catch {
      setError("Image choices could not be refreshed. Please try again.");
    }
  }, []);
  return { choices, reload, error };
}
