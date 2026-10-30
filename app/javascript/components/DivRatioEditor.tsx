import React, { useState } from "react";

interface Props {
  widths: Array<string | null | undefined>;
  onChange: (widths: string[]) => void;
}

export default function DivRatioEditor({ widths, onChange }: Props) {
  const [value, setValue] = useState(() => widths.map(width => parseFloat(width || '') || 50).join(':'));
  const [invalid, setInvalid] = useState(false);

  const apply = () => {
    const match = value.match(/^\s*(\d+(?:\.\d+)?)\s*:\s*(\d+(?:\.\d+)?)\s*$/);
    const left = match ? Number(match[1]) : 0;
    const right = match ? Number(match[2]) : 0;
    if (!left || !right || !Number.isFinite(left + right)) {
      setInvalid(true);
      return;
    }
    setInvalid(false);
    const leftPercent = Number((100 * left / (left + right)).toFixed(6));
    onChange([`${leftPercent}%`, `${Number((100 - leftPercent).toFixed(6))}%`]);
  };

  return (
    <div className="row mb-2">
      <label htmlFor="divRatio" className="col-2 d-flex align-items-center">Div Ratio:</label>
      <div className="col-5">
        <div className="d-flex gap-2">
          <input id="divRatio" type="text" className="form-control" value={value}
            onChange={event => { setValue(event.target.value); setInvalid(false); }}
            aria-invalid={invalid} aria-describedby="divRatioHelp" />
          <button type="button" className="btn btn-secondary text-nowrap" onClick={apply}>Apply Ratio</button>
        </div>
        <div id="divRatioHelp" className={invalid ? 'text-danger' : 'form-text'}>
          {invalid ? 'Enter two positive numbers separated by a colon.' : 'Left column : right column. For example, 7:5 or 59:41. Apply to preview, then Save Section.'}
        </div>
      </div>
    </div>
  );
}
