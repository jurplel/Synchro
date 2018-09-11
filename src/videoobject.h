#ifndef VIDEOOBJECT_H
#define VIDEOOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <mpv/qthelper.hpp>

class VideoObject : public QQuickFramebufferObject
{
    Q_OBJECT

    Q_PROPERTY(qreal currentVideoPos READ getCurrentVideoPos WRITE setCurrentVideoPos NOTIFY currentVideoPosChanged)
    Q_PROPERTY(qreal currentVideoLength READ getCurrentVideoLength WRITE setCurrentVideoLength NOTIFY currentVideoLengthChanged)
public:
    VideoObject();
    virtual ~VideoObject();
    virtual Renderer *createRenderer() const;



    void setMpvRenderContext(mpv_render_context *value);

    qreal getCurrentVideoLength() const;
    void setCurrentVideoLength(const qreal &value);

    qreal getCurrentVideoPos() const;
    void setCurrentVideoPos(const qreal &value);

public slots:
    void command(const QVariant &args);

    void setProperty(const QString name, const QVariant &v);

    QVariant getProperty(const QString name);


signals:
    void requestUpdate();

    void currentVideoPosChanged();
    void currentVideoLengthChanged();

protected:
    void performUpdate();


private:
    mpv_handle *mpvHandler;
    mpv_render_context *mpvRenderContext;

    QTimer* guiUpdateTimer;
    qreal currentVideoPos;
    qreal currentVideoLength;
};

#endif // VIDEOOBJECT_H
