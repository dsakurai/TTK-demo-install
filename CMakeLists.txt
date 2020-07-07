cmake_minimum_required(VERSION 3.10) # Downgrade / upgrade with will
project(TTK_Demo_Install)

# Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
# Email: d.sakurai@computer.org

include(ExternalProject)

include(ProcessorCount)
# number of cores on this system.
ProcessorCount(Num_Processors)

find_package(Python3 COMPONENTS Interpreter Development REQUIRED)


# Check if OpenMP is available
find_package(OpenMP)
set(TTK_ENABLE_OPENMP OFF)
if(OPENMP_FOUND)
    set(TTK_ENABLE_OPENMP ON)
endif()

set(TTK_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/TTK" CACHE PATH "Path to the TTK source")
set(PARAVIEW_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ParaView")
set(Patch_dir "${TTK_SOURCE_DIR}/paraview/patch/")

execute_process(COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/utils/latest_paraview_version_for_ttk.py" "${Patch_dir}" "--first_two" OUTPUT_VARIABLE ParaView_VERSION_NUMBER_FIRST_TWO)

set(MACOSX_APP_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/Applications")

# Set where ParaView configuration file is located.
if(APPLE) # Mac
    set(ParaView_DIR "${CMAKE_CURRENT_BINARY_DIR}/ParaView-prefix/src/ParaView-build")

    set(Set_arg_TTK_INSTALL_PLUGIN_DIR "-DTTK_INSTALL_PLUGIN_DIR=${CMAKE_INSTALL_PREFIX}/Applications/paraview.app/Contents/MacOS/plugins")
    # The version follows the TTK tutorial which installs the TTK plugins into the built ParaView, as opposed to the installed ParaView.
    #set(Set_arg_TTK_INSTALL_PLUGIN_DIR "-DTTK_INSTALL_PLUGIN_DIR=${CMAKE_BINARY_SOURCE_DIR}/ParaView-prefix/src/ParaView-build/bin/paraview.app/Contents/MacOS/plugins")
elseif(UNIX) # Linux
    set(ParaView_DIR "${CMAKE_INSTALL_PREFIX}/lib/cmake/paraview-${ParaView_VERSION_NUMBER_FIRST_TWO}")
else()
    message(FATAL_ERROR "Could not determine the operating system.")
endif()

set(OSPRay_version 1.8.5)

if(ParaView_VERSION_NUMBER_FIRST_TWO STREQUAL "5.6")
    # ParaView 5.6 works with an old OSPRay
    set(OSPRay_version 1.7.3)
endif()

if (APPLE)
    set(OSPRay_URL "https://github.com/ospray/ospray/releases/download/v${OSPRay_version}/ospray-${OSPRay_version}.x86_64.macosx.tar.gz")
else(APPLE)
    # presumably linux
    set(OSPRay_URL "https://github.com/ospray/ospray/releases/download/v${OSPRay_version}/ospray-${OSPRay_version}.x86_64.linux.tar.gz")
endiF(APPLE)

# OSPRay
ExternalProject_Add(OSPRay
        INSTALL_DIR "${CMAKE_INSTALL_PREFIX}"
        URL "${OSPRay_URL}"
        DOWNLOAD_NO_EXTRACT
        CONFIGURE_COMMAND "" # nothing to do for configuration
        BUILD_COMMAND "" # nothing to build
        INSTALL_COMMAND bash -c "${CMAKE_CURRENT_SOURCE_DIR}/utils/install_ospray.sh ${CMAKE_CURRENT_BINARY_DIR}/OSPRay-prefix/src/OSPRay ${CMAKE_INSTALL_PREFIX}"
    )

set(ParaView_CMAKE_BUILD_TYPE Release CACHE STRING "Build type for CMake")
set(TTK_CMAKE_BUILD_TYPE Release CACHE STRING "Build type for TTK")

# How we install TTK
ExternalProject_Add(TTK
        INSTALL_DIR "${CMAKE_INSTALL_PREFIX}"
        SOURCE_DIR "${TTK_SOURCE_DIR}"
    # Configure step
        CMAKE_ARGS
            "-DParaView_DIR=${ParaView_DIR}"
            "-DCMAKE_BUILD_TYPE=${TTK_CMAKE_BUILD_TYPE}"
            "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
            "-DTTK_ENABLE_OPENMP=${TTK_ENABLE_OPENMP}"
            "${Set_arg_TTK_INSTALL_PLUGIN_DIR}"
            "-D" "CMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
            "-D" "CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"

            "-DPYTHON_EXECUTABLE=${Python3_EXECUTABLE}"
            "-DPYTHON_INCLUDE_DIRS=${Python3_INCLUDE_DIRS}"
            "-DPYTHON_LIBRARIES=${Python3_LIBRARIES}"

    # Build step
        BUILD_COMMAND make VERBOSE=ON "-j${Num_Processors}" # verbose output for the sake of communication in mailing list
    )

set(PARAVIEW_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

set(PARAVIEW_INSTALL_COMMAND INSTALL_COMMAND make -j${Num_Processors} install)

if (APPLE)
    # MacOS tends to have problems on rpaths 
    set(PARAVIEW_INSTALL_COMMAND 
        ${PARAVIEW_INSTALL_COMMAND}
        && install_name_tool -add_rpath "${CMAKE_INSTALL_PREFIX}/lib/" "${CMAKE_INSTALL_PREFIX}/Applications/paraview.app/Contents/MacOS/paraview"
        && install_name_tool -add_rpath @executable_path/../lib/ "${CMAKE_INSTALL_PREFIX}/bin/pvpython"
        )
endiF(APPLE)

# How we install ParaView
ExternalProject_Add(ParaView
        INSTALL_DIR "${PARAVIEW_INSTALL_PREFIX}"
        SOURCE_DIR "${PARAVIEW_SOURCE_DIR}"
    # Update step is disabled, because this is known to conflict with the patch step
        UPDATE_DISCONNECTED ON
    # Patch step: will also update the code version using the version control system.
        PATCH_COMMAND
            cd "${CMAKE_CURRENT_SOURCE_DIR}"
            # patch ParaView: pass the version number
            && "${CMAKE_CURRENT_SOURCE_DIR}/utils/checkout_and_patch.sh" "${Patch_dir}" "${PARAVIEW_SOURCE_DIR}" $("${CMAKE_CURRENT_SOURCE_DIR}/utils/latest_paraview_version_for_ttk.py" "${Patch_dir}")
    # Configure step
        CMAKE_ARGS
            # Mandatory
            "-DCMAKE_BUILD_TYPE=${ParaView_CMAKE_BUILD_TYPE}"
            "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
            "-DPARAVIEW_INSTALL_DEVELOPMENT_FILES=ON"

            "-DMACOSX_APP_INSTALL_PREFIX=${MACOSX_APP_INSTALL_PREFIX}"

            "-DPYTHON_EXECUTABLE=${Python3_EXECUTABLE}"
            "-DPYTHON_INCLUDE_DIRS=${Python3_INCLUDE_DIRS}"
            "-DPYTHON_LIBRARY=${Python3_LIBRARIES}"
            "-DPYTHON_LIBRARIES=${Python3_LIBRARIES}"
            "-DVTK_PYTHON_VERSION=3"

            # Turn off the help system since IT departments sometimes forget to install the Qt5 help framework
            "-DPARAVIEW_USE_QTHELP=ON"
            "-DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION=ON"

            # OSPRay
            -D PARAVIEW_ENABLE_RAYTRACING=ON
            -D PARAVIEW_USE_OSPRAY=ON # for old ParaView versions
            "-DOSPRAY_INSTALL_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/ospray-${OSPRay_version}"
            # Nice to have
            "-DPARAVIEW_USE_PYTHON=ON"
            "-DPARAVIEW_ENABLE_PYTHON=ON" # for old ParaViews
            "-DPARAVIEW_ENABLE_FFMPEG=ON"
            # Enable some nice tools
            "-DPARAVIEW_AUTOLOAD_PLUGIN_EmbossingRepresentations=ON"
            "-DPARAVIEW_AUTOLOAD_PLUGIN_ArrowGlyph=ON"
            "-DPARAVIEW_AUTOLOAD_PLUGIN_AcceleratedAlgorithms=ON"
            "-DPARAVIEW_AUTOLOAD_PLUGIN_LagrangianParticleTracker=ON"
            "-DPARAVIEW_AUTOLOAD_PLUGIN_GeodesicMeasurement=ON"
            "-DPARAVIEW_AUTOLOAD_PLUGIN_StreamLinesRepresentation=ON"
            "-DPARAVIEW_AUTOLOAD_PLUGIN_StreamingParticles=ON"
            "-DPARAVIEW_AUTOLOAD_PLUGIN_SurfaceLIC=ON"
            "-DPARAVIEW_AUTOLOAD_PLUGIN_ThickenLayeredCells=ON"
            # Load ICON data
            "-DPARAVIEW_AUTOLOAD_PLUGIN_CDIReader=ON"
        # Build step
            # Parallel builds fail on certain old Ubuntu versions, nonetheless...
            BUILD_COMMAND make "-j${Num_Processors}"
        # Install step
            # Fix bug in pvpython's install name list
            "${PARAVIEW_INSTALL_COMMAND}"
    )

if (APPLE)
    ExternalProject_Add_Step(ParaView Data
        COMMAND
            cd "${CMAKE_CURRENT_BINARY_DIR}" &&
            mkdir -p "${MACOSX_APP_INSTALL_PREFIX}/paraview.app/Contents/share/paraview-${ParaView_VERSION_NUMBER_FIRST_TWO}" &&
            cp -r "${TTK_SOURCE_DIR}/paraview/patch/data" "${MACOSX_APP_INSTALL_PREFIX}/paraview.app/Contents/share/paraview-${ParaView_VERSION_NUMBER_FIRST_TWO}/"
        ALWAYS ON # Execute this always to simplify the management of this project
        )
endif()

# expose some targets to:
#    - let the user fine-tune the installation
#    - tell CMake some tricky dependencies
#        - E.g. TTK install <- Paraview install <- ParaView patch <- TTK download
ExternalProject_Add_StepTargets(
    TTK
    download build install
    )
ExternalProject_Add_StepTargets(
    ParaView
    download patch build install
    )

ExternalProject_Add_StepDependencies(ParaView patch
    TTK-download
    )

# TODO This is possibly unnecessary
ExternalProject_Add_StepDependencies(ParaView download
    TTK-download
    )

ExternalProject_Add_StepDependencies(TTK build
    #ParaView-build
    ParaView-install
    )

ExternalProject_Add_StepDependencies(ParaView download
    OSPRay
    )
ExternalProject_Add_StepDependencies(TTK download
    OSPRay
    )

if (APPLE)
    ExternalProject_Add_StepDependencies(ParaView Data
        TTK-build # Actualy TTK-update or TTK-patch. But as the update & patch are known to be tricky to handle, we simply use build instead.
        )
endif()
