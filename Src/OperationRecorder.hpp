#pragma once

#include <QObject>
#include <QString>
#include <QVector>

//为Qml提供一个数据结构，用来记录用户增,删,改,清空 操作
//这里把数据当作一个QString，不关心内容是什么，只实现undo、redo的逻辑
//数据QString的具体内容在qml中，是一个json格式的字符串

class OperationRecorder : public QObject {
    Q_OBJECT
    Q_PROPERTY(int undoCount READ undoCount WRITE setUndoCount NOTIFY undoCountChanged)
    Q_PROPERTY(int redoCount READ redoCount WRITE setRedoCount NOTIFY redoCountChanged)
public:
    explicit OperationRecorder(QObject *parent = nullptr);

    enum Type {
        Add = 0,
        Delete,
        Clear,
        Modify
    };
    Q_ENUMS(Type)

    //添加一份记录数据
    Q_INVOKABLE void record(const QString& data);

    //获取要撤销的数据，可能为空
    Q_INVOKABLE QString undo();

    //获取要恢复的数据，可能为空
    Q_INVOKABLE QString redo();

    //清空记录
    Q_INVOKABLE void clear();

    int undoCount() const;
    int redoCount() const;

public slots:
    void setUndoCount(int undoCount);

    void setRedoCount(int redoCount);

signals:
    void undoCountChanged(int undoCount);

    void redoCountChanged(int redoCount);

private:
    //更新 count
    void updateCount();

    QVector<QString> mUndoQueue, mRedoQueue;
    int mUndoCount = 0;
    int mRedoCount = 0;
};
