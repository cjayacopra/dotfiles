import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.noctalia.shell

ColumnLayout {
    id: browserRoot
    spacing: 15

    signal mimeTypeSelected(string mimeType)

    TextField {
        id: searchField
        Layout.fillWidth: true
        placeholderText: qsTr("Search file types (e.g., text/plain)...")
        leftPadding: 35
        
        // Placeholder for search icon
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            color: "transparent"
            border.color: searchField.focus ? NoctaliaTheme.accentColor : NoctaliaTheme.textColor
            border.width: 1
            radius: 8
        }
    }

    ListView {
        id: mimeList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        model: ListModel { id: mimeModel }

        delegate: ItemDelegate {
            width: mimeList.width
            text: model.mimeType
            onClicked: browserRoot.mimeTypeSelected(model.mimeType)
            
            contentItem: RowLayout {
                spacing: 10
                Label {
                    text: model.mimeType
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Icon {
                    name: "go-next-symbolic"
                    width: 16
                    height: 16
                    opacity: 0.5
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator { }
        
        Label {
            anchors.centerIn: parent
            text: qsTr("No file types found.")
            visible: mimeList.count === 0 && searchField.text !== ""
            opacity: 0.5
        }
    }
}
