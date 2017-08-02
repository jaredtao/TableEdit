#include "TableStatus.hpp"

TableStatus::TableStatus(QObject *parent) : QObject(parent) {}

void TableStatus::setHasSaved(bool hasSaved) {
    if (mHasSaved == hasSaved) return;
    mHasSaved = hasSaved;
    emit hasSavedChanged(hasSaved);
}

void TableStatus::setSaveWithIndented(bool saveWithIndented) {
    if (mSaveWithIndented == saveWithIndented) return;

    mSaveWithIndented = saveWithIndented;
    emit saveWithIndentedChanged(mSaveWithIndented);
}

void TableStatus::setSourceJsonFilePath(const QString &sourceJsonFilePath) {
    if (mSourceJsonFilePath == sourceJsonFilePath) return;

    mSourceJsonFilePath = sourceJsonFilePath;
    emit sourceJsonFilePathChanged(mSourceJsonFilePath);
}

void TableStatus::setSignalNames(const QStringList &signalNames) {
    if (mSignalNames == signalNames) return;

    mSignalNames = signalNames;
    emit signalNamesChanged(mSignalNames);
}

void TableStatus::setSpecialSignalNames(const QStringList &specialSignalNames) {
    if (mSpecialSignalNames == specialSignalNames) return;

    mSpecialSignalNames = specialSignalNames;
    emit specialSignalNamesChanged(mSpecialSignalNames);
}

void TableStatus::setCommandNames(const QStringList &commandNames) {
    if (mCommandNames == commandNames) return;

    mCommandNames = commandNames;
    emit commandNamesChanged(mCommandNames);
}

void TableStatus::setModelNames(const QStringList &modelNames) {
    if (mModelNames == modelNames) return;

    mModelNames = modelNames;
    emit modelNamesChanged(mModelNames);
}


bool TableStatus::hasSaved() const {
    return mHasSaved;
}

bool TableStatus::saveWithIndented() const {
    return mSaveWithIndented;
}

int TableStatus::getSignalBitByName(const QString &name) {
    return frameBits(SIGNALS_STR, name);
}

int TableStatus::getSpecialSignalBitByName(const QString &name) {
    return frameBits(SPECIAL_SIGNALS_STR, name);
}

int TableStatus::getCommandBitByName(const QString &name) {
    return frameBits(COMMANDS_STR, name);
}

void TableStatus::setmodelKey(const QString &autoCompleterKey) {
    mModelNames.clear();
    mMcuSignalNames.clear();
    mMcuSignalNames = mSignalNames + mSpecialSignalNames + mCommandNames;
    for(int i = 0; i < mMcuSignalNames.count(); ++i) {
        if(mMcuSignalNames.at(i).startsWith(autoCompleterKey)
                && mMcuSignalNames.at(i) != autoCompleterKey) {
            mModelNames << mMcuSignalNames.at(i);
        }
    }
}


void TableStatus::setMcuData(const QString &mcuData) {
    mMcuData = QJsonDocument::fromJson(mcuData.toUtf8());
    setSignalNames(frameNames(SIGNALS_STR));
    setSpecialSignalNames(frameNames(SPECIAL_SIGNALS_STR));
    setCommandNames(frameNames(COMMANDS_STR));
}

QString TableStatus::loadTemplateFile(const QString &filePath) {

    QFile sourceFile(filePath);
    if (!sourceFile.open(QFile::ReadOnly)) {
        return sourceFile.fileName() + sourceFile.errorString();
    }
    auto data = sourceFile.readAll();
    sourceFile.close();

    QFile targetFile(tempFilePath());
    if (targetFile.exists()) {
        targetFile.remove();
    } else {
        QString path = QCoreApplication::applicationDirPath() + "/PreviewWorkingDir/Config";
        QDir dir(path);
        if (!dir.exists()) {
            dir.mkpath(path);
        }
    }
    if (!targetFile.open(QFile::WriteOnly)) {
        return targetFile.fileName() + targetFile.errorString();
    }
    targetFile.write(data);
    targetFile.close();

    setSourceJsonFilePath("");
    setSourceJsonFilePath(tempFilePath());
    return QString("");
}

QString TableStatus::tempFilePath() const {
    return QCoreApplication::applicationDirPath() + "/Mcu.json";
}

const QStringList &TableStatus::signalNames() const {
    return mSignalNames;
}

const QStringList &TableStatus::specialSignalNames() const {
    return mSpecialSignalNames;
}

const QStringList &TableStatus::commandNames() const {
    return mCommandNames;
}

const QStringList &TableStatus:: modelNames() const {
    return mModelNames;
}

const QString &TableStatus::sourceJsonFilePath() const {
    return mSourceJsonFilePath;
}

QStringList TableStatus::frameNames(const QString &frame) {
    QStringList ret;
    auto rootObj = mMcuData.object();
    if (rootObj.contains(frame)) {
        auto frameArray = rootObj[frame].toArray();
        for (auto i = 0; i < frameArray.count(); ++i) {
            auto obj = frameArray[i].toObject();
            if (!obj.isEmpty() && obj.contains(NAME_STR)) {
                if (!obj[NAME_STR].toString().isEmpty())
                    ret.append(obj[NAME_STR].toString());
            }
        }
    }
    return ret;
}

int TableStatus::frameBits(const QString &frame, const QString &name) {
    int ret = 0;
    auto rootObj = mMcuData.object();
    if (rootObj.contains(frame)) {
        auto frameArray = rootObj[frame].toArray();
        for (auto i = 0; i < frameArray.count(); i++) {
            auto obj = frameArray[i].toObject();
            if (!obj.isEmpty() && obj.contains(NAME_STR)) {
                if (obj[NAME_STR].toString() == name) {
                    ret = obj[BITS_STR].toInt();
                    break;
                }
            }
        }
    }
    return ret;
}

