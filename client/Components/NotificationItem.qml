import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 250
    height: 60
    radius: 15
    color: root.notificationColor
    clip: true

    property string notificationMessage: "Сообщение"
    property string notificationType: "info"
    property var closeCallback: null

    readonly property color successColor: "#439F47"
    readonly property color warningColor: "#F69F00"
    readonly property color infoColor: "#2262A1"
    readonly property color errorColor: "#CE2C22"

    readonly property color notificationColor: {
        switch(root.notificationType) {
            case "success": return successColor
            case "warning": return warningColor
            case "error": return errorColor
            case "info": return infoColor
            default: return infoColor
        }
    }

    readonly property string iconSource: {
        switch(root.notificationType) {
            case "success": return "qrc:/resources/icons/check-circle.svg"
            case "warning": return "qrc:/resources/icons/exclamation-circle.svg"
            case "error": return "qrc:/resources/icons/x-circle.svg"
            case "info": return "qrc:/resources/icons/notification-info-circle.svg"
            default: return "qrc:/resources/icons/x-circle.svg"
        }
    }

    Timer {
        id: closeTimer
        interval: 10000
        running: true
        repeat: false
        onTriggered: root.startClose()
    }

    function startClose() {
        fadeOut.start()
    }

    SequentialAnimation {
        id: fadeOut
        NumberAnimation {
            target: root
            property: "opacity"
            to: 0.0
            duration: 400
        }
        ScriptAction {
            script: {
                if (root.closeCallback)
                    root.closeCallback()
            }
        }
    }

    opacity: 0.0
    Component.onCompleted: appearAnim.start()

    NumberAnimation {
        id: appearAnim
        target: root
        property: "opacity"
        from: 0.0
        to: 1.0
        duration: 300
    }

    RowLayout {
        id: contentRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 12
        spacing: 10

        Image {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            Layout.alignment: Qt.AlignVCenter
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.notificationMessage
                color: "#E6E8E9"
                font.family: "Roboto"
                font.pixelSize: 10
                font.weight: 500
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                height: Math.min(implicitHeight, font.pixelSize * 1.4 * 3)
                clip: true
            }
        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            radius: 4
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: parent.color = Qt.rgba(1, 1, 1, 0.2)
                onExited: parent.color = "transparent"
                onClicked: root.startClose()
            }

            Text {
                anchors.centerIn: parent
                text: "×"
                color: "#E6E8E9"
                font.pixelSize: 20
                font.weight: Font.Light
            }
        }
    }
}