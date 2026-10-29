import { useState } from "react";

/** Own the editable copy and original snapshot for one mounted editor session. */
export function useEditorDraft<T>(initialize: () => T | null) {
  const [original] = useState<T | null>(() => {
    const record = initialize();
    return record === null ? null : structuredClone(record);
  });
  const [draft, setDraft] = useState<T | null>(() =>
    original === null ? null : structuredClone(original),
  );

  return [draft, setDraft, original] as const;
}
