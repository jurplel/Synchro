#include <locale.h>

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QSurfaceFormat>
#include <QQmlContext>

#include "videoobject.h"
#include "synchronycontroller.h"
#include "serverbrowser.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    app.setOrganizationName(COMPANY);
    app.setApplicationName(PROJECT_NAME);
    app.setApplicationVersion(VERSION);
    // libmpv requires LC_NUMERIC to be set to "C"
    setlocale(LC_NUMERIC, "C");

    qmlRegisterType<VideoObject>("Synchro.Core", 1, 0, "VideoObject");
    qmlRegisterType<SynchronyController>("Synchro.Core", 1, 0, "SynchronyController");
    qmlRegisterType<ServerBrowser>("Synchro.Core", 1, 0, "ServerBrowser");

    //disable vsync for perfect resizing
//    QSurfaceFormat fmt;
//    fmt.setSwapInterval(0);
//    QSurfaceFormat::setDefaultFormat(fmt);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("NIGHTLY", NIGHTLY);
    engine.rootContext()->setContextProperty("VERSION", VERSION);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
