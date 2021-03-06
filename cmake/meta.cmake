macro(fix_project_version)

if (NOT PROJECT_VERSION_PATCH)
    set(PROJECT_VERSION_PATCH 0)
endif()

if (NOT PROJECT_VERSION_TWEAK)
    set(PROJECT_VERSION_TWEAK 0)
endif()

endmacro()

macro(setup_meta_files FILES_TO_INCLUDE)

fix_project_version()

IF(NIGHTLY)
    set(ICON_NAME Nightly)
ELSE()
    set(ICON_NAME ${PROJECT_NAME})
ENDIF()

if (WIN32)
    set(ICON_FILE "${PROJECT_SOURCE_DIR}/dist/win/${ICON_NAME}.ico")
elseif (APPLE)
    set(ICON_FILE "${PROJECT_SOURCE_DIR}/dist/mac/${ICON_NAME}.icns")
endif()

if (WIN32)
    configure_file("${PROJECT_SOURCE_DIR}/dist/win/${PROJECT_NAME}.rc"
      "{PROJECT_NAME}.rc"
    )
    set(RES_FILES "{PROJECT_NAME}.rc")

    set(${FILES_TO_INCLUDE} ${RES_FILES})
endif()

if (APPLE)
    set_source_files_properties(${ICON_FILE} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    
    # Identify MacOS bundle
    set(MACOSX_BUNDLE_BUNDLE_NAME ${PROJECT_NAME})
    set(MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION})
    set(MACOSX_BUNDLE_LONG_VERSION_STRING ${PROJECT_VERSION})
    set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
    set(MACOSX_BUNDLE_COPYRIGHT ${COPYRIGHT})
    set(MACOSX_BUNDLE_GUI_IDENTIFIER ${IDENTIFIER})
    set(MACOSX_BUNDLE_ICON_FILE ${ICON_NAME})

    set(${FILES_TO_INCLUDE} ${ICON_FILE})
endif()

endmacro()
