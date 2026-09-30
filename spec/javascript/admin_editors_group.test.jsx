import { readFileSync } from 'node:fs';
import { runInNewContext } from 'node:vm';
import { describe, expect, it, vi } from 'vitest';
const source = readFileSync(`${process.cwd()}/app/assets/javascripts/views/admin/image_files/index.js`, 'utf8');
function handler(token, updateOk = true) {
  const context = {
    fetch: vi.fn().mockResolvedValueOnce({ ok: true, json: async () => ({ Gallery: 3 }) })
      .mockResolvedValueOnce({ ok: updateOk }),
    document: { querySelector: () => token ? { content: token } : null },
    prompt: vi.fn(() => 'Gallery'), alert: vi.fn(), console: { error: vi.fn() },
    location: { reload: vi.fn() }
  };
  runInNewContext(source, context);
  return context;
}
describe('image group list handler', () => {
  it('updates and reloads when Rails omits the CSRF meta tag', async () => {
    const ctx = handler(null); await ctx.addToGroup(7);
    const [url, options] = ctx.fetch.mock.calls[1];
    expect(url).toBe('/admin/image_files/7');
    expect(options.method).toBe('PATCH');
    expect(JSON.parse(options.body)).toEqual({ image_file: { group: 'Gallery', slide_order: 4 } });
    expect(options.headers['X-CSRF-Token']).toBeUndefined();
    expect(ctx.location.reload).toHaveBeenCalledOnce(); expect(ctx.alert).not.toHaveBeenCalled();
  });
  it('includes the CSRF token when present', async () => {
    const ctx = handler('auth-token'); await ctx.addToGroup(7);
    expect(ctx.fetch.mock.calls[1][1].headers['X-CSRF-Token']).toBe('auth-token');
  });
  it('reports rejected updates without reloading', async () => {
    const ctx = handler(null, false); await ctx.addToGroup(7);
    expect(ctx.location.reload).not.toHaveBeenCalled();
    expect(ctx.alert).toHaveBeenCalledWith('Could not update image group: Failed to update image group');
  });
  it('does not update when the prompt is canceled', async () => {
    const ctx = handler(null); ctx.prompt.mockReturnValue(null); await ctx.addToGroup(7);
    expect(ctx.fetch).toHaveBeenCalledTimes(1); expect(ctx.location.reload).not.toHaveBeenCalled();
  });
});
