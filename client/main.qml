import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 6.11
import io.backend 1.0
import "Pages"
import "Components"

ProgramWindow {
    Notificator {
        z:999
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
                    useWindow: true
                    useRouterData: true
                    path: "/detailWindow"
                    page: Component {
                        DetailWindow {}
                    }
                },
                Page{
                    useWindow: true
                    useRouterData: true
                    path: "/detailScanned"
                    page: Component {
                        DetailScanned {}
                    }
                }

            ]
            notFound:  Text {
                text: "not found"
            }
        }
}
