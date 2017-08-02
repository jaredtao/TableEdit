import QtQuick 2.0

Rectangle {
    id: root
    property alias text: centerText.text
    property alias containsMouse: area.containsMouse
    property alias hoverEnabled: area.hoverEnabled
    signal clicked()

    implicitHeight: 30
    implicitWidth: 80
    color: area.containsMouse ? (area.pressed ? Qt.lighter("#1dc0e3"): "#1dc0e3") : "#179dba"
    radius: 5

    Text {
        id: centerText
        anchors.centerIn: parent
        color: "#ffffff"
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
