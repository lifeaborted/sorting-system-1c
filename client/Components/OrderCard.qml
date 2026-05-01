import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Components"
import QtQuick.Controls.Fusion 2.15
Rectangle {
    id: root
    height: 100
    radius: 8
    color: "#3E3E42"

    property string customerName: "Название заказчика"
    property string status: "выполняется"
    property int priority: 5
    property string note: ""
    property real progress: 0
    property real price: 0
    property var materials: []
    property var onEditClicked: null

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        // Название + статус
        ColumnLayout {
            Layout.preferredWidth: 180
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Text {
                text: root.customerName
                color: "#E6E8E9"
                font.pixelSize: 14
                font.family: "Roboto"
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            Text {
                text: root.status
                color: "#B2B4BC"
                font.pixelSize: 11
                font.family: "Roboto"
            }
        }

        // Приоритет + заметка
        ColumnLayout {
            Layout.preferredWidth: 220
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            RowLayout {
                spacing: 4
                Text {
                    text: qsTr("Приоритет:")
                    color: "white"
                    font.pixelSize: 12
                    font.family: "Roboto"
                }
                Text {
                    text: root.priority
                    color: "#E6E8E9"
                    font.pixelSize: 10
                    font.family: "Roboto"
                    font.weight: Font.Bold
                }
            }
            RowLayout {
                spacing: 4
                Layout.fillWidth: true
                Text {
                    text: qsTr("Заметка:")
                    color: "white"
                    font.pixelSize: 12
                    font.family: "Roboto"
                }
                Text {
                    text: root.note
                    color: "#B2B4BC"
                    font.pixelSize: 10
                    font.family: "Roboto"
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        // Разделитель
        Rectangle {
            width: 1
            Layout.fillHeight: true
            Layout.topMargin: 12
            Layout.bottomMargin: 12
            color: "#55555A"
        }

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 3

            Repeater {
                model: root.materials.slice(0,5)
                delegate: Row {
                    width: parent.width
                    spacing: 0

                    Text {
                        text: "• " + modelData.name
                        color: "#B2B4BC"
                        font.pixelSize: 11
                        font.family: "Roboto"
                        width: parent.width - 36
                    }
                    Text {
                        text: "x" + modelData.quantity
                        color: "#B2B4BC"
                        font.pixelSize: 11
                        font.family: "Roboto"
                        width: 36
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        // Стоимость
        Text {
            text: root.price + "р"
            color: "#E6E8E9"
            font.pixelSize: 18
            font.family: "Roboto"
            font.weight: Font.Bold
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }

        // Кнопка редактирования
        IconButton {
            onClickedHandler: function() {
                if (root.onEditClicked)
                    root.onEditClicked()
            }
        }

        // Прогресс-круг
        Item {
            width: 64; height: 64
            Layout.alignment: Qt.AlignVCenter

            Canvas {
                id: progressCanvas
                anchors.fill: parent
                onPaint: {
                    let ctx = getContext("2d")
                    let cx = width / 2, cy = height / 2, r = 27
                    ctx.clearRect(0, 0, width, height)

                    ctx.beginPath()
                    ctx.arc(cx, cy, r, 0, Math.PI * 2)
                    ctx.strokeStyle = "#55555A"
                    ctx.lineWidth = 5
                    ctx.stroke()

                    ctx.beginPath()
                    ctx.arc(cx, cy, r, -Math.PI / 2,
                            -Math.PI / 2 + Math.PI * 2 * (root.progress / 100))
                    ctx.strokeStyle = "#E6E8E9"
                    ctx.lineWidth = 5
                    ctx.lineCap = "round"
                    ctx.stroke()
                }

                Connections {
                    target: root
                    function onProgressChanged() { progressCanvas.requestPaint() }
                }
            }

            Text {
                anchors.centerIn: parent
                text: Math.round(root.progress) + "%"
                color: "#E6E8E9"
                font.pixelSize: 12
                font.family: "Roboto"
                font.weight: Font.Medium
            }
        }
    }
}
