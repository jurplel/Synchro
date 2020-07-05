#ifndef SYNCHRONYCONTROLLER_H
#define SYNCHRONYCONTROLLER_H

#include <QObject>

#include "libsynchro.hpp"

class SynchronyController : public QObject
{
    Q_OBJECT
public:
    explicit SynchronyController(QObject *parent = nullptr);
    ~SynchronyController() override;

    void receiveCommand(Synchro_Command command);

signals:
    void pause(bool paused, double percentPos);

    void seek(double percentPos, bool useKeyframes);

    void updateClientList(QString clientList);

    void connected();

    void disconnected();

public slots:
    void disconnect();

    void connectToServer(QString ip, quint16 port);

    void connectionEstablished(SynchroConnection *newConnection);

    void sendCommand(quint8 command, QVariantList arguments = QVariantList());

private:
    SynchroConnection *connection;
};

#endif // SYNCHRONYCONTROLLER_H
