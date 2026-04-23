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
    property QtObject sortingParams: QtObject {
        property string search: ""
        property var status: null
        property var priority: null
        property var customer: null
        property QtObject date: QtObject {
            property string from: "01.04.2020"
            property string to: "20.04.2027"
        }
    }

    property var ordersFilter


    function loadDetails() {
        // detailsFilter = Backend.user.load_sorting_options()
        let orders = Backend.user.load_orders(sortingParams)
        ordersFilter = Backend.user.load_orders_filters()
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
                progress: order["completedPercentage"] * 100,
                price: order["fullPrice"],
                materials: materials
            })
        }
    }

    function resetParams() {
        sortingParams = Qt.createQmlObject(`
            import QtQuick
                QtObject {
                    property string search: ""
                    property var status: null
                    property var priority: null
                    property var customer: null
                    property QtObject date: QtObject {
                        property string from: "01.04.2020"
                        property string to: "20.04.2027"
                    }
                }
        `, detailsPage, "sortingParams")
        loadDetails()
    }


    Component.onCompleted: {
        loadDetails()
    }

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

                ProfileAndSearch {
                    text: sortingParams.search
                    onValueChanged: (value) => {
                        sortingParams.search = value
                        // If this laggs add timeout debouncer
                        loadDetails()
                    }
                }

                // ── Фильтры ─────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Filter {
                        filterLabel: qsTr("Статус")
                        filterModel: ["Все", "Только активные", "Завершенные"]
                        selectedValue: {
                            switch (sortingParams.status) {
                                case "sorting": return "Только активные"
                                case "completed": return "Завершенные"
                                case null: return "Все"
                            }
                        }

                        onValueSelected: function(value) {
                            switch (value) {
                                case "Все":             sortingParams.status = null; break
                                case "Только активные": sortingParams.status = "sorting"; break
                                case "Завершенные":     sortingParams.status = "completed"; break
                            }

                            loadDetails()
                        }
                    }

                    Filter {
                        filterLabel: qsTr("Приоритет")
                        filterModel: ["Все"].concat(ordersFilter["priority"])
                        selectedValue: sortingParams.priority != null ? sortingParams.priority : "Все"
                        onValueSelected: (value) => {
                            sortingParams.priority = value != "Все" ? value : null
                            loadDetails()
                        }
                    }

                    Filter {
                        filterLabel: qsTr("Заказчик")
                        filterModel: ["Все"].concat(ordersFilter["customer"])
                        selectedValue: sortingParams.customer != null ? sortingParams.customer : "Все"
                        onValueSelected: (value) => {
                            sortingParams.customer = value != "Все" ? value : null
                            loadDetails()
                        }
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
                            from: sortingParams.date.from
                            to: sortingParams.date.to
                            onFromSelected: (date) => {
                                sortingParams.date.from = date
                                loadDetails()
                            }
                            onToSelected: (date) => {
                                sortingParams.date.to = date
                                loadDetails()
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 5
                        Layout.preferredHeight: 50

                        Text { text: ""; font.pixelSize: 12 }

                        TextButton {
                            buttonText: "Сбросить"
                            onClickedHandler: function() {
                                resetParams()
                            }
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
