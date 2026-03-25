const fs = require('fs');
const path = require('path');

const qmlPath = path.join(__dirname, '..', 'MimeTypeBrowser.qml');

describe('MIME Type Browser UI', () => {
  it('should have a MimeTypeBrowser.qml file', () => {
    expect(fs.existsSync(qmlPath)).toBe(true);
  });

  it('should contain a search field and a list view', () => {
    if (fs.existsSync(qmlPath)) {
      const content = fs.readFileSync(qmlPath, 'utf8');
      expect(content).toContain('TextField');
      expect(content).toContain('ListView');
    }
  });
});
