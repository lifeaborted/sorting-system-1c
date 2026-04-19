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
    // property QtObject sortingParams: ...
    // function loadDetails() { ... }
    // Component.onCompleted: { loadDetails() }

    property var mockDetails: [
        {
            customerName: "ООО «Рога и Копыта»",
            status: "выполняется",
            priority: 5,
            note: "Производство скворечников",
            progress: 75,
            price: 25000,
            materials: [
                {"name": "Доска 200×2000", "quantity": 123},
                {"name": "Гвоздь 20×2",   "quantity": 321},
                {"name": "Саморез 80×4",  "quantity": 228}
            ]
        },
        {
            customerName: "ИП Петров",
            status: "ожидает",
            priority: 3,
            note: "Срочный заказ, доставка до пятницы",
            progress: 30,
            price: 15000,
            materials: [
                {"name": "Лист сталь 2мм", "quantity": 50},
                {"name": "Болт М8",        "quantity": 200}
            ]
        },
        {
            customerName: "ЗАО «СтройМонтаж»",
            status: "завершён",
            priority: 1,
            note: "Повторный заказ, постоянный клиент",
            progress: 100,
            price: 42000,
            materials: [
                {"name": "Труба профильная", "quantity": 80},
                {"name": "Уголок 50×50",     "quantity": 40},
                {"name": "Краска антикор",   "quantity": 15}
            ]
        },
        {
            customerName: "ООО «МеталлСервис»",
            status: "на паузе",
            priority: 2,
            note: "Ждём подтверждения спецификации",
            progress: 10,
            price: 8500,
            materials: [
                {"name": "Проволока стальная", "quantity": 500},
                {"name": "Шайба М10",          "quantity": 100}
            ]
        },
        {
            customerName: "ИП Сидоров",
            status: "выполняется",
            priority: 4,
            note: "Производство металлоконструкций",
            progress: 55,
            price: 31000,
            materials: [
                {"name": "Уголок 40×40", "quantity": 60},
                {"name": "Болт М12",     "quantity": 150}
            ]
        },
        {
            customerName: "ООО «ПромДеталь»",
            status: "ожидает",
            priority: 2,
            note: "Согласование чертежей",
            progress: 5,
            price: 12000,
            materials: [
                {"name": "Пруток Ø20", "quantity": 30}
            ]
        },
        {
            customerName: "АО «ТехноСтрой»",
            status: "выполняется",
            priority: 5,
            note: "Изготовление несущих конструкций",
            progress: 62,
            price: 87000,
            materials: [
                {"name": "Балка двутавровая", "quantity": 12},
                {"name": "Анкер М16",         "quantity": 80},
                {"name": "Грунтовка ГФ-021",  "quantity": 20}
            ]
        },
        {
            customerName: "ИП Кузнецова А.В.",
            status: "ожидает",
            priority: 1,
            note: "Декоративные кованые изделия",
            progress: 0,
            price: 6400,
            materials: [
                {"name": "Полоса стальная 40×4", "quantity": 18},
                {"name": "Прут квадратный 12×12", "quantity": 25}
            ]
        }
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 0

        LeftSidebar {}

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#2e2e2e"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                anchors.topMargin: 60
                spacing: 15

                ProfileAndSearch {}

                // ── Фильтры ─────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Filter {
                        filterLabel: qsTr("Статус")
                        filterModel: ["Все", "Только активные"]
                        selectedValue: "Только активные"
                    }

                    Filter {
                        filterLabel: qsTr("Приоритет")
                        filterModel: ["Все", "1", "2", "3", "4", "5"]
                        selectedValue: "Все"
                    }

                    Filter {
                        filterLabel: qsTr("Заказчик")
                        filterModel: ["Все"]
                        selectedValue: "Все"
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 160
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

                        FilterCalendar {
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 30
                            from: "01.01.2026"
                            to:   "01.01.2027"
                        }
                    }

                    ColumnLayout {
                        spacing: 5
                        Layout.preferredHeight: 50

                        Text { text: ""; font.pixelSize: 12 }

                        TextButton {
                            buttonText: "Сбросить"
                            onClickedHandler: function() {}
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                // Список заказов
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        id: orderList
                        width: parent.width
                        spacing: 8
                        model: mockDetails

                        delegate: OrderCard {
                            width: orderList.width
                            customerName: modelData.customerName
                            status:       modelData.status
                            priority:     modelData.priority
                            note:         modelData.note
                            progress:     modelData.progress
                            price:        modelData.price
                            materials:    modelData.materials
                            onEditClicked: function() {
                                console.log("edit", modelData.customerName)
                            }
                        }
                    }
                }
            }
        }
    }
}