#include "serverbrowser.h"

#include <QUrl>

ServerBrowser::ServerBrowser(QObject *parent) : QObject(parent)
{
}

void ServerBrowser::refresh()
{
    serverList.clear();
    serverList.append("0.0.0.0:32019");

    // Get server list from interverse
    QUrl url("https://pastebin.com/raw/qtbyBM6k");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "text/plain");

    auto *networkManager = new QNetworkAccessManager(this);
    connect(networkManager, &QNetworkAccessManager::finished, this, &ServerBrowser::receiveList);

    networkManager->get(request);
}

void ServerBrowser::receiveList(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError)
    {
        serverList.clear();
        serverList.append("Error checking server list");
        return;
    }

    QByteArray byteArray = reply->readAll();
    auto string = QString(byteArray);
    serverList.append(string.split("\r\n"));
    qDebug() << serverList;

    emit refreshed();
}

QStringList ServerBrowser::getList()
{
    if (!serverList.isEmpty()) {
        return serverList;
    } else {
        return QStringList();
    }
}
