const fs = require('fs');
const path = require('path');

const qmlPath = path.join(__dirname, '..', 'HandlerSelection.qml');

describe('Handler Selection UI', () => {
  it('should have a HandlerSelection.qml file', () => {
    expect(fs.existsSync(qmlPath)).toBe(true);
  });

  it('should contain a section for current default and a list of options', () => {
    if (fs.existsSync(qmlPath)) {
      const content = fs.readFileSync(qmlPath, 'utf8');
      expect(content).toContain('ListView');
      expect(content).toContain('RadioButton');
    }
  });
});
