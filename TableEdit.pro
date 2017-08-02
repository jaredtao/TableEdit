QT += qml quick

CONFIG += c++11

SOURCES += Src/Main.cpp \
    Src/FileIO.cpp \
    Src/FileInfo.cpp \
    Src/TableStatus.cpp \
    Src/OperationRecorder.cpp

RESOURCES += Qml.qrc \
    Image.qrc \
    Json.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

HEADERS += \
    Src/FileIO.hpp \
    Src/FileInfo.hpp \
    Src/TableStatus.hpp \
    Src/OperationRecorder.hpp
