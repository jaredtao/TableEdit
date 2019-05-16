#! /bin/bash
wget https://github.com/probonopd/linuxdeployqt/releases/download/6/linuxdeployqt-6-x86_64.AppImage
mv linuxdeployqt-6-x86_64.AppImage linuxdeployqt.AppImage
chmod a+x linuxdeployqt.AppImage
./linuxdeployqt.AppImage bin/TableEdit -qmake="/opt/qt512/bin/qmake" -qmldir="/opt/qt512/qml" -appimage
move bin/TableEdit.AppImage bin/TableEdit_ubuntu_xenial_x64.AppImage
