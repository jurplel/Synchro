#ifndef VIDEOOBJECT_H
#define VIDEOOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <mpv/qthelper.hpp>

class VideoObject : public QQuickFramebufferObject
{
    Q_OBJECT

public:
    VideoObject();
    virtual ~VideoObject();
    virtual Renderer *createRenderer() const;


public slots:
    void command(const QVariant &args);

signals:
    void requestUpdate();

protected:
    void performUpdate();


private:
    mpv_handle *mpvHandler;
    mpv_render_context *mpvRenderContext;

};

#endif // VIDEOOBJECT_H
