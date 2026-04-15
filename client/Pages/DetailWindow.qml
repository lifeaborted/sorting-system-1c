import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import io.backend 1.0
import "../Components"

Rectangle {
    id: detailInfoPage
    width: 800
    height: 500
    color: "#28282A"



    // Заголовок окна
    RowLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 45
        anchors.leftMargin: 25
        spacing: 12

        Image {
            source: "qrc:/resources/icons/info-circle.svg"
            width: 22
            height: 22
            fillMode: Image.PreserveAspectFit
        }

        Text {
            text: qsTr("Информация о детали")
            color: "#E6E8E9"
            font.pixelSize: 18
            font.weight: Font.Bold
            font.family: "Roboto"
        }
    }

    // Основная область с разделением на левую и правую панели
    RowLayout {
        anchors.top: parent.top
        anchors.topMargin: 85
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0

        // Левая панель
        Rectangle {
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            color: "#181819"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 25
                spacing: 20

                // 1. Тип
                InfoRow {
                    iconSource: "qrc:/resources/icons/type.svg"
                    labelText: qsTr("Тип")
                }

                // 2. Серийный номер
                InfoRow {
                    iconSource: "qrc:/resources/icons/serial-number.svg"
                    labelText: qsTr("Серийный номер")
                }

                // 3. Номер партии
                InfoRow {
                    iconSource: "qrc:/resources/icons/batch-number.svg"
                    labelText: qsTr("Номер партии")
                }

                // 4. Статус
                InfoRow {
                    iconSource: "qrc:/resources/icons/status.svg"
                    labelText: qsTr("Статус")
                }

                // 5. Принадлежит заказу
                InfoRow {
                    iconSource: "qrc:/resources/icons/order.svg"
                    labelText: qsTr("Принадлежит заказу")
                }

                // 6. Склад
                InfoRow {
                    iconSource: "qrc:/resources/icons/warehouse.svg"
                    labelText: qsTr("Склад")
                }

                // 7. Дата производства
                InfoRow {
                    iconSource: "qrc:/resources/icons/date.svg"
                    labelText: qsTr("Дата производства")
                }
            }
        }

        // Правая панель
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#28282A"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 25
                spacing: 20

                // Значение 1
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    text: "Шкив"
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

                // Значение 2
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    text: "Ш-123-4567890"
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

                // Значение 3
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    text: "П-12345"
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

                // Значение 4
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    text: "На сортировке"
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

                // Выпадающий список (Принадлежит заказу)
                ComboBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    model: ["Не выбран", "Заказ №1024", "Заказ №2048"]
                    currentIndex: 0

                    contentItem: Text {
                        text: parent.displayText
                        color: "#B2B4BC"
                        font.pixelSize: 13
                        font.family: "Roboto"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }

                    background: Rectangle {
                        color: "#3E3E42"
                        radius: 5
                    }

                    indicator: Image {
                        source: "qrc:/resources/icons/list-triangle.svg"
                        width: 10
                        height: 8
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    delegate: ItemDelegate {
                        width: parent.width
                        contentItem: Text {
                            text: modelData
                            color: "#B2B4BC"
                            font.pixelSize: 13
                            font.family: "Roboto"
                            leftPadding: 10
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#46464A" : "#3E3E42"
                        }
                    }
                }

                // Значение 6 (Склад)
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    text: "Россия, Челябинская обл., г. Челябинск, пр. Ленина, д. 228, 456789"
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                // Значение 7 (Дата)
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    text: "01.01.26"
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

                // Распорка, прижимающая кнопки к низу
                Item { Layout.fillHeight: true }

                // Кнопки управления
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                    spacing: 10

                    TextButton {
                        buttonText: qsTr("Отменить")
                        buttonWidth: 120
                        buttonHeight: 30
                        bgColor: "#3E3E42"
                        bgColorPressed: "#4E4E52"
                        textColor: "#B2B4BC"
                        textColorPressed: "#909092"
                        onClickedHandler: function() {
                            Backend.router.route = "/details" // можно попробовать добавить команду Back
                        }
                    }

                    TextButton {
                        buttonText: qsTr("Сохранить")
                        buttonWidth: 120
                        buttonHeight: 30
                        onClickedHandler: function() {
                            // Логика сохранения
                        }
                    }
                }
            }
        }
    }
}
