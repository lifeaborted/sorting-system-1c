import QtQuick 2.15
import QtQuick.Controls 2.15
import io.backend 1.0
import "../Components"

Item {
    id: root
    anchors.fill: parent

    ListModel {
        id: notifModel
    }

    function syncModel() {
        var data = Backend.notificator.visible_notifications

        for (var i = notifModel.count - 1; i >= 0; i--) {
            var found = false
            for (var j = 0; j < data.length; j++) {
                if (notifModel.get(i).uuid === data[j].uuid) {
                    found = true
                    break
                }
            }
            if (!found) notifModel.remove(i)
        }

        for (var j = 0; j < data.length; j++) {
            var exists = false
            for (var i = 0; i < notifModel.count; i++) {
                if (notifModel.get(i).uuid === data[j].uuid) {
                    exists = true
                    break
                }
            }
            if (!exists) notifModel.append(data[j])
        }
    }

    Connections {
        target: Backend.notificator
        function onNotificationChanged() {
            root.syncModel()
        }
    }

    Component.onCompleted: root.syncModel()

    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.rightMargin: 20
        spacing: 10
        width: 250

        Repeater {
            model: notifModel
            delegate: NotificationItem {
                width: 250
                notificationMessage: model.message
                notificationType: {
                    if (model.importance === "success") return "success"
                    else if (model.importance === "warning") return "warning"
                    else if (model.importance === "error") return "error"
                    else return "info"
                }
                closeCallback: function() {
                    Backend.notificator.remove_notification(model.uuid)
                }
            }
        }
    }
}