cmake_minimum_required(VERSION 3.10) # Downgrade / upgrade with will

# Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
# Email: d.sakurai@computer.org

include(ExternalProject)

include(ProcessorCount)
# number of cores on this system.
ProcessorCount(Num_Processors)

set(Patch_dir "${CMAKE_CURRENT_SOURCE_DIR}/TTK-prefix/src/TTK/paraview/patch/")

# Check if OpenMP is available
find_package(OpenMP)
set(TTK_ENABLE_OPENMP OFF)
if(OPENMP_FOUND)
    set(TTK_ENABLE_OPENMP ON)
endif()

# How we install TTK 
ExternalProject_Add(TTK
    # Download step
        GIT_REPOSITORY https://github.com/topology-tool-kit/ttk.git
        GIT_TAG "${TTK_VERSION_TAG}"
        GIT_SHALLOW ON # Do a shallow clone to save the disk space
        GIT_PROGRESS ON # Show progress to the user
    # Configure step
        CMAKE_ARGS
            "-DCMAKE_BUILD_TYPE=${TTK_CMAKE_BUILD_TYPE}"
            "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
            "-DTTK_ENABLE_OPENMP=${TTK_ENABLE_OPENMP}"
            "\"-DParaView_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/paraview-$(\"${CMAKE_CURRENT_SOURCE_DIR}/utils/latest_paraview_version_for_ttk.py\" \"${Patch_dir}\" \"--first_two\")\""
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
    # Patch step
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

            # Dependency not installed by default on some Linux machines
            "-DPARAVIEW_USE_QTHELP=OFF"
            "-DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION=OFF"

            # Nice to have
            "-DPARAVIEW_ENABLE_PYTHON=ON"
            # Load ICON data
            "-DPARAVIEW_AUTOLOAD_PLUGIN_CDIReader=ON"
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
            #"-DPARAVIEW_ENABLE_FFMPEG=ON"
    # Build step
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
    download patch build
    )

ExternalProject_Add_StepDependencies(ParaView patch
    TTK-download
    )

# TODO This is possibly unnecessary
ExternalProject_Add_StepDependencies(ParaView download
    TTK-download
    )

ExternalProject_Add_StepDependencies(TTK build
    ParaView-build
    )

