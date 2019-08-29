#include "serverbrowser.h"

#include <QUrl>
#include <QJsonDocument>

ServerBrowser::ServerBrowser(QObject *parent) : QObject(parent)
{
}

void ServerBrowser::refresh()
{
    serverList.clear();
    serverList.append("0.0.0.0:32019");

    // Get server list from interverse
    QUrl url("https://interversehq.com/synchro/synchro.json");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    auto *networkManager = new QNetworkAccessManager(this);
    connect(networkManager, &QNetworkAccessManager::finished, this, &ServerBrowser::receiveList);

    networkManager->get(request);
}

void ServerBrowser::receiveList(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        error();
        return;
    }

    QByteArray byteArray = reply->readAll();
    QJsonDocument json = QJsonDocument::fromJson(byteArray);
    
    if (json.isNull()) {
        error();
        return;
    }

    QJsonObject jsonObj = json.object();
    QJsonValue value = jsonObj.constFind("servers").value();

    if (!value.isArray()) {
        error();
        return;
    }

    auto servers = value.toArray().toVariantList();
    foreach (auto variant, servers) {
        serverList.append(variant.toString());
    }

    qDebug() << serverList;

    emit refreshed();
}

void ServerBrowser::error() {
    serverList.clear();
    serverList.append("Error checking server list");
}

QStringList ServerBrowser::getList()
{
    if (!serverList.isEmpty()) {
        return serverList;
    } else {
        return QStringList();
    }
}
