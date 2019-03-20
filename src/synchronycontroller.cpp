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
    quint8 extraFieldCount;
    quint8 numericCommand;
    QVariantList additionalData;
    in >> incomingData >> extraFieldCount >> numericCommand;

    if (extraFieldCount > 0)
    {
        in >> additionalData;
    }

    if (!in.commitTransaction())
        return;


    auto command = static_cast<Command>(numericCommand);

    qDebug() << "Recieved new command:" << command << additionalData;

    recieveCommand(command, additionalData);

    if (!in.atEnd())
        dataRecieved();
}

void SynchronyController::sendCommand(Command command, QVariantList data)
{
    QByteArray dataBlock;
    QDataStream dataBlockStream(&dataBlock, QIODevice::WriteOnly);
    dataBlockStream << quint16(0);
    switch(command) {
    case Command::Pause: {
        dataBlockStream << quint8(1) << quint8(command) << data;
        break;
    }
    case Command::Seek: {
        dataBlockStream << quint8(2) << quint8(command) << data;
        break;
    }
    }

    dataBlockStream.device()->seek(0);
    dataBlockStream << quint16(dataBlock.size() - static_cast<int>(sizeof(quint16)));

    qDebug() << "send em" << socket->write(dataBlock) << "bytes";
}

void SynchronyController::recieveCommand(Command command, QVariantList data)
{
    switch(command) {
    case Command::Pause: {
        if (data.length() > 0)
            emit pause(data[0].toDouble());
        break;
    }
    case Command::Seek: {
        if (data.length() > 1)
            emit seek(data[0].toDouble(), data[1].toBool());
        break;
    }
    }
}
