import QtQuick 2.9
import io.router 1.0
import QtQuick.Controls 2.15
Item {
    anchors.fill: parent
    id: root
    required property list<Page> pages
    required property Item notFound
    required property string defaultPath
    Component.onCompleted: {
        Router.route = defaultPath
    }

    Connections {
        target: Router
        function onRouteChanged() {
            notFound.parent = null
            var item = null
            for (const p of root.pages) {
                p.page.parent = null
                if (p.path === Router.route) {
                    item = p
                }
            }
            if (item != null) {
                item.page.parent = root
            } else {
                notFound.parent = root
            }
        }
    }
}
