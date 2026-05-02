import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0


Item {
    anchors.margins: 10
    property list<string> languages: Backend.translator.language_list()

    ComboBox {
        width: 50
        anchors.right: parent.right
        id: combo
        model: languages
        currentIndex: languages.indexOf(Backend.translator.current_language())
        onActivated: function (index) {
            Backend.translator.translate(languages[index])
        }
    }
}
