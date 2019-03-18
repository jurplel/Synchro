#ifndef SYNCHRONYCONTROLLER_H
#define SYNCHRONYCONTROLLER_H

#include <QObject>
#include <QTcpSocket>

class SynchronyController : public QObject
{
    Q_OBJECT
public:
    enum class Command : quint8
    {
       Pause
    };
    Q_ENUM(Command)

    explicit SynchronyController(QObject *parent = nullptr);

    void readNewData();

    void recieveCommand(Command command);

signals:
    void pause();


public slots:
    void connectToServer(QString ip, quint16 port);

    void sendCommand(Command command);

private:
    QTcpSocket *socket;
    quint16 incomingSize;
};

#endif // SYNCHRONYCONTROLLER_H
