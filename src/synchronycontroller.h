#ifndef SYNCHRONYCONTROLLER_H
#define SYNCHRONYCONTROLLER_H

#include <QObject>

#include "libsynchro.hpp"

class SynchronyController : public QObject
{
    Q_OBJECT
public:
    explicit SynchronyController(QObject *parent = nullptr);

    void handleCommand(Command command);

signals:
    void pause(bool paused, double percentPos);

    void seek(double percentPos, bool useKeyframes);

public slots:
    void connectToServer(QString ip, quint16 port);

    void sendCommand(quint8 command, QVariantList arguments);

private:
    SynchroConnection *socket2;
};

#endif // SYNCHRONYCONTROLLER_H
