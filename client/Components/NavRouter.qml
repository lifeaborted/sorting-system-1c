import QtQuick 2.9
import io.backend 1.0
import QtQuick.Controls 2.15

Item {
    // anchors.fill: parent
    width: 1280
    height: 720
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
    }
    Loader {
        anchors.fill: parent
        id: loader
    }
}
