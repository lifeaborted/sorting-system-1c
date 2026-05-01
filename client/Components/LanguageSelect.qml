import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import io.backend 1.0


Item {
    RowLayout {
        Repeater {
            model: Backend.translator.language_list()
            Button {
                required property string modelData
                text: modelData
                onClicked: {
                    Backend.translator.translate(modelData)
                }
            }
        }

    }
}
