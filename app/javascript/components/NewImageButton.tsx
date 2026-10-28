import React, { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";

export default function NewImageButton({ onReturn }: { onReturn: () => void }) {
  const [open, setOpen] = useState(false);
  const dialog = useRef<HTMLDialogElement>(null);
  const frame = useRef<HTMLIFrameElement>(null);
  const trigger = useRef<HTMLButtonElement>(null);

  const close = () => {
    setOpen(false);
    onReturn();
    trigger.current?.focus();
  };

  useEffect(() => {
    if (!open) return;
    dialog.current?.showModal();
    const returned = (event: MessageEvent) => {
      if (event.origin === window.location.origin && event.source === frame.current?.contentWindow &&
          event.data?.type === "jumpstart:image-picker-complete") close();
    };
    window.addEventListener("message", returned);
    return () => window.removeEventListener("message", returned);
  }, [open, onReturn]);

  if (!document.querySelector('meta[name="admin-image-create"][content="true"]')) return null;

  return <>
    <button ref={trigger} type="button" className="btn btn-secondary mt-2" onClick={() => setOpen(true)}>New Image</button>
    {open && createPortal(
      <dialog ref={dialog} aria-label="New Image" onCancel={(event) => { event.preventDefault(); close(); }}
              style={{ width: "95vw", maxWidth: "1200px", padding: "1rem", border: "1px solid #dee2e6", borderRadius: "0.5rem" }}>
        <div className="d-flex justify-content-between align-items-center mb-2">
          <h2 className="h4 mb-0">New Image</h2>
          <button type="button" className="btn btn-secondary" onClick={close}>Cancel</button>
        </div>
        <iframe ref={frame} title="New Image form"
                src="/admin/image_files/new?return_url=%2Fadmin%2Fimage_files%3Fimage_picker_complete%3Dtrue"
                style={{ width: "100%", height: "75vh", border: 0 }} />
      </dialog>, document.body)}
  </>;
}
