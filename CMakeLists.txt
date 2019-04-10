cmake_minimum_required(VERSION 3.12)

project(Synchro LANGUAGES CXX)

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
)
set(RESOURCES
    src/qml.qrc
    resources/resources.qrc
)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 QuickCompiler Widgets Network REQUIRED)
find_library(LIBMPV libmpv mpv PATHS ${CMAKE_CURRENT_SOURCE_DIR}/mpv/x86_64/)

#Enable QtQuickCompiler for faster startup time
qtquick_compiler_add_resources(RESOURCES ${RESOURCES})

message(STATUS ${LIBMPV})

add_executable(${PROJECT_NAME} WIN32 ${SOURCES} ${RESOURCES})
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/mpv/include/)
target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBMPV} Qt5::Core Qt5::Quick Qt5::QuickControls2 Qt5::Widgets Qt5::Network)