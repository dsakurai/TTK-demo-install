cmake_minimum_required(VERSION 3.10) # Downgrade / upgrade with will

# Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
# Email: d.sakurai@computer.org

include(ExternalProject)

include(ProcessorCount)
# number of cores on this system.
ProcessorCount(Num_Processors)


# Check if OpenMP is available
find_package(OpenMP)
set(TTK_ENABLE_OPENMP OFF)
if(OPENMP_FOUND)
    set(TTK_ENABLE_OPENMP ON)
endif()

if (TTK_VERSION_TAG)
    set(TTK_GIT_BRANCH "-b ${TTK_VERSION_TAG}")
endif()

set(TTK_DOWNLOWAD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/TTK-prefix/src/TTK")
set(Patch_dir "${TTK_DOWNLOWAD_DIR}/paraview/patch/")

# clone
execute_process(COMMAND echo hello)
if (TTK_GIT_BRANCH)
    execute_process(COMMAND git clone "${TTK_GIT_BRANCH}" https://github.com/topology-tool-kit/ttk.git "${TTK_DOWNLOWAD_DIR}")
else()
    execute_process(COMMAND git clone https://github.com/topology-tool-kit/ttk.git "${TTK_DOWNLOWAD_DIR}")
endif()
execute_process(COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/utils/latest_paraview_version_for_ttk.py" "${Patch_dir}" "--first_two" OUTPUT_VARIABLE ParaView_VERSION_NUMBER_FIRST_TWO)

# Set where ParaView configuration file is located.
if(APPLE) # Mac
    set(ParaView_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ParaView-prefix/src/ParaView-build")
    set(Set_arg_TTK_INSTALL_PLUGIN_DIR "-DTTK_INSTALL_PLUGIN_DIR=${CMAKE_INSTALL_PREFIX}/Applications/paraview.app/Contents/Plugins")
elseif(UNIX) # Linux
    set(ParaView_DIR "${CMAKE_INSTALL_PREFIX}/lib/cmake/paraview-${ParaView_VERSION_NUMBER_FIRST_TWO}")
else()
    message(FATAL_ERROR "Could not determine the operating system.")
endif()

# How we install TTK 
ExternalProject_Add(TTK
    # Configure step
        CMAKE_ARGS
            "-DParaView_DIR=${ParaView_DIR}"
            "-DCMAKE_BUILD_TYPE=${TTK_CMAKE_BUILD_TYPE}"
            "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
            "-DTTK_ENABLE_OPENMP=${TTK_ENABLE_OPENMP}"
            "${Set_arg_TTK_INSTALL_PLUGIN_DIR}"
    # Build step
        BUILD_ALWAYS ON # Ensure that the build will run regardless of time stamp
        BUILD_COMMAND make VERBOSE=ON "-j${Num_Processors}" # verbose output for the sake of communication in mailing list
    )

# How we install ParaView
ExternalProject_Add(ParaView
    # Download step
        GIT_REPOSITORY https://github.com/Kitware/ParaView.git
        GIT_SHALLOW ON # Do a shallow clone to save the disk space
        GIT_PROGRESS ON # Show progress to the user
    # Update step is disabled, because this is known by CMake people to conflict with the patch step
        UPDATE_DISCONNECTED ON
    # Patch step: will also update the code version through the version control system.
        PATCH_COMMAND
            cd "${CMAKE_CURRENT_SOURCE_DIR}"
            # patch ParaView: pass the version number
            && ./utils/patch_command.sh "${Patch_dir}" $("${CMAKE_CURRENT_SOURCE_DIR}/utils/latest_paraview_version_for_ttk.py" "${Patch_dir}")
    # Configure step
        CMAKE_ARGS
            # Mandatory
            "-DCMAKE_BUILD_TYPE=${ParaView_CMAKE_BUILD_TYPE}"
            "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
            "-DPARAVIEW_INSTALL_DEVELOPMENT_FILES=ON"

            "-DMACOSX_APP_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/Applications"

            # Turn off the help system since IT departments sometimes forget to install the Qt5 help framework
            "-DPARAVIEW_USE_QTHELP=OFF"
            "-DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION=OFF"

            # Nice to have
            "-DPARAVIEW_ENABLE_PYTHON=ON"
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
            BUILD_ALWAYS ON # Ensure that the build will run regardless of time stamp
            BUILD_COMMAND make VERBOSE=ON
            # Faster, but this parallel build fails due to some oddness...
            #BUILD_COMMAND make VERBOSE=ON "-j${Num_Processors}"
    )

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

