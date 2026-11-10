import React from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { cleanup, fireEvent, render, screen } from '@testing-library/react';

vi.mock('../../app/javascript/components/RenderCell', () => ({ default: () => <div>Preview</div> }));
vi.mock('../../app/javascript/components/renderUtilities', () => ({
  renderSectionName: () => <div>Section name field</div>,
  renderCellName: () => <div>Column name field</div>,
  renderImage: () => <div>Image picker</div>,
  renderLink: () => <div>Link field</div>,
  renderCellOrder: () => <div>Order field</div>,
  renderCellWidth: () => <div>Width field</div>,
  renderContent: () => <div>Content field</div>
}));
import FormattingEditor from '../../app/javascript/components/FormattingEditor';
import CellEditor from '../../app/javascript/components/CellEditor';
afterEach(cleanup);

const lastFormatting = onChange => onChange.mock.calls.at(-1)[0];

describe('Use rounded borders on the Layout tab', () => {
  it('adds the box classes and shows them in the Classes field', () => {
    const onChange = vi.fn();
    render(<FormattingEditor formatting={{ classes: 'mb-3' }} onChange={onChange} />);
    fireEvent.click(screen.getByLabelText('Use rounded borders'));
    expect(lastFormatting(onChange).classes).toBe('mb-3 bg-white rounded-4 shadow-sm p-3 p-lg-4');
    expect(screen.getByLabelText('Classes:').value).toBe('mb-3 bg-white rounded-4 shadow-sm p-3 p-lg-4');
    expect(screen.getByLabelText('Use rounded borders').checked).toBe(true);
  });

  it('takes the box classes out again and keeps the others', () => {
    const onChange = vi.fn();
    render(<FormattingEditor formatting={{ classes: 'mb-3 bg-white rounded-4 shadow-sm p-3 p-lg-4 text-center' }} onChange={onChange} />);
    const box = screen.getByLabelText('Use rounded borders');
    expect(box.checked).toBe(true);
    fireEvent.click(box);
    expect(lastFormatting(onChange).classes).toBe('mb-3 text-center');
  });

  it('leaves out the white background when the column has a background colour', () => {
    const onChange = vi.fn();
    render(<FormattingEditor formatting={{ 'background-color': '#eef' }} onChange={onChange} />);
    fireEvent.click(screen.getByLabelText('Use rounded borders'));
    expect(lastFormatting(onChange).classes).toBe('rounded-4 shadow-sm p-3 p-lg-4');
  });

  it('follows a change typed in the Classes field', () => {
    render(<FormattingEditor formatting={{}} onChange={vi.fn()} />);
    fireEvent.change(screen.getByLabelText('Classes:'), { target: { value: 'rounded-4' } });
    expect(screen.getByLabelText('Use rounded borders').checked).toBe(true);
  });
});

describe('Round the picture corners on the Image tab', () => {
  const cell = { id: 4, cell_name: 'photos', section_name: 'garden', content: null, enabled: true };

  it('rounds a group slide show and the Layout tab keeps it', () => {
    render(<CellEditor cell={{ ...cell, image: 'ImageGroup:roses', formatting: { image_classes: 'shadow' } }} editorOptions={{ tabbed: true }} />);
    fireEvent.click(screen.getByLabelText("Round the corners of the group's pictures"));
    expect(screen.getByLabelText('Image Classes:').value).toBe('shadow rounded-3');

    // A later change on the Layout tab must not put back the old image classes.
    fireEvent.click(screen.getByRole('tab', { name: 'Layout' }));
    fireEvent.click(screen.getByLabelText('Use rounded borders'));
    expect(screen.getByLabelText('Image Classes:').value).toBe('shadow rounded-3');
    expect(screen.getByLabelText("Round the corners of the group's pictures").checked).toBe(true);
  });

  it('offers it for a single picture but not for a video', () => {
    const { unmount } = render(<CellEditor cell={{ ...cell, image: 'ImageFile:rose', formatting: {} }} editorOptions={{ tabbed: true }} />);
    expect(screen.getByLabelText('Round the picture corners')).toBeTruthy();
    unmount();
    render(<CellEditor cell={{ ...cell, image: 'VideoImage:"tour"', formatting: {} }} editorOptions={{ tabbed: true }} />);
    expect(screen.queryByLabelText('Round the picture corners')).toBeNull();
  });
});
