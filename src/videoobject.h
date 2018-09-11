#ifndef VIDEOOBJECT_H
#define VIDEOOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <mpv/qthelper.hpp>

class VideoObject : public QQuickFramebufferObject
{
    Q_OBJECT

public:
    VideoObject();
    virtual ~VideoObject();
    virtual Renderer *createRenderer() const;


    mpv_handle *getMpvHandler() const;
    void setMpvHandler(mpv_handle *value);

    mpv_render_context *getMpvRenderContext() const;
    void setMpvRenderContext(mpv_render_context *value);


public slots:
    void command(const QVariant &args);

    void setProperty(const QString name, const QVariant &v);

    void getProperty(const QString name);


signals:
    void requestUpdate();


protected:
    void performUpdate();


private:
    mpv_handle *mpvHandler;
    mpv_render_context *mpvRenderContext;

};

#endif // VIDEOOBJECT_H
