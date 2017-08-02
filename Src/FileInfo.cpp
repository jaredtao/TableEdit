#include "FileInfo.hpp"

FileInfo::FileInfo(QObject *parent) : QObject(parent) {}

QString FileInfo::baseName(const QString &filePath) {
    QFileInfo info(filePath);
    return info.baseName();
}

QString FileInfo::suffix(const QString &filePath) {
    QFileInfo info(filePath);
    return info.suffix();
}

QString FileInfo::absoluteDir(const QString &filePath) {
    QFileInfo info(filePath);
    return info.absoluteDir().absolutePath();
}

QUrl FileInfo::toUrl(const QString &filePath) {
    return QUrl::fromLocalFile(filePath);
}

QString FileInfo::toLocal(const QUrl &url) {
    return url.toLocalFile();
}
