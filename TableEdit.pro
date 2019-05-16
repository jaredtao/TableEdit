QT += qml quick

CONFIG += c++11

HEADERS += \
    Src/FileIO.hpp \
    Src/FileInfo.hpp \
    Src/TableStatus.hpp \
    Src/OperationRecorder.hpp

SOURCES += Src/Main.cpp \
    Src/FileIO.cpp \
    Src/FileInfo.cpp \
    Src/TableStatus.cpp \
    Src/OperationRecorder.cpp

RESOURCES += Qml.qrc \
    Image.qrc \
    Json.qrc

DESTDIR = bin

OTHER_FILES += README.md \
    appveyor.yml \
    .travis.yml
macos {

}

linux {
OTHER_FILES += \
    scripts/ubuntu/install.sh \
    scripts/ubuntu/build.sh \
    scripts/ubuntu/deploy.sh
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

