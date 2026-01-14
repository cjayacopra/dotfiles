import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.UI

Item {
  id: root
  property var pluginApi: null

  // Logger helper functions (fallback to console if Logger not available)
  function logDebug(msg) {
    if (typeof Logger !== 'undefined') Logger.d(msg);
    else console.log(msg);
  }

  function logInfo(msg) {
    if (typeof Logger !== 'undefined') Logger.i(msg);
    else console.log(msg);
  }

  function logWarn(msg) {
    if (typeof Logger !== 'undefined') Logger.w(msg);
    else console.warn(msg);
  }

  function logError(msg) {
    if (typeof Logger !== 'undefined') Logger.e(msg);
    else console.error(msg);
  }

  onPluginApiChanged: {
    if (pluginApi) {
      logInfo("HyprlandCheatsheet: pluginApi loaded, starting generator");
      runGenerator();
    }
  }

  Component.onCompleted: {
    if (pluginApi) {
      logDebug("HyprlandCheatsheet: Component.onCompleted, starting generator");
      runGenerator();
    }
  }

  function runGenerator() {
    logDebug("HyprlandCheatsheet: === START GENERATOR ===");
    
    var homeDir = Quickshell.env("HOME");
    if (!homeDir) {
      logError("HyprlandCheatsheet: ERROR - cannot get $HOME");
      saveToDb([{
        "title": pluginApi?.tr("main.error") || "ERROR",
        "binds": [{ "keys": "ERROR", "desc": pluginApi?.tr("main.cannot_get_home") || "Cannot get $HOME" }]
      }]);
      return;
    }

    var filePath = homeDir + "/.config/hypr/keybind.conf";
    logDebug("HyprlandCheatsheet: HOME = " + homeDir);
    logDebug("HyprlandCheatsheet: Full path = " + filePath);
    
    // Most robust execution: use bash redirection to a temp file
    // This avoids all stream/listener issues in Quickshell
    var tmpFile = "/tmp/hypr_cheatsheet.tmp";
    runner.command = ["bash", "-c", "cat " + filePath + " > " + tmpFile];
    runner.running = true;
  }

  Process {
    id: runner

    onExited: (exitCode) => {
      logDebug("HyprlandCheatsheet: Process finished. ExitCode: " + exitCode);
      running = false;
      
      if (exitCode !== 0) {
          logError("HyprlandCheatsheet: ERROR! Code: " + exitCode);
          saveToDb([{
              "title": pluginApi?.tr("main.read_error") || "READ ERROR",
              "binds": [{ "keys": "EXIT CODE", "desc": exitCode.toString() }]
          }]);
          return;
      }

      // Now read the temp file using FileView
      logDebug("HyprlandCheatsheet: Reading temp file");
      tmpFileReader.path = "/tmp/hypr_cheatsheet.tmp";
    }
  }

  FileView {
    id: tmpFileReader
    onTextChanged: {
        if (text && text.length > 0) {
            logDebug("HyprlandCheatsheet: Content retrieved from temp file. Length: " + text.length);
            parseAndSave(text);
            path = ""; // Reset
        }
    }
  }

  function parseAndSave(text) {
    logDebug("HyprlandCheatsheet: Parsing started");
    var lines = text.split('\n');
    logDebug("HyprlandCheatsheet: Number of lines: " + lines.length);
    
    var categories = [];
    var currentCategory = null;

    for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trim();

        if (line.startsWith("#") && line.match(/#\s*\d+\./)) {
            if (currentCategory) {
                categories.push(currentCategory);
            }
            var title = line.replace(/#\s*\d+\.\s*/, "").trim();
            currentCategory = { "title": title, "binds": [] };
        } 
        else if (line.includes("bind") && line.includes('#"')) {
            if (currentCategory) {
                var descMatch = line.match(/#"(.*?)"$/);
                var description = descMatch ? descMatch[1] : "Description";
                
                var parts = line.split(',');
                if (parts.length >= 2) {
                    var modMatch = parts[0].match(/bind\s*=\s*([^,]+)/);
                    var mod = modMatch ? modMatch[1].trim() : parts[0].trim();
                    mod = mod.replace("$mod", "Super"); // Using Title Case to match Panel.qml expectation
                    
                    var keyPart = parts[1].trim();
                    var key = keyPart.toUpperCase();
                    
                    // Standardize key names for color coding in Panel.qml
                    var fullKey = mod;
                    if (mod.includes("SHIFT")) fullKey = fullKey.replace("SHIFT", "Shift");
                    if (mod.includes("CTRL")) fullKey = fullKey.replace("CTRL", "Ctrl");
                    if (mod.includes("ALT")) fullKey = fullKey.replace("ALT", "Alt");
                    
                    // Ensure space around +
                    if (fullKey && key) fullKey += " + " + key;
                    else if (key) fullKey = key;

                    currentCategory.binds.push({
                        "keys": fullKey,
                        "desc": description
                    });
                }
            }
        }
    }
    
    if (currentCategory) {
        categories.push(currentCategory);
    }

    logDebug("HyprlandCheatsheet: Found " + categories.length + " categories.");
    saveToDb(categories);
  }

  function saveToDb(data) {
      if (pluginApi) {
          pluginApi.pluginSettings.cheatsheetData = data;
          pluginApi.saveSettings();
          logInfo("HyprlandCheatsheet: SAVED TO DB " + data.length + " categories");
      } else {
          logError("HyprlandCheatsheet: ERROR - pluginApi is null!");
      }
  }

  IpcHandler {
    target: "plugin:hyprland-cheatsheet"
    function toggle() {
      logDebug("HyprlandCheatsheet: IPC toggle called");
      if (pluginApi) {
        runGenerator();
        pluginApi.withCurrentScreen(screen => pluginApi.openPanel(screen));
      }
    }
    
    function generate() {
      logDebug("HyprlandCheatsheet: IPC generate called");
      runGenerator();
    }
  }
}
