import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import io.backend 1.0

Item {
    id: root
    width: 32
    height: 32

    property list<string> languages: Backend.translator.language_list()
    property int currentIndex: languages.indexOf(Backend.translator.current_language())
    property var rootWindow: Window.window

    readonly property var languageMeta: ({
        "ru": { code: "RU", native: "Русский"    },
        "en": { code: "EN", native: "English"    },
        "zn": { code: "CN", native: "中文"        },
        "es": { code: "ES", native: "Español"    },
        "de": { code: "DE", native: "Deutsch"    },
        "fr": { code: "FR", native: "Français"   },
        "pt": { code: "PT", native: "Português"  },
        "ar": { code: "AR", native: "العربية"    },
        "hi": { code: "HI", native: "हिन्दी"      }
    })

    function metaFor(lang) {
        return languageMeta[lang] ?? { code: lang.substring(0, 2).toUpperCase(), native: lang }
    }

    // Кнопка-триггер
    Rectangle {
        id: triggerBtn
        width: 32
        height: 32
        radius: 20
        color: triggerArea.containsMouse ? "#C8C8C8" : "#D9D9D9"

        Behavior on color { ColorAnimation { duration: 120 } }

        Image {
            anchors.centerIn: parent
            source: "qrc:/resources/icons/language.svg"
            width: 16
            height: 16
            fillMode: Image.PreserveAspectFit
        }

        MouseArea {
            id: triggerArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: dropdownWrapper.visible = !dropdownWrapper.visible
        }
    }

    // Обёртка для тени
    Item {
        id: dropdownWrapper
        visible: false
        width: 100
        height: listView.contentHeight + 12
        anchors.top: triggerBtn.bottom
        anchors.topMargin: 8
        anchors.right: triggerBtn.right

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 20
            samples: 41
            spread: 0.01
            color: "#40000000"
            transparentBorder: true
        }

        Rectangle {
            id: dropdown
            anchors.fill: parent
            radius: 10
            color: "#D9D9D9"

            ListView {
                id: listView
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 8
                    leftMargin: 6
                    rightMargin: 10
                    bottomMargin: 4
                }
                height: contentHeight
                clip: false
                model: root.languages
                interactive: false
                spacing: 0

                delegate: Item {
                    width: listView.width
                    height: 24

                    readonly property var meta: root.metaFor(modelData)
                    readonly property bool isCurrent: index === root.currentIndex

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: "#C8C8C8"
                        opacity: itemArea.containsMouse ? 1.0 : 0.0
                    }

                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 4
                            rightMargin: 4
                        }
                        spacing: 6

                        Text {
                            text: meta.code
                            font.family: "Roboto"
                            font.pixelSize: 8
                            font.weight: 800
                            color: "#28282A"
                            Layout.preferredWidth: 10
                        }

                        Text {
                            text: meta.native
                            font.family: "Roboto"
                            font.pixelSize: 10
                            font.weight: 500
                            color: "#28282A"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: isCurrent
                            text: "✓"
                            font.family: "Roboto"
                            font.pixelSize: 10
                            font.weight: 500
                            color: "#28282A"
                        }
                    }

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.currentIndex = index
                            Backend.translator.translate(modelData)
                            dropdownWrapper.visible = false
                        }
                    }
                }
            }
        }
    }

    // Клик вне дропдауна — закрыть
    MouseArea {
        z: -1
        enabled: dropdownWrapper.visible
        width: root.rootWindow ? root.rootWindow.width : 0
        height: root.rootWindow ? root.rootWindow.height : 0
        x: -root.mapToItem(null, 0, 0).x
        y: -root.mapToItem(null, 0, 0).y
        onClicked: dropdownWrapper.visible = false
    }
}