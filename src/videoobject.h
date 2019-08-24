#ifndef VIDEOOBJECT_H
#define VIDEOOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <mpv/qthelper.hpp>

class VideoObject : public QQuickFramebufferObject
{
    Q_OBJECT

    Q_PROPERTY(qreal percentPos READ getPercentPos WRITE setPercentPos NOTIFY percentPosChanged)
    Q_PROPERTY(QString timePosString READ getTimePosString WRITE setTimePosString NOTIFY timePosStringChanged)
    Q_PROPERTY(QString durationString READ getDurationString WRITE setDurationString NOTIFY durationStringChanged)
    Q_PROPERTY(qreal duration READ getDuration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(bool isPaused READ getIsPaused WRITE setIsPaused NOTIFY isPausedChanged)
    Q_PROPERTY(bool muted READ getMuted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(qreal currentVolume READ getCurrentVolume WRITE setCurrentVolume NOTIFY currentVolumeChanged)
    Q_PROPERTY(QVariantList chapterList READ getChapterList WRITE setChapterList NOTIFY chapterListChanged)
    Q_PROPERTY(QVariantList cachedList READ getCachedList WRITE setCachedList NOTIFY chapterListChanged)


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

    bool getSeeking() const { return seeking; }
    void setSeeking(bool value) { seeking = value; }


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

    void seeked(qreal percentPos, bool dragged);
    void paused();

public slots:
    void poll();

    void onMpvEvents();

    void setProperty(const QString name, const QVariant &v);

    QVariant getProperty(const QString name);

    void seek(const qreal newPos, const bool useKeyframes, const bool synchronize = false);

    void pause(bool newPaused);

    void command(const QVariant &args);

    void loadFile(const QString &fileName);

    void back();

    void forward();

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

};

#endif // VIDEOOBJECT_H
