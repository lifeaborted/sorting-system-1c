import QtQuick 6.11
import QtQuick.Controls 6.11
import QtQuick.Layouts 1.15

Item {
    id: root
    required property string from
    required property string to
    signal fromSelected(from: string)
    signal toSelected(from: string)


    // private
    property int month: (new Date()).getMonth()
    property int year: (new Date()).getFullYear()
    property int fromEpoch: getDayIdFromDate(from)
    property int toEpoch: getDayIdFromDate(to)
    property int clickCount: 0

    function getDayIdFromDate(date: string): int {
        let splt = date.split(".")
        let day = Number(splt[0])
        let month = Number(splt[1])
        let year = Number(splt[2])
        return getDayIdFromEpoch(day, month, year)
    }

    function getDayIdFromEpoch(day: int, month: int, year: int): int {
        let epoch = 1970
        let dayMod = day
        let monthMod = month * 32
        let yearMod = (year - epoch) * 32 * 13
        return yearMod + monthMod + dayMod
    }


    Button {
        font.pixelSize: 12
        font.family: "Roboto"
        text: from + "-" + to
        onClicked: popup.open()
    }

    Popup {
        // center popup related to root position
        // was clipped before
        x: root.x - popup.width / 2
        id: popup
        background: Rectangle {
            color: "#3E3E42"
            radius: 5
        }

        GridLayout {
            columns: 1
            Text {
                text: {
                    let text = Qt.locale("ru_RU").standaloneMonthName(month, Locale.LongFormat )
                    return text[0].toUpperCase() + text.slice(1) + " " + year
                }
            }
            RowLayout {
                Layout.fillWidth: true
                TextButton {
                    text: "<"
                    onClicked: {
                        if (month != 0) {
                            month -= 1
                        } else {
                            month = Calendar.January
                            year -= 1
                        }
                    }
                }
                TextButton {
                    text: ">"
                    onClicked: {
                        if (month != Calendar.December) {
                            month += 1
                        } else {
                            month = Calendar.January
                            year += 1
                        }
                    }
                }
                TextButton {
                    text: "^"
                    onClicked: {
                        year += 1
                    }
                }
                TextButton {
                    text: "down"
                    onClicked: {
                        year -= 1
                    }
                }
            }

            DayOfWeekRow {
                locale: grid.locale
                Layout.fillWidth: true
                delegate: Text {
                    text: shortName[0].toUpperCase() + shortName.slice(1)
                    // font: control.font
                    // color: control.palette.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    required property string shortName
                }
            }

            MonthGrid {
                locale: Qt.locale("ru_RU")
                id: grid
                month: root.month
                year: root.year
                Layout.fillWidth: true
                Layout.fillHeight: true
                delegate: Button {
                    property int dayEpoch: getDayIdFromEpoch(model.day, model.month + 1, model.year)
                    opacity: model.month === root.month ? 1 : 0
                    background: Rectangle {
                        color: {
                            if (fromEpoch == toEpoch && fromEpoch == dayEpoch) {
                                return "purple"
                            }

                            if (dayEpoch == fromEpoch) {
                                return "cyan"
                            }
                            if (dayEpoch == toEpoch) {
                                return "cyan"
                            }

                            return (fromEpoch < dayEpoch) && (dayEpoch < toEpoch) ? "wheat" : "white"
                        }
                    }
                    text: model.day
                    required property var model
                    onClicked: {
                        let emitDate = qsTr("%1.%2.%3").arg(String(model.day).padStart(2, "0")).arg(String(model.month + 1).padStart(2, "0")).arg(model.year)
                        let resetClickCount = true
                        if (dayEpoch == toEpoch) {
                            fromSelected(emitDate)
                        } else if (dayEpoch == fromEpoch) {
                            toSelected(emitDate)
                        } else if (dayEpoch > toEpoch) {
                            toSelected(emitDate)
                        } else if (dayEpoch < fromEpoch) {
                            fromSelected(emitDate)
                        } else {
                            resetClickCount = false
                            clickCount = clickCount % 2
                            if (clickCount == 0) {
                                fromSelected(emitDate)
                            } else {
                                toSelected(emitDate)
                            }

                            clickCount += 1
                        }

                        if (resetClickCount) {
                            clickCount = 0
                        }
                    }
                }
            }
        }
    }


}
