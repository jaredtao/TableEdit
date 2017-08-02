#pragma once

#include <QUrl>
#include <QDir>
#include <QObject>
#include <QString>
#include <QFileInfo>

//为qml提供文件路径处理、文件名处理相关的功能
class FileInfo : public QObject {
    Q_OBJECT
public:
    explicit FileInfo(QObject *parent = 0);

    //这些API的功能，请参考QFileInfo的文档。
    Q_INVOKABLE QString baseName(const QString &filePath);
    Q_INVOKABLE QString suffix(const QString &filePath);
    Q_INVOKABLE QString absoluteDir(const QString &filePath);
    //转成QUrl
    Q_INVOKABLE QUrl toUrl(const QString &filePath);
    //转成local
    Q_INVOKABLE QString toLocal(const QUrl &url);
};
