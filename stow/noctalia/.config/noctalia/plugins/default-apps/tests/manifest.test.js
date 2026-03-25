const fs = require('fs');
const path = require('path');

const manifestPath = path.join(__dirname, '..', 'manifest.json');

describe('Plugin Scaffolding', () => {
  it('should have a manifest.json file', () => {
    expect(fs.existsSync(manifestPath)).toBe(true);
  });

  it('should have a valid JSON manifest', () => {
    if (fs.existsSync(manifestPath)) {
      const content = fs.readFileSync(manifestPath, 'utf8');
      const manifest = JSON.parse(content);
      expect(manifest).toBeDefined();
      expect(manifest.id).toBeDefined();
      expect(manifest.name).toBeDefined();
      expect(manifest.version).toBeDefined();
      expect(manifest.main).toBeDefined();
      expect(manifest.type).toBe('standalone');
    }
  });
});
