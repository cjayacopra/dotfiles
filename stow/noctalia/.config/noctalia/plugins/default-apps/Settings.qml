import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.UI

ColumnLayout {
    spacing: 20
    Layout.margins: 20

    // This needs to be here for Noctalia to inject it
    property var pluginApi: null

    property var categoryNames: ["Browser", "Terminal", "File Manager", "Email", "Video", "Audio", "Image", "Text Editor"]
    property var categoryIds: ["browser", "terminal", "file-manager", "email", "video", "audio", "image", "text"]
    
    property bool showCurrentInBar: true
    property string barCategory: "browser"
    property var visibleCategories: ["browser", "terminal", "file-manager", "email"]

    NText {
        text: "Default Apps Settings"
        font.pointSize: 20
        font.bold: true
        color: Color.mOnSurface
    }

    // Bar Widget Section
    NText {
        text: "Bar Widget"
        font.pointSize: 16
        font.bold: true
        color: Color.mOnSurface
    }

    RowLayout {
        NText { text: "Show in bar"; color: Color.mOnSurface }
        NToggle { checked: showCurrentInBar; onToggled: showCurrentInBar = checked }
    }

    // Category dropdown using Repeater
    NText { text: "Bar category"; color: Color.mOnSurface }
    
    ColumnLayout {
        Repeater {
            model: categoryNames
            RowLayout {
                NText {
                    text: modelData
                    color: barCategory === categoryIds[index] ? Color.mPrimary : Color.mOnSurface
                }
                MouseArea {
                    width: 20; height: 20
                    onClicked: barCategory = categoryIds[index]
                    Rectangle {
                        anchors.fill: parent
                        color: barCategory === categoryIds[index] ? Color.mPrimary : Color.mSurfaceVariant
                        radius: 4
                    }
                }
            }
        }
    }

    Rectangle { height: 1; color: Color.mOutline }

    // Visible Categories
    NText {
        text: "Visible Categories"
        font.pointSize: 16
        font.bold: true
        color: Color.mOnSurface
    }

    ColumnLayout {
        Repeater {
            model: categoryNames
            RowLayout {
                NText { text: modelData; color: Color.mOnSurface }
                NToggle {
                    checked: visibleCategories.indexOf(categoryIds[index]) !== -1
                    onToggled: {
                        var arr = visibleCategories.slice();
                        var idx = arr.indexOf(categoryIds[index]);
                        if (checked && idx === -1) arr.push(categoryIds[index]);
                        else if (!checked && idx !== -1) arr.splice(idx, 1);
                        visibleCategories = arr;
                    }
                }
            }
        }
    }

    function saveSettings() {
        Logger.i("DefaultApps", "Saving settings:", showCurrentInBar, barCategory, visibleCategories);
        
        if (root.pluginApi) {
            root.pluginApi.pluginSettings.showCurrentInBar = showCurrentInBar;
            root.pluginApi.pluginSettings.barCategory = barCategory;
            root.pluginApi.pluginSettings.visibleCategories = visibleCategories;
            root.pluginApi.saveSettings();
            ToastService.showNotice("Settings saved");
            Logger.i("DefaultApps", "Settings saved successfully");
        } else {
            Logger.e("DefaultApps", "pluginApi is null");
        }
    }
}