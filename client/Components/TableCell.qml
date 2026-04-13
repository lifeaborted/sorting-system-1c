import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Text {
    id: root

    // Настраиваемые свойства
    property string cellText: ""
    property int cellWidth: 100
    property int textLeftPadding: 5
    property bool enableElide: true

    // Связываем свойства
    text: root.cellText
    Layout.preferredWidth: root.cellWidth
    color: "#B2B4BC"
    font.pixelSize: 12
    font.family: "Roboto"
    font.weight: 400
    elide: root.enableElide ? Text.ElideRight : Text.ElideNone
    leftPadding: root.textLeftPadding
    verticalAlignment: Text.AlignVCenter
}