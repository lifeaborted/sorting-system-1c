import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import io.backend 1.0
import "../Components"
Rectangle {
    id: detailsPage
    color: "#2e2e2e"
    width: 1280
    height: 720

    Material.theme: Material.Dark
    Material.accent: Material.Blue

    // property list<var> details: []
    // property var detailsFilter

    // property QtObject sortingParams: QtObject {
    //     property string search: ""
    //     property string type: "Все"
    //     property string batch: "Все"
    //     property string status: "Все"
    //     property string order: "Все"
    //     property string warehouse: "Все"
    //     property var date: undefined
    //     //       ^^^^^^ <-- ???
    // }

    // function loadDetails() {
    //     detailsFilter = Backend.user.load_sorting_options()
    //     // Биндинг из  controller.detail.py Детали
    //     // Можно считать, что значения закешированы, и никакой дополнительной нагрузке вызов функции не несёт
    //     // Детали не надо напрямую редачить
    //     // и массив тоже не имеет смысла :p
    //     details = Backend.user.load_details_filter(sortingParams)
    // }

    // Component.onCompleted: {
    //     loadDetails()
    // }

    // onSortingParamsChanged: {
    //     loadDetails()
    // }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        LeftSidebar{}

        // Основная часть
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#2e2e2e"

            NavButtons{}

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                anchors.topMargin: 60
                spacing: 15

                ProfileAndSearch{}

                // Фильтры
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    // Статус
                    Filter {
                        filterLabel: qsTr("Статус")
                        filterModel: ["Все"].concat(Object.keys(detailsFilter.detail_type))
                        selectedValue: sortingParams.type
                        onValueSelected: function(value) {
                            sortingParams.type = value
                            loadDetails()
                        }
                    }

                    // Приоритет
                    Filter {
                        filterLabel: qsTr("Приоритет")
                        filterModel: ["Все"].concat(Object.keys(detailsFilter.batch))
                        selectedValue: sortingParams.batch
                        onValueSelected: function(value) {
                            sortingParams.batch = value
                            loadDetails()
                        }
                    }

                    // Заказчик
                    Filter {
                        filterLabel: qsTr("Заказчик")
                        filterModel: ["Все"].concat(Object.keys(detailsFilter.status))
                        selectedValue: sortingParams.status
                        onValueSelected: function(value) {
                            sortingParams.status = value
                            loadDetails()
                        }
                    }

                    // Сроки выполнения
                    ColumnLayout {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        spacing: 5

                        Text {
                            text: qsTr("Сроки выполнения")
                            color: "#B2B4BC"
                            font.pixelSize: 12
                            font.weight: 400
                            font.family: "Roboto"
                            leftPadding: 5
                            bottomPadding: -5
                        }

                        Rectangle {
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 30
                            color: "#3E3E42"
                            radius: 5

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                Text {
                                    text: qsTr("01.01.26 - 01.01.27")
                                    color: "#B2B4BC"
                                    font.pixelSize: 12
                                    font.family: "Roboto"
                                    font.weight: 400
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Item { Layout.fillWidth: true }

                                Image {
                                    source: "qrc:/resources/icons/calendar.svg"
                                    width: 16
                                    height: 16
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        spacing: -3

                        Text {
                            text: ""
                            font.pixelSize: 12
                        }

                        // Кнопка сброса фильтров
                        WhiteButton {
                            buttonText: "Сбросить"
                            onClickedHandler: function() {
                                // Сброс всех фильтров
                            }
                        }
                    }
                }
            }
        }
    }
}
