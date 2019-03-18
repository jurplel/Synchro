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
    qDebug() << incomingSize;
    qDebug() << socket->bytesAvailable();
    if (socket->bytesAvailable() != incomingSize)
        return;

    incomingSize = 0;

    QByteArray data = socket->read(incomingSize);
    QDataStream dataStream(data);

    quint8 numericCommand;
    dataStream >> numericCommand;
    auto command = static_cast<Command>(numericCommand);

    qDebug() << "Recieved new data:" << command;

    recieveCommand(command);
}

void SynchronyController::sendCommand(Command command)
{
    QByteArray dataBlock;
    QDataStream dataBlockStream(&dataBlock, QIODevice::WriteOnly);
    dataBlockStream << quint16(0);

    switch(command) {
    case Command::Pause: {
        dataBlockStream << quint8(command);
        break;
    }
    }

    dataBlockStream.device()->seek(0);
    dataBlockStream << quint16(dataBlock.size() - static_cast<int>(sizeof(quint16)));
    socket->write(dataBlock);
}

void SynchronyController::recieveCommand(Command command)
{
    switch(command) {
    case Command::Pause: {
        emit pause();
        break;
    }
    }
}
