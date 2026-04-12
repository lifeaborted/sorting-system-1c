import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import io.backend 1.0
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

        // Левая боковая панель
        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: "#1e1e1e"

            Column {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 60
                spacing: 5

                // Детали
                Rectangle {
                    id: detailsButton
                    width: 220
                    height: 50
                    color: "#46464A"
                    radius: 5
                    anchors.horizontalCenter: parent.horizontalCenter

                    RowLayout {
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Image {
                            source: "qrc:/resources/icons/clipboard.svg"
                            width: 24
                            height: 24
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            id: detailsText
                            text: qsTr("Детали")
                            color: "white"
                            font.pixelSize: 14
                            font.family: "Roboto"
                            font.weight: 300
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            detailsButton.color = "#46464A"
                            ordersButton.color = "transparent"
                            detailsText.color = "white"
                            ordersText.color = "#aaaaaa"

                            // Далее логика переключения на страницу "Детали"
                        }
                    }
                }

                // Заказы
                Rectangle {
                    id: ordersButton
                    width: 220
                    height: 50
                    color: "transparent"
                    radius: 5
                    anchors.horizontalCenter: parent.horizontalCenter

                    RowLayout {
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Image {
                            id: ordersIcon
                            source: "qrc:/resources/icons/tag.svg"
                            width: 24
                            height: 24
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            id: ordersText
                            text: qsTr("Заказы")
                            color: "#aaaaaa"
                            font.pixelSize: 14
                            font.family: "Roboto"
                            font.weight: 300
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            ordersButton.color = "#46464A"
                            detailsButton.color = "transparent"
                            ordersText.color = "white"
                            detailsText.color = "#aaaaaa"

                            // Далее логика переключения на страницу "Заказы"
                        }
                    }
                }
            }
        }

        // Основная часть
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#2e2e2e"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Верхняя панель с поиском и профилем
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    // Поиск
                    Rectangle {
                        Layout.preferredWidth: 780
                        Layout.preferredHeight: 50
                        color: "#3E3E42"
                        radius: 5

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15

                            Image {
                                source: "qrc:/resources/icons/search.svg"
                                width: 24
                                height: 24
                                fillMode: Image.PreserveAspectFit
                            }

                            TextField {
                                id: searchField
                                Layout.fillWidth: true
                                placeholderText: qsTr("Поиск...")
                                color: "#B2B4BC"
                                font.pixelSize: 14
                                font.weight: 400
                                font.family: "Roboto"
                                placeholderTextColor: activeFocus || text.length > 0 ? "transparent" : "#B2B4BC"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10

                                background: Rectangle {
                                    color: "transparent"
                                }
                            }
                        }
                    }

                    // Профиль пользователя
                    Rectangle {
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 50
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.rightMargin: 10
                            spacing: 10

                            // Аватарка
                            Rectangle {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                radius: 24
                                color: "#3e3e42"

                                Image {
                                    anchors.centerIn: parent
                                    source: "qrc:/resources/icons/profile-picture.svg"
                                    width: 24
                                    height: 24
                                    fillMode: Image.PreserveAspectFit
                                }
                            }

                            // Имя пользователя
                            Text {
                                text: Backend.user.format_username("{first} {second[0]}.{middle[0]}.")
                                color: "#B2B4BC"
                                font.pixelSize: 16
                                font.weight: 500
                                font.family: "Roboto"
                                elide: Text.ElideRight
                            }

                            // Треугольник
                            Image {
                                source: "qrc:/resources/icons/profile-triangle.svg"
                                width: 16
                                height: 12
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                    }
                }

                // Фильтры
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    // Тип детали
                    ColumnLayout {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50

                        Text {
                            text: qsTr("Тип детали")
                            color: "#B2B4BC"
                            font.pixelSize: 12
                            font.weight: 400
                            font.family: "Roboto"
                            leftPadding: 5
                            bottomPadding: -5
                        }

                        ComboBox {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 30
                            model: ["Все"].concat(Object.keys(detailsFilter.detail_type))
                            currentIndex: 0

                            contentItem: Text {
                                text: parent.displayText
                                color: "#B2B4BC"
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                                implicitHeight: 30
                            }

                            popup.background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                            }

                            indicator: Image {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 7
                                source: "qrc:/resources/icons/list-triangle.svg"
                                width: 7
                                height: 6
                                fillMode: Image.PreserveAspectFit
                            }

                            delegate: ItemDelegate {
                                width: parent.width
                                height: 30

                                contentItem: Text {
                                    text: modelData
                                    color: "#B2B4BC"
                                    font.pixelSize: 12
                                    font.family: "Roboto"
                                    font.weight: 400
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.hovered ? "#46464A" : "#3E3E42"
                                    radius: 3
                                }
                            }

                            onActivated: {
                                sortingParams.type = currentValue
                                loadDetails()
                            }
                        }
                    }

                    // Партия
                    ColumnLayout {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        spacing: 5

                        Text {
                            text: qsTr("Партия")
                            color: "#B2B4BC"
                            font.pixelSize: 12
                            font.weight: 400
                            font.family: "Roboto"
                            leftPadding: 5
                            bottomPadding: -5
                        }

                        ComboBox {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 30
                            model: ["Все"].concat(Object.keys(detailsFilter.batch))
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "#B2B4BC"
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                                implicitHeight: 30
                            }

                            popup.background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                            }

                            indicator: Image {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 7
                                source: "qrc:/resources/icons/list-triangle.svg"
                                width: 7
                                height: 6
                                fillMode: Image.PreserveAspectFit
                            }

                            delegate: ItemDelegate {
                                width: parent.width
                                contentItem: Text {
                                    text: modelData
                                    color: "#B2B4BC"
                                    font.pixelSize: 12
                                    font.family: "Roboto"
                                    font.weight: 400
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.hovered ? "#46464A" : "#3E3E42"
                                    radius: 3
                                }
                            }

                            onActivated: {
                                sortingParams.batch = currentValue
                                loadDetails()
                            }
                        }
                    }

                    // Статус
                    ColumnLayout {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        spacing: 5

                        Text {
                            text: qsTr("Статус")
                            color: "#B2B4BC"
                            font.pixelSize: 12
                            font.weight: 400
                            font.family: "Roboto"
                            leftPadding: 5
                            bottomPadding: -5
                        }

                        ComboBox {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 30
                            model: ["Все"].concat(Object.keys(detailsFilter.status))
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "#B2B4BC"
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                                implicitHeight: 30
                            }

                            popup.background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                            }

                            indicator: Image {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 7
                                source: "qrc:/resources/icons/list-triangle.svg"
                                width: 7
                                height: 6
                                fillMode: Image.PreserveAspectFit
                            }

                            delegate: ItemDelegate {
                                width: parent.width
                                contentItem: Text {
                                    text: modelData
                                    color: "#B2B4BC"
                                    font.pixelSize: 12
                                    font.family: "Roboto"
                                    font.weight: 400
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.hovered ? "#46464A" : "#3E3E42"
                                    radius: 3
                                }
                            }

                            onActivated: {
                                sortingParams.status = currentValue
                                loadDetails()
                            }
                        }
                    }

                    // Заказ
                    ColumnLayout {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        spacing: 5

                        Text {
                            text: qsTr("Заказ")
                            color: "#B2B4BC"
                            font.pixelSize: 12
                            font.weight: 400
                            font.family: "Roboto"
                            leftPadding: 5
                            bottomPadding: -5
                        }

                        ComboBox {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 30
                            model: ["Все"].concat(Object.keys(detailsFilter.order))
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "#B2B4BC"
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                                implicitHeight: 30
                            }

                            popup.background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                            }

                            indicator: Image {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 7
                                source: "qrc:/resources/icons/list-triangle.svg"
                                width: 7
                                height: 6
                                fillMode: Image.PreserveAspectFit
                            }

                            delegate: ItemDelegate {
                                width: 120 // высыпает ошибку (TypeError: Cannot read property 'width' of null) при width: parent.width
                                contentItem: Text {
                                    text: modelData
                                    color: "#B2B4BC"
                                    font.pixelSize: 12
                                    font.family: "Roboto"
                                    font.weight: 400
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.hovered ? "#46464A" : "#3E3E42"
                                    radius: 3
                                }
                            }

                            onActivated: {
                                sortingParams.order = currentValue
                                loadDetails()
                            }
                        }
                    }

                    // Склад
                    ColumnLayout {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 50
                        spacing: 5

                        Text {
                            text: qsTr("Склад")
                            color: "#B2B4BC"
                            font.pixelSize: 12
                            font.weight: 400
                            font.family: "Roboto"
                            leftPadding: 5
                            bottomPadding: -5
                        }

                        ComboBox {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 30
                            model: ["Все"].concat(Object.keys(detailsFilter.warehouse))
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "#B2B4BC"
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }

                            background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                                implicitHeight: 30
                            }

                            popup.background: Rectangle {
                                color: "#3E3E42"
                                radius: 5
                            }

                            indicator: Image {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 7
                                source: "qrc:/resources/icons/list-triangle.svg"
                                width: 7
                                height: 6
                                fillMode: Image.PreserveAspectFit
                            }

                            delegate: ItemDelegate {
                                width: parent.width
                                contentItem: Text {
                                    text: modelData
                                    color: "#B2B4BC"
                                    font.pixelSize: 12
                                    font.family: "Roboto"
                                    font.weight: 400
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.hovered ? "#46464A" : "#3E3E42"
                                    radius: 3
                                }
                            }

                            onActivated: {
                                sortingParams.warehouse = currentValue
                                loadDetails()
                            }
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

                        Button {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40
                            text: "Сбросить"

                            contentItem: Text {
                                text: parent.text
                                color: parent.pressed ? "#505050" : "#181819"
                                font.pixelSize: 12
                                font.weight: 500
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.pressed ? "#C8CACC" : "#E6E8E9"
                                radius: 5
                            }

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }

                            onClicked: {
                                // Сброс всех фильтров
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
                    property string sortColumn: "date"  // По умолчанию сортировка по дате
                    property bool sortAscending: false  // false = по убыванию (новые сверху)

                    // Функция сортировки массива деталей
                    function sortDetailsList() {
                        if (!details || details.length === 0) return

                        // Создаем копию массива и сортируем
                        var sorted = JSON.parse(JSON.stringify(details))

                        sorted.sort(function(a, b) {
                            var valA, valB

                            // Получаем значения для сравнения в зависимости от колонки
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

                            // Сравнение
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
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.fillHeight: true
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 4

                                Text {
                                    text: qsTr("Тип")
                                    color: "#B2B4BC"
                                    font.pixelSize: 14
                                    font.weight: 400
                                    font.family: "Roboto"
                                    leftPadding: -10
                                }

                                Image {
                                    source: "qrc:/resources/icons/list-triangle.svg"
                                    width: 12
                                    height: 12
                                    fillMode: Image.PreserveAspectFit
                                    visible: headerRow.sortColumn === "type"
                                    rotation: headerRow.sortColumn === "type" ? (headerRow.sortAscending ? 180 : 0) : 0
                                    Behavior on rotation {
                                        NumberAnimation { duration: 0 }
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    headerRow.toggleSort("type")
                                }
                            }
                        }

                        // Номер
                        Rectangle {
                            Layout.preferredWidth: 120
                            Layout.fillHeight: true
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 4

                                Text {
                                    text: qsTr("Номер")
                                    color: "#B2B4BC"
                                    font.pixelSize: 14
                                    font.weight: 400
                                    font.family: "Roboto"
                                }

                                Image {
                                    source: "qrc:/resources/icons/list-triangle.svg"
                                    width: 12
                                    height: 12
                                    fillMode: Image.PreserveAspectFit
                                    visible: headerRow.sortColumn === "number"
                                    rotation: headerRow.sortColumn === "number" ? (headerRow.sortAscending ? 180 : 0) : 0
                                    Behavior on rotation {
                                        NumberAnimation { duration: 0 }
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    headerRow.toggleSort("number")
                                }
                            }
                        }

                        // Партия
                        Rectangle {
                            Layout.preferredWidth: 115
                            Layout.fillHeight: true
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 4

                                Text {
                                    text: qsTr("Партия")
                                    color: "#B2B4BC"
                                    font.pixelSize: 14
                                    font.weight: 400
                                    font.family: "Roboto"
                                }

                                Image {
                                    source: "qrc:/resources/icons/list-triangle.svg"
                                    width: 12
                                    height: 12
                                    fillMode: Image.PreserveAspectFit
                                    visible: headerRow.sortColumn === "batch"
                                    rotation: headerRow.sortColumn === "batch" ? (headerRow.sortAscending ? 180 : 0) : 0
                                    Behavior on rotation {
                                        NumberAnimation { duration: 0 }
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    headerRow.toggleSort("batch")
                                }
                            }
                        }

                        // Статус
                        Rectangle {
                            Layout.preferredWidth: 110
                            Layout.fillHeight: true
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 4

                                Text {
                                    text: qsTr("Статус")
                                    color: "#B2B4BC"
                                    font.pixelSize: 14
                                    font.weight: 400
                                    font.family: "Roboto"
                                }

                                Image {
                                    source: "qrc:/resources/icons/list-triangle.svg"
                                    width: 12
                                    height: 12
                                    fillMode: Image.PreserveAspectFit
                                    visible: headerRow.sortColumn === "status"
                                    rotation: headerRow.sortColumn === "status" ? (headerRow.sortAscending ? 180 : 0) : 0
                                    Behavior on rotation {
                                        NumberAnimation { duration: 0 }
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    headerRow.toggleSort("status")
                                }
                            }
                        }

                        // Заказ
                        Rectangle {
                            Layout.preferredWidth: 125
                            Layout.fillHeight: true
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 4

                                Text {
                                    text: qsTr("Заказ")
                                    color: "#B2B4BC"
                                    font.pixelSize: 14
                                    font.weight: 400
                                    font.family: "Roboto"
                                }

                                Image {
                                    source: "qrc:/resources/icons/list-triangle.svg"
                                    width: 12
                                    height: 12
                                    fillMode: Image.PreserveAspectFit
                                    visible: headerRow.sortColumn === "order"
                                    rotation: headerRow.sortColumn === "order" ? (headerRow.sortAscending ? 180 : 0) : 0
                                    Behavior on rotation {
                                        NumberAnimation { duration: 0 }
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    headerRow.toggleSort("order")
                                }
                            }
                        }

                        // Склад
                        Rectangle {
                            Layout.preferredWidth: 160
                            Layout.fillHeight: true
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 4

                                Text {
                                    text: qsTr("Склад")
                                    color: "#B2B4BC"
                                    font.pixelSize: 14
                                    font.weight: 400
                                    font.family: "Roboto"
                                }

                                Image {
                                    source: "qrc:/resources/icons/list-triangle.svg"
                                    width: 12
                                    height: 12
                                    fillMode: Image.PreserveAspectFit
                                    visible: headerRow.sortColumn === "warehouse"
                                    rotation: headerRow.sortColumn === "warehouse" ? (headerRow.sortAscending ? 180 : 0) : 0
                                    Behavior on rotation {
                                        NumberAnimation { duration: 0 }
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    headerRow.toggleSort("warehouse")
                                }
                            }
                        }

                        // Дата
                        Rectangle {
                            Layout.preferredWidth: 100
                            Layout.fillHeight: true
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 4

                                Text {
                                    text: qsTr("Дата")
                                    color: "#B2B4BC"
                                    font.pixelSize: 14
                                    font.weight: 400
                                    font.family: "Roboto"
                                }

                                Image {
                                    source: "qrc:/resources/icons/list-triangle.svg"
                                    width: 12
                                    height: 12
                                    fillMode: Image.PreserveAspectFit
                                    visible: headerRow.sortColumn === "date"
                                    rotation: headerRow.sortColumn === "date" ? (headerRow.sortAscending ? 180 : 0) : 0
                                    Behavior on rotation {
                                        NumberAnimation { duration: 0 }
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    headerRow.toggleSort("date")
                                }
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

                                    Button {
                                        Layout.preferredWidth: 120
                                        Layout.preferredHeight: 40
                                        text: {
                                            switch (modelData.status) {
                                                case "pending": return "Распределить"
                                                case "in_production": return "Распределить"
                                                case "sorting": return "Распределить"
                                                case "completed": return "Отменить"
                                                case "canceled": return "-"
                                                default: {
                                                    console.error("Uknown type of modelData.status=", modelData.status)
                                                    return "undefined"
                                                }
                                            }
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: parent.pressed ? "#505050" : "#181819"
                                            font.pixelSize: 12
                                            font.weight: 500
                                            font.family: "Roboto"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        HoverHandler {
                                            cursorShape: Qt.PointingHandCursor
                                        }

                                        background: Rectangle {
                                            color: parent.pressed ? "#C8CACC" : "#E6E8E9"
                                            radius: 5
                                        }

                                        onClicked: {
                                            // Действие с деталью
                                        }
                                    }

                                    // Иконка информации
                                    Rectangle {
                                        Layout.preferredWidth: 30
                                        Layout.preferredHeight: 30
                                        radius: 4
                                        color: "#3e3e3e"

                                        Image {
                                            anchors.centerIn: parent
                                            source: "qrc:/resources/icons/info-circle.svg"
                                            width: 20
                                            height: 20
                                            fillMode: Image.PreserveAspectFit
                                        }

                                        HoverHandler {
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }

                                    // Тип
                                    Text {
                                        Layout.preferredWidth: 80
                                        text: modelData.type.name
                                        color: "#B2B4BC"
                                        font.pixelSize: 12
                                        font.family: "Roboto"
                                        font.weight: 400
                                        elide: Text.ElideRight
                                        leftPadding: 5
                                    }

                                    // Номер
                                    Text {
                                        Layout.preferredWidth: 120
                                        text: modelData.serial_number
                                        color: "#B2B4BC"
                                        font.pixelSize: 12
                                        font.family: "Roboto"
                                        font.weight: 400
                                        elide: Text.ElideRight
                                        leftPadding: 5
                                    }

                                    // Партия
                                    Text {
                                        Layout.preferredWidth: 100
                                        text: modelData.serial_number
                                        color: "#B2B4BC"
                                        font.pixelSize: 12
                                        font.family: "Roboto"
                                        font.weight: 400
                                        elide: Text.ElideRight
                                        leftPadding: -5
                                    }

                                    // Статус
                                    Text {
                                        Layout.preferredWidth: 100
                                        text: {
                                            switch (modelData.status) {
                                                case "pending": return "Обрабатывается"
                                                case "in_production": return "В производстве"
                                                case "sorting": return "Сортировка"
                                                case "completed": return "Отсортирован"
                                                case "canceled": return "Отменён"
                                                default: {
                                                    console.error("Uknown type of modelData.status=", modelData.status)
                                                    return "undefined"
                                                }
                                            }
                                        }
                                        color: "#B2B4BC"
                                        font.pixelSize: 12
                                        font.family: "Roboto"
                                        font.weight: 400
                                        elide: Text.ElideRight
                                    }

                                    // Заказ
                                    Text {
                                        Layout.preferredWidth: 120
                                        text: modelData.order != undefined ? modelData.order.name : "-"
                                        color: "#B2B4BC"
                                        font.pixelSize: 12
                                        font.family: "Roboto"
                                        font.weight: 400
                                        elide: Text.ElideRight
                                    }

                                    // Склад
                                    Text {
                                        Layout.preferredWidth: 145
                                        text: qsTr("%1,%2...").arg(modelData.warehouse.address.street).arg(modelData.warehouse.address.building)
                                        color: "#B2B4BC"
                                        font.pixelSize: 12
                                        font.family: "Roboto"
                                        font.weight: 400
                                        elide: Text.ElideRight
                                        leftPadding: -5
                                    }

                                    // Дата
                                    Text {
                                        Layout.preferredWidth: 100
                                        text: modelData.manufacture_date
                                        color: "#B2B4BC"
                                        font.pixelSize: 12
                                        font.family: "Roboto"
                                        font.weight: 400
                                        elide: Text.ElideRight
                                        leftPadding: -2
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
