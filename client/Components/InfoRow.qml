import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0

RowLayout {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 36
    Layout.alignment: Qt.AlignVCenter
    spacing: 12

    // Настраиваемые свойства
    property string iconSource: ""
    property string labelText: ""
    property int iconSize: 20
    property color textColor: "#E6E8E9"
    property int textPixelSize: 14
    property string textFontFamily: "Roboto"

    Image {
        source: root.iconSource
        Layout.preferredWidth: root.iconSize
        Layout.preferredHeight: root.iconSize
        fillMode: Image.PreserveAspectFit
    }

    Text {
        text: root.labelText
        color: root.textColor
        font.pixelSize: root.textPixelSize
        font.family: root.textFontFamily
        verticalAlignment: Text.AlignVCenter
    }
}