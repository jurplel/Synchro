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

    qreal getPercentPos() const;
    void setPercentPos(const qreal &value);

    bool getPaused() const;
    void setPaused(bool value);

    bool getMuted() const;
    void setMuted(bool value);

    qreal getCurrentVolume() const;
    void setCurrentVolume(const qreal &value);

    QString getTimePosString() const;
    void setTimePosString(const QString &value);

    QString getDurationString() const;
    void setDurationString(const QString &value);

    bool getSeeking() const;
    void setSeeking(bool value);


signals:
    void pausedChanged();
    void mutedChanged();
    void currentVolumeChanged();
    void percentPosChanged();
    void timePosStringChanged();
    void durationStringChanged();

public slots:
    void onMpvEvents();

    void seek(const qreal newPos);

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
