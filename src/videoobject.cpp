#include "videoobject.h"
#include "corerenderer.h"

#include <QtQuick/QQuickWindow>
#include <QStringList>
#include <QTimer>

#include <QDebug>

VideoObject::VideoObject() : QQuickFramebufferObject()
{
    isResizing = false;
    paused = true;

    mpvHandler = mpv_create();
    mpvRenderContext = nullptr;

    if (!mpvHandler)
        throw std::runtime_error("failed to create mpv instance");

    if (mpv_initialize(mpvHandler) != 0)
        throw std::runtime_error("failed to initalize mpv instance");

    setProperty("terminal", true);
    setProperty("pause", true);

    guiUpdateTimer = new QTimer();
    guiUpdateTimer->setInterval(100);
    connect(guiUpdateTimer, &QTimer::timeout, this, [this]{
        currentVideoPos = getProperty("percent-pos").toReal();
        emit updateGui();
    });
    guiUpdateTimer->start();

    resizingTimer = new QTimer();
    resizingTimer->setInterval(100);
    resizingTimer->setSingleShot(true);
    connect(resizingTimer, &QTimer::timeout, this, [this]{
        isResizing = false;
        update();
    });
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

void VideoObject::seek(const qreal newPos)
{
    mpv::qt::command(mpvHandler, QStringList() << "seek" << QString::number(newPos) << "absolute-percent+keyframes");
}

void VideoObject::pause()
{
    bool pauseStatus = getProperty("pause").toBool();
    setProperty("pause", !pauseStatus);
    setPaused(!pauseStatus);
}

void VideoObject::command(const QVariant &args)
{  
    mpv::qt::command(mpvHandler, args);
}

void VideoObject::setProperty(const QString name, const QVariant &v)
{
    mpv::qt::set_property(mpvHandler, name, v);
}

QVariant VideoObject::getProperty(const QString name)
{
    return mpv::qt::get_property(mpvHandler, name);
}

void VideoObject::setMpvRenderContext(mpv_render_context *value)
{
    mpvRenderContext = value;
}

void VideoObject::resized()
{
    isResizing = true;
    resizingTimer->start();
}

bool VideoObject::getPaused() const
{
    return paused;
}

void VideoObject::setPaused(bool value)
{
    paused = value;
    emit pausedChanged();
}

qreal VideoObject::getCurrentVideoPos() const
{
    return currentVideoPos;
}

void VideoObject::setCurrentVideoPos(const qreal &value)
{
    currentVideoPos = value;
}

qreal VideoObject::getCurrentVideoLength() const
{
    return currentVideoLength;
}

bool *VideoObject::getIsResizing()
{
    return &isResizing;
}
