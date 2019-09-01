#ifndef SERVERBROWSER_H
#define SERVERBROWSER_H

#include <QObject>

class ServerBrowser : public QObject
{
    Q_OBJECT
public:
    explicit ServerBrowser(QObject *parent = nullptr);

    void error();

signals:
    void refreshed();

public slots:
    void refresh();

    QStringList getList();

private:
    QStringList serverList;
};

#endif // SERVERBROWSER_H
