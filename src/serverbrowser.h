#ifndef SERVERBROWSER_H
#define SERVERBROWSER_H

#include <QAbstractListModel>

class Server
{
public:
    Server(QString newName, QString newIp): name(newName), ip(newIp) {}

    QString getName() const { return name; }
    QString getIp() const { return ip; }

private:
    QString name;
    QString ip;
};

class ServerBrowser : public QAbstractListModel
{
    Q_OBJECT
public:
    enum ServerRoles {
        NameRole = Qt::UserRole + 1,
        IpRole
    };

    explicit ServerBrowser(QObject *parent = nullptr);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

public slots:
    void refresh();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<Server> serverList;
};

#endif // SERVERBROWSER_H
