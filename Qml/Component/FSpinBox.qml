import QtQuick 2.7
import QtQuick.Controls 2.1

SpinBox {
    id: root
    property int decimals: 0
    property bool pressed: textinputPressed | down.pressed | up.pressed

    property bool textinputPressed: false
    signal editingFinished()

    property bool showNan: false
    property bool boxShow: false
    property alias displayText: textInput.displayText
    validator: DoubleValidator {
        bottom: Math.min(root.from, root.to)
        top:  Math.max(root.from, root.to)
    }

    textFromValue: function(value, locale) {
        if (showNan && value === -1)
            return "";
        else
            return Number(value).toLocaleString(locale, 'f', root.decimals)
    }

    valueFromText: function(text, locale) {
        return Number.fromLocaleString(locale, text)
    }
    editable: true
    contentItem: TextInput {
        id: textInput
        z: 2
        text: root.textFromValue(root.value, root.locale)
        font: root.font
        color: boxShow ? "#ededed" : "#272727"
        selectionColor: "#4283aa"
        selectedTextColor: "#ffffff"
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        selectByMouse: true
        readOnly: !root.editable
        validator: root.validator
        echoMode: TextInput.Normal
        inputMethodHints: Qt.ImhFormattedNumbersOnly

        onEditingFinished: {
            root.editingFinished()
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
                    root.textinputPressed = false;
                }
            }
            onDoubleClicked: mouse.accepted = false;
            onPositionChanged: mouse.accepted = false;
            onPressAndHold: mouse.accepted = false;
            onClicked:mouse.accepted = false;
            onReleased: {
                root.textinputPressed = false;
                root.editingFinished()
                mouse.accepted = false;
            }
            onPressed: {
                root.textinputPressed = true;
                mouse.accepted = false;
            }
        }
    }

    up.indicator: Rectangle {
        x: root.mirrored ? 0 : parent.width - width - 1.5
        y: 1.5
        height: parent.height - 3
        implicitWidth: 30
        implicitHeight: 30
        color: "transparent"
        border.color: enabled ? "#8f5c50" : "#4d4e52"
        Text {
            text: "+"
            font.pixelSize: root.font.pixelSize * 2
            color: boxShow ? "#fffcfc" : "#00a7ff"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: root.mirrored ? parent.width - width : 1.5
        y: 1.5
        height: parent.height - 3
        implicitWidth: 30
        implicitHeight: 30
        color: "transparent"
        border.color: enabled ? "#8f5c50" : "#4d4e52"
        Text {
            text: "-"
            font.pixelSize: root.font.pixelSize * 2
            color: boxShow ? "#fffcfc" : "#00a7ff"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        implicitWidth: 120
        color: "transparent"//"#cecfd3"
    }
    up.onPressedChanged: {
        if (pressed) {
            syncer.restart()
        }
    }
    down.onPressedChanged: {
        if (pressed) {
            syncer.restart()
        }
    }
    Timer {
        id: syncer
        running: false
        repeat: false
        interval: 300
        onTriggered: {
            root.editingFinished()
        }
    }
}
