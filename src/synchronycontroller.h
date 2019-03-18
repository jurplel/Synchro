#ifndef SYNCHRONYCONTROLLER_H
#define SYNCHRONYCONTROLLER_H

#include <QObject>
#include <QTcpSocket>

class SynchronyController : public QObject
{
    Q_OBJECT
public:
    explicit SynchronyController(QObject *parent = nullptr);

    void readNewData();

signals:

public slots:
    void connectToServer(QString ip, quint16 port);

private:
    QTcpSocket *socket;
    quint16 incomingSize;
};

#endif // SYNCHRONYCONTROLLER_H
