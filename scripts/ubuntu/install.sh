#! /bin/bash
sudo add-apt-repository ppa:beineri/opt-qt-5.12.3-xenial -y
sudo apt-get update -qq
sudo apt-get install -y libglew-dev libglfw3-dev
sudo apt-get install -y qt512-meta-minimal
wget https://github.com/probonopd/linuxdeployqt/releases/download/6/linuxdeployqt-6-x86_64.AppImage
mv linuxdeployqt-6-x86_64.AppImage linuxdeployqt.AppImage
chmod +x linuxdeployqt.AppImage
