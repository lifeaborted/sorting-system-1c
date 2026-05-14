import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import io.backend 1.0

Item {
    id: root
    width: 32
    height: 32

    property string iconSource: "qrc:/resources/icons/language.svg"
    property color triggerColor: "#D9D9D9"
    property color triggerHoverColor: "#C8C8C8"
    property int triggerWidth: 32
    property int triggerHeight: 32
    property int triggerRadius: 20
    property bool dropdownOpen: languagePopup.visible
    property list<string> languages: Backend.translator.language_list()
    property int currentIndex: languages.indexOf(Backend.translator.current_language())

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
        width: root.triggerWidth
        height: root.triggerHeight
        radius: root.triggerRadius
        color: triggerArea.containsMouse ? root.triggerHoverColor : root.triggerColor

        Behavior on color { ColorAnimation { duration: 120 } }

        Image {
            anchors.centerIn: parent
            source: root.iconSource
            width: 16
            height: 16
            fillMode: Image.PreserveAspectFit
        }

        MouseArea {
            id: triggerArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: languagePopup.open()
        }
    }

    Popup {
        id: languagePopup
        parent: Overlay.overlay
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0
        clip: false
        width: 100
        height: listView.contentHeight + 12

        onOpened: {
            var globalPos = triggerBtn.mapToItem(Overlay.overlay, 0, triggerBtn.height)
            x = globalPos.x - 68
            y = globalPos.y + 8
        }

        background: Item {
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
                anchors.fill: parent
                radius: 10
                color: "#D9D9D9"
            }
        }

        contentItem: ListView {
            id: listView
            clip: false
            model: root.languages
            interactive: false
            spacing: 0
            height: contentHeight

            delegate: Item {
                width: ListView.view.width
                height: 24

                readonly property var meta: root.metaFor(modelData)
                readonly property bool isCurrent: index === root.currentIndex

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "#C8C8C8"
                    opacity: itemArea.containsMouse ? 1.0 : 0.0
                }

                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
                        rightMargin: 10
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
                        languagePopup.close()
                    }
                }
            }
        }
    }
}