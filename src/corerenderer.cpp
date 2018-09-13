#include "corerenderer.h"

#include <QtGui/QOpenGLFramebufferObject>
#include <QtQuick/QQuickWindow>

#include <QObject>
#include <QDebug>


CoreRenderer::CoreRenderer(VideoObject *newVideoObject, mpv_handle *newMpvHandler, mpv_render_context *newMpvRenderContext) : QQuickFramebufferObject::Renderer()
{
    videoObject = newVideoObject;
    mpvHandler = newMpvHandler;
    mpvRenderContext = newMpvRenderContext;
    mpv_set_wakeup_callback(mpvHandler, onMpvEvents, nullptr);
    isResizing = videoObject->getIsResizing();
}

CoreRenderer::~CoreRenderer()
{

}

// This function is called when a new FBO is needed.
// This happens on the initial frame.
QOpenGLFramebufferObject* CoreRenderer::createFramebufferObject(const QSize &size)
{
    if (!mpvRenderContext)
    {
        mpv_opengl_init_params gl_init_params{get_proc_address_mpv, nullptr, nullptr};
        mpv_render_param params[]{
            {MPV_RENDER_PARAM_API_TYPE, const_cast<char*>(MPV_RENDER_API_TYPE_OPENGL)},
            {MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &gl_init_params},
            {MPV_RENDER_PARAM_INVALID, nullptr}
        };

        if (mpv_render_context_create(&mpvRenderContext, mpvHandler, params) != 0)
            throw std::runtime_error("failed to initialize mpv GL context");
    }

    videoObject->setMpvRenderContext(mpvRenderContext);
    return QQuickFramebufferObject::Renderer::createFramebufferObject(size);
}

void CoreRenderer::render()
{
    QOpenGLFramebufferObject *fbo = framebufferObject();
    mpv_opengl_fbo mpfbo;
    mpfbo.fbo = static_cast<int>(fbo->handle());
    mpfbo.w = fbo->width();
    mpfbo.h = fbo->height();
    mpfbo.internal_format = 0;

    int flipY{0};

    mpv_render_param params[] = {
        // Specify the default framebuffer (0) as target. This will
        // render onto the entire screen. If you want to show the video
        // in a smaller rectangle or apply fancy transformations, you'll
        // need to render into a separate FBO and draw it manually.
        {MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo},
        // Flip rendering (needed due to flipped GL coordinate system).
        {MPV_RENDER_PARAM_FLIP_Y, &flipY},
        {MPV_RENDER_PARAM_INVALID, nullptr}
    };
    // See render_gl.h on what OpenGL environment mpv expects, and
    // other API details.
    mpv_render_context_render(mpvRenderContext, params);

    if (!*isResizing)
        update();
}
