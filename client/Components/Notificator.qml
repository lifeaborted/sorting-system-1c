import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0

Item {
    id: root
    anchors.fill: parent

    ColumnLayout {
        anchors.right: parent.right
        spacing: 5

        Repeater {
            model: Backend.notificator.notifications
            delegate:
                Rectangle {
                implicitHeight: layoutChild.implicitHeight
                required property var modelData
                color: {
                    if (modelData.importance == "error") {
                        return "red"
                    } else if (modelData.importance == "success") {
                        return "green"
                    } else {
                        // == normal
                        return "grey"
                    }
                }

                ColumnLayout {
                    id: layoutChild
                    width: 400
                    Text {
                        text: modelData.title
                    }
                    Text {
                        Layout.fillWidth: true
                        font.pointSize:12
                        wrapMode: Text.Wrap
                        text: modelData.message
                    }
                    Button {
                        text: "x"
                        onClicked: {
                            Backend.notificator.remove_notification(modelData.uuid)
                        }
                    }
                }

                width: 500
                height: 40
                radius: 5
            }
        }
    }
}
