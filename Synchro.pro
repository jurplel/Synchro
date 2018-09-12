QT += quick
CONFIG += c++14

VERSION = 0.1 # major.minor

# allows use of version variable elsewhere
DEFINES += "VERSION=$$VERSION"

# build folder organization
DESTDIR = bin
OBJECTS_DIR = intermediate
MOC_DIR = intermediate
UI_DIR = intermediate
RCC_DIR = intermediate

# link mpv
QT_CONFIG -= no-pkg-config
CONFIG += link_pkgconfig
PKGCONFIG += mpv

# Windows specific stuff
win32:CONFIG += static
#RC_ICONS = "dist/win/Synchro.ico"
QMAKE_TARGET_COPYRIGHT = "Copyright © 2018 jurplel and Synchro contributors"
QMAKE_TARGET_DESCRIPTION = "Synchro"

# macOS specific stuff
QMAKE_TARGET_BUNDLE_PREFIX = "com.synchro"
#QMAKE_INFO_PLIST = "dist/mac/Info.plist"
#ICON = "dist/mac/qView.icns"

# Linux specific stuff
binary.path = /usr/bin
binary.files = bin/synchro

unix:!macx:INSTALLS += binary
unix:!macx:TARGET = synchro

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/main.cpp \
    src/corerenderer.cpp \
    src/videoobject.cpp \
    src/seekworker.cpp

RESOURCES += src/qml.qrc

OTHER_FILES += src/*.qml

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

HEADERS += \
    src/corerenderer.h \
    src/videoobject.h \
    src/seekworker.h
