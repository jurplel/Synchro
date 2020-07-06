cmake_minimum_required(VERSION 3.12)

set(THREADS_PREFER_PTHREAD_FLAG ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(NIGHTLY "Nightly")
set(BUILD_NUMBER "0" CACHE STRING "Build number to be set as the version (for ci)")

include(meta)

# Set project metadata

set(VERSION 0.1)

IF(NIGHTLY)
    set(VERSION "0.${BUILD_NUMBER}")
ELSE()
    set(NIGHTLY OFF)
ENDIF()

project("Synchro" VERSION ${VERSION} LANGUAGES CXX)
set(COMPANY "Interverse")
set(COPYRIGHT "Copyright © 2020 jurplel")
set(IDENTIFIER "com.interverse.Synchro")

setup_meta_files(META_FILES)

# End of metadata section

set(SOURCES
    src/main.cpp
    src/corerenderer.cpp
    src/videoobject.cpp
    src/synchronycontroller.cpp
    src/serverlistmodel.cpp
    src/clientlistmodel.cpp
    src/trackhandler.cpp
)
set(RESOURCES
    src/qml/qml.qrc
    resources/resources.qrc
)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 QuickCompiler Widgets Network REQUIRED)
find_package(Threads REQUIRED)

# Enable QtQuickCompiler for faster startup time
qtquick_compiler_add_resources(RESOURCES ${RESOURCES})

# Link libmpv
if (WIN32)
    find_library(MPV_LIBRARIES NAMES libmpv.dll.lib libmpv.lib mpv.lib PATHS ${CMAKE_CURRENT_SOURCE_DIR}/mpv/)
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

add_compile_definitions(QT_DEPRECATED_WARNINGS)
add_compile_definitions(VERSION="${VERSION}" NIGHTLY=$<BOOL:${NIGHTLY}> PROJECT_NAME="${PROJECT_NAME}" COMPANY="${COMPANY}")
add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE ${SOURCES} ${RESOURCES} ${META_FILES})
target_include_directories(${PROJECT_NAME} PRIVATE ${MPV_INCLUDE_DIRS} ${LIBSYNCHRO_INCLUDE_DIRS})
target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE ${MPV_LIBRARIES} ${LIBSYNCHRO_LIBRARIES} Threads::Threads ${CMAKE_DL_LIBS} Qt5::Core Qt5::Quick Qt5::QuickControls2 Qt5::Widgets Qt5::Network)
