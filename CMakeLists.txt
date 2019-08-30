cmake_minimum_required(VERSION 3.12)

project(Synchro LANGUAGES CXX)

set(THREADS_PREFER_PTHREAD_FLAG ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_definitions(QT_DEPRECATED_WARNINGS)
add_compile_definitions(VERSION=0.1)

set(SOURCES
    src/main.cpp
    src/corerenderer.cpp
    src/videoobject.cpp
    src/synchronycontroller.cpp
    src/serverbrowser.cpp
    src/trackhandler.cpp
)
set(RESOURCES
    src/qml.qrc
    resources/resources.qrc
)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 QuickCompiler Widgets Network REQUIRED)
find_package(Threads REQUIRED)

# Enable QtQuickCompiler for faster startup time
qtquick_compiler_add_resources(RESOURCES ${RESOURCES})

# Link libmpv
if (WIN32)
    find_library(MPV_LIBRARIES NAMES libmpv.dll.lib libmpv.lib mpv.lib PATHS ${CMAKE_CURRENT_SOURCE_DIR}/mpv/x86_64/)
    find_path(MPV_INCLUDE_DIRS NAMES mpv/client.h mpv/render.h mpv/render_gl.h PATHS ${CMAKE_CURRENT_SOURCE_DIR}/mpv/include/)
elseif (UNIX)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(MPV REQUIRED mpv)
endif()

# Link libsynchro
find_library(LIBSYNCHRO_LIBRARIES NAMES libsynchro.so libsynchro.dylib synchro.dll PATHS ${CMAKE_CURRENT_SOURCE_DIR}/libsynchro/capi/target/release/)
find_path(LIBSYNCHRO_INCLUDE_DIRS NAMES libsynchro.hpp PATHS ${CMAKE_CURRENT_SOURCE_DIR}/libsynchro/capi/target/include/)

# Fix linking on 10.14+. See https://stackoverflow.com/questions/54068035
IF(APPLE)
    LINK_DIRECTORIES(/usr/local/lib)
ENDIF()

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE ${SOURCES} ${RESOURCES})
target_include_directories(${PROJECT_NAME} PRIVATE ${MPV_INCLUDE_DIRS} ${LIBSYNCHRO_INCLUDE_DIRS})
target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE ${MPV_LIBRARIES} ${LIBSYNCHRO_LIBRARIES} Threads::Threads ${CMAKE_DL_LIBS} Qt5::Core Qt5::Quick Qt5::QuickControls2 Qt5::Widgets Qt5::Network)
