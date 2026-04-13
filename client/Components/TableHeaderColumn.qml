import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "transparent"

    // Настраиваемые свойства
    property string columnHeader: "Заголовок"
    property string columnKey: ""
    property string currentSortColumn: ""
    property bool sortAscending: false
    property var onSortClicked: null  // Функция-колбэк: function(columnKey)
    property int columnWidth: 100
    property int textLeftPadding: 0

    // Размеры
    Layout.preferredWidth: columnWidth
    Layout.fillHeight: true

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 4

        Text {
            text: qsTr(root.columnHeader)
            color: "#B2B4BC"
            font.pixelSize: 14
            font.weight: 400
            font.family: "Roboto"
            leftPadding: root.textLeftPadding
        }

        Image {
            source: "qrc:/resources/icons/list-triangle.svg"
            width: 12
            height: 12
            fillMode: Image.PreserveAspectFit
            visible: root.currentSortColumn === root.columnKey
            rotation: root.currentSortColumn === root.columnKey
                     ? (root.sortAscending ? 180 : 0)
                     : 0
            Behavior on rotation {
                NumberAnimation { duration: 0 }
            }
        }

        Item { Layout.fillWidth: true }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.onSortClicked)
                root.onSortClicked(root.columnKey)
        }
    }
}