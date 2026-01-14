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
    
    // Reset buffers and start process
    runner.allLines = [];
    runner.command = ["cat", filePath];
    runner.running = true;
  }

  Process {
    id: runner
    property var allLines: []

    stdout: SplitParser {
      onRead: (data) => {
        runner.allLines.push(data);
      }
    }

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

      if (allLines.length > 0) {
          logDebug("HyprlandCheatsheet: Content retrieved. Lines: " + allLines.length);
          parseAndSave(allLines.join("\n"));
      } else {
          logWarn("HyprlandCheatsheet: No lines retrieved on exit!");
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

        if (line.startsWith("#") && line.match(/#\s*[0-9]*[A-Z].*/)) {
            if (currentCategory) {
                categories.push(currentCategory);
            }
            var title = line.replace(/#\s*[0-9\.]*\s*/, "").trim();
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
                    mod = mod.replace("$mod", "Super");
                    
                    var keyPart = parts[1].trim();
                    var key = keyPart.toUpperCase();
                    
                    var fullKey = mod;
                    // Standardize modifiers to match Panel.qml's getKeyColor
                    if (fullKey.includes("SHIFT")) fullKey = fullKey.replace("SHIFT", "Shift");
                    if (fullKey.includes("CTRL")) fullKey = fullKey.replace("CTRL", "Ctrl");
                    if (fullKey.includes("ALT")) fullKey = fullKey.replace("ALT", "Alt");

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
