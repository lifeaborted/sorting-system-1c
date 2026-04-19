import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import io.backend 1.0
import "../Components"

Rectangle {
    id: detailsPage
    color: "#2e2e2e"
    anchors.fill: parent

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
                        TextButton {
                            buttonText: "Сбросить"
                            onClickedHandler: function() {
                                // Сброс всех фильтров
                            }
                        }
                    }
                }
                Rectangle { // заменить на ScrollView
                    Layout.fillWidth: true
                    Layout.preferredHeight: 717
                    color: "transparent"

                    GridLayout {
                        anchors.fill: parent
                        rows: 3
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 10

                        // Карточка 1
                        OrderCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            customerName: "ООО «Рога и Копыта»"
                            status: "выполняется"
                            priority: 5
                            note: "Производство деревянных домов"
                            progress: 75.0
                            price: 25000
                            materials: [
                                {"name": "Доска 200×2000", "quantity": 123},
                                {"name": "Гвоздь 20×2", "quantity": 321},
                                {"name": "Саморез 80×4", "quantity": 228}
                            ]
                            onEditClicked: function() {
                                console.log("Редактировать заказ 1")
                            }
                        }

                        // Карточка 2
                        OrderCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            customerName: "ИП Петров"
                            status: "ожидает"
                            priority: 3
                            note: "Срочный заказ, доставка до пятницы"
                            progress: 30.0
                            price: 15000
                            materials: [
                                {"name": "Лист сталь 2мм", "quantity": 50},
                                {"name": "Болт М8", "quantity": 200}
                            ]
                            onEditClicked: function() {
                                console.log("Редактировать заказ 2")
                            }
                        }

                        // Карточка 3
                        OrderCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            customerName: "ЗАО «СтройМонтаж»"
                            status: "завершён"
                            priority: 1
                            note: "Повторный заказ, постоянный клиент"
                            progress: 100.0
                            price: 42000
                            materials: [
                                {"name": "Труба профильная", "quantity": 80},
                                {"name": "Уголок 50×50", "quantity": 40},
                                {"name": "Краска антикор", "quantity": 15}
                            ]
                            onEditClicked: function() {
                                console.log("Редактировать заказ 3")
                            }
                        }

                        // Карточка 4
                        OrderCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            customerName: "ООО «МеталлСервис»"
                            status: "на паузе"
                            priority: 2
                            note: "Ждём подтверждения спецификации"
                            progress: 10.0
                            price: 8500
                            materials: [
                                {"name": "Проволока стальная", "quantity": 500},
                                {"name": "Шайба М10", "quantity": 100}
                            ]
                            onEditClicked: function() {
                                console.log("Редактировать заказ 4")
                            }
                        }
                    }
                }
            }
        }
    }
}
