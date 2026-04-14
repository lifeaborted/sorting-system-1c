import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.preferredWidth: 120
    Layout.preferredHeight: 50
    spacing: 5

    // Настраиваемые свойства
    property string filterLabel: "Фильтр"
    property var filterModel: ["Все"]
    default property string selectedValue: "Все"
    property var onValueSelected: null  // Функция-колбэк: function(value)

    // Заголовок фильтра
    Text {
        text: qsTr(root.filterLabel)
        color: "#B2B4BC"
        font.pixelSize: 12
        font.weight: 400
        font.family: "Roboto"
        leftPadding: 5
        bottomPadding: -5
    }

    // Выпадающий список
    ComboBox {
        id: comboBox
        Layout.preferredWidth: 120
        Layout.preferredHeight: 30
        model: root.filterModel
        currentIndex: root.filterModel.indexOf(root.selectedValue) >= 0
                     ? root.filterModel.indexOf(root.selectedValue)
                     : 0

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
            width: 120
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
            // This breaks qml bindings, update should be made only from parent
            // root.selectedValue = currentValue
            if (root.onValueSelected)
                root.onValueSelected(currentValue)
        }
    }
}
