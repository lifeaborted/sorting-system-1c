import QtQuick 2.15
import io.backend 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 6.11
import QtQuick.Window 2.15

Item {
    width: 1280
    height: 720
    // Layout.fillWidth: true
    // Layout.fillHeight: true
    id: root
    required property list<Page> pages
    required property Item notFound
    required property string defaultPath

    Component.onCompleted: {
        Backend.router.route = defaultPath
    }

    Connections {
        target: Backend.router
        function onRouteChanged() {
            notFound.parent = null
            var item = null
            for (const p of root.pages) {
                // p.page.parent = null
                if (p.path === Backend.router.route) {
                    item = p
                }
            }
            if (item != null) {
                loader.sourceComponent = item.page
            } else {
                notFound.parent = root
            }
        }

        function onPopupRequested(data) {
            let route = data["route"]
            let routeData = data["data"]
            var item = null
            for (const p of root.pages) {
                if (p.path === route) {
                    item = p
                }
            }
            if (item != null) {
                var comp = Qt.createComponent("../ProgramWindow.qml");
                let win = comp.createObject(root, {page: item, routeData})

            } else {
                console.error("Not found route=",route, ".Not showing popup")
            }
        }
    }


    Loader {
        anchors.fill: parent
        id: loader
    }
}
