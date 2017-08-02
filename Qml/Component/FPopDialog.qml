import QtQuick 2.7
import QtQuick.Controls 2.0

Popup {
    id: root
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    implicitWidth: 300
    implicitHeight: 200
    property alias title: titleText.text
    property alias text: contentText.text
    property alias okButtonText: okButton.text
    property alias cancleButtonText: cancleButton.text
    property bool cancleButtonVisible: true
    property var okClickFunc: function() {root.close()}
    property var cancleClickFunc: function() {root.close()}
    contentItem: Item {
        Rectangle {
            id: titleRect
            height: 30
            width: parent.width
            radius: 2
            color: "#09556c"
            Text {
                id: titleText
                anchors.centerIn: parent
            }
        }
        Rectangle {
            height: 1
            width: parent.width
            y: titleRect.height + 5
            color: "black"
        }
        Text {
            id: contentText
            anchors.centerIn: parent
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            spacing: 10
            FColorButton {
                id: okButton
                text: "确定"
                onClicked: {
                    root.okClickFunc()
                }
            }
            FColorButton {
                id: cancleButton
                text: "取消"
                visible: root.cancleButtonVisible
                onClicked: {
                    root.cancleClickFunc()
                }
            }
        }
    }
    background: Rectangle {
        color: "#09556c"
    }
}
