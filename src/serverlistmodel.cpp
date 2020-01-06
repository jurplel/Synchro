#include "serverlistmodel.h"
#include "libsynchro.hpp"

#include <QDebug>

ServerListModel::ServerListModel(QObject *parent) : QAbstractListModel(parent)
{
    refresh();
}

int ServerListModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return serverList.count();
}

QVariant ServerListModel::data(const QModelIndex & index, int role) const {
    if (index.row() < 0 || index.row() >= serverList.count())
        return QVariant();

    const Server &server = serverList[index.row()];

    switch (role)
    {
    case NameRole: {
        return server.getName();
    }
    case IpRole: {
        return server.getIp();
    }
    }

    return QVariant();
}

QHash<int, QByteArray> ServerListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[IpRole] = "ip";
    return roles;
}

void ServerListModel::refresh()
{
    serverList.clear();
    // serverList.append(Server({"Local Server", "0.0.0.0:32019"}));

    QString retrievedServers = qPrintable(synchro_get_server_list(""));
    QStringList retrievedServerList = retrievedServers.split(";");

    foreach (auto serverString, retrievedServerList) {
        QStringList serverFields = serverString.split(",");

        serverList.append(Server({serverFields[0], serverFields[1]}));
    }
}
