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

    property list<var> mockDetails: []
    // property var detailsFilter
    // property QtObject sortingParams: ...
    // function loadDetails() { ... }
    // Component.onCompleted: { loadDetails() }

    function loadDetails() {
        // detailsFilter = Backend.user.load_sorting_options()
        let orders = Backend.user.load_orders()

        mockDetails = []
        for (const order of orders) {
            let materials = []

            for (const orderItems of order["orderItems"]) {
                materials.push({
                    name: orderItems["partType"]["name"],
                    quantity: orderItems["required_quantity"]
                })
            }

            mockDetails.push({
                customerName: order["customer"]["company_name"],
                status: "ожидает",
                priority: order["priority"],
                note: order["notes"] || "-",
                progress: 0,
                price: 6400,
                materials: materials
            })
        }

    }

    Component.onCompleted: {
        loadDetails()
    }

    // onSortingParamsChanged: {
    //     loadDetails()
    // }
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
