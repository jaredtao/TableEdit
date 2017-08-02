import QtQuick 2.7
import QtQuick.Controls 2.1

Item {
    id: root
    implicitWidth: 40
    implicitHeight: 30

    property alias backImageSource: backImage.source
    property alias frontImageSource: frontImage.source
    property alias tipText: toolTip.text
    property bool isAtAbove: false
    property alias containMouse: mouseArea.containsMouse
    property bool buttonEnabled: true
    signal clicked
    Image {
        id: backImage
        anchors.centerIn: parent
    }
    Image {
        id: frontImage
        anchors.centerIn: parent
        visible: mouseArea.containsMouse && root.buttonEnabled
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            forceActiveFocus();
            root.clicked()
        }
    }

    FToolTip {
        id: toolTip
        tipVisible: mouseArea.containsMouse
        delay: 500
    }
}
