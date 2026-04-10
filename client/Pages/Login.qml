import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0

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
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        width: 140
        height: 40
        color: "transparent"
        radius: 4

        Row {
            anchors.fill: parent

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
        }
    }

    // Центральная карточка
    Rectangle {
        id: card
        width: 400
        height: 550
        color: "#E6E8E9"
        radius: 30
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
                font.pixelSize: 24
                font.family: "Roboto"
                font.weight: 700
                color: "#28282A"
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
                    font.pixelSize: 8
                    font.weight: 500
                    font.family: "Roboto"
                    color: "#3E3E42"
                }

                TextField {
                    id: loginField
                    placeholderText: qsTr("Логин")
                    placeholderTextColor: "#B2B4BC"
                    Layout.fillWidth: true
                    font.pixelSize: 14
                    font.weight: 700
                    font.family: "Roboto"
                    leftPadding: 10
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        color: "transparent"
                    }
                }

                // Нижняя линия
                Rectangle {
                    Layout.fillWidth: true
                    height: 1.5 // 2 - шире нижней, 1 - уже нижней. 1.5 - оптимальное значение
                    color: loginField.activeFocus ? "#6e707b" : "#B2B4BC"
                }
            }

            // Поле пароля
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true

                Text {
                    text: qsTr("Пароль")
                    font.pixelSize: 8
                    font.weight: 500
                    font.family: "Roboto"
                    color: "#3E3E42"
                }

                TextField {
                    id: passwordField
                    placeholderText: qsTr("Пароль")
                    placeholderTextColor: "#B2B4BC"
                    echoMode: TextField.Password
                    Layout.fillWidth: true
                    font.pixelSize: 14
                    font.weight: 700
                    font.family: "Roboto"
                    leftPadding: 10
                    Layout.preferredHeight: 40

                    background: Rectangle {
                        color: "transparent"
                    }
                }

                // Нижняя линия
                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: passwordField.activeFocus ? "#6e707b" : "#B2B4BC"
                }
            }

            // Кнопка Войти
            Button {
                text: qsTr("Войти")
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.preferredWidth: 300

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 18
                    font.family: "Roboto"
                    font.weight: 400
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    opacity: enabled ? 1.0 : 0.3
                }

                background: Rectangle {
                    color: parent.pressed ? "#1a1a1a" : "#2a2a2a"
                    radius: 5
                }

                onClicked: {
                    // Логика авторизации
                    // заглушка для переноса на другую страницу
                    Backend.login("Гайдулян", "Андрей", "Сергевич")
                    Backend.router.route = "/details"
                }
            }
        }
    }
}
