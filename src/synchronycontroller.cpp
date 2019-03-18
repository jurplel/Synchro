#include "synchronycontroller.h"
#include <QTcpSocket>
#include <QDebug>

SynchronyController::SynchronyController(QObject *parent) : QObject(parent)
{
    auto socket = new QTcpSocket(this);
    socket->connectToHost("127.0.0.1", 32019);
    socket->waitForConnected();
    if (socket->state() == QAbstractSocket::ConnectedState)
    {
        qInfo() << "connected, waiting for handshake";
        socket->waitForReadyRead();
        qInfo() << "Message recieved: " << QString(socket->read(99999));
    }
}
