import React from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { cleanup, fireEvent, render, screen } from '@testing-library/react';

vi.mock('../../app/javascript/components/RenderCell', () => ({ default: () => <div>Preview</div> }));
vi.mock('../../app/javascript/components/FormattingEditor', () => ({ default: () => <div>Formatting fields</div> }));
vi.mock('../../app/javascript/components/renderUtilities', () => ({
  renderSectionName: () => <div>Section name field</div>,
  renderCellName: () => <div>Column name field</div>,
  renderImage: () => <div>Image picker</div>,
  renderLink: () => <div>Link field</div>,
  renderCellOrder: () => <div>Order field</div>,
  renderCellWidth: (width, setValue) => <input aria-label="Width" value={width || ''} onChange={e => setValue(e.target.value, 'width')} />,
  renderContent: (key, value, setValue) => <input aria-label="Column content" value={value || ''} onChange={e => setValue(e.target.value, key)} />
}));
import CellEditor from '../../app/javascript/components/CellEditor';
afterEach(cleanup);

// A field is shown when no tab pane around it is hidden.
const shown = element => element.closest('[hidden]') === null;

const cell = { id: 4, cell_name: 'intro', section_name: 'garden', content: '<p>Hello</p>', image: null, formatting: {}, enabled: true };

describe('the column editor in the page workspace', () => {
  it('groups the fields into Content, Image, Layout and Advanced tabs', () => {
    render(<CellEditor cell={cell} editorOptions={{ tabbed: true }} />);
    expect(screen.getAllByRole('tab').map(tab => tab.textContent)).toEqual(['Content', 'Image', 'Layout', 'Advanced']);
    expect(shown(screen.getByText('Link field'))).toBe(true);
    expect(shown(screen.getByText('Image picker'))).toBe(false);

    fireEvent.click(screen.getByRole('tab', { name: 'Advanced' }));
    expect(shown(screen.getByText('Column name field'))).toBe(true);
    expect(shown(screen.getByText('Order field'))).toBe(true);
    expect(screen.getByRole('tab', { name: 'Advanced' }).getAttribute('aria-selected')).toBe('true');
  });

  it('keeps what was typed when switching tabs', () => {
    render(<CellEditor cell={cell} editorOptions={{ tabbed: true }} />);
    fireEvent.change(screen.getByLabelText('Column content'), { target: { value: 'Changed text' } });
    fireEvent.click(screen.getByRole('tab', { name: 'Layout' }));
    expect(shown(screen.getByText('Formatting fields'))).toBe(true);
    fireEvent.click(screen.getByRole('tab', { name: 'Content' }));
    expect(screen.getByLabelText('Column content').value).toBe('Changed text');
  });

  it('opens an image column on the Image tab', () => {
    render(<CellEditor cell={{ ...cell, content: null, image: 'ImageFile:rose' }} editorOptions={{ tabbed: true }} />);
    expect(screen.getByRole('tab', { name: 'Image' }).getAttribute('aria-selected')).toBe('true');
    expect(shown(screen.getByText('Image picker'))).toBe(true);
  });

  it('edits the column width on the Advanced tab', () => {
    const onChange = vi.fn();
    render(<CellEditor cell={{ ...cell, width: 'auto' }} editorOptions={{ tabbed: true }} />);
    fireEvent.click(screen.getByRole('tab', { name: 'Advanced' }));
    const width = screen.getByLabelText('Width');
    expect(shown(width)).toBe(true);
    fireEvent.change(width, { target: { value: '100%' } });
    expect(screen.getByLabelText('Width').value).toBe('100%');
  });

  it('keeps the classic layout without the option', () => {
    render(<CellEditor cell={cell} />);
    expect(screen.queryAllByRole('tab')).toHaveLength(0);
    expect(shown(screen.getByText('Image picker'))).toBe(true);
  });
});
