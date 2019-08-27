#include "synchronycontroller.h"

#include <QtConcurrent/QtConcurrentRun>

#include <QVariantList>

#include <QDebug>

static void callback(void *ctx, Synchro_Command cmd) {
    auto obj = reinterpret_cast<SynchronyController*>(ctx);
    obj->receiveCommand(cmd);
}

SynchronyController::SynchronyController(QObject *parent) : QObject(parent)
{
    socket = nullptr;
}

SynchronyController::~SynchronyController() {
    disconnect();
}

void SynchronyController::disconnect() {
    if (socket == nullptr)
        return;

    synchro_connection_free(socket);
    socket = nullptr;
}

void SynchronyController::connectToServer(QString ip, quint16 port)
{
    if (socket != nullptr)
        disconnect();

    socket = synchro_connection_new(qPrintable(ip), port, callback, this);
    if (socket == nullptr)
        return;

    QtConcurrent::run(synchro_connection_run, socket);
}

void SynchronyController::sendCommand(quint8 cmdNum, QVariantList arguments)
{
    if (socket == nullptr)
        return;

    Synchro_Command cmd = Synchro_Command();
    cmd.tag = static_cast<Synchro_Command::Tag>(cmdNum);

    switch(cmd.tag) {
    case Synchro_Command::Tag::Pause: {
        cmd.pause.paused = arguments.takeFirst().toBool();
        cmd.pause.percent_pos = arguments.takeFirst().toDouble();
        break;
    }
    case Synchro_Command::Tag::Seek: {
        cmd.seek.percent_pos = arguments.takeFirst().toDouble();
        cmd.seek.dragged = arguments.takeFirst().toBool();
        break;
    }
    case Synchro_Command::Tag::UpdateClientList: {
        cmd.update_client_list.client_list = nullptr;
        break;
    }
    case Synchro_Command::Tag::SetName: {
        char* name = arguments.takeFirst().toString().toUtf8().data();
        cmd.set_name.desired_name = name;
        break;
    }
    default: {
        break;
    }
    }

    synchro_connection_send(socket, cmd);
    qDebug() << "send em";
}

void SynchronyController::receiveCommand(Synchro_Command command)
{
    qDebug() << "recieved command" << static_cast<int>(command.tag);
    switch(command.tag) {
    case Synchro_Command::Tag::Pause: {
        emit pause(command.pause.paused, command.pause.percent_pos);
        break;
    }
    case Synchro_Command::Tag::Seek: {
        emit seek(command.seek.percent_pos, command.seek.dragged);
        break;
    }
    case Synchro_Command::Tag::UpdateClientList: {
        qDebug() << QString::fromUtf8(command.update_client_list.client_list).split(",");
        emit updateClientList(QString::fromUtf8(command.update_client_list.client_list).split(","));
        synchro_char_free(command.update_client_list.client_list);
        break;
    }
    case Synchro_Command::Tag::SetName: {
        qDebug() << "SetName command received";
        break;
    }
    case Synchro_Command::Tag::Invalid: {
        qDebug() << "Invalid command received";
        break;
    }
    default: {
        qDebug() << "Unknown command received";
        break;
    }
    }
}
