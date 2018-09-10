#include "videoobject.h"
#include "corerenderer.h"

#include <QtQuick/QQuickWindow>

#include <QDebug>

VideoObject::VideoObject() : QQuickFramebufferObject()
{
    mpvHandler = mpv_create();
    mpvRenderContext = nullptr;
    if (!mpvHandler)
        throw std::runtime_error("failed to create mpv instance");

    mpv::qt::set_property(mpvHandler, "terminal", "yes");

    if (mpv_initialize(mpvHandler) != 0)
        throw std::runtime_error("failed to initalize mpv instance");

    mpv::qt::set_property(mpvHandler, "hwdec", "auto");

    connect(this, &VideoObject::requestUpdate, this, &VideoObject::performUpdate);
}

VideoObject::~VideoObject()
{
    if (mpvRenderContext) // only initialized if something got drawn
        mpv_render_context_free(mpvRenderContext);

    mpv_terminate_destroy(mpvHandler);
}

QQuickFramebufferObject::Renderer *VideoObject::createRenderer() const
{
    window()->setPersistentOpenGLContext(true);
    window()->setPersistentSceneGraph(true);
    return new CoreRenderer(const_cast<VideoObject*>(this), mpvHandler, mpvRenderContext);
}

void VideoObject::performUpdate()
{
    update();
}

void VideoObject::command(const QVariant &args)
{
    mpv::qt::command(mpvHandler, args);
}
