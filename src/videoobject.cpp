#include "videoobject.h"
#include "corerenderer.h"

#include <QtQuick/QQuickWindow>
#include <QStringList>

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
    if (mpvRenderContext)
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

void VideoObject::setProperty(const QString name, const QVariant &v)
{
    mpv::qt::set_property(mpvHandler, name, v);
}

void VideoObject::getProperty(const QString name)
{
    mpv::qt::get_property(mpvHandler, name);
}


mpv_render_context *VideoObject::getMpvRenderContext() const
{
    return mpvRenderContext;
}

void VideoObject::setMpvRenderContext(mpv_render_context *value)
{
    mpvRenderContext = value;
}

mpv_handle *VideoObject::getMpvHandler() const
{
    return mpvHandler;
}

void VideoObject::setMpvHandler(mpv_handle *value)
{
    mpvHandler = value;
}
