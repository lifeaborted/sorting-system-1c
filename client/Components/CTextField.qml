import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    property string placeholder
    default property int echo: TextField.Normal
    property alias text: textField.text
    signal valueChanged(text: string)
    spacing: 5
    Layout.fillWidth: true

    Text {
        text: placeholder
        font.pixelSize: 8
        font.weight: 500
        font.family: "Roboto"
        color: "#3E3E42"
    }

    TextField {
        id: textField
        placeholderText: placeholder
        placeholderTextColor: "#B2B4BC"
        Layout.fillWidth: true
        font.pixelSize: 14
        font.weight: 700
        font.family: "Roboto"
        echoMode: echo
        leftPadding: 10
        Layout.preferredHeight: 40
        text: text
        background: Rectangle {
            color: "transparent"
        }
        onTextChanged: valueChanged(text)
    }

    // Нижняя линия
    Rectangle {
        Layout.fillWidth: true
        height: 1.5 // 2 - шире нижней, 1 - уже нижней. 1.5 - оптимальное значение
        color: textField.activeFocus ? "#6e707b" : "#B2B4BC"
    }
}
