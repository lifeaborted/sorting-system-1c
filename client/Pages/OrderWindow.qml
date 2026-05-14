import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import io.backend 1.0
import "../Components"

Rectangle {
    required property var routeData
    required property Window window
    property int orderId: routeData["orderId"]
    property var order: Backend.user.get_order(orderId)
    property int maxAmountOfOrderItems: 0
    property int currentAmountOfOrderItems: 0

    Component.onCompleted: {
        window.width = 800
        window.height = 500
        const orderItems = order.orderItems
        for (const item of orderItems) {
            maxAmountOfOrderItems += item.required_quantity
            currentAmountOfOrderItems += item.orderItemParts.length
        }
    }

    id: orderInfoPage
    anchors.fill: parent
    color: "#28282A"

    RowLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0

        // Левая панель
        Rectangle {
            Layout.preferredWidth: 230
            Layout.fillHeight: true
            color: "#181819"

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 45
                anchors.topMargin: 40
                anchors.rightMargin: 10
                spacing: 10

                // Заголовок окна
                RowLayout {
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignTop
                    Layout.leftMargin: -38
                    spacing: 10

                    Image {
                        source: "qrc:/resources/icons/detail-info.svg"
                        width: 32
                        height: 32
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: qsTr("Информация о заказе")
                        color: "#E6E8E9"
                        font.pixelSize: 16
                        font.weight: 400
                        font.family: "Roboto"
                    }

                    Item { Layout.fillWidth: true }
                }

                InfoRow {
                    Layout.preferredHeight: 30
                    Layout.maximumHeight: 30
                    iconSource: "qrc:/resources/icons/type-new.svg"
                    labelText: qsTr("Заказчик")
                }

                InfoRow {
                    Layout.preferredHeight: 30
                    Layout.maximumHeight: 30
                    iconSource: "qrc:/resources/icons/serial-number.svg"
                    labelText: qsTr("Номер заказа")
                }

                InfoRow {
                    Layout.preferredHeight: 30
                    Layout.maximumHeight: 30
                    iconSource: "qrc:/resources/icons/batch-number.svg"
                    labelText: qsTr("Статус")
                }

                InfoRow {
                    Layout.preferredHeight: 30
                    Layout.maximumHeight: 30
                    iconSource: "qrc:/resources/icons/status.svg"
                    labelText: qsTr("Стоимость")
                }

                InfoRow {
                    Layout.preferredHeight: 30
                    Layout.maximumHeight: 30
                    iconSource: "qrc:/resources/icons/person.svg"
                    labelText: qsTr("Создан")
                }

                InfoRow {
                    Layout.preferredHeight: 30
                    Layout.maximumHeight: 30
                    Layout.bottomMargin: 80
                    iconSource: "qrc:/resources/icons/warehouse.svg"
                    labelText: qsTr("Состав")
                }

                InfoRow {
                    Layout.preferredHeight: 30
                    Layout.maximumHeight: 30
                    iconSource: "qrc:/resources/icons/date.svg"
                    labelText: qsTr("Заметка")
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
                anchors.topMargin: 100
                anchors.bottomMargin: 60
                anchors.leftMargin: 25
                anchors.rightMargin: 25
                spacing: 10

                // Заказчик
                InfoText {
                    infoText: order.customer.company_name
                }

                // Номер заказа
                InfoText {
                    infoText: order.order_number
                }

                // Статус
                InfoText {
                    infoText: order["status"] !== "completed" ? qsTr("Выполняется") : qsTr("Завершён")
                }

                // Стоимость
                InfoText {
                    infoText: qsTr("%1р").arg(order["fullPrice"])
                }

                // Создан
                InfoText {
                    infoText: {
                        const date = new Date(order["created_at"])
                        return qsTr("%1.%2.%3 %4:%5:%6")
                            .arg(String(date.getDate()).padStart(2, '0'))
                            .arg(String(date.getMonth()).padStart(2, '0'))
                            .arg(date.getFullYear())
                            .arg(String(date.getHours()).padStart(2, '0'))
                            .arg(String(date.getMinutes()).padStart(2, '0'))
                            .arg(String(date.getSeconds()).padStart(2, '0'))
                    }
                }

                // Состав
                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 110
                    Layout.alignment: Qt.AlignVCenter
                    color: "#3E3E42"
                    radius: 5

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true
                        contentHeight: materialsCol.height
                        contentWidth: width

                        Column {
                            id: materialsCol
                            width: parent.width
                            spacing: 3

                            Repeater {
                                model: order.orderItems
                                delegate: Row {
                                    width: parent.width
                                    spacing: 0

                                    Text {
                                        text: "• " + modelData.partType.name
                                        color: "#B2B4BC"
                                        font.pixelSize: 10
                                        font.family: "Roboto"
                                        width: parent.width - 36
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: "x" + modelData.required_quantity
                                        color: "#B2B4BC"
                                        font.pixelSize: 10
                                        font.family: "Roboto"
                                        width: 36
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }

                        ScrollIndicator.vertical: ScrollIndicator {
                            opacity: 0.7
                        }
                    }
                }

                // Заметка
                InfoText {
                    infoText: order.notes || "-"
                }

                Item { Layout.fillHeight: true }
            }

            TextButton {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 30
                anchors.rightMargin: 40
                buttonText: qsTr("Отменить")
                buttonWidth: 120
                buttonHeight: 30
                bgColor: "#3E3E42"
                bgColorPressed: "#4E4E52"
                textColor: "#B2B4BC"
                textColorPressed: "#909092"
                onClickedHandler: function() {
                    orderInfoPage.window.close()
                }
            }

            // Прогресс-круг
            Item {
                width: 110
                height: 110
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 90
                anchors.rightMargin: 50

                Canvas {
                    id: progressCanvas
                    anchors.fill: parent
                    onPaint: {
                        let ctx = getContext("2d")
                        let cx = width / 2, cy = height / 2, r = 46
                        ctx.clearRect(0, 0, width, height)

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, -Math.PI / 2,
                                -Math.PI / 2 + Math.PI * 2 * order.completedPercentage)
                        ctx.strokeStyle = "#E6E8E9"
                        ctx.lineWidth = 12
                        ctx.lineCap = "round"
                        ctx.stroke()
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: Math.round(order.completedPercentage * 100) + "%"
                        color: "#E6E8E9"
                        font.pixelSize: 24
                        font.family: "Roboto"
                        font.weight: Font.Bold
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: qsTr("%1 из %2").arg(currentAmountOfOrderItems).arg(maxAmountOfOrderItems)
                        color: "#E6E8E9"
                        font.pixelSize: 10
                        font.family: "Roboto"
                        font.weight: Font.Medium
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}