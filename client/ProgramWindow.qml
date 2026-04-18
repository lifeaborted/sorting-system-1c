// НЕ УДАЛЯТЬ!!!! ВИНДЕ НАДО!!
import QtQuick.Controls.Fusion
import QtQuick 2.9
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 6.11
import io.backend 1.0
import "Pages"
import "Components"

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: qsTr("sorting system 1c")
    flags: Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.Window
    property Page page
    property var routeData
    NavButtons{
        z:999
        onDragAreaPressed: window.startSystemMove()
    }
    Component.onCompleted: {
        if (page) {
            let data = {}
            if (page.useRouterData) {
                data["routeData"] = routeData
            }
            if (page.useWindow) {
                data["window"] = window
            }

            page.page.createObject(window, data)
        }
    }
}
