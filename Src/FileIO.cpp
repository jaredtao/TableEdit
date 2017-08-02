#include "FileIO.hpp"

FileIO::FileIO(QObject *parent) : QObject(parent) {}

bool FileIO::writeFile(const QString &filePath, const QString &data) {
    QFile file(filePath);
    if (file.open(QFile::WriteOnly)) {
        //这里使用QJsonDocument转换一次，规避windows和Linux平台 不一致
        auto json = QJsonDocument::fromJson(data.toUtf8());
        auto data  = json.toJson();

        file.write(data);
        file.close();
        mError.clear();
        return true;
    } else {
        mError = "FileName: " + file.fileName() + " Error: " + file.errorString();
        return false;
    }
}

QString FileIO::readFile(const QString &filePath) {
    QString ret;
    QFile file(filePath);
    if (file.open(QFile::ReadOnly)) {
        auto bytes = file.readAll();
        //如果Json中的字符串被手动编辑时，按下了回车键，qml中的JSON.parse会认不出来。所以这里用QJsonDocument格式化一下，再给出去。
        auto json = QJsonDocument::fromJson(bytes);
        ret = QString(json.toJson());

        file.close();
        mError.clear();
    } else {
        ret.clear();
        mError = "FileName: " + file.fileName() + " Error: " + file.errorString();
    }
    return ret;
}

const QString &FileIO::errorString() {
    return mError;
}
