import QtQuick
import Quickshell.Io
import qs.Commons

Item {
    property var pluginApi: null

    Component.onCompleted: {
        if (pluginApi) {
            Logger.i("DefaultApps", "Plugin initialized");
        }
    }
}