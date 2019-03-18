#include "synchronycontroller.h"

#include <QDebug>
#include <QDataStream>

SynchronyController::SynchronyController(QObject *parent) : QObject(parent)
{
    incomingSize = 0;
    socket = new QTcpSocket(this);

    connect(socket, &QTcpSocket::connected, []{ qInfo() << "Connection successfully established."; });
    connect(socket, &QTcpSocket::readyRead, this, &SynchronyController::readNewData);

    connectToServer("35.227.80.175", 32019);
}

void SynchronyController::connectToServer(QString ip, quint16 port)
{
    socket->connectToHost(ip, port);
}

void SynchronyController::readNewData()
{
    if (!incomingSize)
    {
        QByteArray data = socket->read(2);
        QDataStream dataStream(data);
        dataStream >> incomingSize;
    }
    qInfo() << incomingSize;
    qInfo() << socket->bytesAvailable();
    if (socket->bytesAvailable() != incomingSize)
        return;

    qInfo() << "Recieved new data:" << socket->read(incomingSize);
    incomingSize = 0;
}
