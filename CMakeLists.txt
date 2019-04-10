cmake_minimum_required(VERSION 3.1)

project(Synchro LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


add_compile_definitions(QT_DEPRECATED_WARNINGS)
add_compile_definitions(VERSION=0.1)

if(WIN32)
    include_directories(${CMAKE_SOURCE_DIR}/mpv/include/)
    set(LIBMPV ${CMAKE_SOURCE_DIR}/mpv/x86_64/libmpv.lib)
endif()

set(SOURCES
    src/main.cpp
    src/corerenderer.cpp
    src/videoobject.cpp
    src/synchronycontroller.cpp
    src/qml.qrc
    resources/resources.qrc
)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 Widgets Network Svg REQUIRED)

add_executable(${PROJECT_NAME} WIN32 ${SOURCES})
target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt5::Core Qt5::Quick Qt5::QuickControls2 Qt5::Widgets Qt5::Network Qt5::Svg ${LIBMPV})