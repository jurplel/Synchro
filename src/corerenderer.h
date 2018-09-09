#ifndef CORERENDERER_H
#define CORERENDERER_H

#include "videoobject.h"

#include <QOpenGLContext>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <mpv/qthelper.hpp>

class CoreRenderer : public QQuickFramebufferObject::Renderer
{

public:
    CoreRenderer(VideoObject *newVideoObject, mpv_handle *mpv, mpv_render_context *mpvGL);
    ~CoreRenderer();

    QOpenGLFramebufferObject* createFramebufferObject(const QSize &size);

    void render();

private:
    VideoObject* videoObject;
    mpv_handle *mpv;
    mpv_render_context *mpvGL;

    static void *get_proc_address_mpv(void *ctx, const char *name)
    {
        Q_UNUSED(ctx)

        QOpenGLContext *glctx = QOpenGLContext::currentContext();
        if (!glctx) return nullptr;

        return reinterpret_cast<void *>(glctx->getProcAddress(QByteArray(name)));
    }
};

#endif // CORERENDERER_H
