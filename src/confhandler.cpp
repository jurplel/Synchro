#include "confhandler.h"

#include <QRegularExpressionMatchIterator>
#include <QSettings>
#include <QStandardPaths>

ConfHandler::ConfHandler(QObject *parent) : QObject(parent)
{
    highlighter = nullptr;

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
    file.open(QIODevice::ReadOnly);
    if (!file.isOpen())
        return false;

    mpvConfMap.clear();

    QTextStream stream(&file);
    conf = stream.readAll();
    stream.seek(0);

    while (!stream.atEnd()) {
        QString line = stream.readLine();
        qDebug() << line;
        if (line.startsWith("#"))
            continue;

        QStringList fields = line.split("=");
        // if there is not exactly one equals sign in the line, this is an error
        if (fields.length() != 2)
            return false;

        mpvConfMap.insert(fields.at(0), fields.at(1));
    }
    emit readConf();
    return true;
}

ConfSyntaxHighlighter::ConfSyntaxHighlighter(QTextDocument *parent) : QSyntaxHighlighter(parent)
{

}

void ConfSyntaxHighlighter::highlightBlock(const QString &text)
{
    QTextCharFormat keyFormat;
    keyFormat.setForeground(QColor("#0ba9db"));

    QRegularExpression key("(.*)=");
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
