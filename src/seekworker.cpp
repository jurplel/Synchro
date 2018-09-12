#include "seekworker.h"
#include <QDebug>
#include <QThread>

SeekWorker::SeekWorker(QObject *parent) : QObject(parent)
{
    lastSeek = 0;
}

void SeekWorker::seek(void *mpvHandler, const qreal newPos)
{
    if (newPos != lastSeek || lastSeek == 0)
    {
        mpv::qt::command(reinterpret_cast<mpv_handle*>(mpvHandler), QStringList() << "seek" << QString::number(newPos) << "absolute-percent+keyframes");
        lastSeek = newPos;
    }
}
