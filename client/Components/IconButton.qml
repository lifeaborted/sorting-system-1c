import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    id: root

    // Настраиваемые свойства
    property string iconSource: "qrc:/resources/icons/pencil.svg"
    property int buttonWidth: 30
    property int buttonHeight: 30
    property int iconSize: 16
    property bool isDisabled: false
    property var onClickedHandler: null

    Layout.preferredWidth: buttonWidth
    Layout.preferredHeight: buttonHeight
    enabled: !isDisabled

    // Иконка кнопки
    contentItem: Item {
        width: parent.width
        height: parent.height

        Image {
            anchors.centerIn: parent
            source: root.iconSource
            width: root.iconSize
            height: root.iconSize
            fillMode: Image.PreserveAspectFit
            opacity: root.enabled ? (root.pressed ? 0.7 : 1.0) : 0.5
        }
    }

    // Фон кнопки
    background: Rectangle {
        color: {
            if (!root.enabled) return "#E6E8E9"
            if (root.pressed) return "#C8CACC"
            return "#E6E8E9"
        }
        radius: 5
    }

    // Курсор при наведении
    HoverHandler {
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    // Обработчик клика
    onClicked: {
        if (onClickedHandler)
            onClickedHandler()
    }
}