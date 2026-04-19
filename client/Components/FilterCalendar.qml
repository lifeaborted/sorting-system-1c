import QtQuick 6.11
import QtQuick.Controls 6.11
import QtQuick.Layouts 1.15

Item {
    id: root
    required property string from
    required property string to
    signal fromSelected(from: string)
    signal toSelected(to: string)

    property int month: (new Date()).getMonth()
    property int year: (new Date()).getFullYear()
    property int fromEpoch: getDayIdFromDate(from)
    property int toEpoch: getDayIdFromDate(to)
    property string selectMode: "from"   // from | to
    property bool showYearPicker: false

    readonly property int popupW:  264
    readonly property int pad:      12
    readonly property int cellSz:   32
    readonly property int cellGap:   2
    readonly property int gridW:  7 * cellSz + 6 * cellGap   // 236

    function getDayIdFromDate(date: string): int {
        let s = date.split(".")
        return getDayIdFromEpoch(Number(s[0]), Number(s[1]), Number(s[2]))
    }
    function getDayIdFromEpoch(day: int, month: int, year: int): int {
        return (year - 1970) * 32 * 13 + month * 32 + day
    }
    function shortDate(d: string): string {
        return d.replace(/\.(\d{4})$/, (_, y) => "." + y.slice(2))
    }

    // Button
    Rectangle {
        width: root.width
        height: root.height
        color: "#3E3E42"
        radius: 5

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 0

            Text {
                text: shortDate(root.from) + " - " + shortDate(root.to)
                color: "#B2B4BC"
                font.pixelSize: 12
                font.family: "Roboto"
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
            }
            Image {
                source: "qrc:/resources/icons/calendar.svg"
                width: 16
                height: 16
                fillMode: Image.PreserveAspectFit
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: popup.opened ? popup.close() : popup.open()
        }
    }

    Popup {
        id: popup
        x: 0; y: root.height + 6
        width: root.popupW
        padding: root.pad
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        onClosed: root.showYearPicker = false

        background: Rectangle {
            color: "#2E2E2E"
            radius: 8
            border.color: "#4A4A4E"
            border.width: 1
        }

        ColumnLayout {
            width: parent.width
            spacing: 8

            // Заголовок
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Item {
                    height: 28
                    width: titleRow.implicitWidth + 8

                    Row {
                        id: titleRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        Text {
                            text: {
                                let t = Qt.locale("ru_RU").standaloneMonthName(root.month, Locale.LongFormat)
                                return t[0].toUpperCase() + t.slice(1) + " " + root.year
                            }
                            color: "#B2B4BC"
                            font.pixelSize: 13
                            font.family: "Roboto"
                            font.weight: Font.Medium
                        }
                        Text {
                            text: root.showYearPicker ? "▲" : "▼"
                            color: "#6E7080"
                            font.pixelSize: 9
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.showYearPicker = !root.showYearPicker
                            if (root.showYearPicker)
                                Qt.callLater(() => yearGrid.positionViewAtIndex(
                                    root.year - yearGrid.baseYear, GridView.Center))
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 2
                    visible: !root.showYearPicker

                    Repeater {
                        model: [{ label: "‹", d: -1 }, { label: "›", d: 1 }]
                        delegate: Rectangle {
                            width: 24
                            height: 24
                            radius: 4
                            color: nm.containsPress ? "#4E4E52" : nm.containsMouse ? "#3E3E42" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: "#B2B4BC"
                                font.pixelSize: 16
                                font.family: "Roboto"
                            }
                            MouseArea {
                                id: nm
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    let m = root.month + modelData.d
                                    if (m < 0)       { root.month = 11; root.year -= 1 }
                                    else if (m > 11) { root.month = 0;  root.year += 1 }
                                    else               root.month = m
                                }
                            }
                        }
                    }
                }
            }

            // Кнопки "От" | "До"
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: !root.showYearPicker

                Repeater {
                    model: [{ key: "from", label: "От" }, { key: "to", label: "До" }]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 28
                        radius: 5
                        color: root.selectMode === modelData.key ? "#E6E8E9" : "#3E3E42"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 4

                            Text {
                                text: modelData.label
                                color: root.selectMode === modelData.key ? "#505050" : "#6E7080"
                                font.pixelSize: 10
                                font.family: "Roboto"
                            }
                            Text {
                                text: shortDate(modelData.key === "from" ? root.from : root.to)
                                color: root.selectMode === modelData.key ? "#181819" : "#B2B4BC"
                                font.pixelSize: 11
                                font.family: "Roboto"
                                font.weight: Font.Medium
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectMode = modelData.key
                                let parts = (modelData.key === "from" ? root.from : root.to).split(".")
                                root.month = Number(parts[1]) - 1
                                root.year  = Number(parts[2])
                            }
                        }
                    }
                }
            }

            // Календарь
            Column {
                visible: !root.showYearPicker
                spacing: 2
                Layout.alignment: Qt.AlignHCenter

                DayOfWeekRow {
                    locale: Qt.locale("ru_RU")
                    width: root.gridW

                    delegate: Text {
                        required property string shortName
                        width: root.cellSz
                        height: 20
                        text: shortName[0].toUpperCase()
                        color: "#6E7080"
                        font.pixelSize: 11
                        font.family: "Roboto"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MonthGrid {
                    id: grid
                    locale: Qt.locale("ru_RU")
                    month: root.month
                    year: root.year
                    width: root.gridW
                    spacing: root.cellGap

                    delegate: Item {
                        required property var model
                        width: root.cellSz
                        height: root.cellSz

                        property int   dayEpoch:   getDayIdFromEpoch(model.day, model.month + 1, model.year)
                        property bool  inMonth:    model.month === root.month
                        property bool  isSelected: inMonth && (dayEpoch === fromEpoch || dayEpoch === toEpoch)
                        property bool  isInRange:  inMonth && fromEpoch < dayEpoch && dayEpoch < toEpoch

                        Rectangle {
                            anchors.centerIn: parent
                            width: root.cellSz - 2
                            height: root.cellSz - 2
                            radius: (root.cellSz - 2) / 2
                            color: {
                                if (!inMonth)   return "transparent"
                                if (isSelected) return "#E6E8E9"
                                if (isInRange)  return "#4A4A52"
                                return dm.containsMouse ? "#3E3E42" : "transparent"
                            }

                            Text {
                                anchors.centerIn: parent
                                text: model.day
                                visible: inMonth
                                color: isSelected ? "#181819" : isInRange ? "#C8CACC" : "#B2B4BC"
                                font.pixelSize: 12
                                font.family: "Roboto"
                                font.weight: isSelected ? Font.Medium : Font.Normal
                            }
                        }

                        MouseArea {
                            id: dm
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: inMonth
                            cursorShape: inMonth ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                let emitDate = "%1.%2.%3"
                                    .arg(String(model.day).padStart(2, "0"))
                                    .arg(String(model.month + 1).padStart(2, "0"))
                                    .arg(model.year)

                                let newFrom = root.from
                                let newTo   = root.to

                                if (root.selectMode === "from") newFrom = emitDate
                                else                            newTo   = emitDate

                                // Автоматическая перестановка, если from > to
                                if (getDayIdFromDate(newFrom) > getDayIdFromDate(newTo)) {
                                    let tmp = newFrom; newFrom = newTo; newTo = tmp
                                }

                                fromSelected(newFrom)
                                toSelected(newTo)

                                // Автопереключение режима
                                let nextMode = root.selectMode === "from" ? "to" : "from"
                                root.selectMode = nextMode
                                let np = (nextMode === "from" ? root.from : root.to).split(".")
                                root.month = Number(np[1]) - 1
                                root.year  = Number(np[2])
                            }
                        }
                    }
                }
            }

            // Выбор года
            GridView {
                id: yearGrid
                visible: root.showYearPicker
                Layout.fillWidth: true
                height: 200
                clip: true

                property int baseYear: 1924
                model: 201

                cellWidth:  Math.floor((root.popupW - root.pad * 2) / 3)
                cellHeight: 36

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: "#6E7080"
                        opacity: parent.active ? 1.0 : 0.5
                    }
                    background: Rectangle { color: "transparent" }
                }

                // Крутилочка годов
                WheelHandler {
                    onWheel: (e) => {
                        yearGrid.contentY = Math.max(0,
                            Math.min(yearGrid.contentHeight - yearGrid.height,
                                yearGrid.contentY - e.angleDelta.y * 0.5))
                    }
                }

                delegate: Item {
                    width: yearGrid.cellWidth
                    height: yearGrid.cellHeight

                    property int  itemYear:  yearGrid.baseYear + index
                    property bool isCurrent: itemYear === root.year

                    Rectangle {
                        anchors.centerIn: parent
                        width: yearGrid.cellWidth - 8
                        height: yearGrid.cellHeight - 8
                        radius: 6
                        color: isCurrent ? "#E6E8E9" : ym.containsMouse ? "#3E3E42" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: itemYear
                            color: isCurrent ? "#181819" : "#B2B4BC"
                            font.pixelSize: 12
                            font.family: "Roboto"
                            font.weight: isCurrent ? Font.Medium : Font.Normal
                        }
                    }

                    MouseArea {
                        id: ym
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.year = itemYear
                            root.showYearPicker = false
                        }
                    }
                }
            }
        }
    }
}