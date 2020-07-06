#ifndef VIDEOOBJECT_H
#define VIDEOOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include "qthelper.hpp"

class VideoObject : public QQuickFramebufferObject
{
    Q_OBJECT

    Q_PROPERTY(qreal percentPos READ getPercentPos NOTIFY percentPosChanged)
    Q_PROPERTY(QString timePosString READ getTimePosString NOTIFY timePosStringChanged)
    Q_PROPERTY(QString durationString READ getDurationString NOTIFY durationStringChanged)
    Q_PROPERTY(qreal duration READ getDuration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(bool isPaused READ getIsPaused WRITE setIsPaused NOTIFY isPausedChanged)
    Q_PROPERTY(bool muted READ getMuted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(qreal currentVolume READ getCurrentVolume WRITE setCurrentVolume NOTIFY currentVolumeChanged)
    Q_PROPERTY(QVariantList chapterList READ getChapterList NOTIFY chapterListChanged)
    Q_PROPERTY(QVariantList cachedList READ getCachedList NOTIFY chapterListChanged)
    Q_PROPERTY(QString currentFileName READ getCurrentFileName NOTIFY currentFileNameChanged)
    Q_PROPERTY(int currentFileSize READ getCurrentFileSize NOTIFY currentFileSizeChanged)
    Q_PROPERTY(QStringList audioTrackList READ getAudioTrackList)
    Q_PROPERTY(QStringList subTrackList READ getSubTrackList)
    Q_PROPERTY(QStringList videoTrackList READ getVideoTrackList)
    Q_PROPERTY(int maxVolume READ getMaxVolume WRITE setMaxVolume NOTIFY maxVolumeChanged)


public:
    VideoObject();
    virtual ~VideoObject();

    virtual Renderer *createRenderer() const;

    void handleMpvEvent(const mpv_event *event);

    qreal getPercentPos() const { return percentPos; }
    void setPercentPos(const qreal &value) { setProperty("percentPos", value); percentPos = value; emit percentPosChanged(); }

    bool getIsPaused() const { return isPaused; }
    void setIsPaused(bool value) { setProperty("pause", value); isPaused = value; emit isPausedChanged(); }

    bool getMuted() const { return muted; }
    void setMuted(bool value) { setProperty("mute", value); muted = value; emit mutedChanged(); }

    qreal getCurrentVolume() const { return currentVolume; }
    void setCurrentVolume(const qreal &value);

    QString getTimePosString() const { return timePosString; }
    void setTimePosString(const QString &value) { timePosString = value; emit timePosStringChanged(); }

    QString getDurationString() const { return durationString; }
    void setDurationString(const QString &value) { durationString = value; emit durationStringChanged(); }

    qreal getDuration() const { return duration; }
    void setDuration(const qreal &value) { duration = value; emit durationChanged(); }

    QVariantList getChapterList() const { return chapterList; }
    void setChapterList(const QVariantList &value) { chapterList = value; emit chapterListChanged(); }

    QVariantList getCachedList() const { return cachedList; }
    void setCachedList(const QVariantList &value) { cachedList = value; emit cachedListChanged(); }

    QString getCurrentFileName() const { return currentFileName; }
    void setCurrentFileName(const QString &value) { currentFileName = value; emit currentFileNameChanged(); }

    int getCurrentFileSize() const { return currentFileSize; }
    void setCurrentFileSize(const int &value) { currentFileSize = value; emit currentFileSizeChanged(); }

    QStringList getAudioTrackList() const { return audioTrackList; }
    QStringList getSubTrackList() const { return subTrackList; }
    QStringList getVideoTrackList() const { return videoTrackList; }

    bool getSeeking() const { return seeking; }
    void setSeeking(bool value) { seeking = value; }

    int getMaxVolume() const { return maxVolume; }
    void setMaxVolume(int value) { maxVolume = value; emit maxVolumeChanged(); }

signals:
    void isPausedChanged();
    void mutedChanged();
    void currentVolumeChanged();
    void percentPosChanged();
    void timePosStringChanged();
    void durationStringChanged();
    void durationChanged();
    void chapterListChanged();
    void cachedListChanged();
    void currentFileNameChanged();
    void currentFileSizeChanged();
    void maxVolumeChanged();

    void trackListsUpdated();

    void fileChanged();

    void seeked(qreal percentPos, bool dragged);
    void paused();


public slots:
    void poll();

    void onMpvEvents();

    void setProperty(const QString name, const QVariant &v);

    QVariant getProperty(const QString name);

    void seek(const qreal newPos, const bool useKeyframes, const bool synchronize = false);

    void seekBy(const qreal seconds);

    void pause(bool newPaused);

    void command(const QVariant &args);

    void loadFile(const QString &fileName);

    void back();

    void forward();

    void setVideoTrack(int id);

    void setAudioTrack(int id);

    void setSubTrack(int id);

private:
    mpv_handle *mpvHandler;

    QTimer *pollTimer;
    QTimer *seekTimer;
    bool seeking;

    qreal percentPos;
    QString timePosString;
    QString durationString;
    qreal duration;
    bool isPaused;
    bool muted;
    qreal currentVolume;
    QVariantList chapterList;
    QVariantList cachedList;

    QStringList audioTrackList;
    QStringList subTrackList;
    QStringList videoTrackList;

    QString currentFileName;
    qlonglong currentFileSize;

    int maxVolume;
};

#endif // VIDEOOBJECT_H
