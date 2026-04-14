import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 320
    height: 250
    radius: 5
    color: "#3e3e42"

    // Настраиваемые свойства
    property string customerName: "Название заказчика"
    property string status: "выполняется"
    property int priority: 5
    property string note: "Производство цинковых гробов"
    property real progress: 75.0
    property real price: 25000
    property var materials: [
        {"name": "Доска 200x2000", "quantity": 123},
        {"name": "Гвоздь 20x2", "quantity": 321},
        {"name": "Саморез 80x4", "quantity": 228}
    ]
    property var onEditClicked: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        // Заголовок - название заказчика
        Text {
            Layout.fillWidth: true
            text: root.customerName
            color: "white"
            font.pixelSize: 18
            font.weight: Font.Bold
            font.family: "Roboto"
            wrapMode: Text.Wrap
        }

        // Статус и приоритет
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                RowLayout {
                    spacing: 5
                    Text {
                        text: "Статус:"
                        color: "#B2B4BC"
                        font.pixelSize: 12
                        font.family: "Roboto"
                    }
                    Text {
                        text: root.status
                        color: "#B2B4BC"
                        font.pixelSize: 12
                        font.family: "Roboto"
                    }
                }

                RowLayout {
                    spacing: 5
                    Text {
                        text: "Приоритет:"
                        color: "#B2B4BC"
                        font.pixelSize: 12
                        font.family: "Roboto"
                    }
                    Text {
                        text: root.priority.toString()
                        color: "#B2B4BC"
                        font.pixelSize: 12
                        font.family: "Roboto"
                    }
                }
            }

            // Progress ring
            Item {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80

                Canvas {
                    id: progressCanvas
                    anchors.centerIn: parent
                    width: 80
                    height: 80

                    property real progressValue: root.progress

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()

                        var centerX = width / 2
                        var centerY = height / 2
                        var radius = 35
                        var lineWidth = 6

                        // Фоновый круг
                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                        ctx.strokeStyle = "#505050"
                        ctx.lineWidth = lineWidth
                        ctx.stroke()

                        // Прогресс
                        var startAngle = -Math.PI / 2
                        var endAngle = startAngle + (2 * Math.PI * progressValue / 100)

                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                        ctx.strokeStyle = "#E6E8E9"
                        ctx.lineWidth = lineWidth
                        ctx.lineCap = "round"
                        ctx.stroke()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Math.round(root.progress) + "%"
                    color: "white"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.family: "Roboto"
                }
            }
        }

        // Заметка
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Text {
                    text: "Заметка:"
                    color: "#B2B4BC"
                    font.pixelSize: 12
                    font.family: "Roboto"
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.note
                color: "#B2B4BC"
                font.pixelSize: 12
                font.family: "Roboto"
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        // Состав материалов
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            Text {
                text: "Состав:"
                color: "#B2B4BC"
                font.pixelSize: 12
                font.family: "Roboto"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: root.materials

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: "• " + modelData.name
                            color: "#B2B4BC"
                            font.pixelSize: 11
                            font.family: "Roboto"
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "x" + modelData.quantity
                            color: "#808080"
                            font.pixelSize: 11
                            font.family: "Roboto"
                        }
                    }
                }
            }
        }

        // Нижняя часть - кнопка и цена
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom

            // Кнопка редактирования
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 5
                color: "#E6E8E9"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.onEditClicked)
                            root.onEditClicked()
                    }
                }

                // Иконка карандаша (простая)
                Text {
                    anchors.centerIn: parent
                    text: "✎"
                    color: "#181819"
                    font.pixelSize: 18
                }
            }

            Item { Layout.fillWidth: true }

            // Цена
            Text {
                text: root.price + "р"
                color: "white"
                font.pixelSize: 24
                font.weight: Font.Bold
                font.family: "Roboto"
            }
        }
    }

    // Функция для обновления прогресса
    function setProgress(value) {
        progress = value
        progressCanvas.requestPaint()
    }

    // Функция для обновления материалов
    function setMaterials(newMaterials) {
        materials = newMaterials
    }
}