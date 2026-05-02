import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0
import "../Components"

Item {
    id: window
    width: 1280
    visible: true
    property string password: passwordField.text
    property string login: loginField.text

    // Фон
    Image {
        anchors.fill: parent
        source: "qrc:/resources/backgrounds/background1.png"
        fillMode: Image.PreserveAspectCrop
    }

    // Центральная карточка
    Rectangle {

        id: card
        width: 400
        height: 550
        color: "#E6E8E9"
        radius: 30
        anchors.centerIn: parent

        LanguageSelect {
            anchors.top: parent.top
            anchors.right: parent.right
        }



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
            CTextField {
                placeholder: qsTr("Логин")
                id: loginField
                // Альтернатива с калбэком, впринципе для кнопочек там или обратной связи чеб нет
                // onValueChanged: {
                //     console.log(arguments[0])
                // }
            }
            // Поле пароля
            CTextField {
                placeholder: qsTr("Пароль")
                id: passwordField
                echo: TextField.Password
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
                    Backend.login(loginField.text, passwordField.text)
                }
            }
        }
    }
}
