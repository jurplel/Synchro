#ifndef CONFHANDLER_H
#define CONFHANDLER_H

#include "videoobject.h"

#include <QObject>
#include <QQuickTextDocument>
#include <QSyntaxHighlighter>

class ConfSyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    explicit ConfSyntaxHighlighter(QTextDocument *parent = nullptr);

protected:
    void highlightBlock(const QString &text) override;

};

class ConfHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(VideoObject* vidObj WRITE setVidObj)

public:

    explicit ConfHandler(QObject *parent = nullptr);

public slots:
    bool readMpvConf();

    void updateProperties();

    void setSyntaxHighlighter(QQuickTextDocument *document);

    void saveMpvConf(QQuickTextDocument *document);

    QString getConf() const { return conf; }

    void setVidObj(VideoObject *value);


signals:
    void readConf();


private:
    QHash<QString, QString> mpvConfHash;

    QString confLocation;
    QString conf; 
    const QString defaultConf = "# This file uses the same format as mpv.conf\n"
                                "video-sync=display-resample\n"
                                "interpolation=yes\n";

    ConfSyntaxHighlighter *highlighter;

    VideoObject *vidObj;
};

#endif // CONFHANDLER_H
