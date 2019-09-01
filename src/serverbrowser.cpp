#include "serverbrowser.h"
#include "libsynchro.hpp"

#include <QUrl>
#include <QJsonDocument>

ServerBrowser::ServerBrowser(QObject *parent) : QObject(parent)
{
}

void ServerBrowser::refresh()
{
    serverList.clear();
    serverList.append("0.0.0.0:32019");

    QString retrievedServers = qPrintable(synchro_get_server_list(""));
    QStringList retrievedServerList = retrievedServers.split(",");
    serverList.append(retrievedServerList);

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
