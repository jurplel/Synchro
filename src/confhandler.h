#ifndef CONFHANDLER_H
#define CONFHANDLER_H

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
public:

    explicit ConfHandler(QObject *parent = nullptr);

public slots:
    bool readMpvConf();

    void setSyntaxHighlighter(QQuickTextDocument *document);

    void saveMpvConf(QQuickTextDocument *document);

    QString getConf() const { return conf; }

signals:
    void readConf();


private:
    QMap<QString, QString> mpvConfMap;

    QString confLocation;
    QString conf; 
    const QString defaultConf = "# This file uses the same format as mpv.conf\n"
                                "video-sync=display-resample\n"
                                "interpolation=yes\n";

    ConfSyntaxHighlighter *highlighter;
};

#endif // CONFHANDLER_H
