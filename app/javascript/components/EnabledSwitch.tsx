import React, { useId } from "react";

export default function EnabledSwitch({ enabled, onChange }: { enabled?: boolean; onChange: (enabled: boolean) => void }) {
  const id = useId();
  return <div className="form-check form-switch mb-3">
    <input id={id} type="checkbox" role="switch" className="form-check-input" checked={enabled !== false} onChange={event => onChange(event.target.checked)} />
    <label htmlFor={id} className="form-check-label">Enabled</label>
  </div>;
}
