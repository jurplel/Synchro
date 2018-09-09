#include "videoobject.h"
#include "corerenderer.h"

VideoObject::VideoObject() : QQuickFramebufferObject()
{
    mpv = mpv_create();
    mpvGL = nullptr;
    if (!mpv)
        throw std::runtime_error("failed to create mpv instance");

    if (mpv_initialize(mpv) != 0)
        throw std::runtime_error("failed to initalize mpv instance");
}

VideoObject::~VideoObject()
{
    if (mpvGL) // only initialized if something got drawn
        mpv_render_context_free(mpvGL);

    mpv_terminate_destroy(mpv);
}

QQuickFramebufferObject::Renderer *VideoObject::createRenderer() const
{
    return new CoreRenderer(const_cast<VideoObject*>(this), mpv, mpvGL);
}
