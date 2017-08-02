#include "OperationRecorder.hpp"

OperationRecorder::OperationRecorder(QObject *parent) : QObject(parent) {}

void OperationRecorder::record(const QString &data) {
    mUndoQueue.push_back(data);
    //Note 新增记录时，要把redo队列清空，保证时间上的正确性
    mRedoQueue.clear();
    updateCount();
}

QString OperationRecorder::undo() {
    if (mUndoQueue.length() <= 0) {
        return QString();
    }
    auto ret = mUndoQueue.last();
    mRedoQueue.push_back(ret);
    mUndoQueue.pop_back();
    updateCount();
    return ret;
}

QString OperationRecorder::redo() {
    if (mRedoQueue.length() <= 0) {
        return QString();
    }
    auto ret = mRedoQueue.last();
    mUndoQueue.push_back(ret);
    mRedoQueue.pop_back();
    updateCount();
    return ret;
}

void OperationRecorder::clear() {
    mUndoQueue.clear();
    mRedoQueue.clear();
    updateCount();
}

int OperationRecorder::undoCount() const {
    return mUndoCount;
}

int OperationRecorder::redoCount() const {
    return mRedoCount;
}

void OperationRecorder::setUndoCount(int undoCount) {
    if (mUndoCount == undoCount) return;

    mUndoCount = undoCount;
    emit undoCountChanged(mUndoCount);
}

void OperationRecorder::setRedoCount(int redoCount) {
    if (mRedoCount == redoCount) return;

    mRedoCount = redoCount;
    emit redoCountChanged(mRedoCount);
}

void OperationRecorder::updateCount() {
    setRedoCount(mRedoQueue.length());
    setUndoCount(mUndoQueue.length());
}
