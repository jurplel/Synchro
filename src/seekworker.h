#ifndef SEEKWORKER_H
#define SEEKWORKER_H

#include <QObject>

#include <mpv/client.h>
#include <mpv/qthelper.hpp>

class SeekWorker : public QObject
{
    Q_OBJECT
public:
    explicit SeekWorker(QObject *parent = nullptr);

signals:

public slots:
    void seek(void *mpvHandler, const qreal newPos);

private:
    qreal lastSeek;
};

#endif // SEEKWORKER_H
