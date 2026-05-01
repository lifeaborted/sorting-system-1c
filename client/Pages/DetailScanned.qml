import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import io.backend 1.0
import "../Components"

Rectangle {
    required property var routeData
    required property Window window
    required property string routePath
    property int detailId: routeData["part"]["part_id"]
    property var detail: routeData["part"]
    property var image: routeData["image"]
    property var orderId: routeData["order"]
    property var order: null
    property var possibleOrdersFull: routeData["allOrders"]
    property list<string> ordersCodes: []
    property var codesMap: ({})

    function format_order(x): String {
        return qsTr("%1 от '%2' (%3) %4%")
            .arg(x["order_number"])
            .arg(x["customer"]["company_name"])
            .arg(x["priority"])
            .arg(Math.round(x["quantity"] / x["required_quantity"] * 100))
    }

    Connections {
        target: Backend.router
        function onBeforePopupRequested(path) {
            if (path == routePath) {
                window.close()
            }
        }
    }

    Component.onCompleted: {
        window.width = 900
        window.height = 680
        possibleOrdersFull.forEach((x, i) => {
            ordersCodes.push(format_order(x))
            codesMap[format_order(x)] = {
                order_id: x["order_id"],
                sequence_id: i
            }
            if (orderId == x["order_id"]) {
                order = x
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
            text: detail.serial_number
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
                    iconSource: "qrc:/resources/icons/person.svg"
                    labelText: qsTr("Сортировщик")
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

                InfoRow {
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    iconSource: "qrc:/resources/icons/order.svg"
                    labelText: qsTr("Распределен в")
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

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 25

                    // Левая колонка с информацией
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 25

                        // Тип детали
                        InfoText {
                            infoText: detail.partType?.name || "-"
                        }

                        // Серийный номер
                        InfoText {
                            infoText: detail.serial_number || "-"
                        }

                        // Номер партии
                        InfoText {
                            infoText: detail.batch_number || "-"
                        }

                        // Статус
                        InfoText {
                            infoText: {
                                switch (detail.status) {
                                    case "pending": return qsTr("Обрабатывается")
                                    case "in_production": return qsTr("В производстве")
                                    case "sorting": return qsTr("Сортировка")
                                    case "completed": return qsTr("Отсортирован")
                                    case "canceled": return qsTr("Отменён")
                                    default: return "—"
                                }
                            }
                        }

                        // Сортировщик
                        InfoText {
                            infoText: Backend.user.format_username("{first} {second} {middle}")
                        }
                    }

                    // Изображение
                    Image {
                        Layout.preferredWidth: 320
                        Layout.preferredHeight: 160
                        Layout.rightMargin: 20
                        fillMode: Image.PreserveAspectFit
                        source: qsTr("data:image/jpeg;base64,%1").arg(image["data"])
                    }
                }

                // Склад (с переносом текста)
                InfoText {
                    infoText: detail.warehouse != null
                             ? qsTr("%1, %2, %3, %4, %5, %6")
                                .arg(detail.warehouse.address.country)
                                .arg(detail.warehouse.address.region)
                                .arg(detail.warehouse.address.city)
                                .arg(detail.warehouse.address.street)
                                .arg(detail.warehouse.address.building)
                                .arg(detail.warehouse.address.postal_code)
                             : "-"
                    enableWrap: true
                    maxLineCount: 2
                    enableElide: true
                }

                // Дата производства
                InfoText {
                    infoText: {
                        const date = new Date(detail.manufacture_date);

                        const day = date.getDate();
                        const month = date.getMonth() + 1;
                        const year = date.getFullYear();

                        const hours = date.getHours();
                        const minutes = date.getMinutes();
                        const seconds = date.getSeconds();

                        return `${day}.${month}.${year} ${hours}:${minutes}:${seconds}`;
                    }
                }

                // Распределен в
                ComboBox {
                    id: orderComboBox
                    Layout.preferredWidth: 500
                    Layout.preferredHeight: 36
                    Layout.maximumHeight: 36
                    model: [qsTr("Не выбран")].concat(ordersCodes)
                    currentValue: order != null ? format_order(order)  : qsTr("Не выбран")


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

                    Component.onCompleted: {
                        popup.enter = null
                        popup.exit = null
                        popup.padding = 0
                    }
                }

                Item { Layout.fillHeight: true }

                // Кнопки управления
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                    Layout.bottomMargin: 10
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
                            if (orderComboBox.currentValue != qsTr("Не выбран")) {
                                o_id = codesMap[orderComboBox.currentValue]["order_id"]
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
