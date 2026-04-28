import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0

Text {
    id: root

    // Настраиваемые свойства
    property string infoText: ""
    property int textHeight: 36
    property color textColor: "#B2B4BC"
    property int textPixelSize: 13
    property string textFontFamily: "Roboto"
    property int textFontWeight: 400
    property bool enableWrap: false
    property int maxLineCount: 1
    property bool enableElide: true

    // Связываем свойства с базовыми свойствами Text
    text: root.infoText
    Layout.fillWidth: true
    Layout.preferredHeight: root.textHeight
    Layout.maximumHeight: root.textHeight
    color: root.textColor
    font.pixelSize: root.textPixelSize
    font.family: root.textFontFamily
    font.weight: root.textFontWeight
    verticalAlignment: Text.AlignVCenter
    wrapMode: root.enableWrap ? Text.Wrap : Text.NoWrap
    maximumLineCount: root.maxLineCount
    elide: root.enableElide ? Text.ElideRight : Text.ElideNone
}