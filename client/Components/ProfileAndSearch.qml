import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0

// Верхняя панель с поиском и профилем
RowLayout {
    Layout.fillWidth: true
    spacing: 15

    // Поиск
    Rectangle {
        Layout.preferredWidth: 780
        Layout.preferredHeight: 50
        color: "#3E3E42"
        radius: 5

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15

            Image {
                source: "qrc:/resources/icons/search.svg"
                width: 24
                height: 24
                fillMode: Image.PreserveAspectFit
            }

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: qsTr("Поиск...")
                color: "#B2B4BC"
                font.pixelSize: 14
                font.weight: 400
                font.family: "Roboto"
                placeholderTextColor: activeFocus || text.length > 0 ? "transparent" : "#B2B4BC"
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10

                background: Rectangle {
                    color: "transparent"
                }
            }
        }
    }

    // Профиль пользователя
    Rectangle {
        Layout.preferredWidth: 180
        Layout.preferredHeight: 50
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.rightMargin: 10
            spacing: 10

            // Аватарка
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 24
                color: "#3e3e42"

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/resources/icons/profile-picture.svg"
                    width: 24
                    height: 24
                    fillMode: Image.PreserveAspectFit
                }
            }

            // Имя пользователя
            Text {
                text: Backend.user.format_username("{first} {second[0]}.{middle[0]}.")
                color: "#B2B4BC"
                font.pixelSize: 16
                font.weight: 500
                font.family: "Roboto"
                elide: Text.ElideRight
            }

            // Треугольник
            Image {
                source: "qrc:/resources/icons/profile-triangle.svg"
                width: 16
                height: 12
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}