#include "confhandler.h"

#include <QRegularExpressionMatchIterator>
#include <QSettings>
#include <QStandardPaths>

ConfHandler::ConfHandler(QObject *parent) : QObject(parent)
{
    highlighter = nullptr;
    vidObj = nullptr;

    QSettings settings(QSettings::IniFormat, QSettings::UserScope, QCoreApplication::organizationName(), "mpv");
    confLocation = settings.fileName().replace("ini", "conf");
    readMpvConf();
}

void ConfHandler::setSyntaxHighlighter(QQuickTextDocument *document)
{
    if (!highlighter)
        highlighter = new ConfSyntaxHighlighter();

    highlighter->setDocument(document->textDocument());
}

void ConfHandler::saveMpvConf(QQuickTextDocument *document)
{
    QString text = document->textDocument()->toPlainText();
    QFile file(confLocation, this);
    file.remove();
    file.open(QIODevice::ReadWrite);
    file.write(text.toUtf8());
    file.close();
    readMpvConf();
}

bool ConfHandler::readMpvConf()
{
    QFile file(confLocation, this);
    // If the mpv.conf file doesn't already exist, write a default one
    if (!file.exists())
    {
        file.open(QIODevice::WriteOnly);
        file.write(defaultConf.toUtf8());
        file.close();
    }
    file.open(QIODevice::ReadWrite);
    if (!file.isOpen())
        return false;

    mpvConfHash.clear();

    QTextStream stream(&file);
    conf = stream.readAll();
    stream.seek(0);

    while (!stream.atEnd()) {
        QString line = stream.readLine();
        if (line.startsWith("#"))
            continue;

        mpvConfHash.insert(line.section('=', 0, 0), line.section('=', 1));
    }
    stream.seek(0);
    updateProperties();
    emit readConf();
    return true;
}

void ConfHandler::updateProperties()
{
    if (!vidObj)
        return;

    const auto &keys = mpvConfHash.keys();
    for (const auto &key : keys)
    {
        auto value = mpvConfHash.value(key);
        vidObj->setProperty(key, value);
        qDebug() << key << "set to:" << value;
    }
}

void ConfHandler::setVidObj(VideoObject *value)
{
    vidObj = value;
    updateProperties();
}

ConfSyntaxHighlighter::ConfSyntaxHighlighter(QTextDocument *parent) : QSyntaxHighlighter(parent)
{

}

void ConfSyntaxHighlighter::highlightBlock(const QString &text)
{
    QTextCharFormat keyFormat;
    keyFormat.setForeground(QColor("#0ba9db"));

    QRegularExpression key("(.*?)=(.*)");
    QRegularExpressionMatchIterator i1 = key.globalMatch(text);
    while (i1.hasNext())
    {
      QRegularExpressionMatch match = i1.next();
      setFormat(match.capturedStart(1), match.capturedLength(1), keyFormat);
    }

    QTextCharFormat commentedFormat;
    commentedFormat.setFontItalic(true);
    commentedFormat.setForeground(Qt::gray);

    QRegularExpression commented("^#.*");
    QRegularExpressionMatchIterator i0 = commented.globalMatch(text);
    while (i0.hasNext())
    {
      QRegularExpressionMatch match = i0.next();
      setFormat(match.capturedStart(), match.capturedLength(), commentedFormat);
    }
}
