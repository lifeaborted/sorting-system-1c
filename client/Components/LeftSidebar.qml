import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0

// Левая боковая панель
Rectangle {
    Layout.preferredWidth: 250
    Layout.fillHeight: true
    color: "#1e1e1e"

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 60
        spacing: 5

        // Детали
        LeftSidebarTab {
            tabText: "Детали"
            iconSource: "qrc:/resources/icons/clipboard.svg"
            isSelected: Backend.router.route == "/details"
            onClicked: {
                Backend.router.route = "/details"
            }
        }
        // Заказы
        LeftSidebarTab {
            tabText: "Заказы"
            iconSource: "qrc:/resources/icons/tag.svg"
            isSelected: Backend.router.route == "/orders"
            onClicked: {
                Backend.router.route = "/orders"
            }
        }
    }
}
