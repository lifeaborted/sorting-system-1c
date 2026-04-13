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
    property bool isDisabled: false
    property var onClickedHandler: null  // Функция-колбэк: function()

    text: buttonText
    Layout.preferredWidth: buttonWidth
    Layout.preferredHeight: buttonHeight
    enabled: !isDisabled

    // Текст кнопки
    contentItem: Text {
        text: root.text
        color: root.pressed ? "#505050" : "#181819"
        font.pixelSize: 12
        font.weight: 500
        font.family: "Roboto"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: root.enabled ? 1.0 : 0.5
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