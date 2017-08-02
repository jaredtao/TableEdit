#pragma once

#include <QUrl>
#include <QFile>
#include <QObject>
#include <QString>
#include <QJsonDocument>

//为qml提供文件读写
class FileIO : public QObject {
    Q_OBJECT
public:
    explicit FileIO(QObject *parent = nullptr);

    //写文件，成功返回true，失败返回false，失败的错误信息可以通过errorString获取
    Q_INVOKABLE bool writeFile(const QString &filePath, const QString &data);

    //读文件，返回值为文件内容，失败返回空QString，失败的错误信息可以通过errorString获取，文件为空属于错误信息的一种
    Q_INVOKABLE QString readFile(const QString &filePath);
    //获取错误信息
    Q_INVOKABLE const QString &errorString();
private:
    QString mError;
};
