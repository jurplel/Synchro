#include <locale.h>

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QSurfaceFormat>

#include "videoobject.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    app.setOrganizationName("Synchro");
    app.setApplicationName("Synchro");
    app.setApplicationVersion(QString::number(VERSION));
    // libmpv requires LC_NUMERIC to be set to "C"
    setlocale(LC_NUMERIC, "C");

    qmlRegisterType<VideoObject>("Synchro.Core", 1, 0, "VideoObject");

    //disable vsync for perfect resizing
//    QSurfaceFormat fmt;
//    fmt.setSwapInterval(0);
//    QSurfaceFormat::setDefaultFormat(fmt);

    QQuickStyle::setStyle("synchrostyle");
    QQuickStyle::setFallbackStyle("Fusion");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
