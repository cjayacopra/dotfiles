const MimeDiscovery = require('../lib/mime_discovery');

describe('MIME Type Discovery Logic', () => {
  it('should list common MIME types', async () => {
    const mimes = await MimeDiscovery.listMimeTypes();
    expect(Array.isArray(mimes)).toBe(true);
    expect(mimes.length).toBeGreaterThan(0);
    expect(mimes).toContain('text/plain');
    expect(mimes).toContain('image/png');
  });

  it('should handle search for MIME types', async () => {
    const results = await MimeDiscovery.searchMimeTypes('text');
    expect(results.every(m => m.includes('text'))).toBe(true);
  });
});
