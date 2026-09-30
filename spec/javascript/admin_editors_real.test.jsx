import React from 'react';
import { afterEach, expect, it, vi } from 'vitest';
import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
vi.mock('quill', () => ({ default: { import: () => class {}, register: vi.fn() } }));
vi.mock('react-quill', () => ({ default: React.forwardRef(({ value, onChange }, ref) => {
  React.useImperativeHandle(ref, () => ({ getEditor: () => ({ root: { innerHTML: value }, getModule: () => ({ addHandler() {} }) }) }));
  return <textarea aria-label="Rich text" value={value} onChange={e => onChange(e.target.value)} />;
}) }));
vi.mock('../../app/javascript/components/RenderCell', () => ({ default: () => <div>Preview</div> }));
import CellEditor from '../../app/javascript/components/CellEditor';
afterEach(cleanup);
it('initializes the standalone column and image picker without changing parent hook order', () => {
  const cell = { id: 1, cell_name: 'column', section_name: 'section', content: 'Text', formatting: {}, image: null };
  const onFinished = vi.fn();
  const { container } = render(<CellEditor cell={cell} editorOptions={{ availableSectionNames: ['section'], availableImages: ['photo'], availableImageGroups: ['gallery'], availableVideos: ['clip'] }} onFinished={onFinished} />);
  expect(screen.getByText('Save Column')).toBeTruthy();
  fireEvent.change(container.querySelector('#image_type'), { target: { value: 'Groups' } });
  expect(container.querySelector('#image_type').value).toBe('Groups');
  fireEvent.change(container.querySelector('#cell_name'), { target: { value: 'changed' } });
  fireEvent.click(screen.getByText('Cancel'));
  expect(onFinished).toHaveBeenCalledWith(cell);
});


it('toggles the responsive menu and aria state in both directions', async () => {
  const { Application } = await import('@hotwired/stimulus');
  const { default: NavigationController } = await import('../../app/javascript/controllers/navigation_controller');
  const application = Application.start();
  application.register('navigation', NavigationController);
  const { container } = render(<nav data-controller="navigation">
    <button data-action="navigation#toggle" data-navigation-target="toggle" aria-expanded="false">Toggle</button>
    <div data-navigation-target="menu" className="collapse">Menu</div>
  </nav>);
  const button = screen.getByText('Toggle');
  try {
    await waitFor(() => expect(application.getControllerForElementAndIdentifier(container.firstChild, 'navigation')).toBeTruthy());
    fireEvent.click(button);
    expect(button.getAttribute('aria-expanded')).toBe('true');
    expect(container.querySelector('.collapse').classList.contains('show')).toBe(true);
    fireEvent.click(button);
    expect(button.getAttribute('aria-expanded')).toBe('false');
    expect(container.querySelector('.collapse').classList.contains('show')).toBe(false);
  } finally { application.stop(); }
});
