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

    property list<var> details: []
    property var detailsFilter

    property QtObject sortingParams: QtObject {
        property string search: ""
        property string type: "Все"
        property string batch: "Все"
        property string status: "Все"
        property string order: "Все"
        property string warehouse: "Все"
        property QtObject date: QtObject {
            property string from: "01.04.2020"
            property string to: "20.04.2027"
        }
    }

    property QtObject sortingProperty: QtObject {
        property string propertyName: "date"
        property bool sortAsc: true

    }

    function toggleSort(columnName) {
        if (sortingProperty.propertyName === columnName) {
            sortingProperty.sortAsc = !sortingProperty.sortAsc
        } else {
            sortingProperty.propertyName = columnName
            sortingProperty.sortAsc = false
        }

        loadDetails()
    }


    function resetParams() {
        sortingProperty = Qt.createQmlObject(`
            import QtQuick
            QtObject {
                property string propertyName: "date"
                property bool sortAsc: true
            }
        `, detailsPage, "sortingProperty")
        sortingParams = Qt.createQmlObject(`
            import QtQuick
                QtObject {
                    property string search: ""
                    property string type: "Все"
                    property string batch: "Все"
                    property string status: "Все"
                    property string order: "Все"
                    property string warehouse: "Все"
                    property QtObject date: QtObject {
                        property string from: "01.04.2020"
                        property string to: "20.04.2027"
                    }
                }
        `, detailsPage, "sortingParams")

    }

    function loadDetails() {
        detailsFilter = Backend.user.load_sorting_options()
        // Биндинг из  controller.detail.py Детали
        // Можно считать, что значения закешированы, и никакой дополнительной нагрузке вызов функции не несёт
        // Детали не надо напрямую редачить
        // и массив тоже не имеет смысла :p
        details = Backend.user.load_details_filter(sortingParams, sortingProperty)
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
                        Layout.preferredWidth: 160
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
                                resetParams()
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

                    Image {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 20
                        source: "qrc:/resources/icons/info-circle-old.svg"
                        width: 20
                        height: 20
                        fillMode: Image.PreserveAspectFit
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 0

                        // Тип
                        TableHeaderColumn {
                            columnHeader: "Тип"
                            columnKey: "type"
                            columnWidth: 135
                            textLeftPadding: 45
                            currentSortColumn: sortingProperty.propertyName
                            sortAscending: sortingProperty.sortAsc
                            onSortClicked: function(key) {
                                toggleSort(key)
                            }
                        }

                        // Номер
                        TableHeaderColumn {
                            columnHeader: "Номер"
                            columnKey: "serial"
                            columnWidth: 120
                            textLeftPadding: -5
                            currentSortColumn: sortingProperty.propertyName
                            sortAscending: sortingProperty.sortAsc
                            onSortClicked: function(key) {
                                toggleSort(key)
                            }
                        }

                        // Партия
                        TableHeaderColumn {
                            columnHeader: "Партия"
                            columnKey: "batch"
                            columnWidth: 100
                            textLeftPadding: 10
                            currentSortColumn: sortingProperty.propertyName
                            sortAscending: sortingProperty.sortAsc
                            onSortClicked: function(key) {
                                toggleSort(key)
                            }
                        }

                        // Статус
                        TableHeaderColumn {
                            columnHeader: "Статус"
                            columnKey: "status"
                            columnWidth: 100
                            textLeftPadding: 28
                            currentSortColumn: sortingProperty.propertyName
                            sortAscending: sortingProperty.sortAsc
                            onSortClicked: function(key) {
                                toggleSort(key)
                            }
                        }

                        // Заказ
                        TableHeaderColumn {
                            columnHeader: "Заказ"
                            columnKey: "order"
                            columnWidth: 120
                            textLeftPadding: 40
                            currentSortColumn: sortingProperty.propertyName
                            sortAscending: sortingProperty.sortAsc
                            onSortClicked: function(key) {
                                toggleSort(key)
                            }
                        }

                        // Склад
                        TableHeaderColumn {
                            columnHeader: "Склад"
                            columnKey: "warehouse"
                            columnWidth: 145
                            textLeftPadding: 33
                            currentSortColumn: sortingProperty.propertyName
                            sortAscending: sortingProperty.sortAsc
                            onSortClicked: function(key) {
                                toggleSort(key)
                            }
                        }

                        // Дата
                        TableHeaderColumn {
                            columnHeader: "Дата"
                            columnKey: "date"
                            columnWidth: 80
                            textLeftPadding: 9
                            currentSortColumn: sortingProperty.propertyName
                            sortAscending: sortingProperty.sortAsc
                            onSortClicked: function(key) {
                                toggleSort(key)
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

                                    // Иконка информации
                                    IconButton {
                                        iconSource: "qrc:/resources/icons/info-circle.svg"
                                        buttonWidth: 30
                                        buttonHeight: 30
                                        iconSize: 20
                                        onClickedHandler: function() {
                                            Backend.router.open_popup_detailed("/detailWindow", {
                                                detailId: modelData.id
                                            })
                                        }

                                        background: Rectangle {
                                            color: "#E6E8E9"
                                            radius: 4
                                        }
                                    }

                                    // Тип
                                    TableCell {
                                        cellText: modelData.type?.name || "-"
                                        cellWidth: 80
                                    }

                                    // Номер
                                    TableCell {
                                        cellText: modelData.serial_number || "-"
                                        cellWidth: 120
                                    }

                                    // Партия
                                    TableCell {
                                        cellText: modelData.batch_number || "-"
                                        cellWidth: 100
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
                                    }

                                    // Заказ
                                    TableCell {
                                        cellText: modelData.order?.name || "-"
                                        cellWidth: 100
                                    }

                                    // Склад
                                    TableCell {
                                        cellText: modelData.warehouse?.address
                                                 ? qsTr("%1,%2...").arg(modelData.warehouse.address.street)
                                                                   .arg(modelData.warehouse.address.building)
                                                 : "-"
                                        cellWidth: 130
                                    }

                                    // Дата
                                    TableCell {
                                        cellText: modelData.manufacture_date || "-"
                                        cellWidth: 50
                                        wrapMode: Text.WordWrap
                                        textLeftPadding: -20
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
