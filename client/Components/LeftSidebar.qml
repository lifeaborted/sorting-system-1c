import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Левая боковая панель
Rectangle {
    Layout.preferredWidth: 250
    Layout.fillHeight: true
    color: "#1e1e1e"

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 60
        spacing: 5

        // Детали
        Rectangle {
            id: detailsButton
            width: 220
            height: 50
            color: "#46464A"
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Image {
                    source: "qrc:/resources/icons/clipboard.svg"
                    width: 24
                    height: 24
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    id: detailsText
                    text: qsTr("Детали")
                    color: "white"
                    font.pixelSize: 14
                    font.family: "Roboto"
                    font.weight: 300
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    detailsButton.color = "#46464A"
                    ordersButton.color = "transparent"
                    detailsText.color = "white"
                    ordersText.color = "#aaaaaa"

                    // Далее логика переключения на страницу "Детали"
                }
            }
        }

        // Заказы
        Rectangle {
            id: ordersButton
            width: 220
            height: 50
            color: "transparent"
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Image {
                    id: ordersIcon
                    source: "qrc:/resources/icons/tag.svg"
                    width: 24
                    height: 24
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    id: ordersText
                    text: qsTr("Заказы")
                    color: "#aaaaaa"
                    font.pixelSize: 14
                    font.family: "Roboto"
                    font.weight: 300
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    ordersButton.color = "#46464A"
                    detailsButton.color = "transparent"
                    ordersText.color = "white"
                    detailsText.color = "#aaaaaa"

                    // Далее логика переключения на страницу "Заказы"
                }
            }
        }
    }
}