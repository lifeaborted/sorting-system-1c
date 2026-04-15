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

    property list<var> details: []
    property var detailsFilter

    property QtObject sortingParams: QtObject {
        property string search: ""
        property string type: "Все"
        property string batch: "Все"
        property string status: "Все"
        property string order: "Все"
        property string warehouse: "Все"
        property var date: undefined
        //       ^^^^^^ <-- ???
    }


    function createSortingParams() {
        return Qt.createQmlObject(`
            import QtQuick
                QtObject {
                    property string search: ""
                    property string type: "Все"
                    property string batch: "Все"
                    property string status: "Все"
                    property string order: "Все"
                    property string warehouse: "Все"
                    property var date: undefined
                    //       ^^^^^^ <-- ???
                }
        `, detailsPage, "sortingParams")

    }

    function loadDetails() {
        detailsFilter = Backend.user.load_sorting_options()
        // Биндинг из  controller.detail.py Детали
        // Можно считать, что значения закешированы, и никакой дополнительной нагрузке вызов функции не несёт
        // Детали не надо напрямую редачить
        // и массив тоже не имеет смысла :p
        details = Backend.user.load_details_filter(sortingParams)
    }

    Component.onCompleted: {
        loadDetails()
    }

    onSortingParamsChanged: {
        loadDetails()
    }

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

                ProfileAndSearch{
                    text: sortingParams.search
                    onValueChanged: (value) => {
                        sortingParams.search = value
                        // If this laggs add timeout debouncer
                        loadDetails()
                    }
                }

                // Фильтры
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    // Тип детали
                    Filter {
                        filterLabel: qsTr("Тип детали")
                        filterModel: ["Все"].concat(Object.keys(detailsFilter.detail_type))
                        selectedValue: sortingParams.type
                        onValueSelected: function(value) {
                            sortingParams.type = value
                            loadDetails()
                        }
                    }

                    // Партия
                    Filter {
                        filterLabel: qsTr("Партия")
                        filterModel: ["Все"].concat(Object.keys(detailsFilter.batch))
                        selectedValue: sortingParams.batch
                        onValueSelected: function(value) {
                            sortingParams.batch = value
                            loadDetails()
                        }
                    }

                    // Статус
                    Filter {
                        filterLabel: qsTr("Статус")
                        filterModel: ["Все"].concat(Object.keys(detailsFilter.status))
                        selectedValue: sortingParams.status
                        onValueSelected: function(value) {
                            sortingParams.status = value
                            loadDetails()
                        }
                    }

                    // Заказ
                    Filter {
                        filterLabel: qsTr("Заказ")
                        filterModel: ["Все"].concat(Object.keys(detailsFilter.order))
                        selectedValue: sortingParams.order
                        onValueSelected: function(value) {
                            sortingParams.order = value
                            loadDetails()
                        }
                    }

                    // Склад
                    Filter {
                        filterLabel: qsTr("Склад")
                        filterModel: ["Все"].concat(Object.keys(detailsFilter.warehouse))
                        selectedValue: sortingParams.warehouse
                        onValueSelected: function(value) {
                            sortingParams.warehouse = value
                            loadDetails()
                        }
                    }

                    // Дата производства
                    ColumnLayout {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        spacing: 5

                        Text {
                            text: qsTr("Дата производства")
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
                                sortingParams = createSortingParams()
                            }
                        }
                    }
                }

                // Заголовки таблицы
                Rectangle {
                    id: headerRow
                    Layout.preferredWidth: 980
                    Layout.preferredHeight: 60
                    color: "#3E3E42"
                    radius: 5

                    // Свойства для сортировки
                    property string sortColumn: "date"
                    property bool sortAscending: false

                    // Функция сортировки массива деталей
                    function sortDetailsList() {
                        if (!details || details.length === 0) return

                        var sorted = JSON.parse(JSON.stringify(details))

                        sorted.sort(function(a, b) {
                            var valA, valB

                            switch(headerRow.sortColumn) {
                                case "action": return 0
                                case "type":
                                    valA = a.type ? a.type.name : ""
                                    valB = b.type ? b.type.name : ""
                                    break
                                case "number":
                                    valA = a.serial_number || ""
                                    valB = b.serial_number || ""
                                    break
                                case "batch":
                                    valA = a.batch || ""
                                    valB = b.batch || ""
                                    break
                                case "status":
                                    valA = a.status || ""
                                    valB = b.status || ""
                                    break
                                case "order":
                                    valA = a.order ? a.order.name : ""
                                    valB = b.order ? b.order.name : ""
                                    break
                                case "warehouse":
                                    valA = a.warehouse ? (a.warehouse.address?.street + a.warehouse.address?.building) : ""
                                    valB = b.warehouse ? (b.warehouse.address?.street + b.warehouse.address?.building) : ""
                                    break
                                case "date":
                                    valA = a.manufacture_date || ""
                                    valB = b.manufacture_date || ""
                                    break
                                default: return 0
                            }

                            if (valA < valB) return headerRow.sortAscending ? -1 : 1
                            if (valA > valB) return headerRow.sortAscending ? 1 : -1
                            return 0
                        })

                        details = sorted
                    }

                    // Функция переключения сортировки
                    function toggleSort(columnName) {
                        if (headerRow.sortColumn === columnName) {
                            headerRow.sortAscending = !headerRow.sortAscending
                        } else {
                            headerRow.sortColumn = columnName
                            headerRow.sortAscending = false
                        }

                        sortDetailsList()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 0

                        // Действие
                        Rectangle {
                            Layout.preferredWidth: 180
                            Layout.fillHeight: true
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 4

                                Text {
                                    text: qsTr("Действие")
                                    color: "#B2B4BC"
                                    font.pixelSize: 14
                                    font.weight: 400
                                    font.family: "Roboto"
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }

                        // Тип
                        TableHeaderColumn {
                            columnHeader: "Тип"
                            columnKey: "type"
                            columnWidth: 80
                            textLeftPadding: -10
                            currentSortColumn: headerRow.sortColumn
                            sortAscending: headerRow.sortAscending
                            onSortClicked: function(key) {
                                headerRow.toggleSort(key)
                            }
                        }

                        // Номер
                        TableHeaderColumn {
                            columnHeader: "Номер"
                            columnKey: "number"
                            columnWidth: 120
                            currentSortColumn: headerRow.sortColumn
                            sortAscending: headerRow.sortAscending
                            onSortClicked: function(key) {
                                headerRow.toggleSort(key)
                            }
                        }

                        // Партия
                        TableHeaderColumn {
                            columnHeader: "Партия"
                            columnKey: "batch"
                            columnWidth: 115
                            currentSortColumn: headerRow.sortColumn
                            sortAscending: headerRow.sortAscending
                            onSortClicked: function(key) {
                                headerRow.toggleSort(key)
                            }
                        }

                        // Статус
                        TableHeaderColumn {
                            columnHeader: "Статус"
                            columnKey: "status"
                            columnWidth: 110
                            currentSortColumn: headerRow.sortColumn
                            sortAscending: headerRow.sortAscending
                            onSortClicked: function(key) {
                                headerRow.toggleSort(key)
                            }
                        }

                        // Заказ
                        TableHeaderColumn {
                            columnHeader: "Заказ"
                            columnKey: "order"
                            columnWidth: 125
                            currentSortColumn: headerRow.sortColumn
                            sortAscending: headerRow.sortAscending
                            onSortClicked: function(key) {
                                headerRow.toggleSort(key)
                            }
                        }

                        // Склад
                        TableHeaderColumn {
                            columnHeader: "Склад"
                            columnKey: "warehouse"
                            columnWidth: 160
                            currentSortColumn: headerRow.sortColumn
                            sortAscending: headerRow.sortAscending
                            onSortClicked: function(key) {
                                headerRow.toggleSort(key)
                            }
                        }

                        // Дата
                        TableHeaderColumn {
                            columnHeader: "Дата"
                            columnKey: "date"
                            columnWidth: 100
                            currentSortColumn: headerRow.sortColumn
                            sortAscending: headerRow.sortAscending
                            onSortClicked: function(key) {
                                headerRow.toggleSort(key)
                            }
                        }
                    }
                }

                // Список деталей
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            model: details

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "#2e2e2e"
                                radius: 5

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    spacing: 10

                                    TextButton {
                                        buttonText: {
                                            switch (modelData.status) {
                                                case "pending": return "Распределить"
                                                case "in_production": return "Распределить"
                                                case "sorting": return "Распределить"
                                                case "completed": return "Отменить"
                                                case "canceled": return "-"
                                                default: {
                                                    console.error("Unknown type of modelData.status=", modelData.status)
                                                    return "undefined"
                                                }
                                            }
                                        }
                                        isDisabled: modelData.status === "canceled"
                                        onClickedHandler: function() {
                                            // Действие с деталью
                                        }
                                    }

                                    // Иконка информации
                                    IconButton {
                                        iconSource: "qrc:/resources/icons/info-circle.svg"
                                        buttonWidth: 30
                                        buttonHeight: 30
                                        iconSize: 20
                                        onClickedHandler: function() {
                                            Backend.router.route = "/detailWindow"
                                        }

                                        background: Rectangle {
                                            color: "#3e3e3e"
                                            radius: 4
                                        }
                                    }

                                    // Тип
                                    TableCell {
                                        cellText: modelData.type?.name || "-"
                                        cellWidth: 80
                                        textLeftPadding: 5
                                    }

                                    // Номер
                                    TableCell {
                                        cellText: modelData.serial_number || "-"
                                        cellWidth: 120
                                        textLeftPadding: 5
                                    }

                                    // Партия
                                    TableCell {
                                        cellText: modelData.batch_number || "-"
                                        cellWidth: 100
                                        textLeftPadding: -5
                                    }

                                    // Статус
                                    TableCell {
                                        cellText: {
                                            switch (modelData.status) {
                                                case "pending": return "Обрабатывается"
                                                case "in_production": return "В производстве"
                                                case "sorting": return "Сортировка"
                                                case "completed": return "Отсортирован"
                                                case "canceled": return "Отменён"
                                                default: return "—"
                                            }
                                        }
                                        cellWidth: 100
                                        textLeftPadding: -1
                                    }

                                    // Заказ
                                    TableCell {
                                        cellText: modelData.order?.name || "-"
                                        cellWidth: 120
                                        textLeftPadding: -1
                                    }

                                    // Склад
                                    TableCell {
                                        cellText: modelData.warehouse?.address
                                                 ? qsTr("%1,%2...").arg(modelData.warehouse.address.street)
                                                                   .arg(modelData.warehouse.address.building)
                                                 : "-"
                                        cellWidth: 145
                                        textLeftPadding: -5
                                    }

                                    // Дата
                                    TableCell {
                                        cellText: modelData.manufacture_date || "-"
                                        cellWidth: 100
                                        textLeftPadding: -2
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
