import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    // Configuration
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property bool showCurrentInBar: cfg.showCurrentInBar ?? defaults.showCurrentInBar ?? true
    property string barCategory: cfg.barCategory || defaults.barCategory || "browser"

    // Bar layout properties
    property string barPosition: Settings.data.bar.position || "top"
    property string barDensity: Settings.data.bar.density || "compact"
    property bool barIsSpacious: barDensity !== "mini"
    property bool barIsVertical: barPosition === "left" || barPosition === "right"

    function getCategoryName(cat) {
        var names = {
            "browser": "Browser",
            "terminal": "Terminal",
            "file-manager": "File Manager",
            "email": "Email",
            "video": "Video",
            "audio": "Audio",
            "image": "Image",
            "text": "Text Editor"
        };
        return names[cat] || "Apps";
    }

    // Content dimensions
    readonly property real contentWidth: barIsVertical 
        ? Style.capsuleHeight 
        : Math.max(contentRow.implicitWidth, Style.marginM * 4)
    readonly property real contentHeight: barIsVertical 
        ? Math.round(contentRow.implicitHeight + Style.marginM * 2) 
        : Style.capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    // Visual capsule with custom plugin icon
    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        color: Style.capsuleColor
        radius: Style.radiusM
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: Style.marginS

            // Custom plugin icon - stacked icon representing defaults
            NIcon {
                id: appIcon
                icon: "stack"
                color: Color.mOnSurfaceVariant
                pointSize: Style.fontSizeM
            }

            // Category name - hidden, icon only
            NText {
                visible: false
                text: root.getCategoryName(root.barCategory)
                color: Color.mOnSurfaceVariant
                pointSize: Style.barFontSize * 0.8
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }

    // Click to open panel
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton && root.pluginApi) {
                root.pluginApi.openPanel(root.screen, root);
            }
        }
    }

    // Right-click context menu
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onPressed: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                PanelService.showContextMenu(contextMenu, root, screen);
            }
        }

        NPopupContextMenu {
            id: contextMenu

            model: [
                { "label": "Open Panel", "action": "open-panel", "icon": "settings" },
                { "label": "Refresh", "action": "refresh", "icon": "refresh" },
                { "label": "Settings", "action": "widget-settings", "icon": "settings-cog" }
            ]

            onTriggered: function(action) {
                contextMenu.close();
                PanelService.closeContextMenu(screen);

                switch (action) {
                    case "open-panel":
                        if (root.pluginApi) root.pluginApi.openPanel(root.screen, root);
                        break;
                    case "refresh":
                        ToastService.showNotice("Refreshed");
                        break;
                    case "widget-settings":
                        BarService.openPluginSettings(screen, pluginApi.manifest);
                        break;
                }
            }
        }
    }
}