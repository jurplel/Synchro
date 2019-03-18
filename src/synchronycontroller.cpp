#include "synchronycontroller.h"
#include <QDebug>

SynchronyController::SynchronyController(QObject *parent) : QObject(parent)
{
    socket = new QTcpSocket(this);

    connect(socket, &QTcpSocket::connected, []{ qInfo() << "Connection successfully established"; });
    connect(socket, &QTcpSocket::readyRead, this, &SynchronyController::readNewData);

    connectToServer("35.227.80.175", 32019);
}

void SynchronyController::connectToServer(QString ip, quint16 port)
{
    socket->connectToHost(ip, port);
}

void SynchronyController::readNewData()
{
    qInfo() << "Recieved new data: " << QString(socket->read(99999));
}
