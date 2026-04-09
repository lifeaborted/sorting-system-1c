import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import io.backend 1.0
Rectangle {
    id: detailsPage
    color: "#2e2e2e"
    width: 1280
    height: 720

    Material.theme: Material.Dark
    Material.accent: Material.Blue

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Левая боковая панель
        Rectangle {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: "#1e1e1e"

            Column {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 60
                anchors.margins: 10
                spacing: 5

                // Детали
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "#3e3e3e"
                    radius: 4

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Image {
                            source: "qrc:/resources/icons/clipboard.svg"
                            width: 20
                            height: 20
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            text: qsTr("Детали")
                            color: "white"
                            font.pixelSize: 14
                        }
                    }
                }

                // Заказы
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    radius: 4

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Image {
                            source: "qrc:/resources/icons/tag.svg"
                            width: 20
                            height: 20
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            text: qsTr("Заказы")
                            color: "#aaaaaa"
                            font.pixelSize: 14
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Переход на страницу заказов
                        }
                    }
                }
            }
        }

        // Основная часть
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#2e2e2e"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Верхняя панель с поиском и профилем
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    // Поиск
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "#3e3e3e"
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Text {
                                text: "🔍"
                                color: "#aaaaaa"
                                font.pixelSize: 16
                            }

                            TextField {
                                Layout.fillWidth: true
                                placeholderText: qsTr("Поиск...")
                                color: "white"
                                font.pixelSize: 14
                                background: Rectangle {
                                    color: "transparent"
                                }
                            }
                        }
                    }

                    // Профиль пользователя
                    RowLayout {
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "#3e3e3e"

                            Text {
                                anchors.centerIn: parent
                                text: Backend.user.format_username("{first[0]}{second[0]}")
                                color: "white"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                            }
                        }

                        Text {
                            text: Backend.user.format_username("{first} {second[0]}.{middle[0]}.")
                            color: "white"
                            font.pixelSize: 14
                        }

                        Text {
                            text: "▼"
                            color: "white"
                            font.pixelSize: 10
                        }
                    }
                }

                // Фильтры
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Тип детали
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: qsTr("Тип детали")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Все", "Шкив", "Вал", "Подшипник"]
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: "#3e3e3e"
                                radius: 4
                                implicitHeight: 35
                            }
                        }
                    }

                    // Партия
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: qsTr("Партия")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Все", "П-12345", "П-67890"]
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: "#3e3e3e"
                                radius: 4
                                implicitHeight: 35
                            }
                        }
                    }

                    // Статус
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: qsTr("Статус")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Все", "Сортировка", "Отсортирован"]
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: "#3e3e3e"
                                radius: 4
                                implicitHeight: 35
                            }
                        }
                    }

                    // Заказ
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: qsTr("Заказ")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Все"]
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: "#3e3e3e"
                                radius: 4
                                implicitHeight: 35
                            }
                        }
                    }

                    // Склад
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: qsTr("Склад")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Все"]
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: "#3e3e3e"
                                radius: 4
                                implicitHeight: 35
                            }
                        }
                    }

                    // Дата производства
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: qsTr("Дата производства")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 35
                            color: "#3e3e3e"
                            radius: 4

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                Text {
                                    text: qsTr("01.01.26 - 01.01.27")
                                    color: "white"
                                    font.pixelSize: 13
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: "📅"
                                    color: "#aaaaaa"
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }

                    // Кнопка Сбросить
                    Button {
                        Layout.preferredHeight: 35
                        Layout.preferredWidth: 100
                        text: qsTr("Сбросить")

                        contentItem: Text {
                            text: parent.text
                            color: "#2e2e2e"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: "#f5f5f5"
                            radius: 4
                        }

                        onClicked: {
                            // Сброс фильтров
                        }
                    }
                }

                // Заголовки таблицы
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#3e3e3e"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10

                        Text {
                            Layout.preferredWidth: 120
                            text: qsTr("Действие")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 80
                            text: qsTr("Тип")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Номер")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 100
                            text: qsTr("Партия")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 150
                            text: qsTr("Статус")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 100
                            text: qsTr("Заказ")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Склад")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 80
                            text: qsTr("Дата")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }
                    }
                }

                // Список деталей
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            model: 10

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "#2e2e2e"
                                radius: 5

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    spacing: 10

                                    Button {
                                        Layout.preferredWidth: 120
                                        Layout.preferredHeight: 40
                                        text: index % 2 === 0 ? qsTr("Распределить") : qsTr("Отменить")

                                        contentItem: Text {
                                            text: parent.text
                                            color: "#2e2e2e"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        background: Rectangle {
                                            color: "#f5f5f5"
                                            radius: 5
                                        }

                                        onClicked: {
                                            // Действие с деталью
                                        }
                                    }

                                    // Иконка информации
                                    Rectangle {
                                        Layout.preferredWidth: 30
                                        Layout.preferredHeight: 30
                                        radius: 4
                                        color: "#3e3e3e"

                                        Image {
                                            anchors.centerIn: parent
                                            source: "qrc:/resources/icons/info-circle.svg"
                                            width: 20
                                            height: 20
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }

                                    // Тип
                                    Text {
                                        Layout.preferredWidth: 80
                                        text: qsTr("Шкив")
                                        color: "white"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }

                                    // Номер
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Ш-123-4567890"
                                        color: "white"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }

                                    // Партия
                                    Text {
                                        Layout.preferredWidth: 100
                                        text: "П-12345"
                                        color: "white"
                                        font.pixelSize: 13
                                    }

                                    // Статус
                                    Text {
                                        Layout.preferredWidth: 150
                                        text: index % 2 === 0 ? qsTr("Сортировка") : qsTr("Отсортирован №123-ЧКПЭ-45...")
                                        color: "white"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }

                                    // Заказ
                                    Text {
                                        Layout.preferredWidth: 100
                                        text: "-"
                                        color: "white"
                                        font.pixelSize: 13
                                    }

                                    // Склад
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("пр. Ленина, д. 8...")
                                        color: "white"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }

                                    // Дата
                                    Text {
                                        Layout.preferredWidth: 80
                                        text: "01.01.26"
                                        color: "white"
                                        font.pixelSize: 13
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
