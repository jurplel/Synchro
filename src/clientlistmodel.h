#ifndef CLIENTLISTMODEL_H
#define CLIENTLISTMODEL_H

#include <QAbstractListModel>

class Client
{
public:
    Client(QString newName): name(newName) {}

    QString getName() const { return name; }

private:
    QString name;
};

class ClientListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum ClientRoles {
        NameRole = Qt::UserRole + 1,
    };

    explicit ClientListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

public slots:
    void updateClientList(QString rawString);

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<Client> clientList;
};

#endif // CLIENTLISTMODEL_H
