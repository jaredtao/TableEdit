#! /bin/bash
/usr/local/opt/qt/bin/macdeployqt bin/TableEdit.app -qmldir=/usr/local/opt/qt/qml -verbose=1 -dmg
mv bin/TableEdit.dmg bin/TableEdit_macos10-14_xcode10-2.dmg