import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    id: root

    // Настраиваемые свойства
    property string buttonText: ""
    property int buttonWidth: 120
    property int buttonHeight: 28
    property int fontPixelSize: 12
    property string fontFamily: "Roboto"
    property int fontWeight: 500
    property bool isDisabled: false
    property var onClickedHandler: null

    // Цвета кнопки по-умолчанию
    property color bgColor: "#E6E8E9"
    property color bgColorPressed: "#C8CACC"
    property color bgColorDisabled: "#E6E8E9"
    property color textColor: "#181819"
    property color textColorPressed: "#505050"

    text: buttonText
    Layout.preferredWidth: buttonWidth
    Layout.preferredHeight: buttonHeight
    enabled: !isDisabled

    // Текст кнопки
    contentItem: Text {
        text: root.text
        color: root.enabled ? (root.pressed ? root.textColorPressed : root.textColor) : root.textColor
        font.pixelSize: root.fontPixelSize
        font.weight: root.fontWeight
        font.family: root.fontFamily
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: root.enabled ? 1.0 : 0.5
    }

    // Фон кнопки
    background: Rectangle {
        color: {
            if (!root.enabled) return root.bgColorDisabled
            if (root.pressed) return root.bgColorPressed
            return root.bgColor
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