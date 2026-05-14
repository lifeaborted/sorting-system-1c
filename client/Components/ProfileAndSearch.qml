import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
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
                text: Backend.user.format_username("{second} {first[0]}.{middle[0]}.")
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
                cursorShape: Qt.PointingHandCursor
                onClicked: popup.open()

                Image {
                    source: "qrc:/resources/icons/profile-triangle.svg"
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                }

                Popup {
                    id: popup
                    x: -(userProfile.width - 5)
                    y: 38
                    width: 200
                    height: 120
                    padding: 0
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                    clip: false

                    background: Item {
                        // Тень
                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 0
                            verticalOffset: 4
                            radius: 20
                            samples: 41
                            spread: 0
                            color: "#40000000"
                            transparentBorder: true
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "#212122"
                            radius: 5
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            // Иконка человечка
                            Image {
                                source: "qrc:/resources/icons/person-x2.svg"
                                width: 32
                                height: 32
                                fillMode: Image.PreserveAspectFit
                                Layout.leftMargin: 12
                                Layout.topMargin: 12
                            }

                            // Имя + должность
                            ColumnLayout {
                                anchors.leftMargin: 20
                                width: 140
                                height: 28
                                spacing: 2

                                Text {
                                    text: Backend.user.format_username("{second}")
                                    color: "#E6E8E9"
                                    font.pixelSize: 12
                                    font.weight: 400
                                    font.family: "Roboto"
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: Backend.user.format_username("{first} {middle}")
                                    color: "#E6E8E9"
                                    font.pixelSize: 12
                                    font.weight: 400
                                    font.family: "Roboto"
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "сортировщик"
                                    color: "#B2B4BC"
                                    font.pixelSize: 10
                                    font.weight: 400
                                    font.family: "Roboto"
                                }
                            }

                            // Иконка языка
                            LanguageSelect {
                                iconSource: "qrc:/resources/icons/language-light.svg"
                                Layout.topMargin: -40
                                Layout.rightMargin: -15
                                triggerColor: "transparent"
                                triggerHoverColor: "#3E3E42"
                                triggerWidth: 24
                                triggerHeight: 24
                                triggerRadius: 20
                                z: 999
                            }
                        }

                        // Кнопка Выйти
                        Rectangle {
                            Layout.leftMargin: 20
                            width: 140
                            height: 30
                            radius: 5
                            z: -1
                            color: logoutMouse.containsMouse ? "#4A4A4E" : "#3E3E42"

                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Выйти")
                                color: "#E6E8E9"
                                font.pixelSize: 10
                                font.weight: 400
                                font.family: "Roboto"
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
}
