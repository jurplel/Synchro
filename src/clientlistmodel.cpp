#include "clientlistmodel.h"
#include "libsynchro.hpp"

#include <QLocale>
#include <QTime>

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
    case FileSizeRole: {
        return client.getFileSize();
    }
    case FileDurationRole: {
        return client.getFileDuration();
    }
    case FileNameRole: {
        return client.getFileName();
    }
    }

    return QVariant();
}

QHash<int, QByteArray> ClientListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[FileSizeRole] = "fileSize";
    roles[FileDurationRole] = "fileDuration";
    roles[FileNameRole] = "fileName";
    return roles;
}

void ClientListModel::updateClientList(QString rawString)
{

    beginResetModel();
    clientList.clear();

    QLocale locale;

    QStringList retrievedClientList = rawString.split(",");
    foreach (auto clientString, retrievedClientList)
    {
        if (clientString.isEmpty())
            continue;

        QStringList clientFields = clientString.split(";");
        QTime time = QTime::fromMSecsSinceStartOfDay(clientFields[2].toDouble()*1000);

        clientList.append(Client(clientFields[0], locale.formattedDataSize(clientFields[1].toInt()), time.toString("H:mm:ss"), clientFields[3]));
    }
    endResetModel();
}
