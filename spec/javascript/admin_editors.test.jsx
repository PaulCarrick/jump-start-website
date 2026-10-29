import React from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { cleanup, fireEvent, render, screen } from '@testing-library/react';

vi.mock('quill', () => ({ default: { import: () => class {}, register: vi.fn() } }));
vi.mock('react-quill', () => ({ default: React.forwardRef(({ value, onChange, onBlur }, ref) => {
  React.useImperativeHandle(ref, () => ({ getEditor: () => ({ root: { innerHTML: value },
    getModule: () => ({ addHandler() {} }), clipboard: { dangerouslyPasteHTML() {} } }) }));
  return <textarea aria-label="Rich text" value={value} onChange={e => onChange(e.target.value)} onBlur={onBlur} />;
}) }));
vi.mock('../../app/javascript/components/RenderCell', () => ({ default: () => <div>Preview</div> }));
vi.mock('../../app/javascript/components/renderUtilities', () => ({
  renderSectionName: () => null, renderCellName: () => null, renderImage: () => null,
  renderLink: () => null, renderCellOrder: () => null,
  renderContent: (key, value, setValue) => <input aria-label="Column content" value={value || ''} onChange={e => setValue(e.target.value, key)} />
}));
import HtmlEditor from '../../app/javascript/components/HtmlEditor.jsx';
import FormattingEditor from '../../app/javascript/components/FormattingEditor';
import CellEditor from '../../app/javascript/components/CellEditor';
afterEach(() => { cleanup(); delete window.editorChanged; });

describe('admin editor regressions', () => {
  it('delivers HTML for hyphenated IDs without storing the view toggle as content', () => {
    window.editorChanged = vi.fn();
    render(<HtmlEditor id="blog-post-content" onChange="window.editorChanged(editorContent,id);" />);
    fireEvent.change(screen.getByLabelText('Rich text'), { target: { value: '<p>Post body</p>' } });
    expect(window.editorChanged).toHaveBeenLastCalledWith('<p>Post body</p>', 'blog-post-content');
    fireEvent.click(screen.getByText('Switch to HTML View **'));
    fireEvent.change(screen.getByPlaceholderText('Edit raw HTML here'), { target: { value: '<p>Edited HTML</p>' } });
    expect(window.editorChanged).toHaveBeenLastCalledWith('<p>Edited HTML</p>', 'blog-post-content');
    expect(window.editorChanged.mock.calls.every(([value]) => typeof value === 'string')).toBe(true);
    fireEvent.click(screen.getByText('Switch to Editor View'));
    expect(screen.getByLabelText('Rich text').value).toBe('<p>Edited HTML</p>');
  });

  it('passes raw HTML content on blur when Quill is unmounted', () => {
    const onBlur = vi.fn();
    render(<HtmlEditor id="content" value="old" onBlur={onBlur} />);
    fireEvent.click(screen.getByText('Switch to HTML View **'));
    const field = screen.getByPlaceholderText('Edit raw HTML here');
    fireEvent.change(field, { target: { value: '<p>Raw body</p>' } }); fireEvent.blur(field);
    expect(onBlur).toHaveBeenLastCalledWith('<p>Raw body</p>', 'content');
  });

  it('preserves all four margin choices and background in stored formatting', () => {
    const onChange = vi.fn();
    const { container } = render(<FormattingEditor formatting={{ classes: 'col-6 m-2' }} onChange={onChange} />);
    for (const [id, value] of Object.entries({ marginTop: 'mt-3', marginLeft: 'ms-3', marginBottom: 'mb-3', marginRight: 'me-3', backgroundColor: 'red' })) {
      fireEvent.change(container.querySelector('#' + id), { target: { value } });
    }
    const value = onChange.mock.calls.at(-1)[0];
    expect(value.classes).toBe('col-6 m-2 mt-3 ms-3 mb-3 me-3');
    expect(value['background-color']).toBe('red');
    expect(container.querySelector('#marginTop').value).toBe('mt-3');
  });

  it('adds and edits a CSS entry without rendering stale parent props', () => {
    const onChange = vi.fn(); const { container } = render(<FormattingEditor formatting={{}} onChange={onChange} />);
    fireEvent.click(screen.getByText('Switch to Formatting Mode **'));
    fireEvent.change(container.querySelector('#formattingField'), { target: { value: 'container_classes' } });
    const field = container.querySelector('#container_classes');
    for (const value of ['e', 'e2e', 'e2e-formatting-value']) fireEvent.change(field, { target: { value } });
    expect(field.value).toBe('e2e-formatting-value');
    expect(onChange.mock.calls.at(-1)[0].container_classes).toBe('e2e-formatting-value');
    fireEvent.click(screen.getByText('Delete')); expect(container.querySelector('#container_classes')).toBeNull();
  });

  it('cancels a column with its original snapshot rather than null or edited data', () => {
    const cell = { id: 1, cell_name: 'original', section_name: 'section', content: 'Original content', formatting: {}, image: null };
    const onFinished = vi.fn(); render(<CellEditor cell={cell} onFinished={onFinished} />);
    fireEvent.change(screen.getByLabelText('Column content'), { target: { value: 'Discarded content' } });
    fireEvent.click(screen.getByText('Cancel'));
    expect(onFinished).toHaveBeenCalledWith(cell);
  });
});
