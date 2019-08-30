#ifndef TRACKHANDLER_H
#define TRACKHANDLER_H

#include <QObject>

#include <mpv/client.h>
#include <mpv/qthelper.hpp>

class TrackHandler : public QObject
{
    Q_OBJECT
public:
    explicit TrackHandler(mpv_handle *newMpvHandler, QObject *parent = nullptr);

    struct Track {
        int id;
        QString type;
        QString title;
        QString lang;
        QString codec;
        QString readable;
    };

    void updateTracks();

    QVariant getTrackProperty(QString property);

public slots:
    QStringList getAudioTrackList();
    QStringList getSubTrackList();
    QStringList getVideoTrackList();

private:
    mpv_handle *mpvHandler;

    QList<Track> trackList;
};

#endif // TRACKHANDLER_H
