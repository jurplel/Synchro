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

private:
    mpv_handle *mpv;
    mpv_render_context *mpvGL;

};

#endif // VIDEOOBJECT_H
