#ifndef SYNCHRONYCONTROLLER_H
#define SYNCHRONYCONTROLLER_H

#include <QObject>
#include <QTcpSocket>

class SynchronyController : public QObject
{
    Q_OBJECT
public:
    explicit SynchronyController(QObject *parent = nullptr);

    void connectToServer(QString ip, quint16 port);

    void readNewData();

signals:

public slots:

private:
    QTcpSocket *socket;
};

#endif // SYNCHRONYCONTROLLER_H
