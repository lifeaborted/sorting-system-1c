import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import io.backend 1.0
import "../Components"

Rectangle {
    required property var routeData
    required property Window window
    property int detailId: routeData["detailId"]
    property var detail: Backend.user.get_detail(detailId)
    property var possibleOrdersFull: Backend.user.load_details_possible_orders(detailId)
    property list<string> ordersCodes: []
    property var codesMap: ({
        orderCodes: ({}),
        orderIds: ({})
    })

    Component.onCompleted: {
        possibleOrdersFull.forEach((x, i) => {
            ordersCodes.push(x["order_number"])
            codesMap["orderCodes"][x["order_number"]] = {
                order_id: x["order_id"],
                sequence_id: i
            }
        })
    }

    id: detailInfoPage
    anchors.fill: parent
    color: "#28282A"

    // Заголовок окна
    RowLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 45
        anchors.leftMargin: 25
        spacing: 12

        Image {
            source: "qrc:/resources/icons/info-circle-old.svg"
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

    // Основная область
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
                anchors.topMargin: 25
                anchors.bottomMargin: 10
                anchors.leftMargin: 50
                anchors.rightMargin: 10
                spacing: 25

                InfoRow {
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    iconSource: "qrc:/resources/icons/type.svg"
                    labelText: qsTr("Тип")
                }

                InfoRow {
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    iconSource: "qrc:/resources/icons/serial-number.svg"
                    labelText: qsTr("Серийный номер")
                }

                InfoRow {
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    iconSource: "qrc:/resources/icons/batch-number.svg"
                    labelText: qsTr("Номер партии")
                }

                InfoRow {
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    iconSource: "qrc:/resources/icons/status.svg"
                    labelText: qsTr("Статус")
                }

                InfoRow {
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    iconSource: "qrc:/resources/icons/order.svg"
                    labelText: qsTr("Принадлежит заказу")
                }

                InfoRow {
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    iconSource: "qrc:/resources/icons/warehouse.svg"
                    labelText: qsTr("Склад")
                }

                InfoRow {
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    iconSource: "qrc:/resources/icons/date.svg"
                    labelText: qsTr("Дата производства")
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Правая панель
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#28282A"

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 25
                anchors.bottomMargin: 10
                anchors.leftMargin: 25
                anchors.rightMargin: 25
                spacing: 25

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    text: detail.type.name
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    text: detail.serial_number
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    text: detail.batch_number
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    text: switch (detail.status) {
                        case "pending": return "Обрабатывается"
                        case "in_production": return "В производстве"
                        case "sorting": return "Сортировка"
                        case "completed": return "Отсортирован"
                        case "canceled": return "Отменён"
                        default: return "—"
                    }
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBox {
                    id: orderComboBox
                    Layout.preferredWidth: 500
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    model: ["Не выбран"].concat(ordersCodes)
                    currentValue: detail["order"] != null ? detail["order"]["name"] : "Не выбран"

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

                    popup.background: Rectangle {
                        color: "#3E3E42"
                        radius: 5
                    }

                    popup.contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: orderComboBox.popup.visible ? orderComboBox.delegateModel : null
                        currentIndex: orderComboBox.popup.visible ? orderComboBox.highlightedIndex : -1
                    }

                    delegate: ItemDelegate {
                        width: parent.width
                        height: 36
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

                    // popup без анимаций
                    Component.onCompleted: {
                        popup.enter = null
                        popup.exit = null
                        popup.padding = 0
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    text: qsTr("%1, %2, %3, %4, %5, %6")
                        .arg(detail.warehouse.address.country)
                        .arg(detail.warehouse.address.region)
                        .arg(detail.warehouse.address.city)
                        .arg(detail.warehouse.address.street)
                        .arg(detail.warehouse.address.building)
                        .arg(detail.warehouse.address.postal_code)
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    text: detail.manufacture_date
                    color: "#B2B4BC"
                    font.pixelSize: 13
                    font.family: "Roboto"
                    verticalAlignment: Text.AlignVCenter
                }

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
                            detailInfoPage.window.close()
                        }
                    }

                    TextButton {
                        buttonText: qsTr("Сохранить")
                        buttonWidth: 120
                        buttonHeight: 30
                        onClickedHandler: function() {
                            let o_id = -1
                            if (orderComboBox.currentValue != "Не выбран") {
                                o_id = codesMap["orderCodes"][orderComboBox.currentValue]["order_id"]
                            }
                            Backend.user.change_detail_order(detailId, o_id)
                            detailInfoPage.window.close()
                        }
                    }
                }
            }
        }
    }
}
