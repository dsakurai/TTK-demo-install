cmake_minimum_required(VERSION 3.10) # Downgrade / upgrade with will

# Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
# Email: d.sakurai@computer.org

include(ExternalProject)

set(ttk_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ttk")

message(FATAL_ERROR Assuming ParaView 5.5)
message(FATAL_ERROR Bad path settings for ParaView)

# How we install TTK 
ExternalProject_Add(TTK
    # General
        SOURCE_DIR "${ttk_SOURCE_DIR}"
        # This doesn't work. I don't know why...
        #BINARY_DIR "${ttk_SOURCE_DIR}/build-${TTK_CMAKE_BUILD_TYPE}"
    # Download step
        GIT_REPOSITORY https://github.com/topology-tool-kit/ttk.git
        GIT_TAG "${TTK_VERSION_TAG}"
        GIT_SHALLOW ON # Do a shallow clone to save the disk space
        GIT_PROGRESS ON # Show progress to the user
    # Configure step
        CMAKE_ARGS
            "-DCMAKE_BUILD_TYPE=${TTK_CMAKE_BUILD_TYPE}"
            "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
            "-DParaView_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/paraview-5.5"
    # Build step
        BUILD_ALWAYS ON # Ensure that the build will run regardless of time stamp
        BUILD_COMMAND make VERBOSE=ON -j16 # verbose output for the sake of communication in mailing list
    )

set(ParaView_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ParaView")
# How we install ParaView
ExternalProject_Add(ParaView
    # General
        SOURCE_DIR "${ParaView_SOURCE_DIR}"
        # TODO remove this line
        BINARY_DIR "${ParaView_SOURCE_DIR}/build"
    # Download step
        GIT_REPOSITORY https://github.com/Kitware/ParaView.git
        #GIT_TAG "${ParaView_VERSION_TAG}"
        GIT_SHALLOW ON # Do a shallow clone to save the disk space
        GIT_PROGRESS ON # Show progress to the user
    # Update step is disabled, because this is known by CMake people to conflict with the patch step
        UPDATE_DISCONNECTED ON
    # Patch step
        PATCH_COMMAND
            # This sets the git directory to the intended version before patching.
            cd "${CMAKE_CURRENT_SOURCE_DIR}"
            && ./utils/patch_command.sh "${CMAKE_CURRENT_SOURCE_DIR}/ttk/paraview/patch/"
    # Configure step
        CMAKE_ARGS
            "-DCMAKE_BUILD_TYPE=${ParaView_CMAKE_BUILD_TYPE}"
            "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
            "-DPARAVIEW_INSTALL_DEVELOPMENT_FILES=ON"
    # Build step
    #BUILD_ALWAYS ON # Ensure that the build will run regardless of time stamp
        BUILD_COMMAND make VERBOSE=ON -j16 # verbose output for the sake of communication in mailing list
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

ExternalProject_Add_StepDependencies(ParaView download
    TTK-download
    )

ExternalProject_Add_StepDependencies(TTK build
    ParaView-build
    )

