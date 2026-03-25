.pragma library

/**
 * Common logic for MIME management in QML context.
 * In a real Noctalia environment, this would use shell-exposed methods.
 * For this MVP, we assume a bridge is provided.
 */

function listMimeTypes(callback) {
    // This would call a native method or run a shell command
    // Placeholder implementation for QML logic
    Noctalia.Shell.execute("cat /usr/share/mime/types", function(stdout) {
        var mimes = stdout.split('\n')
            .map(function(l) { return l.trim(); })
            .filter(function(l) { return l && !l.startsWith('#'); });
        callback(mimes);
    });
}

function getDefaultHandler(mimeType, callback) {
    Noctalia.Shell.execute("xdg-mime query default " + mimeType, function(stdout) {
        callback(stdout.trim());
    });
}

function getAllHandlers(mimeType, callback) {
    Noctalia.Shell.execute("gio mime " + mimeType, function(stdout) {
        var lines = stdout.split('\n');
        var handlers = [];
        var sectionFound = false;

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line.startsWith('Registered applications:') || 
                line.startsWith('Recommended applications:')) {
                sectionFound = true;
                continue;
            }
            
            if (sectionFound && line.endsWith('.desktop')) {
                if (handlers.indexOf(line) === -1) {
                    handlers.push(line);
                }
            }
        }
        callback(handlers);
    });
}

function setDefaultHandler(mimeType, handler, callback) {
    Noctalia.Shell.execute("xdg-mime default " + handler + " " + mimeType, function() {
        if (callback) callback();
    });
}
