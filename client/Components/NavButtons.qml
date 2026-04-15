import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Кнопки управления окном
Rectangle {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 10
    height: 40
    color: "transparent"
    radius: 4
    signal dragAreaPressed()

    // Dragarea to move window
    MouseArea {
        anchors.fill: parent
        anchors.margins: -10

        onPressed: {
            dragAreaPressed()
        }
    }

    Row {
        layoutDirection: Qt.RightToLeft
        anchors.fill: parent

        // Кнопка закрыть
        Button {
            width: 70
            height: 40
            onClicked: window.close()

            background: Rectangle {
                color: "transparent"
            }

            contentItem: Item {
                width: parent.width
                height: parent.height

                Image {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 10
                    anchors.leftMargin: 25
                    source: "qrc:/resources/icons/close-app.svg"
                    width: 20
                    height: 20
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                }
            }
        }

        // Кнопка скрыть
        Button {
            width: 70
            height: 40
            onClicked: window.visibility = Window.Minimized

            background: Rectangle {
                color: "transparent"
            }

            contentItem: Item {
                width: parent.width
                height: parent.height

                Image {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 20
                    anchors.leftMargin: 27
                    source: "qrc:/resources/icons/minimise-app.svg"
                    width: 20
                    height: 20
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                }
            }
        }
    }
}
