#ifndef VIDEOOBJECT_H
#define VIDEOOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <mpv/qthelper.hpp>

class VideoObject : public QQuickFramebufferObject
{
    Q_OBJECT

    Q_PROPERTY(qreal currentVideoPos READ getCurrentVideoPos WRITE setCurrentVideoPos)
    Q_PROPERTY(qreal currentVideoLength READ getCurrentVideoLength)
public:
    VideoObject();
    virtual ~VideoObject();
    virtual Renderer *createRenderer() const;



    void setMpvRenderContext(mpv_render_context *value);

    qreal getCurrentVideoLength() const;

    qreal getCurrentVideoPos() const;
    void setCurrentVideoPos(const qreal &value);


signals:
    void requestUpdate();

    void updateGui();


public slots:
    void command(const QVariant &args);

    void setProperty(const QString name, const QVariant &v);

    QVariant getProperty(const QString name);


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
