#ifndef CLIENTLISTMODEL_H
#define CLIENTLISTMODEL_H

#include <QAbstractListModel>

class Client
{
public:
    Client(QString newName, QString newFileSize, QString newFileDuration, QString newFileName): name(newName), fileSize(newFileSize), fileDuration(newFileDuration), fileName(newFileName) {}

    QString getName() const { return name; }
    QString getFileSize() const { return fileSize; }
    QString getFileDuration() const { return fileDuration; }
    QString getFileName() const { return fileName; }

private:
    QString name;
    QString fileSize;
    QString fileDuration;
    QString fileName;
};

class ClientListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum ClientRoles {
        NameRole = Qt::UserRole + 1,
        FileSizeRole,
        FileDurationRole,
        FileNameRole
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
