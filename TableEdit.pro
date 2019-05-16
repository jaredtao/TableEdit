QT += qml quick

CONFIG += c++11
QMAKE_CFLAGS += -source-charset:utf-8
QMAKE_CXXFLAGS += -source-charset:utf-8
HEADERS += \
    Src/FileIO.hpp \
    Src/FileInfo.hpp \
    Src/TableStatus.hpp \
    Src/OperationRecorder.hpp \
    Src/Logger/Logger.h \
    Src/Logger/LoggerTemplate.h

SOURCES += Src/Main.cpp \
    Src/FileIO.cpp \
    Src/FileInfo.cpp \
    Src/TableStatus.cpp \
    Src/OperationRecorder.cpp \
    Src/Logger/Logger.cpp

RESOURCES += Qml.qrc \
    Image.qrc \
    Json.qrc

DESTDIR = bin
CONFIG(debug, debug|release) {
    MOC_DIR = build/debug/moc
    RCC_DIR = build/debug/rcc
    UI_DIR = build/debug/ui
    OBJECTS_DIR = build/debug/obj
} else {
    MOC_DIR = build/release/moc
    RCC_DIR = build/release/rcc
    UI_DIR = build/release/ui
    OBJECTS_DIR = build/release/obj
}



OTHER_FILES += README.md \
    appveyor.yml \
    .travis.yml

macos {
OTHER_FILES += \
    scripts/macos/install.sh \
    scripts/macos/build.sh \
    scripts/macos/deploy.sh
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

