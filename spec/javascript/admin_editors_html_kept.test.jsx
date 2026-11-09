import React from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { cleanup, fireEvent, render, screen } from '@testing-library/react';

// A stand-in for Quill that behaves like the real one: as soon as it starts it
// rewrites the HTML it was given (dropping a class) and reports that as an
// "api" change; typing reports "user" changes.
vi.mock('react-quill-new', () => ({
  Quill: { import: () => class {}, register: vi.fn() },
  default: React.forwardRef(({ value, onChange, onBlur }, ref) => {
    const cleaned = value.replace(/ class="[^"]*"/g, '');
    React.useImperativeHandle(ref, () => ({
      getEditor: () => ({ root: { innerHTML: cleaned }, getSemanticHTML: () => cleaned, getModule: () => ({ addHandler() {} }), getSelection: () => null }),
    }));
    React.useEffect(() => { onChange(cleaned, null, 'api'); }, []);
    return <textarea aria-label="Rich text" value={cleaned} onChange={event => onChange(event.target.value, null, 'user')} onBlur={onBlur} />;
  }),
}));
import HtmlEditor from '../../app/javascript/components/HtmlEditor.jsx';
afterEach(cleanup);

const stored = '<p class="fw-light lead mb-3">Paul and Virginia in Japan.</p>';

describe('the rich-text editor keeps HTML it was not asked to change', () => {
  it('reports nothing when it only loads the text', () => {
    const onChange = vi.fn();
    const onBlur = vi.fn();
    render(<HtmlEditor id="content" value={stored} onChange={onChange} onBlur={onBlur} />);
    fireEvent.blur(screen.getByLabelText('Rich text'));
    expect(onChange).not.toHaveBeenCalled();
    expect(onBlur).not.toHaveBeenCalled();
  });

  it('shows the stored HTML, classes included, in the HTML view', () => {
    render(<HtmlEditor id="content" value={stored} onChange={vi.fn()} />);
    fireEvent.click(screen.getByText('Switch to HTML View **'));
    expect(screen.getByPlaceholderText('Edit raw HTML here').value).toContain('class="fw-light lead mb-3"');
  });

  it('reports the text once the person edits it', () => {
    const onChange = vi.fn();
    render(<HtmlEditor id="content" value={stored} onChange={onChange} />);
    fireEvent.change(screen.getByLabelText('Rich text'), { target: { value: '<p>Edited</p>' } });
    expect(onChange).toHaveBeenLastCalledWith('<p>Edited</p>', 'content');
  });
});
