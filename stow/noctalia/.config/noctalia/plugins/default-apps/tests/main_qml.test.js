const fs = require('fs');
const path = require('path');

const qmlPath = path.join(__dirname, '..', 'main.qml');

describe('Main Entry Point', () => {
  it('should have a main.qml file', () => {
    expect(fs.existsSync(qmlPath)).toBe(true);
  });

  it('should import Noctalia components', () => {
    if (fs.existsSync(qmlPath)) {
      const content = fs.readFileSync(qmlPath, 'utf8');
      expect(content).toContain('import QtQuick');
      expect(content).toContain('import org.noctalia.shell');
    }
  });

  it('should define an AppWindow', () => {
    if (fs.existsSync(qmlPath)) {
      const content = fs.readFileSync(qmlPath, 'utf8');
      expect(content).toContain('AppWindow');
    }
  });

  it('should integrate MimeTypeBrowser and HandlerSelection', () => {
    if (fs.existsSync(qmlPath)) {
      const content = fs.readFileSync(qmlPath, 'utf8');
      expect(content).toContain('MimeTypeBrowser');
      expect(content).toContain('HandlerSelection');
    }
  });
});
