#include "videoobject.h"
#include "corerenderer.h"
#include "trackhandler.h"

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
    isPaused = true;
    muted = false;
    seeking = false;
    currentVolume = 100;
    percentPos = 0;
    duration = 0;

    mpvHandler = mpv_create();

    if (!mpvHandler)
        throw std::runtime_error("failed to create mpv instance");

    if (mpv_initialize(mpvHandler) != 0)
        throw std::runtime_error("failed to initalize mpv instance");

    mpv_set_wakeup_callback(mpvHandler, wakeup, this);

    mpv_observe_property(mpvHandler, 0, "percent-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpvHandler, 0, "time-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpvHandler, 0, "duration", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpvHandler, 0, "chapter-list", MPV_FORMAT_NODE);
    mpv_observe_property(mpvHandler, 0, "track-list", MPV_FORMAT_NODE);
    mpv_observe_property(mpvHandler, 0, "path", MPV_FORMAT_NODE);

//    setProperty("terminal", true);
    setProperty("pause", true);

    setProperty("audio-client-name", "Synchro");

    setProperty("video-timing-offset", 0);
    setProperty("video-sync", "display-resample");
    setProperty("interpolation", "yes");
    setProperty("keep-open", "always");

    //update variables with mpv values for safety
    isPaused = getProperty("pause").toBool();
    muted = getProperty("mute").toBool();
    currentVolume = getProperty("volume").toReal();

    seekTimer = new QTimer(this);
    seekTimer->setInterval(1000);
    connect(seekTimer, &QTimer::timeout, this, [this]{seeking = false;});
    seekTimer->setSingleShot(true);

    pollTimer = new QTimer(this);
    pollTimer->setInterval(1000);
    pollTimer->start();
    connect(pollTimer, &QTimer::timeout, this, &VideoObject::poll);
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

void VideoObject::poll() 
{
    auto seekableRanges = getProperty("demuxer-cache-state").value<QVariantMap>().value("seekable-ranges").value<QVariantList>();
    QVariantList seekableRangesList;
    foreach (auto variant, seekableRanges)
    {
        auto variantMap = variant.value<QVariantMap>();
        auto start = variantMap.value("start").toDouble()/duration;
        auto end = variantMap.value("end").toDouble()/duration;
        seekableRangesList.append({start, end});
    }
    if (getCachedList() != seekableRangesList)
        setCachedList(seekableRangesList);
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

void VideoObject::handleMpvEvent(const mpv_event *event)
{
    switch (event->event_id)
    {
    case MPV_EVENT_PROPERTY_CHANGE:
    {
        auto *prop = reinterpret_cast<mpv_event_property*>(event->data);

        if (strcmp(prop->name, "percent-pos") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
            setPercentPos(*reinterpret_cast<double*>(prop->data));
        } 
        else if (strcmp(prop->name, "time-pos") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
            setTimePosString(QString::fromUtf8(mpv_get_property_osd_string(mpvHandler, "time-pos")));
        }
        else if (strcmp(prop->name, "duration") == 0 && prop->format == MPV_FORMAT_DOUBLE) {
            setDuration(*reinterpret_cast<double*>(prop->data));
            setDurationString(QString::fromUtf8(mpv_get_property_osd_string(mpvHandler, "duration")));
        }
        else if (strcmp(prop->name, "chapter-list") == 0 && prop->format == MPV_FORMAT_NODE) {
            setChapterList(getProperty("chapter-list").value<QVariantList>());
        }
        else if (strcmp(prop->name, "track-list") == 0 && prop->format == MPV_FORMAT_NODE) {
            TrackHandler trackHandler(mpvHandler, this);
            trackHandler.updateTracks();
            audioTrackList = trackHandler.getAudioTrackList();
            subTrackList = trackHandler.getSubTrackList();
            videoTrackList = trackHandler.getVideoTrackList();
            emit trackListsUpdated();
        }
        else if (strcmp(prop->name, "path") == 0 && prop->format == MPV_FORMAT_NODE) {
            emit fileChanged();
        }
        break;
    }
    default:
        break;
}
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

void VideoObject::seek(const qreal newPos, const bool useKeyframes, const bool synchronize)
{
    if (synchronize)
        emit seeked(newPos, useKeyframes);

    QStringList command = QStringList() << "seek" << QString::number(newPos);
    //keyframes are used when dragging, and exact used when clicking
    if (useKeyframes)
        command << "absolute-percent+keyframes";
    else
        command << "absolute-percent+exact";

    mpv::qt::node_builder node(command);
    mpv_command_node_async(mpvHandler, 0, node.node());

    seeking = true;
    if (!seekTimer->isActive())
    {
        seekTimer->start();
        update();
    }
}

void VideoObject::seekBy(const qreal seconds)
{
    qreal currentSeconds = getProperty("time-pos").toReal();
    qreal targetedSeconds = currentSeconds+seconds;
    qreal totalSeconds = getProperty("duration").toReal();

    qreal targetedPercentage = (targetedSeconds/totalSeconds)*100;
    seek(targetedPercentage, false, true);
}

void VideoObject::pause(bool newPaused) {
    setIsPaused(newPaused);
    emit paused();
}

void VideoObject::loadFile(const QString &fileName)
{
    command(QStringList() << "loadfile" << fileName);
    seek(0, false);
}

void VideoObject::back()
{
     command(QStringList() << "add" << "chapter" << "-1");
     emit seeked(getProperty("percent-pos").toReal(), false);
}

void VideoObject::forward()
{
    command(QStringList() << "add" << "chapter" << "1");
    emit seeked(getProperty("percent-pos").toReal(), false);
}

void VideoObject::setVideoTrack(int id)
{
    setProperty("vid", id);
}

void VideoObject::setAudioTrack(int id)
{
    setProperty("aid", id);
}

void VideoObject::setSubTrack(int id)
{
    setProperty("sid", id);
}

void VideoObject::setCurrentVolume(const qreal &value)
{
    qreal newValue = value;
    if (newValue < 0)
        newValue = 0;
    else if (newValue > 100)
        newValue = 100;

    setMuted(false);
    command(QStringList() << "set" << "volume" << QString::number(newValue));
    currentVolume = newValue;
    emit currentVolumeChanged();
}
