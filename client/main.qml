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

    NavButtons{
        z:999
        onDragAreaPressed: window.startSystemMove()
    }
    NavRouter {
        id: router
        defaultPath: "/login"
        pages: [
            Page {
                path: "/"
                page:  Component {
                    Text {
                        text: "test"
                    }
                }
            },
            Page {
                path: "/login"
                page: Component {
                    Login {}
                }
            },
            Page {
                path: "/details"
                page: Component {
                    Details {}
                }
            },
            Page{
                path: "/orders"
                page: Component {
                    Orders {}
                }
            },
            Page{
                path: "/detailWindow"
                page: Component {
                    DetailWindow {}
                }
            }

        ]
        notFound:  Text {
            text: "not found"
        }
    }
}
