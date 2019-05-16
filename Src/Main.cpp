#include <QQmlEngine>
#include <QQuickView>
#include <QQmlContext>
#include <QGuiApplication>

#include "Logger/Logger.h"
#include "FileIO.hpp"
#include "FileInfo.hpp"
#include "TableStatus.hpp"
#include "OperationRecorder.hpp"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    Logger::initLog();

    qmlRegisterType<FileIO>("Tools", 1, 0, "FileIO");
    qmlRegisterType<FileInfo>("Tools", 1, 0, "FileInfo");
    qmlRegisterType<OperationRecorder>("Tools", 1, 0, "OperationRecorder");

    TableStatus tableStatus;
    QQuickView view;
    view.engine()->rootContext()->setContextProperty("TableStatus", &tableStatus);
    view.setSource(QUrl("qrc:/Qml/Main.qml"));
    view.show();
    return app.exec();
}
