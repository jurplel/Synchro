#include "synchronycontroller.h"

#include <QDebug>

SynchronyController::SynchronyController(QObject *parent) : QObject(parent)
{
    socket = new QTcpSocket(this);

    in.setDevice(socket);
    in.setVersion(QDataStream::Qt_5_9);

    connect(socket, &QTcpSocket::connected, []{ qInfo() << "Connection successfully established."; });
    connect(socket, &QTcpSocket::readyRead, this, &SynchronyController::dataRecieved);

    connectToServer("35.227.80.175", 32019);
}

void SynchronyController::connectToServer(QString ip, quint16 port)
{
    socket->connectToHost(ip, port);
}

void SynchronyController::dataRecieved()
{
    in.startTransaction();

    quint16 incomingData;
    quint8 numericCommand;
    in >> incomingData >> numericCommand;

    if (!in.commitTransaction())
        return;

    auto command = static_cast<Command>(numericCommand);

    qDebug() << "Recieved new data:" << command;

    recieveCommand(command);
}

void SynchronyController::sendCommand(Command command)
{
    qDebug() << socket->openMode();
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

    qDebug() << "send em" << socket->write(dataBlock);
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
