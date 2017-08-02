import QtQuick 2.0
import QtQuick.Controls 2.1

Rectangle {
    id: root
    implicitWidth: 240
    implicitHeight: 30

    property alias backImageSourceOne: tipButtonOne.backImageSource
    property alias frontImageSourceOne: tipButtonOne.frontImageSource
    property alias tipTextOne: tipButtonOne.tipText
    property alias isAtAboveOne: tipButtonOne.isAtAbove

    property alias backImageSourceTwo: tipButtonTwo.backImageSource
    property alias frontImageSourceTwo: tipButtonTwo.frontImageSource
    property alias tipTextTwo: tipButtonTwo.tipText
    property alias isAtAboveTwo: tipButtonTwo.isAtAbove


    property alias hitText: textField.placeholderText
    property var buttonOneClickFuc: function() {}
    property var buttonTwoClickFuc: function() {}
    property int current: 0
    property int count: 0
    signal trigger(string text);

    radius: 4
    color: "transparent"
    TextField {
        id: textField
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 1
        verticalAlignment: Text.AlignVCenter
        selectByMouse: true
        onEditingFinished: {
            if (textField.text)
                root.trigger(textField.text)
        }
        background: Rectangle {
            implicitWidth: root.width
            implicitHeight: root.height
            radius: 4
            color: "transparent"
            border.color: (textinputArea.containsMouse || tipButtonOne.containMouse || tipButtonTwo.containMouse) ? "#0099cc" : "#b8b9ba"
        }
        MouseArea {
            id: textinputArea
            anchors.fill: parent
            hoverEnabled: true

            propagateComposedEvents: true
            onContainsMouseChanged: {
                if (containsMouse) {
                    cursorShape = Qt.IBeamCursor;
                } else {
                    cursorShape = Qt.ArrowCursor;
                }
            }
            onDoubleClicked: mouse.accepted = false;
            onPositionChanged: mouse.accepted = false;
            onPressAndHold: mouse.accepted = false;
            onClicked:mouse.accepted = false;
            onReleased: {
                mouse.accepted = false;
            }
            onPressed: {
                mouse.accepted = false;
            }
        }
    }
    Row {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        Text {
            id: text
            text: current + " of " + count
            visible: textField.text
            anchors.verticalCenter: parent.verticalCenter
        }
        FHoverButton {
            id: tipButtonOne
            onClicked: buttonOneClickFuc()
            width: 30
            height: 30
            implicitWidth: 30
            implicitHeight: 30
            anchors.verticalCenter: parent.verticalCenter
        }
        FHoverButton {
            id: tipButtonTwo
            onClicked: buttonTwoClickFuc()
            width: 30
            height: 30
            implicitWidth: 30
            implicitHeight: 30
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
