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
    CoreRenderer(VideoObject *newVideoObject, mpv_handle *mpvHandler, mpv_render_context *mpvRenderContext);
    ~CoreRenderer();

    QOpenGLFramebufferObject* createFramebufferObject(const QSize &size);

    void render();

    void redraw(void *ctx);

private:
    VideoObject* videoObject;
    mpv_handle *mpvHandler;
    mpv_render_context *mpvRenderContext;

    static void *get_proc_address_mpv(void *ctx, const char *name)
    {
        Q_UNUSED(ctx)

        QOpenGLContext *glctx = QOpenGLContext::currentContext();
        if (!glctx) return nullptr;

        return reinterpret_cast<void *>(glctx->getProcAddress(QByteArray(name)));
    }

    static void onMpvEvents(void *ctx)
    {
        Q_UNUSED(ctx)
    }

    static void onMpvRedraw(void *ctx)
    {
        VideoObject* videoObject = reinterpret_cast<VideoObject*>(ctx);
        emit videoObject->requestUpdate();
    }
};

#endif // CORERENDERER_H
