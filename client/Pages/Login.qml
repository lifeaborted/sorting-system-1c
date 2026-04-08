import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.router 1.0

Item {
    id: window
    anchors.fill: parent
    visible: true

    // Фон
    Image {
        anchors.fill: parent
        source: "qrc:/resources/backgrounds/background1.png"
        fillMode: Image.PreserveAspectCrop
    }

    // Кнопки управления окном
    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10

        Button {
            width: 35
            height: 35
            text: "−"
            onClicked: window.visibility = Window.Minimized
            background: Rectangle {
                color: "transparent"
                radius: 4
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: 35
                color: "#6e707b"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Button {
            width: 35
            height: 35
            text: "×"
            onClicked: window.close()
            background: Rectangle {
                color: "transparent"
                radius: 4
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: 35
                color: "#6e707b"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Центральная карточка
    Rectangle {
        id: card
        width: 360
        height: 540
        color: "#f5f5f5"
        radius: 16
        anchors.centerIn: parent

        ColumnLayout {
            anchors {
                centerIn: parent
                bottomMargin: 20
            }
            spacing: 20
            width: parent.width * 0.8

            // Иконка с ключом
            Rectangle {
                width: 200
                height: 200
                color: "transparent"
                Layout.alignment: Qt.AlignHCenter

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/resources/icons/circle-key.svg"
                    width: 240
                    height: 240
                    fillMode: Image.PreserveAspectFit
                }
            }

            // Заголовок
            Text {
                text: qsTr("Введите логин и пароль")
                font.pixelSize: 22
                font.weight: Font.Bold
                color: "#2a2a2a"
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            // Поле логина
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true

                Text {
                    text: qsTr("Логин")
                    font.pixelSize: 10
                    color: "#666666"
                }

                TextField {
                    id: loginField
                    placeholderText: qsTr("Логин")
                    Layout.fillWidth: true
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "transparent"
                        border.color: loginField.activeFocus ? "#6e707b" : "#dddddd"
                        border.width: 1
                        radius: 4
                        height: 40
                    }
                }
            }

            // Поле пароля
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true

                Text {
                    text: qsTr("Пароль")
                    font.pixelSize: 10
                    color: "#666666"
                }

                TextField {
                    id: passwordField
                    placeholderText: qsTr("Пароль")
                    echoMode: TextField.Password
                    Layout.fillWidth: true
                    font.pixelSize: 14

                    background: Rectangle {
                        color: "transparent"
                        border.color: passwordField.activeFocus ? "#6e707b" : "#dddddd"
                        border.width: 1
                        radius: 4
                        height: 40
                    }
                }
            }

            // Кнопка Войти
            Button {
                text: qsTr("Войти")
                Layout.fillWidth: true
                Layout.preferredHeight: 44

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    opacity: enabled ? 1.0 : 0.3
                }

                background: Rectangle {
                    color: parent.pressed ? "#1a1a1a" : "#2a2a2a"
                    radius: 6
                }

                onClicked: {
                    // Логика авторизации
                    // заглушка для переноса на другую страницу
                    Router.route = "/details"
                }
            }
        }
    }
}
