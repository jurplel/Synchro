#include "videoobject.h"
#include "corerenderer.h"

#include <QtQuick/QQuickWindow>
#include <QStringList>
#include <QTimer>

#include <QDebug>

static void wakeup(void *videoObject)
{
    auto vidObj = reinterpret_cast<VideoObject*>(videoObject);
    QMetaObject::invokeMethod(vidObj, "onMpvEvents", Qt::QueuedConnection);
}

VideoObject::VideoObject() : QQuickFramebufferObject()
{
    //initialize variables
    paused = true;
    muted = false;
    seeking = false;
    currentVolume = 100;
    percentPos = 0;

    mpvHandler = mpv_create();

    if (!mpvHandler)
        throw std::runtime_error("failed to create mpv instance");

    if (mpv_initialize(mpvHandler) != 0)
        throw std::runtime_error("failed to initalize mpv instance");

    mpv_set_wakeup_callback(mpvHandler, wakeup, this);

    mpv_observe_property(mpvHandler, 0, "percent-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpvHandler, 0, "time-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpvHandler, 0, "duration", MPV_FORMAT_DOUBLE);

    setProperty("terminal", true);
    setProperty("pause", true);

    setProperty("audio-client-name", "Synchro");

    setProperty("video-timing-offset", 0);
//    setProperty("video-sync", "display-resample");
//    setProperty("interpolation", "yes");

    //update variables with mpv values for safety
    paused = getProperty("pause").toBool();
    muted = getProperty("mute").toBool();
    currentVolume = getProperty("volume").toReal();

    seekTimer = new QTimer();
    seekTimer->setInterval(50);
    connect(seekTimer, &QTimer::timeout, this, [this]{seeking = false;});
    seekTimer->setSingleShot(true);
}

VideoObject::~VideoObject()
{
    mpv_terminate_destroy(mpvHandler);
}

QQuickFramebufferObject::Renderer *VideoObject::createRenderer() const
{
    window()->setPersistentOpenGLContext(true);
    window()->setPersistentSceneGraph(true);
    return new CoreRenderer(const_cast<VideoObject*>(this), mpvHandler);
}

void VideoObject::onMpvEvents()
{
    // Process all events, until the event queue is empty.
    while (mpvHandler)
    {
        mpv_event *event = mpv_wait_event(mpvHandler, 0);

        if (event->event_id == MPV_EVENT_NONE)
            break;

        handleMpvEvent(event);
    }
}

void VideoObject::handleMpvEvent(mpv_event *event)
{
    switch (event->event_id)
    {
    case MPV_EVENT_PROPERTY_CHANGE:
    {
        auto *prop = reinterpret_cast<mpv_event_property*>(event->data);

        if (strcmp(prop->name, "percent-pos") == 0 && prop->format == MPV_FORMAT_DOUBLE)
            setPercentPos(*reinterpret_cast<double*>(prop->data));

        if (strcmp(prop->name, "time-pos") == 0 && prop->format == MPV_FORMAT_DOUBLE)
            setTimePosString(QString::fromUtf8(mpv_get_property_osd_string(mpvHandler, "time-pos")));

        if (strcmp(prop->name, "duration") == 0 && prop->format == MPV_FORMAT_DOUBLE)
            setDurationString(QString::fromUtf8(mpv_get_property_osd_string(mpvHandler, "duration")));

        break;
    }
    default:
        break;
}
}

void VideoObject::seek(const qreal newPos)
{

    mpv::qt::node_builder node(QStringList() << "seek" << QString::number(newPos) << "absolute-percent+keyframes");
    mpv_command_node_async(mpvHandler, 0, node.node());

    seeking = true;
    seekTimer->start();
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

void VideoObject::loadFile(const QString &fileName)
{
    command(QStringList() << "loadfile" << fileName);
    setPaused(false);
    setPercentPos(0);
    qDebug() << mpv_get_property_osd_string(mpvHandler, "duration");
//    setDuration(QTime::fromMSecsSinceStartOfDay());
}

qreal VideoObject::getCurrentVolume() const
{
    return currentVolume;
}

void VideoObject::setCurrentVolume(const qreal &value)
{
    qreal newValue = value;
    if (newValue < 0)
        newValue = 0;
    else if (newValue > 100)
        newValue = 100;

    setMuted(false);
    setProperty("volume", newValue);
    currentVolume = newValue;
    emit currentVolumeChanged();
}

bool VideoObject::getMuted() const
{
    return muted;
}

void VideoObject::setMuted(bool value)
{
    setProperty("mute", value);
    muted = value;
    emit mutedChanged();
}

bool VideoObject::getPaused() const
{
    return paused;
}

void VideoObject::setPaused(bool value)
{
    setProperty("pause", value);
    paused = value;
    emit pausedChanged();
}

qreal VideoObject::getPercentPos() const
{
    return percentPos;
}

void VideoObject::setPercentPos(const qreal &value)
{
    percentPos = value;
    emit percentPosChanged();
}

QString VideoObject::getTimePosString() const
{
    return timePosString;
}

void VideoObject::setTimePosString(const QString &value)
{
    timePosString = value;
    emit timePosStringChanged();
}

QString VideoObject::getDurationString() const
{
    return durationString;
}

void VideoObject::setDurationString(const QString &value)
{
    durationString = value;
    emit durationStringChanged();
}

bool VideoObject::getSeeking() const
{
    return seeking;
}

void VideoObject::setSeeking(bool value)
{
    seeking = value;
}
