#include "clientlistmodel.h"
#include "libsynchro.hpp"

#include <QDebug>

ClientListModel::ClientListModel(QObject *parent) : QAbstractListModel(parent)
{

}

int ClientListModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return clientList.count();
}

QVariant ClientListModel::data(const QModelIndex & index, int role) const {
    if (index.row() < 0 || index.row() >= clientList.count())
        return QVariant();

    const Client &client = clientList[index.row()];

    switch (role)
    {
    case NameRole: {
        return client.getName();
    }
    }

    return QVariant();
}

QHash<int, QByteArray> ClientListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    return roles;
}

void ClientListModel::updateClientList(QString rawString)
{
    beginResetModel();
    clientList.clear();

    QStringList retrievedClientList = rawString.split(",");

    foreach (auto clientString, retrievedClientList) {
        // QStringList serverFields = serverString.split(",");

        clientList.append(Client({clientString}));
    }
    endResetModel();
}
