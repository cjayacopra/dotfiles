const fs = require('fs');
const path = require('path');

const MIME_TYPES_FILE = '/usr/share/mime/types';

class MimeDiscovery {
  /**
   * Lists all available MIME types on the system.
   * @returns {Promise<string[]>}
   */
  static async listMimeTypes() {
    return new Promise((resolve, reject) => {
      fs.readFile(MIME_TYPES_FILE, 'utf8', (err, data) => {
        if (err) {
          return reject(new Error(`Failed to read MIME types file: ${err.message}`));
        }
        const mimes = data
          .split('\n')
          .map(line => line.trim())
          .filter(line => line && !line.startsWith('#'));
        resolve(mimes);
      });
    });
  }

  /**
   * Searches for MIME types containing a specific query.
   * @param {string} query 
   * @returns {Promise<string[]>}
   */
  static async searchMimeTypes(query) {
    const allMimes = await this.listMimeTypes();
    const q = query.toLowerCase();
    return allMimes.filter(mime => mime.toLowerCase().includes(q));
  }
}

module.exports = MimeDiscovery;
