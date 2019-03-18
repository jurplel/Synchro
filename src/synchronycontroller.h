#ifndef SYNCHRONYCONTROLLER_H
#define SYNCHRONYCONTROLLER_H

#include <QObject>
#include <QTcpSocket>
#include <QDataStream>

class SynchronyController : public QObject
{
    Q_OBJECT
public:
    enum class Command : quint8
    {
       Pause,
       Seek
    };
    Q_ENUM(Command)

    explicit SynchronyController(QObject *parent = nullptr);

    void dataRecieved();

    void recieveCommand(Command command, QVariant data = QVariant());

signals:
    void pause();

    void seek(double percentPos);

public slots:
    void connectToServer(QString ip, quint16 port);

    void sendCommand(Command command, QVariant data = QVariant());

private:
    QTcpSocket *socket;
    QDataStream in;
};

#endif // SYNCHRONYCONTROLLER_H
