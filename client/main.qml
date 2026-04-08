import QtQuick 2.9
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import io.router 1.0
import "Pages"
import "Components"
Window {
    width: 1240
    height: 980
    visible: true
    title: qsTr("sorting system 1c")
    flags: Qt.FramelessWindowHint
    NavRouter {
        id: router
        defaultPath: "/login"
        pages: [
            Page {
                path: "/"
                page: Text {
                    text: "test"
                }
            },
            Page {
                path: "/login"
                page: Login {

                }
            }
        ]
        notFound:  Text {
            text: "not found"
        }
    }
}
