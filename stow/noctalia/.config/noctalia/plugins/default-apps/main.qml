import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.noctalia.shell
import "lib/mime_bridge.js" as MimeBridge

AppWindow {
    id: root
    width: 800
    height: 600
    title: qsTr("Default Apps Manager")

    property string selectedMime: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        RowLayout {
            spacing: 10
            Label {
                text: qsTr("Default Apps Manager")
                font.pixelSize: 24
                font.weight: Font.Bold
                Layout.fillWidth: true
            }
            
            // Back button visible only when a MIME is selected
            Button {
                text: qsTr("Back")
                visible: selectedMime !== ""
                onClicked: selectedMime = ""
                icon.name: "go-previous-symbolic"
            }
        }

        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: selectedMime === "" ? 0 : 1

            MimeTypeBrowser {
                id: mimeBrowser
                onMimeTypeSelected: function(mimeType) {
                    selectedMime = mimeType;
                    updateHandlerInfo(mimeType);
                }
            }

            HandlerSelection {
                id: handlerSelection
                mimeType: selectedMime
                onHandlerSelected: function(desktopFile) {
                    MimeBridge.setDefaultHandler(selectedMime, desktopFile, function() {
                        updateHandlerInfo(selectedMime);
                    });
                }
            }
        }
    }

    function updateHandlerInfo(mimeType) {
        MimeBridge.getDefaultHandler(mimeType, function(handler) {
            handlerSelection.currentDefault = handler;
        });
        
        MimeBridge.getAllHandlers(mimeType, function(handlers) {
            handlerSelection.handlerModel.clear();
            for (var i = 0; i < handlers.length; i++) {
                handlerSelection.handlerModel.append({ "desktopFile": handlers[i] });
            }
        });
    }

    Component.onCompleted: {
        MimeBridge.listMimeTypes(function(mimes) {
            mimeBrowser.mimeModel.clear();
            for (var i = 0; i < mimes.length; i++) {
                mimeBrowser.mimeModel.append({ "mimeType": mimes[i] });
            }
        });
    }
}
