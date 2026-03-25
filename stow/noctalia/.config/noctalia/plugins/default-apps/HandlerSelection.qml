import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.noctalia.shell

ColumnLayout {
    id: handlerRoot
    spacing: 20

    property string mimeType: ""
    property string currentDefault: ""
    property alias handlerModel: handlerModel
    
    signal handlerSelected(string desktopFile)

    Label {
        text: qsTr("Manage: %1").arg(mimeType)
        font.pixelSize: 18
        font.weight: Font.DemiBold
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        Label {
            text: qsTr("Default Application")
            font.weight: Font.DemiBold
            opacity: 0.7
        }

        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: Qt.alpha(NoctaliaTheme.accentColor, 0.05)
            border.color: NoctaliaTheme.borderColor
            border.width: 1
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                // Placeholder for app icon
                Rectangle {
                    width: 32
                    height: 32
                    radius: 4
                    color: NoctaliaTheme.accentColor
                    Icon {
                        anchors.centerIn: parent
                        name: "application-x-executable-symbolic"
                        width: 20
                        height: 20
                        color: "white"
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Label {
                        text: currentDefault || qsTr("None")
                        font.weight: Font.Medium
                    }
                    Label {
                        text: qsTr("Current default handler")
                        font.pixelSize: 11
                        opacity: 0.6
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 10

        Label {
            text: qsTr("Available Applications")
            font.weight: Font.DemiBold
            opacity: 0.7
        }

        ListView {
            id: handlerList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ListModel { id: handlerModel }

            delegate: ItemDelegate {
                width: handlerList.width
                
                contentItem: RowLayout {
                    spacing: 10
                    RadioButton {
                        checked: model.desktopFile === currentDefault
                        onClicked: handlerRoot.handlerSelected(model.desktopFile)
                    }
                    Label {
                        text: model.desktopFile
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
    
    Button {
        Layout.alignment: Qt.AlignLeft
        text: qsTr("Back to list")
        icon.name: "go-previous-symbolic"
        onClicked: handlerRoot.mimeTypeSelected("") // Signal to go back
    }
}
