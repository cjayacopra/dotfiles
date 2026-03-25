import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.noctalia.shell

AppWindow {
    id: root
    width: 800
    height: 600
    title: qsTr("Default Apps Manager")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Label {
            text: qsTr("Default Apps Manager")
            font.pixelSize: 24
            font.weight: Font.Bold
        }

        Label {
            text: qsTr("Select a file type to manage its default application.")
            opacity: 0.7
        }

        // Placeholder for future MIME list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.alpha(NoctaliaTheme.accentColor, 0.1)
            border.color: NoctaliaTheme.borderColor
            border.width: 1
            radius: 8

            Label {
                anchors.centerIn: parent
                text: qsTr("MIME types will appear here.")
                color: NoctaliaTheme.textColor
            }
        }
    }
}
