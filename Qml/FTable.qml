import QtQuick 2.7
import QtQuick.Controls 1.4 as QC14
import QtQuick.Controls.Styles 1.4 as QCS14
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.2
import QtQml 2.2
import Tools 1.0

import "Component"

Item {
    id: root
    anchors.fill: parent

    //表格的表头
    property var headerModel: [];
    onHeaderModelChanged: {
        tableView.loadHeader();
    }

    property var findResult: []
    property int currentFindIndex: 0
    function findNext() {
        if (findResult.length <= 0) return;
        if (currentFindIndex + 1 < findResult.length) {
            currentFindIndex++;
        } else {
            currentFindIndex = 0;
        }
        tableView.currentRow = findResult[currentFindIndex];
        tableView.positionViewAtRow(findResult[currentFindIndex], ListView.Beginning);
    }
    function findLast() {
        if (findResult.length <= 0) return;
        if (currentFindIndex - 1 >= 0) {
            currentFindIndex--;
        } else {
            currentFindIndex = findResult.length - 1;
        }
        tableView.currentRow = findResult[currentFindIndex];
        tableView.positionViewAtRow(findResult[currentFindIndex], ListView.Beginning);
    }

    //表格的数据
    property ListModel dataModel;
    //用来标识是状态帧还是下行帧: "signals" / "commands" / "specialSignals"
    property string tableType: ""

    //下行帧需要用到状态帧的name
    property var signalNames: [""]
    // 固定名称
    property var fixedNames : [""]
    property int undoCount: recorder.undoCount
    property int redoCount: recorder.redoCount

    signal showInfo(string info);
    signal dataEdited()

    //记录器，用来记录增删改操作。
    OperationRecorder {
        id: recorder
    }

    //更新数据
    function updateDatas() {
        tableView.updateDatas();
    }
    //上方添加count行
    function addRowsAbove(count) {
        tableView.addRowsAbove(count, true);
    }
    //下方添加count行
    function addRowsBelow(count) {
        tableView.addRowsBelow(count, true);
    }

    //末尾添加count行
    function addRowsTail(count) {
        tableView.addRowsTail(count, true);
    }


    //删除当前选中行
    function removeRowsFromCurrent() {
        tableView.removeRowsFromIndex(tableView.currentRow, 1, true);
    }

    //清空
    function clear() {
        tableView.clear(true);
    }
    //检查整字节,检查名字
    function check() {
        var err1 = tableView.checkBitLength();
        var err2 = ""

        if (root.tableType === "specialSignals") {
            err2 = tableView.checkSpecialSignals();
        } else {
            err2 = tableView.checkNames();
        }

        var err = "";
        if (err1) err += err1;
        if (err2) err += err2;
        if (err) showInfo(err);
    }
    function checkWithoutShowInfo() {
        var err1 = tableView.checkBitLength();
        var err2 = "";
        if (root.tableType === "specialSignals") {
            err2 = tableView.checkSpecialSignals();
        } else {
            err2 = tableView.checkNames();
        }
        return err1 + err2;
    }
    function redo() {
        var str = recorder.redo();
        if (!str) return;
        var data = JSON.parse(str);
        if (!data) return;
        var items = [];
        var item;
        if (data.type === OperationRecorder.Add) {
            if (data.count <= 0) {
                return;
            }
            items = data.data;
            for (var i = 0; i < items.length; ++i) {
                item = items[i];
                dataModel.insert(data.index, item);
            }
        } else if (data.type === OperationRecorder.Clear) {
            tableView.clear(false);
        } else if (data.type === OperationRecorder.Delete) {
            tableView.removeRowsFromIndex(data.index, data.count, false);
        } else if (data.type === OperationRecorder.Modify) {
            if (data.row < 0 || data.row >= dataModel.count) return;
            dataModel.setProperty(data.row, data.role, data.dataNew);
        } else {
            console.log("redo nothing");
        }
        tableView.updateDatas();
    }
    function undo() {
        var str = recorder.undo();
        if (!str) return;
        var data = JSON.parse(str);
        if (!data) return;
        var items = [];
        var item;
        if (data.type === OperationRecorder.Add) {
            tableView.removeRowsFromIndex(data.index, data.count, false);
        } else if (data.type === OperationRecorder.Delete) {
            if (data.index < 0 || data.count <= 0) {
                return;
            }
            items = data.data;
            for (var i = 0; i < items.length; ++i) {
                item = items[i];
                dataModel.insert(data.index, item);
            }
        } else if (data.type === OperationRecorder.Clear) {
            items = data.data;
            for (var i = 0; i < items.length; ++i) {
                item = items[i];
                dataModel.append(item);
            }
        } else if (data.type === OperationRecorder.Modify) {
            if (data.row < 0 || data.row >= dataModel.count) return;
            dataModel.setProperty(data.row, data.role, data.data);
        } else {
            console.log("redo nothing");
        }
        tableView.updateDatas();
    }
    function clearRecorder() {
        recorder.clear();
    }
    onVisibleChanged: {
        if (visible) {
            loadHeader();
        }
    }
    function loadHeader() {
        tableView.loadHeader();
    }
    function find(text) {
        tableView.find(text);
    }

    //用来动态创建TableView一列的组件
    Component {
        id: columnComponent
        QC14.TableViewColumn {
            width: 120
        }
    }

    //TabelView header代理
    Component {
        id: headerDelegate
        Rectangle {
            width: 300
            height: 30
            color:  "#2d2d2d"
            border.width: 1
            border.color: "#838383"
            Text {
                id: headerTextInput
                anchors.centerIn: parent
                text: styleData.value === "type" ? "事件编号" : styleData.value
                color: "#e5e5e5"

            }
        }
    }

    //TableView row代理
    Component {
        id: rowDelegate
        Item {
            anchors.leftMargin: 3
            width: tableView.width
            height: 35
        }
    }

    readonly property color cellBackgroundColor: "#EDEDF0"
    readonly property color cellCurrentRowColor: "#C4DEF4"
    readonly property color cellSelectedColor: "#32A6FF"
    //TabelView item代理
    Component {
        id: itemDelegate
        //Loader 动态加载不同的组件
        Loader {
            id: itemLoader
            anchors.fill: parent
//            anchors.topMargin: 1
//            anchors.bottomMargin: 1
            visible: status === Loader.Ready
            //根据role加载相应的组件
            sourceComponent: {
                var role = styleData.role;
                if (role === "order")
                    return orderComponent;
                if (role === "name")
                    return nameComponent;
                else if (role === "bits")
                    return bitsComponent;
                else if (role === "coefficient")
                    return coeffComponent;
                else if (role === "offset")
                    return offsetComponent;
                else if (role === "invalid")
                    return invalidComponent;
                else if (role === "description")
                    return descriptionComponent;
                else if (role === "default" || role === "maintain")
                    return defaultComponent;
                else if (role === "min")
                    return minComponent;
                else if (role === "max")
                    return maxComponent;
                else if (role === "type")
                    return typeComponent;
                else return emptyComponent;
            }

            //Note: 各种component需要写在loader内部。因为要访问styleData，在外部会
            //提示找不到styleData
            Component {
                id: emptyComponent
                Item { }
            }
            Component {
                id: orderComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)

                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    Text {
                        id: orderText
                        anchors.fill: parent
                        //                        text: styleData.value ? String(styleData.value) : ""
                        text: {
                            var obj = dataModel.get(styleData.row);
                            if (obj && obj["order"])
                                return obj["order"]
                            return ""
                        }
                        color: parent.isSelected ? "white" : "#1c1d1f"

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                updatePositon()
                            }
                            function updatePositon() {
                                tableView.currentColumn = styleData.column;
                                parent.forceActiveFocus();
                            }
                        }
                    }
                }
            }
            Component {
                id: nameComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"
                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    TextInput {
                        id: nameTextInput
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: {
                            var obj = dataModel.get(styleData.row);
                            if (obj && obj[styleData.role])
                                return obj[styleData.role]
                            return ""
                        }
                        activeFocusOnPress: true
                        selectByMouse: true
                        selectionColor: "#4283aa"
                        selectedTextColor: "#ffffff"
                        color: parent.isSelected ? (isFixedName ? "red" : "#ededed") : "#272727"
                        property bool isUserClicked: false
                        property bool isFixedName: {
                            if (!styleData.value || styleData.value === "")
                                return false;
                            var isFixedName = false;
                            for (var i = 0; i < root.fixedNames.length; ++i) {
                                if (fixedNames[i] === styleData.value) {
                                    isFixedName = true;
                                }
                            }
                            return isFixedName;
                        }
                        //  只能输入数字和英文字母,且第一个字符必须是小写英文字母
                        //                        validator:RegExpValidator {
                        //                            regExp: /[a-z][0-9a-zA-Z_]|^\\s*$*/
                        //                        }

                        onDisplayTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }
                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== text) {
                                tableView.recordModifyData(styleData.row, styleData.role, styleData.value, text ? text : "")
                                dataModel.setProperty(styleData.row, styleData.role, text ? text : "");
                                tableView.updateDatas();
                            }
                        }

                        MouseArea {
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
                                if (pressed) {
                                    nameTextInput.isUserClicked = true;
                                    tableView.currentColumn = styleData.column;
                                    parent.forceActiveFocus();
                                }
                                mouse.accepted = false;
                            }
                            onReleased: { mouse.accepted = false; }
                        }
                    }
                }
            }

            Component {
                id: bitsComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"

                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    FSpinBox {
                        id: bitsSpinBox
                        anchors.fill: parent
                        anchors.margins: 1
                        boxShow: parent.isSelected
                        property var modelValue : styleData.value
                        //bits一列要求修改完,没有按Enter或者Return就作出响应。
                        //这里不能用binding value的方式(会造成Binding  loop)，而是改用这种特殊的方式
                        property bool isUserClicked: false
                        onModelValueChanged: {
                            if (modelValue) {
                                value = parseInt(modelValue)
                            }
                        }
                        decimals: 0
                        from: 1
                        to: 32
                        onDisplayTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }
                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== Number(displayText)) {
                                if (displayText) {
                                    tableView.recordModifyData(styleData.row, styleData.role, styleData.value, Number(displayText))
                                    dataModel.setProperty(styleData.row, styleData.role, Number(displayText));
                                    tableView.updateDatas();
                                }
                            }
                        }
                        onPressedChanged: {
                            if (pressed) {
                                isUserClicked = true;
                                tableView.currentColumn = styleData.column;
                                parent.forceActiveFocus();
                            } else {
                                if (styleData.row >= 0) {
                                    tableView.recordModifyData(styleData.row, styleData.role, styleData.value, value)
                                    dataModel.setProperty(styleData.row, styleData.role, value);
                                    tableView.updateDatas();
                                }
                            }
                        }
                    }
                }
            }
            Component {
                id: coeffComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"

                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    TextInput {
                        id: coeffTextInput
                        anchors.fill: parent
                        text: {
                            var obj = dataModel.get(styleData.row);
                            if (obj && (obj[styleData.role] !== null) && (obj[styleData.role] !== "") && (obj[styleData.role] !== undefined))
                                return parseFloat(obj[styleData.role])
                            return ""
                        }
                        activeFocusOnPress: true
                        selectByMouse: true
                        selectionColor: "#4283aa"
                        selectedTextColor: "#ffffff"
                        color: parent.isSelected ? "#ededed" : "#272727"
                        verticalAlignment: TextInput.AlignVCenter
                        horizontalAlignment: TextInput.AlignHCenter
                        property bool isUserClicked: false

                        onDisplayTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }
                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== displayText) {
                                tableView.recordModifyData(styleData.row, styleData.role, styleData.value, parseFloat(displayText))
                                dataModel.setProperty(styleData.row, styleData.role, parseFloat(displayText));
                                tableView.updateDatas();
                            }
                        }
                        MouseArea {
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
                                if (pressed) {
                                    coeffTextInput.isUserClicked = true;
                                    tableView.currentColumn = styleData.column;
                                    parent.forceActiveFocus();
                                }
                                mouse.accepted = false;
                            }
                            onReleased: { mouse.accepted = false; }
                        }
                    }
                }
            }
            Component {
                id: offsetComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"
                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    TextInput {
                        id: offsetInput
                        anchors.fill: parent
                        text: {
                            var obj = dataModel.get(styleData.row);
                            if (obj && (obj[styleData.role] !== null) && (obj[styleData.role] !== "") && (obj[styleData.role] !== undefined))
                                return parseFloat(obj[styleData.role])
                            return ""
                        }
                        activeFocusOnPress: true
                        selectByMouse: true
                        selectionColor: "#4283aa"
                        selectedTextColor: "#ffffff"
                        color: parent.isSelected ? "#ededed" : "#272727"
                        verticalAlignment: TextInput.AlignVCenter
                        horizontalAlignment: TextInput.AlignHCenter
                        property bool isUserClicked: false

                        onDisplayTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }
                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== displayText) {
                                tableView.recordModifyData(styleData.row, styleData.role, styleData.value, parseFloat(displayText))
                                dataModel.setProperty(styleData.row, styleData.role, parseFloat(displayText));
                                tableView.updateDatas();
                            }
                        }
                        MouseArea {
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
                                if (pressed) {
                                    offsetInput.isUserClicked = true;
                                    tableView.currentColumn = styleData.column;
                                    parent.forceActiveFocus();
                                }
                                mouse.accepted = false;
                            }
                            onReleased: { mouse.accepted = false; }
                        }
                    }
                }
            }
            Component {
                id: invalidComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"
                    z: 3
                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    TextInput {
                        id: invalidInput
                        anchors.fill: parent
                        anchors.leftMargin: 3
                        //                        text: styleData.value ? styleData.value : ""
                        text: {
                            var obj = dataModel.get(styleData.row);
                            if (obj && obj["invalid"])
                                return stringToHex(obj["invalid"])
                            return ""
                        }
                        activeFocusOnPress: true
                        selectByMouse: true
                        selectionColor: "#4283aa"
                        selectedTextColor: "#ffffff"
                        color: parent.isSelected ? "#ededed" : "#272727"
                        verticalAlignment: TextInput.AlignVCenter
                        property bool isUserClicked: false
                        validator:RegExpValidator {
                            regExp: /(0[xX])([0-9a-fA-F]+)(,(0[xX])([0-9a-fA-F]+))*/
                        }

                        onDisplayTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }
                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== stringToHex(displayText)) {
                                tableView.recordModifyData(styleData.row, styleData.role, styleData.value, stringToHex(displayText))
                                dataModel.setProperty(styleData.row, styleData.role, stringToHex(displayText))
                                tableView.updateDatas();
                            }
                        }
                        function stringToHex(str) {
                            var ret = "";
                            var list = String(str).split(',');
                            for (var i = 0; i < list.length; ++i) {
                                var s = list[i]
                                if (i === 0) {
                                    ret += "0x" + parseInt(s).toString(16)
                                } else {
                                    ret += ",0x" + parseInt(s).toString(16)
                                }
                            }
                            return ret;
                        }
                        FToolTip {
                            text: "无效值必须使用十六进制，如果有多个，用逗号隔开"
                            visible: invalidMouseArea.containsMouse
                            delay: 500
                        }
                        MouseArea {
                            id: invalidMouseArea
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
                                if (pressed) {
                                    invalidInput.isUserClicked = true;
                                    tableView.currentColumn = styleData.column;
                                    parent.forceActiveFocus();
                                }
                                mouse.accepted = false;
                            }
                            onReleased: { mouse.accepted = false; }
                        }
                    }
                }
            }
            Component {
                id: typeComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"
                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    TextInput {
                        id: typeInput
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        //                        text: (styleData.value !== undefined && styleData.value !== null) ? styleData.value : ""
                        text: {
                            var obj = dataModel.get(styleData.row);
                            if (obj && obj[styleData.role])
                                return parseInt(obj[styleData.role])
                            return ""
                        }
                        activeFocusOnPress: true
                        selectByMouse: true
                        selectionColor: "#4283aa"
                        selectedTextColor: "#ffffff"
                        color: parent.isSelected ? "#ededed" : "#272727"
                        property bool isUserClicked: false
                        //只能输入数字
                        validator:RegExpValidator {
                            regExp: /[0-9]*/
                        }
                        //  编辑完成时，将displayText写入model
                        onDisplayTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }
                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== parseInt(text)) {
                                tableView.recordModifyData(styleData.row, styleData.role, styleData.value, parseInt(text))
                                dataModel.setProperty(styleData.row, styleData.role, parseInt(text));
                                tableView.updateDatas();
                            }
                        }

                        MouseArea {
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
                                if (pressed) {
                                    typeInput.isUserClicked = true;
                                    tableView.currentColumn = styleData.column;
                                    parent.forceActiveFocus();
                                }
                                mouse.accepted = false;
                            }
                            onReleased: { mouse.accepted = false; }
                        }
                    }
                }
            }
            Component {
                id: minComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"
                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    TextInput {
                        id: minInput
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        //                        text: (styleData.value !== undefined && styleData.value !== null) ? styleData.value : ""
                        text: {
                            var obj = dataModel.get(styleData.row);
                            if (obj && (obj[styleData.role] !== null) && (obj[styleData.role] !== "") && (obj[styleData.role] !== undefined))
                                return parseFloat(obj[styleData.role])
                            return ""
                        }
                        activeFocusOnPress: true
                        selectByMouse: true
                        selectionColor: "#4283aa"
                        selectedTextColor: "#ffffff"
                        color: parent.isSelected ? "#ededed" : "#272727"
                        property bool isUserClicked: false
                        //只能输入数字、负号和小数点
                        validator:RegExpValidator {
                            regExp: /-?[0-9]*.?[0-9]*/
                        }
                        //  编辑完成时，将displayText写入model
                        onDisplayTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }
                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== parseFloat(text)) {
                                tableView.recordModifyData(styleData.row, styleData.role, styleData.value,
                                                           (text === null || text === undefined || text === "") ? "" : parseFloat(text));
                                dataModel.setProperty(styleData.row, styleData.role,
                                                      (text === null || text === undefined || text === "") ? "" : parseFloat(text));
                                tableView.updateDatas();
                            }
                        }

                        MouseArea {
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
                                if (pressed) {
                                    minInput.isUserClicked = true;
                                    tableView.currentColumn = styleData.column;
                                    parent.forceActiveFocus();
                                }
                                mouse.accepted = false;
                            }
                            onReleased: { mouse.accepted = false; }
                        }
                    }
                }
            }
            Component {
                id: maxComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"
                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    TextInput {
                        id: maxInput
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        //                        text: (styleData.value !== undefined && styleData.value !== null) ? styleData.value : ""
                        text: {
                            var obj = dataModel.get(styleData.row);
                            if (obj && (obj[styleData.role] !== null) && (obj[styleData.role] !== "") && (obj[styleData.role] !== undefined))
                                return parseFloat(obj[styleData.role])
                            return ""
                        }
                        activeFocusOnPress: true
                        selectByMouse: true
                        selectionColor: "#4283aa"
                        selectedTextColor: "#ffffff"
                        color: parent.isSelected ? "#ededed" : "#272727"
                        property bool isUserClicked: false
                        //只能输入数字、负号和小数点
                        validator:RegExpValidator {
                            regExp: /-?[0-9]*.?[0-9]*/
                        }
                        onDisplayTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }
                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== parseFloat(text)) {
                                tableView.recordModifyData(styleData.row, styleData.role, styleData.value,
                                                           (text === null || text === undefined || text === "") ? "" : parseFloat(text))
                                dataModel.setProperty(styleData.row, styleData.role,
                                                      (text === null || text === undefined || text === "") ? "" : parseFloat(text));
                                tableView.updateDatas();
                            }
                        }

                        MouseArea {
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
                                if (pressed) {
                                    maxInput.isUserClicked = true;
                                    tableView.currentColumn = styleData.column;
                                    parent.forceActiveFocus();
                                }
                                mouse.accepted = false;
                            }
                            onReleased: { mouse.accepted = false; }
                        }
                    }
                }
            }
            Component {
                id: descriptionComponent
                Rectangle {
                    width: parent.width
                    height: parent.height * (isSelected ? 4 : 1)
                    border.width: 1
                    border.color: "#7f838c"
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row

                    TextArea {
                        id: descriptTextEdit
                        anchors.fill: parent
                        text: {
                            var obj = dataModel.get(styleData.row);
                            if (obj && obj["description"])
                                return obj["description"]
                            return ""
                        }
                        selectionColor: "#4283aa"
                        selectedTextColor: "#ffffff"
                        color: parent.isSelected ? "#ebebeb" : "#272727"
                        property bool isUserClicked: false
                        activeFocusOnPress: true
                        selectByMouse: true
                        wrapMode: TextEdit.WordWrap
                        onTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }

                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== text) {
                                tableView.recordModifyData(styleData.row, styleData.role, styleData.value, text);
                                dataModel.setProperty(styleData.row, styleData.role, text);
                                tableView.updateDatas();
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onContainsMouseChanged: {
                                if (containsMouse) {
                                    cursorShape = Qt.IBeamCursor;
                                } else {
                                    cursorShape = Qt.ArrowCursor;
                                }
                            }
                            onPressed: {
                                if (pressed) {
                                    descriptTextEdit.isUserClicked = true;
                                    tableView.currentColumn = styleData.column;
                                    parent.forceActiveFocus();
                                }
                                mouse.accepted = false;
                            }
                        }
                    }
                }
            }
            Component {
                id: defaultComponent
                Rectangle {
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#7f838c"
                    color: isSelected ? cellSelectedColor :
                                        ((tableView.currentRow === styleData.row) ?
                                             cellCurrentRowColor : cellBackgroundColor)
                    property bool isSelected: tableView.currentColumn === styleData.column &&
                                              tableView.currentRow === styleData.row
                    property alias isMaintain: defaultCheckBox.checked
                    onIsMaintainChanged: {
                        //取消勾选时，将maintain置空
                        if (!isMaintain) {
                            defaultComboBox.currentIndex = 0
                        } else {

                        }
                    }
                    CheckBox {
                        id: defaultCheckBox

                        anchors.left: parent.left
                        anchors.leftMargin: 3
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 3
                        anchors.bottomMargin: 3
                        implicitWidth: 35
                        text: ""
                        indicator: Rectangle {
                            implicitWidth: 25
                            implicitHeight: 25
                            anchors {
                                verticalCenter: defaultCheckBox.verticalCenter
                                left: defaultCheckBox.left
                                leftMargin: 5
                            }
                            radius: 4
                            color: "transparent"
                            border.color: parent.parent.isSelected ? "#cecfd3" : "#f1f4f9"
                            border.width: 2
                            Rectangle {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                radius: 2
                                color: defaultCheckBox.checked ? "#f1f4f9" : "#cecfd3"
                                // visible: defaultCheckBox.checked
                            }
                        }
                        checked: {
                            var obj = dataModel.get(styleData.row)
                            if (obj && obj.maintain) {
                                return true;
                            }
                            return false;
                        }
                        //                        property string modelValue: {
                        //                            var obj = dataModel.get(styleData.row)
                        //                            if (obj && obj["maintain"])
                        //                                return obj["maintain"];
                        //                            return "";
                        //                        }
                        //                        onModelValueChanged: {
                        //                            if (modelValue && modelValue != "") {
                        //                                checked = true;
                        //                            } else {
                        //                                checked = false;
                        //                            }
                        //                        }
                        onCheckedChanged: {
                            tableView.currentColumn = styleData.column;
                            parent.forceActiveFocus();
                            if (tableView.controlKeyPressed && styleData.row >= 0 ) {
                                if (styleData.selected) {
                                    tableView.selection.deselect(styleData.row);
                                } else {
                                    tableView.selection.select(styleData.row);
                                }
                            } else {
                                tableView.selection.clear();
                                tableView.selection.select(styleData.row)
                            }
                        }
                    }
                    ComboBox {
                        id: defaultComboBox

                        anchors.left: defaultCheckBox.right
                        anchors.leftMargin: 3
                        anchors.right: parent.right
                        anchors.rightMargin: 3
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 3
                        anchors.bottomMargin: 3
                        visible: isMaintain
                        onVisibleChanged: {
                            if(visible) {
                                updateIndex();
                            }
                        }
                        model: root.signalNames
                        property bool isUserClicked: false
                        property bool isInited: false
                        property string modelValue: {
                            var obj = dataModel.get(styleData.row)
                            var ret;
                            if (obj && obj["maintain"]) {
                                ret = obj["maintain"];
                                isInited = true;
                            } else {
                                ret = "";
                                isInited = false;
                            }
                            return ret;
                        }
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            setTextToDatamodel(currentIndex)
                            if (isUserClicked) root.dataEdited();
                        }
                        function updateIndex() {
                            if (modelValue && modelValue != "") {
                                currentIndex = find(modelValue)
                            }
                        }
                        function setTextToDatamodel(index) {
                            var row = styleData.row;
                            if (dataModel.count <= row) return;
                            var obj = dataModel.get(row);
                            if (!obj) return;
                            var str = JSON.stringify(obj)
                            obj = JSON.parse(str);
                            obj["maintain"] = textAt(index) ? textAt(index) : "";
                            dataModel.set(row, obj);
                        }
                        onPressedChanged: {
                            if (pressed) {
                                isUserClicked = true;
                                tableView.currentColumn = styleData.column;
                            }
                        }
                    }
                    TextInput {
                        id: defaultTextInput
                        anchors.left: defaultCheckBox.right
                        anchors.right: parent.right
                        anchors.rightMargin: 1
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 1
                        anchors.bottomMargin: 1
                        visible: !parent.isMaintain
                        text : {
                            var obj = dataModel.get(styleData.row);
                            if (obj && (obj[styleData.role] !== null) && (obj[styleData.role] !== "") && (obj[styleData.role] !== undefined))
                                return parseFloat(obj[styleData.role])
                            return ""
                        }
                        activeFocusOnPress: true
                        selectByMouse: true
                        selectionColor: "#4283aa"
                        selectedTextColor: "#ffffff"
                        color: parent.isSelected ? "#ededed" : "#272727"
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter
                        property bool isUserClicked: false
                        //只能输入数字、负号和小数点
                        validator:RegExpValidator {
                            regExp: /-?[0-9]*.?[0-9]*/
                        }
                        onDisplayTextChanged: {
                            if (isUserClicked) root.dataEdited();
                        }
                        onEditingFinished: {
                            if (styleData.row >= 0 && styleData.value !== parseFloat(text)) {
                                tableView.recordModifyData(styleData.row, styleData.role, styleData.value,
                                                           (text === null || text === undefined || text === "") ? "" : parseFloat(text));
                                dataModel.setProperty(styleData.row, styleData.role,
                                                      (text === null || text === undefined || text === "") ? "" : parseFloat(text));
                                tableView.updateDatas();
                            }
                        }
                        MouseArea {
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
                                if (pressed) {
                                    defaultTextInput.isUserClicked = true;
                                    tableView.currentColumn = styleData.column;
                                    parent.forceActiveFocus();
                                }
                                mouse.accepted = false;
                            }
                            onReleased: { mouse.accepted = false; }
                        }
                    }
                }
            }
        }
    }

    QC14.TableView {
        id: tableView
        anchors.fill: parent
        anchors.topMargin: 6

        visible: parent.visible
        frameVisible: false
        alternatingRowColors: true
        backgroundVisible : true

        //点击过cell后，记录cell的column
        property int currentColumn: -1

        //各种delegate
        headerDelegate: headerDelegate
        rowDelegate: rowDelegate
        itemDelegate: itemDelegate

        model: root.dataModel
        onModelChanged: {
            updateDatas();
        }

        //加载完成时，刷新table的头部
        Component.onCompleted: loadHeader()
        function loadHeader() {
            //循环清空tavleview
            while (tableView.columnCount > 0) {
                tableView.removeColumn(0)
            }
            updateDatas();

            if (root.tableType !== "specialSignals") {
                //添加一列 字节号, json文件中没有
                var orderTab = columnComponent.createObject(tableView)
                orderTab.title = qsTr("起始字节号")
                orderTab.role = "order"
                orderTab.width = 100
                tableView.addColumn(orderTab)
            }

            for (var i = 0; i < headerModel.length; ++i) {
                var tab = columnComponent.createObject(tableView)
                var name = headerModel[i]
                tab.title = name
                tab.role = name
                if (name === "description")
                    tab.width = 300
                else if (name === "default" || name === "invalid" || name === "name")
                    tab.width = 160;
                tableView.addColumn(tab)
            }
        }
        function updateDatas() {
            if (root.tableType !== "specialSignals") {
                var order = 1;
                var bits = 0;
                for (var i = 0; i < dataModel.count; ++i) {
                    var obj = dataModel.get(i);
                    var num = obj["bits"];
                    order += parseInt(bits / 8);
                    bits = bits % 8 + num;
                    dataModel.setProperty(i, "order", order)
                }
            }
        }
        readonly property var emptySignalRow : {"name": "", "bits": 1, "coefficient": 1, "offset": 0, "invalid": "", "description": ""}
        readonly property var emptyCommandRow : {"name": "", "bits": 1, "default": 0, "description": ""}
        readonly property var emptySpecialSignalRow : {"name": "", "type": 0}
        function addRowsAbove(count, needRecord) {
            var item = emptyCommandRow;
            if (root.tableType === "signals" )
                item = emptySignalRow;
            else if (root.tableType === "specialSignals")
                item = emptySpecialSignalRow;
            var index = tableView.currentRow;
            if (tableView.rowCount <= 0 || index < 0)
                index = 0;
            for (var i = 0; i < count; ++i) {
                dataModel.insert(index, item);
            }
            if (needRecord) {
                //record
                var oldData = [];
                for (var i = 0; i < count; ++i) {
                    if (index + i >= dataModel.count)
                        break;
                    oldData.push(dataModel.get(index + i));
                }

                var recordObj = Object.create(null);
                recordObj["type"] = OperationRecorder.Add;
                recordObj["index"] = index;
                recordObj["count"] = count;
                recordObj["data"] = oldData;
                recorder.record(JSON.stringify(recordObj));
            }
            updateDatas();
        }
        function addRowsBelow(count, needRecord) {
            var item = emptyCommandRow;
            if (root.tableType === "signals" )
                item = emptySignalRow;
            else if (root.tableType === "specialSignals")
                item = emptySpecialSignalRow;
            var index = tableView.currentRow + 1;
            if (tableView.rowCount <= 0 || index < 0)
                index = 0;
            for (var i = 0; i < count; ++i) {
                dataModel.insert(index, item);
            }
            if (needRecord) {
                //record
                var oldData = [];
                for (var i = 0; i < count; ++i) {
                    if (index + i >= dataModel.count)
                        break;
                    oldData.push(dataModel.get(index + i));
                }
                var recordObj = Object.create(null);
                recordObj["type"] = OperationRecorder.Add;
                recordObj["index"] = index;
                recordObj["count"] = count;
                recordObj["data"] = oldData;
                recorder.record(JSON.stringify(recordObj));
            }
            updateDatas();
        }
        function addRowsTail(count, needRecord) {
            var item = emptyCommandRow;
            if (root.tableType === "signals" )
                item = emptySignalRow;
            else if (root.tableType === "specialSignals")
                item = emptySpecialSignalRow;
            for (var i = 0; i < count; ++i) {
                dataModel.append(item);
            }
            if (needRecord) {
                //record
                var oldData = [];
                for (var i = count; i > 0; --i) {
                    oldData.push(dataModel.get(dataModel.count - i));
                }
                var recordObj = Object.create(null);
                recordObj["type"] = OperationRecorder.Add;
                recordObj["index"] = dataModel.count - count;
                recordObj["count"] = count;
                recordObj["data"] = oldData;
                recorder.record(JSON.stringify(recordObj));
            }
            updateDatas();
        }
        function removeRowsFromIndex(index, count, needRecord) {
            if (tableView.rowCount <= 0 || index < 0 || count <= 0) return;
            if (needRecord) {
                //record
                var oldData = [];
                for (var i = 0; i < count; ++i) {
                    if (index + i >= dataModel.count)
                        break;
                    oldData.push(dataModel.get(index + i));
                }
                var recordObj = Object.create(null);
                recordObj["type"] = OperationRecorder.Delete;
                recordObj["index"] = index;
                recordObj["count"] = count;
                recordObj["data"] = oldData;
                recorder.record(JSON.stringify(recordObj));
            }
            //remove
            for (var i = 0; i < count; ++i) {
                if (index >= dataModel.count )
                    break;
                dataModel.remove(index);
            }
            //update
            updateDatas();
        }
        function clear(needRecord) {
            if (needRecord) {
                var datas = [];
                for (var i = 0; i < dataModel.count; ++i) {
                    datas.push(dataModel.get(i));
                }
                //record
                var recordObj = Object.create(null);
                recordObj["type"] = OperationRecorder.Clear;
                recordObj["data"] = datas;
                recorder.record(JSON.stringify(recordObj));
            }
            dataModel.clear();
        }
        function recordModifyData (row, role, oldData, newData) {
            //record
            var recordObj = Object.create(null);
            recordObj["type"] = OperationRecorder.Modify;
            recordObj["row"] = row;
            recordObj["role"] = role;
            recordObj["data"] = oldData;
            recordObj["dataNew"] = newData;
            recorder.record(JSON.stringify(recordObj));
        }
        function checkBits() {
            var bytes = 1;
            var bits = 0;
            for (var i = 0; i < dataModel.count; ++i) {
                var obj = dataModel.get(i);
                if (obj && obj["bits"]) {
                    var currentBits = obj["bits"];
                    if (!currentBits || currentBits <= 0) {
                        var info = "非法字节提示:<br>  " + "name(" + obj["name"] + ") 起始字节号(" + bytes + ") <br><br>";
                        return info;
                    }
                    var __bits = bits + currentBits
                    if (__bits > 8) {
                        if (__bits % 8 != 0) {
                            var info = "跨字节提示:<br>  " + "name(" + obj["name"] + ") 起始字节号(" + bytes + ") <br><br>";
                            return info;
                        }
                    }
                    bits += currentBits;
                    bytes += parseInt(bits / 8);
                    bits %= 8;
                }
            }
            return "";
        }
        function checkBitLength() {
            var info = "";
            var bits = 0;
            for (var i = 0; i < dataModel.count; ++i) {
                var obj = dataModel.get(i);
                if (obj && obj["bits"]) {
                    var currentBits = obj["bits"];
                    if (!currentBits || currentBits <= 0) {
                        info = "非法字节提示:<br>  " + "name(" + obj["name"] + ") 起始字节号(" + bytes + ") <br><br>";
                        return info;
                    }
                    bits += currentBits;
                }
            }
            if ((bits % 8) != 0) {
                info = "总长度不是整字节<br>";
                return info;
            }
            return info;
        }
        function checkNames() {
            var info = "";

            //检查 名字冲突
            var names = [];
            for (var i = 0; i < dataModel.count; ++i) {
                var obj = dataModel.get(i);
                if (obj && obj["name"]) {
                    var name = obj["name"];
                    if (names.indexOf(name) >= 0) {
                        info += "名字冲突: " + name + "<br>";
                        break;
                    } else {
                        names.push(name);
                    }
                }
            }

            var array = root.fixedNames;
            //外部传进来的Array，在第二次check的时候，会莫名其妙变成空的，这里先用固定的Array
            if (root.tableType === "signals") {
                array = [ "rpm", "igOn", "theme", "language", "dateTime",
                         "enterKey", "backKey", "nextKey", "prevKey", "speed",
                         "hwVersionMax", "hwVersionMid", "hwVersionMin",
                         "mcuVersionMax", "mcuVersionMid", "mcuVersionMin", "projectModeEnabled"
                        ];
            } else if (root.tableType === "commands") {
                array = ["applicationState"];
            }

            //检查 固定名称
            if (array.length > 0) {
                for (var i = 0; i < dataModel.count; ++i) {
                    var obj = dataModel.get(i);
                    if (obj && obj["name"]) {
                        var index = array.indexOf(obj["name"]);
                        if (index >= 0) {
                            array.splice(index, 1);
                        }
                    }
                }
            }

            if (array.length > 0 && array[0] !== "") {
                info += "缺少固定的name:";
                for (var i = 0; i < array.length; ++i) {
                    if (i % 4 == 0)
                        info += "<br> ";
                    info += " " + array[i];
                }
                info += "<br>";
                return info;
            }
            return info;
        }
        function checkSpecialSignals() {
            var types = [];
            var names = [];
            for (var i = 0; i < dataModel.count; ++i) {
                var obj = dataModel.get(i);
                if (obj) {
                    var type = obj["type"];
                    var name = obj["name"];
                    if (!type) {
                        return "事件编号为0或为空";
                    } else {
                        if (types.indexOf(type) >= 0) {
                            return "事件编号 " + type + " 冲突";
                        } else {
                            types.push(type);
                        }
                    }
                    if (!name) {
                        return "事件编号" + type +", name为空";
                    } else {
                        if (names.indexOf(name) >= 0) {
                            return "name冲突:" + name ;
                        } else {
                            names.push(name);
                        }
                    }
                }
            }
            return ""
        }
        function find(text) {
            var result = []
            var key = text.toLowerCase();
            for (var i = 0; i < dataModel.count; ++i) {
                var obj = dataModel.get(i);
                var str = JSON.stringify(obj).toLowerCase();
                if ( str.indexOf(key) >= 0) {
                    result.push(i);
                }
            }
            if (result.length > 0) {
                root.findResult = result;
                root.currentFindIndex = 0;
                currentRow = root.findResult[root.currentFindIndex];
                positionViewAtRow(root.findResult[root.currentFindIndex], ListView.Beginning);
            }
        }
    }
}
