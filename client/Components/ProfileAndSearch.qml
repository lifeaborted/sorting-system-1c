import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0

// Верхняя панель с поиском и профилем
RowLayout {
    id: root
    signal valueChanged(text: string)
    property string text
    Layout.fillWidth: true
    spacing: 15

    function logout() {
        Backend.logout()
        Backend.router.route = "/login"
    }

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
                text: root.text
                font.weight: 400
                font.family: "Roboto"
                placeholderTextColor: activeFocus || text.length > 0 ? "transparent" : "#B2B4BC"
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
                background: Rectangle {
                    color: "transparent"
                }
                onTextEdited: {
                    root.valueChanged(searchField.text)
                }
            }
        }
    }

    // Профиль пользователя
    Rectangle {
        id: userProfile
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
            MouseArea {
                width: 16
                height: 12
                cursorShape: "PointingHandCursor"
                onClicked: popup.open()
                Image {
                    source: "qrc:/resources/icons/profile-triangle.svg"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                }
                Popup {
                    id: popup
                    x: -(userProfile.width - 25)
                    y: 38
                    padding: 0
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                    background: Rectangle {
                        color: "#2E2E2E"
                        radius: 8
                    }

                    Rectangle {
                        id: logoutItem
                        width: userProfile.width
                        height: 40
                        color: logoutMouse.containsMouse ? "#46464A" : "#47494E"
                        border.color: "#4A4A4E"
                        border.width: 1
                        radius: 8

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            text: "Выход"
                            color: "#B2B4BC"
                            font.pixelSize: 13
                            font.family: "Roboto"
                            font.weight: 400
                        }

                        MouseArea {
                            id: logoutMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                popup.close()
                                logout()
                            }
                        }
                    }
                }
            }
        }
    }
}
