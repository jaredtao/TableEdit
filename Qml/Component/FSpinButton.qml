import QtQuick 2.0
import QtQuick.Controls 2.1
Rectangle {
    id: root
    implicitWidth: 120
    implicitHeight: 30
    property alias backImageSource: hoverButton.backImageSource
    property alias frontImageSource: hoverButton.frontImageSource
    property alias tipText: hoverButton.tipText

    signal trigger(int count);
    border.width: hoverButton.containMouse ? 1 : 0
    border.color: "#00A7FF"
    color: "transparent"

    SpinBox {
        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: 3
            bottomMargin: 3
            left: parent.left
            leftMargin: 3
            right: hoverButton.left
        }
        id: control
        from: 1
        to: 1024
        value: 5
        editable: true
        contentItem: Rectangle{
            implicitWidth: 30
            height: control.height
            color: "transparent"
            TextInput {
                z: 2
                anchors.fill: parent
                text: control.textFromValue(control.value, control.locale)
                font: control.font
                color: "#313131"
                selectionColor: "#4283aa"
                selectedTextColor: "#ffffff"
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter

                readOnly: !control.editable
                validator: control.validator
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }
        }

        up.indicator: Rectangle {
            x: control.mirrored ? 0 : parent.width - width
            height: control.height
            implicitWidth: height
            color: "transparent"
            border.color: "#b8b9bc"
            border.width: 3
            radius: 5
            Text {
                text: "+"
                font.pixelSize: control.font.pixelSize * 2
                color: "#b8b9bc"
                anchors.fill: parent
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        down.indicator: Rectangle {
            x: control.mirrored ? parent.width - width : 0
            height: control.height
            implicitWidth: height
            color: "transparent"
            border.color: "#b8b9bc"
            border.width: 3
            radius: 5
            Text {
                text: "-"
                font.pixelSize: control.font.pixelSize * 2
                color: "#b8b9bc"
                anchors.fill: parent
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        background: Rectangle {
            color: "#f1f4f9"
        }
    }
    FHoverButton {
        id: hoverButton
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        onClicked: root.trigger(control.value)
    }

}
