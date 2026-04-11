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
                    RowLayout {
                        spacing: 10

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "#3e3e3e"

                            Text {
                                anchors.centerIn: parent
                                text: Backend.user.format_username("{first[0]}{second[0]}")
                                color: "white"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                            }
                        }

                        Text {
                            text: Backend.user.format_username("{first} {second[0]}.{middle[0]}.")
                            color: "white"
                            font.pixelSize: 14
                        }

                        Text {
                            text: "▼"
                            color: "white"
                            font.pixelSize: 10
                        }
                    }
                }

                // Фильтры
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

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
                            bottomPadding: -8
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

                            // Кастомный индикатор (треугольник)
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
                                    leftPadding: 15
                                }
                                background: Rectangle {
                                    color: parent.pressed ? "#4e4e4e" : "#3e3e3e"
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
                        spacing: 5

                        Text {
                            text: qsTr("Партия")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                            leftPadding: 10
                        }

                        ComboBox {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 35
                            model: ["Все"].concat(Object.keys(detailsFilter.batch))
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }
                            background: Rectangle {
                                color: "#3e3e3e"
                                radius: 5
                                implicitHeight: 35
                            }
                            delegate: ItemDelegate {
                                width: parent.width
                                contentItem: Text {
                                    text: modelData
                                    color: "white"
                                    font.pixelSize: 13
                                    leftPadding: 10
                                }
                                background: Rectangle {
                                    color: parent.pressed ? "#4e4e4e" : "#3e3e3e"
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
                        spacing: 5

                        Text {
                            text: qsTr("Статус")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                            leftPadding: 10
                        }

                        ComboBox {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 35
                            model: ["Все"].concat(Object.keys(detailsFilter.status))
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }
                            background: Rectangle {
                                color: "#3e3e3e"
                                radius: 5
                                implicitHeight: 35
                            }
                            delegate: ItemDelegate {
                                width: parent.width
                                contentItem: Text {
                                    text: modelData
                                    color: "white"
                                    font.pixelSize: 13
                                    leftPadding: 10
                                }
                                background: Rectangle {
                                    color: parent.pressed ? "#4e4e4e" : "#3e3e3e"
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
                        spacing: 5

                        Text {
                            text: qsTr("Заказ")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                            leftPadding: 10
                        }

                        ComboBox {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 35
                            model: ["Все"].concat(Object.keys(detailsFilter.order))
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }
                            background: Rectangle {
                                color: "#3e3e3e"
                                radius: 5
                                implicitHeight: 35
                            }
                            delegate: ItemDelegate {
                                width: parent.width
                                contentItem: Text {
                                    text: modelData
                                    color: "white"
                                    font.pixelSize: 13
                                    leftPadding: 10
                                }
                                background: Rectangle {
                                    color: parent.pressed ? "#4e4e4e" : "#3e3e3e"
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
                        spacing: 5

                        Text {
                            text: qsTr("Склад")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                            leftPadding: 10
                        }

                        ComboBox {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 35
                            model: ["Все"].concat(Object.keys(detailsFilter.warehouse))
                            currentIndex: 0
                            contentItem: Text {
                                text: parent.displayText
                                color: "white"
                                font.pixelSize: 13
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }
                            background: Rectangle {
                                color: "#3e3e3e"
                                radius: 5
                                implicitHeight: 35
                            }
                            delegate: ItemDelegate {
                                width: parent.width
                                contentItem: Text {
                                    text: modelData
                                    color: "white"
                                    font.pixelSize: 13
                                    leftPadding: 10
                                }
                                background: Rectangle {
                                    color: parent.pressed ? "#4e4e4e" : "#3e3e3e"
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
                        spacing: 5

                        Text {
                            text: qsTr("Дата производства")
                            color: "#aaaaaa"
                            font.pixelSize: 11
                            leftPadding: 10
                        }

                        Rectangle {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 35
                            color: "#3e3e3e"
                            radius: 5

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                Text {
                                    text: qsTr("01.01.26 - 01.01.27")
                                    color: "white"
                                    font.pixelSize: 13
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
                }

                // Заголовки таблицы
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "#3e3e3e"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10

                        Text {
                            Layout.preferredWidth: 120
                            text: qsTr("Действие")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 80
                            text: qsTr("Тип")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Номер")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 100
                            text: qsTr("Партия")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 150
                            text: qsTr("Статус")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 100
                            text: qsTr("Заказ")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.fillWidth: true
                            text: qsTr("Склад")
                            color: "#aaaaaa"
                            font.pixelSize: 13
                        }

                        Text {
                            Layout.preferredWidth: 80
                            text: qsTr("Дата")
                            color: "#aaaaaa"
                            font.pixelSize: 13
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
                                            color: "#2e2e2e"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        background: Rectangle {
                                            color: "#f5f5f5"
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
                                    }

                                    // Тип
                                    Text {
                                        Layout.preferredWidth: 80
                                        text: modelData.type.name
                                        color: "white"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }

                                    // Номер
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.serial_number
                                        color: "white"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }

                                    // Партия
                                    Text {
                                        Layout.preferredWidth: 100
                                        text: modelData.serial_number
                                        color: "white"
                                        font.pixelSize: 13
                                    }

                                    // Статус
                                    Text {
                                        Layout.preferredWidth: 150
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

                                        color: "white"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }

                                    // Заказ
                                    Text {
                                        Layout.preferredWidth: 100
                                        text: modelData.order != undefined ? modelData.order.name : "-"
                                        color: "white"
                                        font.pixelSize: 13
                                    }

                                    // Склад
                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("%1,%2...").arg(modelData.warehouse.address.street).arg(modelData.warehouse.address.building)

                                        color: "white"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }

                                    // Дата
                                    Text {
                                        Layout.preferredWidth: 80
                                        text: modelData.manufacture_date
                                        color: "white"
                                        font.pixelSize: 13
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
