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
    bool hasArguments;
    quint8 numericCommand;
    QVariantList arguments;
    in >> incomingData >> hasArguments >> numericCommand;

    if (hasArguments)
        in >> arguments;

    if (!in.commitTransaction())
        return;


    auto command = static_cast<Command>(numericCommand);

    qDebug() << "Recieved new command:" << command << arguments;

    recieveCommand(command, arguments);

    if (!in.atEnd())
        dataRecieved();
}

void SynchronyController::sendCommand(Command command, QVariantList arguments)
{
    QByteArray dataBlock;
    QDataStream dataBlockStream(&dataBlock, QIODevice::WriteOnly);
    dataBlockStream << quint16(0);
    switch(command) {
    case Command::Pause: {
        dataBlockStream << true << quint8(command) << arguments;
        break;
    }
    case Command::Seek: {
        dataBlockStream << true << quint8(command) << arguments;
        break;
    }
    }

    dataBlockStream.device()->seek(0);
    dataBlockStream << quint16(dataBlock.size() - static_cast<int>(sizeof(quint16)));

    qDebug() << "send em" << socket->write(dataBlock) << "bytes";
}

void SynchronyController::recieveCommand(Command command, QVariantList arguments)
{
    switch(command) {
    case Command::Pause: {
        if (arguments.length() > 1)
            emit pause(arguments[0].toBool(), arguments[1].toDouble());
        break;
    }
    case Command::Seek: {
        if (arguments.length() > 1)
            emit seek(arguments[0].toDouble(), arguments[1].toBool());
        break;
    }
    }
}
