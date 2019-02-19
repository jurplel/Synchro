﻿#ifndef VIDEOOBJECT_H
#define VIDEOOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <mpv/qthelper.hpp>

class VideoObject : public QQuickFramebufferObject
{
    Q_OBJECT

    Q_PROPERTY(qreal currentVideoPos READ getCurrentVideoPos WRITE setCurrentVideoPos NOTIFY currentVideoPosChanged)
    Q_PROPERTY(bool paused READ getPaused WRITE setPaused NOTIFY pausedChanged)
    Q_PROPERTY(bool muted READ getMuted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(qreal currentVolume READ getCurrentVolume WRITE setCurrentVolume NOTIFY currentVolumeChanged)


public:
    VideoObject();
    virtual ~VideoObject();

    virtual Renderer *createRenderer() const;

    void setMpvRenderContext(mpv_render_context *value);

    qreal getCurrentVideoPos() const;
    void setCurrentVideoPos(const qreal &value);

    bool getPaused() const;
    void setPaused(bool value);

    bool getMuted() const;
    void setMuted(bool value);

    qreal getCurrentVolume() const;
    void setCurrentVolume(const qreal &value);

    bool getSeeking() const;
    void setSeeking(bool value);

signals:
    void pausedChanged();
    void mutedChanged();
    void currentVolumeChanged();
    void currentVideoPosChanged();

public slots:
    void seek(const qreal newPos);

    void command(const QVariant &args);

    void setProperty(const QString name, const QVariant &v);

    QVariant getProperty(const QString name);

private:
    mpv_handle *mpvHandler;
    mpv_render_context *mpvRenderContext;

    QTimer *currentVideoPosTimer;

    QTimer *seekTimer;
    bool seeking;

    qreal currentVideoPos;
    qreal currentVolume;
    bool paused;
    bool muted;

    static void onMpvEvents(void *videoObject)
    {
        Q_UNUSED(videoObject);
    }
};

#endif // VIDEOOBJECT_H
