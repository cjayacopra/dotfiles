import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    // Panel properties
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

    property real contentPreferredWidth: 480 * Style.uiScaleRatio
    property real contentPreferredHeight: 560 * Style.uiScaleRatio

    anchors.fill: parent

    // State
    property var categoriesModel: []
    property var availableApps: []
    property string selectedCategory: ""
    property bool loadingApps: false
    property bool settingDefault: false

    // All available categories - static
    readonly property var allCategoriesList: [
        { id: "browser", name: "Browser", icon: "world" },
        { id: "terminal", name: "Terminal", icon: "terminal-2" },
        { id: "file-manager", name: "File Manager", icon: "folder" },
        { id: "email", name: "Email", icon: "mail" },
        { id: "video", name: "Video", icon: "player-play" },
        { id: "audio", name: "Audio", icon: "headphones" },
        { id: "image", name: "Image", icon: "photo" },
        { id: "text", name: "Text Editor", icon: "file-text" }
    ]

    // Get visible categories - show all 8 categories
    property var visibleCategories: allCategoriesList

    // Helper script path - always use absolute path
    property string helperScript: "/home/shiraneko/dotfiles/stow/noctalia/.config/noctalia/plugins/default-apps/backend/DefaultAppsHelper.sh"

    // Process for getting all defaults
    Process {
        id: getDefaultsProcess
        running: false

        stdout: StdioCollector {
            id: defaultsCollector
        }

        stderr: StdioCollector {
            id: defaultsStderr
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    var parsed = JSON.parse(defaultsCollector.text);
                    root.categoriesModel = parsed;
                    Logger.i("DefaultApps", "Loaded defaults for", parsed.length, "categories");
                } catch (e) {
                    Logger.e("DefaultApps", "Failed to parse defaults:", e.message);
                }
            } else {
                Logger.e("DefaultApps", "getDefaults process exited with code:", exitCode, "stderr:", defaultsStderr.text);
            }
        }
    }

    // Process for getting applications
    Process {
        id: getAppsProcess
        running: false

        stdout: StdioCollector {
            id: appsCollector
        }

        stderr: StdioCollector {
            id: appsStderr
        }

        onExited: function(exitCode) {
            root.loadingApps = false;
            if (exitCode === 0) {
                try {
                    var parsed = JSON.parse(appsCollector.text);
                    parsed.sort(function(a, b) { return (b.priority || 0) - (a.priority || 0); });
                    root.availableApps = parsed;
                    Logger.i("DefaultApps", "Loaded", parsed.length, "apps for", root.selectedCategory);
                } catch (e) {
                    Logger.e("DefaultApps", "Failed to parse apps:", e.message, "data:", appsCollector.text);
                    root.availableApps = [];
                }
            } else {
                Logger.e("DefaultApps", "getApps process exited with code:", exitCode, "stderr:", appsStderr.text);
            }
        }

        onRunningChanged: {
            if (running) root.loadingApps = true;
        }
    }

    // Process for setting default
    Process {
        id: setDefaultProcess
        running: false

        stdout: StdioCollector {
            id: setDefaultCollector
        }

        stderr: StdioCollector {
            id: setDefaultStderr
        }

        onExited: function(exitCode) {
            root.settingDefault = false;
            if (exitCode === 0) {
                ToastService.showNotice("Default application set");
                refreshDefaults();
                if (root.selectedCategory) {
                    loadAppsForCategory(root.selectedCategory);
                }
            } else {
                ToastService.showError("Failed to set default");
                Logger.e("DefaultApps", "setDefault error:", setDefaultStderr.text);
            }
        }

        onRunningChanged: {
            if (running) root.settingDefault = true;
        }
    }

    // Refresh all defaults
    function refreshDefaults() {
        getDefaultsProcess.command = ["bash", "-c", helperScript + " get-all-defaults"];
        getDefaultsProcess.running = true;
    }

    // Load apps for a category
    function loadAppsForCategory(category) {
        if (!pluginApi) return;

        root.selectedCategory = category;
        root.availableApps = [];

        var cmd = helperScript + " get-applications " + category;
        Logger.i("DefaultApps", "Loading apps for:", category, "command:", cmd);
        
        getAppsProcess.command = ["bash", "-c", cmd];
        getAppsProcess.running = true;
    }

    // Set default app
    function setDefaultApp(desktopFile) {
        if (!pluginApi || !root.selectedCategory || root.settingDefault) return;

        setDefaultProcess.command = ["bash", "-c", helperScript + " set-default " + root.selectedCategory + " " + desktopFile];
        setDefaultProcess.running = true;
    }

    // Get current default for category
    function getCurrentDefault(categoryId) {
        for (var i = 0; i < root.categoriesModel.length; i++) {
            if (root.categoriesModel[i].category === categoryId) {
                return root.categoriesModel[i].default;
            }
        }
        return null;
    }

    // Initial load
    Component.onCompleted: {
        refreshDefaults();
    }

    // UI
    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors { fill: parent; margins: Style.marginL }
            spacing: Style.marginM

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginM

                NIcon {
                    icon: "apps"
                    color: Color.mPrimary
                    pointSize: Style.fontSizeL
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    NText {
                        text: "Default Applications"
                        pointSize: Style.fontSizeL
                        font.weight: Font.Bold
                        color: Color.mOnSurface
                        Layout.fillWidth: true
                    }

                    NText {
                        text: "Choose default applications"
                        pointSize: Style.fontSizeXS
                        color: Color.mOnSurfaceVariant
                    }
                }

                NIconButton {
                    icon: "x"
                    baseSize: 28
                    onClicked: {
                        if (root.pluginApi) {
                            root.pluginApi.closePanel(root.pluginApi.panelOpenScreen);
                        }
                    }
                }
            }

            // Category list - horizontal scrollable
            Rectangle {
                Layout.fillWidth: true
                height: 48 * Style.uiScaleRatio
                color: Color.mSurfaceVariant
                radius: Style.radiusM

                ListView {
                    id: categoryList
                    anchors { fill: parent; margins: Style.marginS }
                    orientation: ListView.Horizontal
                    spacing: Style.marginS
                    model: root.visibleCategories
                    clip: true

                    delegate: Rectangle {
                        width: 100 * Style.uiScaleRatio
                        height: 36 * Style.uiScaleRatio
                        radius: Style.radiusS
                        color: modelData.id === root.selectedCategory ? Color.mPrimaryContainer : Color.mSurface

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Style.marginXS

                            NIcon {
                                icon: modelData.icon
                                color: modelData.id === root.selectedCategory ? Color.mOnPrimaryContainer : Color.mOnSurface
                                pointSize: Style.fontSizeS
                            }

                            NText {
                                text: modelData.name
                                color: modelData.id === root.selectedCategory ? Color.mOnPrimaryContainer : Color.mOnSurface
                                pointSize: Style.fontSizeXS
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.loadAppsForCategory(modelData.id);
                            }
                        }
                    }
                }
            }

            // App list
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(Color.mSurfaceVariant.r, Color.mSurfaceVariant.g, Color.mSurfaceVariant.b, 0.5)
                radius: Style.radiusL

                // Loading
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: root.loadingApps
                    spacing: Style.marginM

                    NIcon {
                        icon: "loader"
                        color: Color.mPrimary
                        pointSize: Style.fontSizeXXL
                        Layout.alignment: Qt.AlignHCenter

                        RotationAnimation on rotation {
                            from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                        }
                    }

                    NText {
                        text: "Loading applications..."
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeM
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // No category selected
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: !root.loadingApps && root.selectedCategory === ""
                    spacing: Style.marginM

                    NIcon {
                        icon: "click"
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeXXL
                        Layout.alignment: Qt.AlignHCenter
                    }

                    NText {
                        text: "Select a category above"
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeM
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // Empty apps list
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: !root.loadingApps && root.selectedCategory !== "" && root.availableApps.length === 0
                    spacing: Style.marginM

                    NIcon {
                        icon: "app-window"
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeXXL
                        Layout.alignment: Qt.AlignHCenter
                    }

                    NText {
                        text: "No applications found"
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeM
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // Apps list
                NListView {
                    anchors { fill: parent; margins: Style.marginS }
                    visible: !root.loadingApps && root.availableApps.length > 0
                    model: root.availableApps
                    gradientColor: Qt.rgba(Color.mSurfaceVariant.r, Color.mSurfaceVariant.g, Color.mSurfaceVariant.b, 0.5)

                    delegate: Rectangle {
                        id: appRow
                        width: ListView.view.width
                        height: 56 * Style.uiScaleRatio
                        property bool isHovered: false
                        property bool isCurrentDefault: modelData.file === (root.getCurrentDefault(root.selectedCategory) || {}).file

                        color: isCurrentDefault
                            ? Qt.rgba(Color.mPrimary.r, Color.mPrimary.g, Color.mPrimary.b, 0.15)
                            : isHovered ? Color.mSurface : "transparent"
                        radius: Style.radiusM
                        Behavior on color { ColorAnimation { duration: 100 } }

                        RowLayout {
                            anchors { fill: parent; leftMargin: Style.marginM; rightMargin: Style.marginM }
                            spacing: Style.marginM

                            // App icon
                            NIcon {
                                icon: modelData.icon || "app-window"
                                color: isCurrentDefault ? Color.mPrimary : Color.mOnSurfaceVariant
                                pointSize: Style.fontSizeL
                                Layout.preferredWidth: 32
                            }

                            // App info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                NText {
                                    text: modelData.name || "Unknown"
                                    color: isCurrentDefault ? Color.mPrimary : Color.mOnSurface
                                    pointSize: Style.fontSizeM
                                    font.weight: isCurrentDefault ? Font.Medium : Font.Normal
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                NText {
                                    text: modelData.comment || ""
                                    color: Color.mOnSurfaceVariant
                                    pointSize: Style.fontSizeXS
                                    elide: Text.ElideRight
                                    visible: modelData.comment
                                    Layout.fillWidth: true
                                }
                            }

                            // Checkmark for current default
                            NIcon {
                                icon: "check"
                                color: Color.mPrimary
                                pointSize: Style.fontSizeM
                                visible: isCurrentDefault
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: appRow.isHovered = true
                            onExited: appRow.isHovered = false

                            onClicked: {
                                if (!root.settingDefault) {
                                    root.setDefaultApp(modelData.file);
                                }
                            }
                        }
                    }
                }
            }

            // Status bar
            Rectangle {
                Layout.fillWidth: true
                height: 32 * Style.uiScaleRatio
                visible: root.selectedCategory !== ""
                color: Color.mSurfaceVariant
                radius: Style.radiusS

                RowLayout {
                    anchors { fill: parent; margins: Style.marginS }
                    spacing: Style.marginS

                    NIcon {
                        icon: root.loadingApps ? "loader" : (root.settingDefault ? "loader" : "info-circle")
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
                    }

                    NText {
                        text: {
                            if (root.loadingApps) {
                                return "Loading...";
                            }
                            if (root.settingDefault) {
                                return "Setting default...";
                            }
                            if (root.selectedCategory) {
                                var current = root.getCurrentDefault(root.selectedCategory);
                                var appName = current ? current.name : "None";
                                return "Current: " + appName;
                            }
                            return "";
                        }
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeXS
                        Layout.fillWidth: true
                    }

                    NText {
                        text: root.availableApps.length + " apps"
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeXS
                        visible: !root.loadingApps && !root.settingDefault
                    }
                }
            }
        }
    }
}