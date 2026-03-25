const { exec } = require('child_process');

class MimeLogic {
  /**
   * Gets the current default handler for a given MIME type.
   * @param {string} mimeType 
   * @returns {Promise<string>}
   */
  static async getDefaultHandler(mimeType) {
    return new Promise((resolve, reject) => {
      exec(`xdg-mime query default "${mimeType}"`, (err, stdout, stderr) => {
        if (err) {
          return reject(new Error(`Failed to query default handler: ${stderr}`));
        }
        resolve(stdout.trim());
      });
    });
  }

  /**
   * Gets all registered handlers for a given MIME type using 'gio mime'.
   * @param {string} mimeType 
   * @returns {Promise<string[]>}
   */
  static async getAllHandlers(mimeType) {
    return new Promise((resolve, reject) => {
      exec(`gio mime "${mimeType}"`, (err, stdout, stderr) => {
        if (err) {
          return reject(new Error(`Failed to list handlers: ${stderr}`));
        }
        
        const lines = stdout.split('\n');
        const handlers = new Set();
        let sectionFound = false;

        for (const line of lines) {
          const trimmedLine = line.trim();
          if (trimmedLine.startsWith('Registered applications:') || 
              trimmedLine.startsWith('Recommended applications:')) {
            sectionFound = true;
            continue;
          }
          
          if (sectionFound && trimmedLine.endsWith('.desktop')) {
            handlers.add(trimmedLine);
          }
        }
        
        resolve(Array.from(handlers));
      });
    });
  }
}

module.exports = MimeLogic;
