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
    Q_PROPERTY(bool paused READ getPaused WRITE setPaused NOTIFY pausedChanged)
    Q_PROPERTY(bool muted READ getMuted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(qreal currentVolume READ getCurrentVolume WRITE setCurrentVolume NOTIFY currentVolumeChanged)


public:
    VideoObject();
    virtual ~VideoObject();

    virtual Renderer *createRenderer() const;

    void handleMpvEvent(mpv_event *event);

    qreal getPercentPos() const { return percentPos; }
    void setPercentPos(const qreal &value) { setProperty("percentPos", value); percentPos = value; emit percentPosChanged(); }

    bool getPaused() const { return paused; }
    void setPaused(bool value) { setProperty("pause", value); paused = value; emit pausedChanged(); }

    bool getMuted() const { return muted; }
    void setMuted(bool value) { setProperty("mute", value); muted = value; emit mutedChanged(); }

    qreal getCurrentVolume() const { return currentVolume; }
    void setCurrentVolume(const qreal &value);

    QString getTimePosString() const { return timePosString; }
    void setTimePosString(const QString &value) { timePosString = value; emit timePosStringChanged(); }

    QString getDurationString() const { return durationString; }
    void setDurationString(const QString &value) { durationString = value; emit durationStringChanged(); }

    bool getSeeking() const { return seeking; }
    void setSeeking(bool value) { seeking = value; }


signals:
    void pausedChanged();
    void mutedChanged();
    void currentVolumeChanged();
    void percentPosChanged();
    void timePosStringChanged();
    void durationStringChanged();

public slots:
    void onMpvEvents();

    void seek(const qreal newPos, bool useKeyframes);

    void command(const QVariant &args);

    void setProperty(const QString name, const QVariant &v);

    QVariant getProperty(const QString name);

    void loadFile(const QString &fileName);

private:
    mpv_handle *mpvHandler;

    QTimer *seekTimer;
    bool seeking;

    qreal percentPos;
    QString timePosString;
    QString durationString;
    qreal currentVolume;
    bool paused;
    bool muted;
};

#endif // VIDEOOBJECT_H
