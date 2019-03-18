#ifndef SYNCHRONYCONTROLLER_H
#define SYNCHRONYCONTROLLER_H

#include <QObject>

class SynchronyController : public QObject
{
    Q_OBJECT
public:
    explicit SynchronyController(QObject *parent = nullptr);

signals:

public slots:
};

#endif // SYNCHRONYCONTROLLER_H
