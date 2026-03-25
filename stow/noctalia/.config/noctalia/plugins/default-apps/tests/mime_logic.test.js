const MimeLogic = require('../lib/mime_logic');

describe('Default Handler Query Logic', () => {
  it('should query the default handler for a MIME type', async () => {
    // text/plain should have a default handler on most systems
    const handler = await MimeLogic.getDefaultHandler('text/plain');
    expect(handler).toBeDefined();
    expect(handler).toMatch(/\.desktop$/);
  });

  it('should list all available handlers for a MIME type', async () => {
    const handlers = await MimeLogic.getAllHandlers('text/plain');
    expect(Array.isArray(handlers)).toBe(true);
    expect(handlers.length).toBeGreaterThan(0);
    expect(handlers.every(h => h.endsWith('.desktop'))).toBe(true);
  });
});
