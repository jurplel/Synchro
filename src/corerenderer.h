#ifndef CORERENDERER_H
#define CORERENDERER_H

#include "videoobject.h"

#include <QOpenGLContext>

class CoreRenderer : public QQuickFramebufferObject::Renderer
{

public:
    CoreRenderer(VideoObject *newVideoObject, mpv_handle *mpvHandler);
    ~CoreRenderer() override;

    QOpenGLFramebufferObject* createFramebufferObject(const QSize &size) override;

    void render() override;

    void synchronize(QQuickFramebufferObject *item) override;

private:
    VideoObject* videoObject;
    mpv_handle *mpvHandle;
    mpv_render_context *mpvRenderContext;


    static void *get_proc_address_mpv(void *ctx, const char *name)
    {
        Q_UNUSED(ctx)

        QOpenGLContext *glctx = QOpenGLContext::currentContext();
        if (!glctx) return nullptr;

        return reinterpret_cast<void *>(glctx->getProcAddress(QByteArray(name)));
    }

    static void onRedraw(void *videoObject)
    {
        auto vidObj = reinterpret_cast<VideoObject*>(videoObject);

        QMetaObject::invokeMethod(vidObj, "update", Qt::QueuedConnection);
    }
};

#endif // CORERENDERER_H
