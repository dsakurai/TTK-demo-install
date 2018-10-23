cmake_minimum_required(VERSION 3.10) # Downgrade / upgrade with will

# Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
# Email: d.sakurai@computer.org

include(ExternalProject)

# TTK version is set by the user?
if (NOT "${TTK_VERSION_TAG}" STREQUAL "")
    # Set version: (e.g. git tag v0.9.2 => 0.9.2)
    string(REGEX MATCH "[^v]*$$" TTK_VERSION_NUMBER "${TTK_VERSION_TAG}")
endif()
# ParaView version is set by the user?
if (NOT "${ParaView_VERSION_TAG}" STREQUAL "")
    # Set version: (e.g. git tag v0.9.2 => 0.9.2)
    string(REGEX MATCH "[^v]*$$" ParaView_VERSION_NUMBER "${ParaView_VERSION_TAG}")
endif()
if (ParaView_USE_LATEST_PATCHABLE)
endif()

set(ttk_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ttk")

# How we install TTK 
ExternalProject_Add(TTK
    # General
    SOURCE_DIR "${ttk_SOURCE_DIR}"
    # Download step
        GIT_REPOSITORY https://github.com/topology-tool-kit/ttk.git
        GIT_TAG "${TTK_VERSION_TAG}"
        GIT_SHALLOW ON # Do a shallow clone to save the disk space
        GIT_PROGRESS ON # Show progress to the user
    )

set(ParaView_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ParaView")
# How we install ParaView
ExternalProject_Add(ParaView
    # General
        SOURCE_DIR "${ParaView_SOURCE_DIR}"
    # Download step
        GIT_REPOSITORY https://github.com/Kitware/ParaView.git
        GIT_TAG "${ParaView_VERSION_TAG}"
        GIT_SHALLOW ON # Do a shallow clone to save the disk space
        GIT_PROGRESS ON # Show progress to the user
    # Update / patch step
        PATCH_COMMAND
            cd "${ParaView_SOURCE_DIR}"
            && git checkout HEAD # clean the repository
            && cd "${ttk_SOURCE_DIR}/paraview/patch"
            && "./patch-paraview-${ParaView_VERSION_NUMBER}.sh" "ParaView"
    )

# expose some targets to:
#    - let the user fine-tune the installation
#    - tell CMake some tricky dependencies
#        - E.g. TTK install <- Paraview install <- ParaView patch <- TTK download
ExternalProject_Add_StepTargets(
    TTK
    download install
    )
ExternalProject_Add_StepTargets(
    ParaView
    download patch build install
    )

ExternalProject_Add_StepDependencies(ParaView patch
    TTK-download
    )

ExternalProject_Add_StepDependencies(ParaView download
    TTK-download
    )

ExternalProject_Add_StepDependencies(TTK install
    ParaView-install
    )

