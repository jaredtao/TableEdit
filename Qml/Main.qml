import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import Tools 1.0
import "qrc:/Qml/Component/"
Item {
    id: root
    width: 1340
    height: 780
    property string sourceFileName: ""

    Connections {
        target: TableStatus
        onSourceJsonFilePathChanged: {
            if (sourceJsonFilePath) {
                //先置空，再赋值，保证能多次加载同一个文件
                root.sourceFileName = ""
                root.sourceFileName = sourceJsonFilePath;
            }
        }
    }
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 5
        Label {
            id: mcuVersionLabel
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Mcu版本")
            color: "#272727"
        }

        TextField {
            id: mcuVersionText
            anchors.verticalCenter: parent.verticalCenter

            selectByMouse: true
            background: Rectangle {
                implicitWidth: 100
                height: 26
                radius: 4
                color: "transparent"
                border.color: mcuVersionArea.containsMouse ? "#0099cc" : "#b8b9ba"
            }
            validator:RegExpValidator {
                regExp: /[0-9a-zA-Z.]*/
            }
            onDisplayTextChanged: {
                jsonListModel.mcuVersion = text
                if (isInited)
                    TableStatus.hasSaved = false;
            }
            property bool isInited: false
            MouseArea {
                id: mcuVersionArea
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: {
                    if (containsMouse) {
                        cursorShape = Qt.IBeamCursor;
                    } else {
                        cursorShape = Qt.ArrowCursor;
                    }
                }
                onClicked: {
                    mouse.accepted = false;
                }
                onDoubleClicked: { mouse.accepted = false; }
                onPressAndHold: {
                    mouse.accepted = false;
                }
                onPositionChanged: {
                    mouse.accepted = false;
                }
                onPressed: {
                    mouse.accepted = false;
                }
                onReleased: { mouse.accepted = false; }
            }
        }
        Item {
            height: parent.height
            width: 20
        }
        Label {
            id: heartBeatIntervalLabel
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("心跳帧频率")
            color: "#272727"
        }
        TextField {
            id: heartBeatIntervalText
            anchors.verticalCenter: parent.verticalCenter
            selectByMouse: true
            validator:RegExpValidator {
                regExp: /[0-9]*/
            }
            property bool isInited: false
            onDisplayTextChanged: {
                if (!text || parseInt(text) === 0)
                    text = "1000"
                jsonListModel.heartBeatInterval = parseInt(text)
                if (isInited)
                    TableStatus.hasSaved = false;
            }
            background: Rectangle {
                implicitWidth: 100
                height: 26
                radius: 4
                color: "transparent"
                border.color: heartBeatIntervalArea.containsMouse ? "#0099cc" : "#b8b9ba"
            }
            MouseArea {
                id: heartBeatIntervalArea
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: {
                    if (containsMouse) {
                        cursorShape = Qt.IBeamCursor;
                    } else {
                        cursorShape = Qt.ArrowCursor;
                    }
                }
                onClicked: {
                    mouse.accepted = false;
                }
                onDoubleClicked: { mouse.accepted = false; }
                onPressAndHold: {
                    mouse.accepted = false;
                }
                onPositionChanged: {
                    mouse.accepted = false;
                }
                onPressed: {
                    mouse.accepted = false;
                }
                onReleased: { mouse.accepted = false; }
            }
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("ms")
            color: "#272727"
        }
    }

    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 5
        width: 1340
        spacing: 10
        FHoverButton {
            tipText: qsTr("加载")
            anchors.verticalCenter: parent.verticalCenter
            backImageSource:  "qrc:/Image/Project/import.png"
            frontImageSource: "qrc:/Image/Project/importBlue.png"
            onClicked: {
                forceActiveFocus();
                mcuJsonfileDialog.openFile()
            }
        }

        FHoverButton {
            anchors.verticalCenter: parent.verticalCenter
            tipText: {
                if (root.sourceFileName)
                    return qsTr("保存至" + root.sourceFileName)
                else
                    return qsTr("另存为");
            }
            backImageSource: "qrc:/Image/Project/save.png"
            frontImageSource: "qrc:/Image/Project/saveBlue.png"
            onClicked: {
                forceActiveFocus();
                root.noProjectSave();
            }
        }

        FHoverButton {
            tipText: qsTr("另存为")
            anchors.verticalCenter: parent.verticalCenter
            backImageSource: "qrc:/Image/Project/saveas.png"
            frontImageSource: "qrc:/Image/Project/saveasBlue.png"
            onClicked: {
                forceActiveFocus();
                var err = tabRect.checkData();
                if (err) {
                    root.showMessageBox(err)
                } else {
                    root.saveAs();
                }
            }
        }
        CheckBox {
            id: indentCheckBox
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Indented格式")

            onCheckStateChanged: {
                TableStatus.saveWithIndented = (indentCheckBox.checkState == Qt.Checked)
            }
            Component.onCompleted: checked = TableStatus.saveWithIndented
            indicator: Rectangle {
                id: indicRect
                implicitWidth: 22
                implicitHeight: 22
                radius: 3
                anchors {
                    verticalCenter: indentCheckBox.verticalCenter
                    left: indentCheckBox.left
                    leftMargin: 5
                }
                color: "transparent"
                border.width: 1.2
                border.color: "#363636"
                Rectangle {
                    width: 10
                    height: 10
                    anchors.centerIn: parent
                    color: "#FF5933"
                    visible: indentCheckBox.checked
                }
            }
            contentItem: Text {
                anchors.left: indicRect.right
                anchors.leftMargin: 4
                text: indentCheckBox.text
                font: indentCheckBox.font
                color: "#272727"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        Item {
            height: parent.height
            width: 20
        }
        Item {
            height: parent.height
            width: currentFileText.width + 10
            visible: true
            Text {
                id: currentFileText
                text: qsTr("当前文件 " + root.sourceFileName);
                visible: root.sourceFileName
                anchors.centerIn: parent
                elide: Text.ElideLeft
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    Row {
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            right: parent.right
            rightMargin: 5
        }
        spacing: 10
        FHoverButton {
            id: undoButton
            tipText: qsTr("撤销")
            anchors.verticalCenter: parent.verticalCenter
            backImageSource: "qrc:/Image/Table/undo.png"
            frontImageSource: "qrc:/Image/Table/undoB.png"
            property int count: 0
            buttonEnabled: count > 0
            onClicked: {
                tabRect.undo();
                TableStatus.hasSaved = false;
            }
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                width: 16
                height: width
                radius: width/2
                color: "red"
                visible: undoButton.count > 0
                Text {
                    anchors.centerIn: parent
                    text: undoButton.count
                    color: "white"
                }
            }
        }
        FHoverButton {
            id:redoButton
            tipText: qsTr("恢复")
            anchors.verticalCenter: parent.verticalCenter
            backImageSource: "qrc:/Image/Table/redo.png"
            frontImageSource: "qrc:/Image/Table/redoB.png"
            property int count: 0
            buttonEnabled: count > 0

            onClicked: {
                tabRect.redo();
                TableStatus.hasSaved = false;
            }
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                width: 16
                height: width
                radius: width/2
                color: "red"
                visible: redoButton.count > 0
                Text {
                    anchors.centerIn: parent
                    text: redoButton.count
                    color: "white"
                }
            }
        }
        //        FHoverButton {
        //            tipText: qsTr("上方添加一行")
        //            backImageSource: "qrc:/Image/Table/insert-rowG.png"
        //            frontImageSource: "qrc:/Image/Table/insert-rowB.png"
        //            onClicked: {
        //                tabRect.addRowsAbove(1);
        //                TableStatus.hasSaved = false;
        //            }
        //        }
        FHoverButton {
            tipText: qsTr("下方添加一行")
            anchors.verticalCenter: parent.verticalCenter
            backImageSource: "qrc:/Image/Table/insert-below.png"
            frontImageSource: "qrc:/Image/Table/insert-belowB.png"
            onClicked: {
                tabRect.addRowsBelow(1);
                TableStatus.hasSaved = false;
            }
        }
        FHoverButton {
            tipText: qsTr("末尾添加一行")
            anchors.verticalCenter: parent.verticalCenter
            backImageSource: "qrc:/Image/Table/append-row.png"
            frontImageSource: "qrc:/Image/Table/append-rowB.png"
            onClicked: {
                tabRect.addRowsTail(1);
                TableStatus.hasSaved = false;
            }
        }
        FHoverButton {
            tipText: qsTr("删除当前行")
            anchors.verticalCenter: parent.verticalCenter
            backImageSource: "qrc:/Image/Table/delete-row.png"
            frontImageSource: "qrc:/Image/Table/delete-rowB.png"
            onClicked: {
                tabRect.removeRowsFromCurrent();
                TableStatus.hasSaved = false;
            }
        }
        FHoverButton {
            tipText: qsTr("清空")
            anchors.verticalCenter: parent.verticalCenter
            backImageSource: "qrc:/Image/Table/clear.png"
            frontImageSource: "qrc:/Image/Table/clearB.png"
            onClicked: {
                root.showClearAllBox();
            }
        }

        FSpinButton {
            tipText: qsTr("末尾添加多行")
            anchors.verticalCenter: parent.verticalCenter
            backImageSource: "qrc:/Image/Table/append-mulit-row.png"
            frontImageSource: "qrc:/Image/Table/append-mulit-rowB.png"
            onTrigger: {
                tabRect.addRowsTail(count);
            }
        }
    }

    //        文件读写
    FileIO {
        id: fileIO
    }
    FileInfo {
        id: fileInfo
    }
    TabBar {
        id: mcuTabBar
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 50
        width: 360
        height: 35
        currentIndex: 0
        TabButton {
            id: signalsButton
            text: qsTr("状态帧")
            contentItem: Text {
                anchors.centerIn: signalsButton
                text: signalsButton.text
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: signalsButton.checked ? "#30D5FD" : "#787878"    //"#d5d5d5"
            }
            background: Rectangle {
                implicitWidth: 120
                implicitHeight: 35
                color: "#F1F4F9"
            }
        }
        TabButton {
            id: specialSignalsButton
            text: qsTr("事件帧")
            contentItem: Text {
                anchors.centerIn: specialSignalsButton
                text: specialSignalsButton.text
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: specialSignalsButton.checked ? "#30D5FD" : "#787878"    //"#d5d5d5"
            }
            background: Rectangle {
                implicitWidth: 120
                implicitHeight: 35
                color: "#F1F4F9"
            }
        }
        TabButton {
            id: commandsButton
            text: qsTr("下行帧")
            contentItem: Text {
                anchors.centerIn: commandsButton
                text: commandsButton.text
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: commandsButton.checked ? "#30D5FD" : "#787878"   //"#d5d5d5"
            }
            background: Rectangle {
                implicitWidth: 120
                implicitHeight: 35
                color: "#F1F4F9"
            }
        }
    }
    Row {
        anchors {
            right: parent.right
            rightMargin: 20
            top: parent.top
            topMargin: 5
        }
        spacing: 10
        FTextButton {
            id: findButton
            width: 260
            hitText: qsTr("搜索...")

            backImageSourceOne: "qrc:/Image/Tools/arrowUpGray.png"
            frontImageSourceOne: "qrc:/Image/Tools/arrowUpBlue.png"
            isAtAboveOne: true

            backImageSourceTwo: "qrc:/Image/Tools/arrowDownGray.png"
            frontImageSourceTwo: "qrc:/Image/Tools/arrowDownBlue.png"
            isAtAboveTwo: true
            onTrigger: {
                root.find(text)
            }
        }
        FHoverButton {
            id: templateButton
            tipText: qsTr("导入模板")
            backImageSource: "qrc:/Image/Tools/importG.png"
            frontImageSource: "qrc:/Image/Tools/importO.png"
            isAtAbove: true
            onClicked: {
                root.showTemplateBox();
            }
        }
        FHoverButton {
            id: checkButton
            tipText: qsTr("检查")
            backImageSource: "qrc:/Image/Tools/checkG.png"
            frontImageSource: "qrc:/Image/Tools/checkR.png"
            isAtAbove: true
            onClicked: {
                tabRect.check();
            }
        }
        FHoverButton {
            id: timButton
            tipText: qsTr("提示")
            backImageSource: "qrc:/Image/Tools/promptG.png"
            frontImageSource: "qrc:/Image/Tools/promptR.png"
            isAtAbove: true
            onClicked: {
                var fixedName = ""
                for (var i = 0; i < tabRect.fixedNames.length; ++i) {
                    if (i % 4 == 0)
                        fixedName += "<br>"
                    fixedName += tabRect.fixedNames[i] + " ";
                }
                var tips = "
    1、bits必须大于0 <br>
    2、状态帧 必须包含以下固定名称: %1<br>
    3、下行帧 必须包含 applicationState<br>
    4、max表示计算后的数据， 计算方法:<br>
        (原始数据 × coefficient) + offset
    ".arg(fixedName);
                root.showMessageBox(tips);
            }
        }
    }
    Item {
        id: tabRect
        anchors {
            left: mcuTabBar.left
            top: mcuTabBar.bottom
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 50
        }
        signal addRowsAbove(int count);
        signal addRowsBelow(int count);
        signal addRowsTail(int count);
        signal removeRowsFromCurrent();
        signal clear();
        signal updateDatas();
        signal check();
        signal find(string text);
        signal redo();
        signal undo();
        property alias currentIndex : mcuTabBar.currentIndex
        onCurrentIndexChanged: {
            if (currentIndex === 0) {
                commandsTable.visible = false;
                specialSignalsTable.visible = false;
                signalsTable.visible = true;
                connectToSignals();
            } else if (currentIndex === 1) {
                commandsTable.visible = false;
                specialSignalsTable.visible = true;
                signalsTable.visible = false;
                connectToSpecialSignals();
            } else if (currentIndex === 2) {
                commandsTable.visible = true;
                specialSignalsTable.visible = false;
                signalsTable.visible = false;
                connectToCommands();
            }
            updateSignalsName();
            updateDatas();
        }
        Component.onCompleted: {
            commandsTable.visible = false;
            specialSignalsTable.visible = false;
            signalsTable.visible = true;
            connectToSignals();
        }
        function connectToSignals() {
            tabRect.addRowsAbove.disconnect(commandsTable.addRowsAbove)
            tabRect.addRowsBelow.disconnect(commandsTable.addRowsBelow)
            tabRect.addRowsTail.disconnect(commandsTable.addRowsTail)
            tabRect.removeRowsFromCurrent.disconnect(commandsTable.removeRowsFromCurrent)
            tabRect.clear.disconnect(commandsTable.clear)
            tabRect.updateDatas.disconnect(commandsTable.updateDatas)
            tabRect.check.disconnect(commandsTable.check)
            tabRect.find.disconnect(commandsTable.find)
            tabRect.redo.disconnect(commandsTable.redo)
            tabRect.undo.disconnect(commandsTable.undo)
            commandsTable.showInfo.disconnect(tabRect.showInfo)

            tabRect.addRowsAbove.disconnect(specialSignalsTable.addRowsAbove)
            tabRect.addRowsBelow.disconnect(specialSignalsTable.addRowsBelow)
            tabRect.addRowsTail.disconnect(specialSignalsTable.addRowsTail)
            tabRect.removeRowsFromCurrent.disconnect(specialSignalsTable.removeRowsFromCurrent)
            tabRect.clear.disconnect(specialSignalsTable.clear)
            tabRect.updateDatas.disconnect(specialSignalsTable.updateDatas)
            tabRect.check.disconnect(specialSignalsTable.check)
            tabRect.find.disconnect(specialSignalsTable.find)
            tabRect.redo.disconnect(specialSignalsTable.redo)
            tabRect.undo.disconnect(specialSignalsTable.undo)
            specialSignalsTable.showInfo.disconnect(tabRect.showInfo)

            tabRect.addRowsAbove.connect(signalsTable.addRowsAbove)
            tabRect.addRowsBelow.connect(signalsTable.addRowsBelow)
            tabRect.addRowsTail.connect(signalsTable.addRowsTail)
            tabRect.removeRowsFromCurrent.connect(signalsTable.removeRowsFromCurrent)
            tabRect.clear.connect(signalsTable.clear)
            tabRect.updateDatas.connect(signalsTable.updateDatas)
            tabRect.check.connect(signalsTable.check)
            tabRect.find.connect(signalsTable.find)
            tabRect.redo.connect(signalsTable.redo)
            tabRect.undo.connect(signalsTable.undo)
            signalsTable.showInfo.connect(tabRect.showInfo)

            findButton.buttonOneClickFuc = signalsTable.findLast
            findButton.buttonTwoClickFuc = signalsTable.findNext
            findButton.current = Qt.binding(function() {
                return signalsTable.currentFindIndex + 1;
            })
            findButton.count = Qt.binding(function() {
                return signalsTable.findResult.length;
            })
            undoButton.count = Qt.binding(function() {
                return signalsTable.undoCount;
            })
            redoButton.count = Qt.binding(function() {
                return signalsTable.redoCount;
            })
        }
        function connectToSpecialSignals() {
            tabRect.addRowsAbove.disconnect(signalsTable.addRowsAbove)
            tabRect.addRowsBelow.disconnect(signalsTable.addRowsBelow)
            tabRect.addRowsTail.disconnect(signalsTable.addRowsTail)
            tabRect.removeRowsFromCurrent.disconnect(signalsTable.removeRowsFromCurrent)
            tabRect.clear.disconnect(signalsTable.clear)
            tabRect.updateDatas.disconnect(signalsTable.updateDatas)
            tabRect.check.disconnect(signalsTable.check)
            tabRect.find.disconnect(signalsTable.find)
            tabRect.redo.disconnect(signalsTable.redo)
            tabRect.undo.disconnect(signalsTable.undo)
            signalsTable.showInfo.disconnect(tabRect.showInfo)

            tabRect.addRowsAbove.disconnect(commandsTable.addRowsAbove)
            tabRect.addRowsBelow.disconnect(commandsTable.addRowsBelow)
            tabRect.addRowsTail.disconnect(commandsTable.addRowsTail)
            tabRect.removeRowsFromCurrent.disconnect(commandsTable.removeRowsFromCurrent)
            tabRect.clear.disconnect(commandsTable.clear)
            tabRect.updateDatas.disconnect(commandsTable.updateDatas)
            tabRect.check.disconnect(commandsTable.check)
            tabRect.find.disconnect(commandsTable.find)
            tabRect.redo.disconnect(commandsTable.redo)
            tabRect.undo.disconnect(commandsTable.undo)
            commandsTable.showInfo.disconnect(tabRect.showInfo)

            tabRect.addRowsAbove.connect(specialSignalsTable.addRowsAbove)
            tabRect.addRowsBelow.connect(specialSignalsTable.addRowsBelow)
            tabRect.addRowsTail.connect(specialSignalsTable.addRowsTail)
            tabRect.removeRowsFromCurrent.connect(specialSignalsTable.removeRowsFromCurrent)
            tabRect.clear.connect(specialSignalsTable.clear)
            tabRect.updateDatas.connect(specialSignalsTable.updateDatas)
            tabRect.check.connect(specialSignalsTable.check)
            tabRect.find.connect(specialSignalsTable.find)
            tabRect.redo.connect(specialSignalsTable.redo)
            tabRect.undo.connect(specialSignalsTable.undo)
            specialSignalsTable.showInfo.connect(tabRect.showInfo)

            findButton.buttonOneClickFuc = specialSignalsTable.findLast
            findButton.buttonTwoClickFuc = specialSignalsTable.findNext
            findButton.current = Qt.binding(function() {
                return specialSignalsTable.currentFindIndex + 1;
            })
            findButton.count = Qt.binding(function() {
                return specialSignalsTable.findResult.length;
            })
            undoButton.count = Qt.binding(function() {
                return specialSignalsTable.undoCount;
            })
            redoButton.count = Qt.binding(function() {
                return specialSignalsTable.redoCount;
            })
        }

        function connectToCommands() {
            tabRect.addRowsAbove.disconnect(signalsTable.addRowsAbove)
            tabRect.addRowsBelow.disconnect(signalsTable.addRowsBelow)
            tabRect.addRowsTail.disconnect(signalsTable.addRowsTail)
            tabRect.removeRowsFromCurrent.disconnect(signalsTable.removeRowsFromCurrent)
            tabRect.clear.disconnect(signalsTable.clear)
            tabRect.updateDatas.disconnect(signalsTable.updateDatas)
            tabRect.check.disconnect(signalsTable.check)
            tabRect.find.disconnect(signalsTable.find)
            tabRect.redo.disconnect(signalsTable.redo)
            tabRect.undo.disconnect(signalsTable.undo)
            signalsTable.showInfo.disconnect(tabRect.showInfo)

            tabRect.addRowsAbove.disconnect(specialSignalsTable.addRowsAbove)
            tabRect.addRowsBelow.disconnect(specialSignalsTable.addRowsBelow)
            tabRect.addRowsTail.disconnect(specialSignalsTable.addRowsTail)
            tabRect.removeRowsFromCurrent.disconnect(specialSignalsTable.removeRowsFromCurrent)
            tabRect.clear.disconnect(specialSignalsTable.clear)
            tabRect.updateDatas.disconnect(specialSignalsTable.updateDatas)
            tabRect.check.disconnect(specialSignalsTable.check)
            tabRect.find.disconnect(specialSignalsTable.find)
            tabRect.redo.disconnect(specialSignalsTable.redo)
            tabRect.undo.disconnect(specialSignalsTable.undo)
            specialSignalsTable.showInfo.disconnect(tabRect.showInfo)

            tabRect.addRowsAbove.connect(commandsTable.addRowsAbove)
            tabRect.addRowsBelow.connect(commandsTable.addRowsBelow)
            tabRect.addRowsTail.connect(commandsTable.addRowsTail)
            tabRect.removeRowsFromCurrent.connect(commandsTable.removeRowsFromCurrent)
            tabRect.clear.connect(commandsTable.clear)
            tabRect.updateDatas.connect(commandsTable.updateDatas)
            tabRect.check.connect(commandsTable.check)
            tabRect.find.connect(commandsTable.find)
            tabRect.redo.connect(commandsTable.redo)
            tabRect.undo.connect(commandsTable.undo)
            commandsTable.showInfo.connect(tabRect.showInfo)

            findButton.buttonOneClickFuc = commandsTable.findLast
            findButton.buttonTwoClickFuc = commandsTable.findNext
            findButton.current = Qt.binding(function() {
                return commandsTable.currentFindIndex + 1;
            })
            findButton.count = Qt.binding(function() {
                return commandsTable.findResult.length;
            })
            undoButton.count = Qt.binding(function() {
                return commandsTable.undoCount;
            })
            redoButton.count = Qt.binding(function() {
                return commandsTable.redoCount;
            })
        }
        function showInfo(info) {
            root.showMessageBox(info)
        }
        function checkData() {
            var err1 =  signalsTable.checkWithoutShowInfo();
            if (err1) {
                return "状态帧 " + err1;
            }

            var err2 = specialSignalsTable.checkWithoutShowInfo();
            if (err2) {
                return "事件帧 " + err2;
            }

            var err3 = commandsTable.checkWithoutShowInfo();
            if (err3) {
                return "下行帧 " + err3
            }
            if (jsonListModel.mcuVersion === "" || jsonListModel.mcuVersion === "0") {
                return "请输入Mcu版本";
            }
            return "";
        }
        function clearReocrder() {
            signalsTable.clearRecorder();
            specialSignalsTable.clearRecorder();
            commandsTable.clearRecorder();
        }
        property variant signalNames;
        function updateSignalsName() {
            var array = [];
            //手动放入一个空字符串
            array.push("")
            var model = jsonListModel.signalsModel;
            for (var i = 0; i < model.count; ++i) {
                var obj = model.get(i);
                if (obj.name) {
                    array.push(obj.name)
                }
            }
            signalNames = array;
        }
        //header数据
        readonly property var signalsHeaderModel: [
            "name", "bits", "coefficient", "offset", "min", "max", "invalid", "description"
        ]
        readonly property var specialSignalHeaderModel: [
            "type", "name", "description"
        ]
        readonly property var commandsHeaderModel: [
            "name","bits","default","min", "max", "description"
        ]
        //固定名称
        readonly property var fixedNames : [
            "rpm", "igOn", "theme", "language", "dateTime",
            "enterKey", "backKey", "nextKey", "prevKey", "speed",
            "hwVersionMax", "hwVersionMid", "hwVersionMin",
            "mcuVersionMax", "mcuVersionMid", "mcuVersionMin", "projectModeEnabled"
        ]
        Rectangle {
            id: busyRect
            z: 3
            anchors.fill: parent
            visible: false
            function open() {
                visible = true;
            }
            function close() {
                busyTimer.restart()
            }
            Timer {
                id: busyTimer
                running: false
                repeat: false
                interval: 500
                onTriggered: busyRect.visible = false
            }
            BusyIndicator {
                id: busyIndicator
                running: true
                anchors.centerIn: parent
                visible: parent.visible
            }
        }
        //data数据
        FJsonListModel {
            id: jsonListModel
            heartBeatIntervalQuery: "$.heartBeatInterval"
            mcuVersionQuery: "$.version"
            signalsQuery: "$.signals[*]"
            specialSignalsQuery: "$.specialSignals[*]"
            commandsQuery: "$.commands[*]"

            property string source: root.sourceFileName
            onSourceChanged: {
                if (source) {
                    heartBeatIntervalText.isInited = false
                    mcuVersionText.isInited = false
                    loadFromSource(source);
                }
            }
            onErrorChanged:  {
                if (error) {
                    //加载出错时，弹窗提示错误信息
                    busyRect.close();
                    root.showMessageBox(error);
                }
            }
            onParseStart: {
                busyRect.open();
            }
            onParseEnd: {
                tabRect.updateDatas();
                mcuVersionText.text = mcuVersion
                heartBeatIntervalText.text = heartBeatInterval
                heartBeatIntervalText.isInited = true
                mcuVersionText.isInited = true
                busyRect.close();
                TableStatus.hasLoadedModel = true;
                TableStatus.setMcuData(jsonListModel.getModelData(false));
                tabRect.clearReocrder();
                var err = tabRect.checkData();
                if (err) {
                    root.showMessageBox(err)
                }
            }
        }

        FTable {
            id: signalsTable
            visible: false
            dataModel: jsonListModel.signalsModel
            headerModel: tabRect.signalsHeaderModel
            fixedNames: tabRect.fixedNames
            tableType: "signals"
            onDataEdited: {
                TableStatus.hasSaved = false;
                //将数据string给出到TableStatus
                TableStatus.setMcuData(jsonListModel.getModelData(false));
            }
        }
        FTable {
            id: specialSignalsTable
            visible: false
            dataModel: jsonListModel.specialSignalsModel
            headerModel: tabRect.specialSignalHeaderModel
            fixedNames: [""]
            tableType: "specialSignals"
            onDataEdited: {
                TableStatus.hasSaved = false;
                //将数据string给出到TableStatus
                TableStatus.setMcuData(jsonListModel.getModelData(false));
            }
        }
        FTable {
            id: commandsTable
            visible: false
            dataModel: jsonListModel.commandsModel
            headerModel: tabRect.commandsHeaderModel
            fixedNames: ["applicationState"]
            tableType: "commands"
            signalNames: tabRect.signalNames
            onDataEdited: {
                TableStatus.hasSaved = false;
                //将数据string给出到TableStatus
                TableStatus.setMcuData(jsonListModel.getModelData(false));
            }
        }
    }
    Component {
        id: templateWindow
        Item {
            y: 28
            width: 400
            height: 200
            Row {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -20
                spacing: 30
                Repeater {
                    model: ListModel {
                        ListElement {
                            name: "简易模板    ";
                            backIcon: "qrc:/Image/Template/simpleTemplateIconG.png";
                            frontIcon: "qrc:/Image/Template/simpleTemplateIcon.png";
                            path:":/Json/sample.json"
                        }
                        ListElement {
                            name: "燃油车模板";
                            backIcon: "qrc:/Image/Template/fuelCarG.png";
                            frontIcon: "qrc:/Image/Template/fuelCar.png";
                            path:":/Json/fuelCar.json"
                        }
                        ListElement {
                            name: "电动车模板";
                            backIcon: "qrc:/Image/Template/electrombileG.png";
                            frontIcon: "qrc:/Image/Template/electrombile.png";
                            path:":/Json/electricCar.json"
                        }
                        ListElement {
                            name: "混动车模板";
                            backIcon: "qrc:/Image/Template/hybridG.png";
                            frontIcon: "qrc:/Image/Template/hybrid.png";
                            path:":/Json/mixingCar.json"
                        }
                    }
                    FHoverButton {
                        width: 50
                        height: 50
                        backImageSource: backIcon
                        frontImageSource: frontIcon
                        tipText: name
                        onClicked: {
                            var ret = TableStatus.loadTemplateFile(path)
                            if (ret !== "") {
                                console.log(ret)
                            }
                        }
                    }
                }
            }
        }
    }

    function loadFromJson(filePath) {
        //先置空，再赋值，保证能多次加载同一个文件
        root.sourceFileName = ""
        root.sourceFileName = filePath;
        mcuTabBar.currentIndex = 0;
        TableStatus.hasSaved = true;
    }
    function saveToJson(filePath, withReloadEvent) {
        var err = jsonListModel.saveModelsToFile(filePath, TableStatus.saveWithIndented)
        if (err !== "") {
            root.showMessageBox(qsTr("Mcu保存出错： " + err));
        } else {
            TableStatus.hasSaved = true;
            root.sourceFileName = filePath;
        }
    }
    function showClearAllBox() {
        popDialog.reset();
        popDialog.open();
        popDialog.title = "警告"
        popDialog.cancleButtonVisible = true;
        popDialog.text = "确定要清空全部内容吗？"
        popDialog.width = 400;
        popDialog.height = 200;
        popDialog.okClickFunc = function() {
            tabRect.clear();
            TableStatus.hasSaved = false;
            popDialog.close();
        }
    }
    function showMessageBox(message) {
        popDialog.reset();
        popDialog.open();
        popDialog.title = "提示"
        popDialog.cancleButtonVisible = false;
        popDialog.text = message
        popDialog.width = 600;
        popDialog.height = 400;
        popDialog.okClickFunc = function() {
            tabRect.clear();
            TableStatus.hasSaved = false;
            popDialog.close();
        }

    }
    function showTemplateBox() {
        popDialog.reset();
        popDialog.open();
        popDialog.title = "模板库"
        popDialog.okButtonText = "关闭"
        popDialog.cancleButtonVisible = false;
        popDialog.text = ""
        popDialog.width = 400;
        popDialog.height = 200;
        popDialog.contentComponent = templateWindow
    }
    function noProjectSave() {
        var err = tabRect.checkData();
        if (err) {
            root.showMessageBox(err)
        } else {
            if (root.sourceFileName) {
                root.saveToJson(root.sourceFileName, false);
            } else {
                saveAs();
            }
        }
    }
    function projectSave() {
        if (TableStatus.sourceJsonFilePath) {
            var err = tabRect.checkData();
            if (err) {
                root.showMessageBox(err)
            } else {
                root.saveToJson(TableStatus.sourceJsonFilePath, false);
            }
        }
    }
    function saveAs() {
        var err = tabRect.checkData();
        if (err) {
            root.showMessageBox(err)
        } else {
            mcuJsonfileDialog.saveFile();
        }
    }
    function projectClose() {
        signalsTable.clear();
        specialSignalsTable.clear();
        commandsTable.clear();
        root.sourceFileName = "";
        TableStatus.hasSaved = true;
        heartBeatIntervalText.isInited = false
        mcuVersionText.isInited = false
    }


    function find(text) {
        tabRect.find(text)
    }
    //加载，保存 对话框
    FileDialog {
        id: mcuJsonfileDialog
        visible: false
        folder: shortcuts.home
        selectFolder: false
        selectMultiple: false
        sidebarVisible: true
        nameFilters: [ "Json files (*.json )"]
        property bool useForSave: false
        //Dialog得到的路径都是url，为了避免url和string到处混用(file://)，这里约定:
        //在Dialog内部给出的路径全部转换为string，再传递给dialog外部，外部不使用url
        onAccepted: {
            if (useForSave) {
                root.saveToJson(fileInfo.toLocal(fileUrl), false);
            } else {
                root.loadFromJson(fileInfo.toLocal(fileUrl));
            }
        }
        function openFile() {
            useForSave = false
            title = qsTr("选择一个 json 格式的文件")
            nameFilters = [ "json files (*.json )"]
            selectExisting = true;
            open();
        }
        function saveFile() {
            useForSave = true
            nameFilters = [ "json files (*.json )"]
            title = qsTr("创建一个 json 文件")
            selectExisting = false;
            open();
        }
    }
    FPopDialog {
        id: popDialog
        width: 600
        height: 400
    }
}
