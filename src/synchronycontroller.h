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

    void updateClientList(QStringList clientList);

public slots:
    void connectToServer(QString ip, quint16 port);

    void sendCommand(quint8 command, QVariantList arguments = QVariantList());

private:
    SynchroConnection *socket;
};

#endif // SYNCHRONYCONTROLLER_H
