Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
Email: d.sakurai@computer.org

What's This Project?
--------------------

A semi-automatic script that installs a demo enviroment of [Topology ToolKit](https://topology-tool-kit.github.io/installation.html) (TTK) for you.

How To
------

On Unix, run the shell command below.
This creates a new project named `TTK-demo-install` under the current directory.
~~~
$ source <(curl -Ls https://github.com/dsakurai/TTK-demo-install/raw/master/utils/one_line_install.sh)
~~~

You are going to be asked several questions before TTK as well as ParaView are installed.
The message will also direct you to the official TTK project page, on which you will find dependencies. Install them separately if you haven't done so.

The default installation directory for the demo binaries is `TTK-demo-install/local`.
On Linux, the ParaView executable will be installed as `installation_directory/bin/paraview` (`installation_directory` is the the installation directory you would have chosen.)

Tips & Tricks
-------------
ParaView is built inside the directory `ParaView-prefix/src/ParaView-build`, while TTK inside `TTK-prefix/src/TTK-build`. This means that you can customize your build by going into these directories and issuing `ccmake .` (or by directly editing the CMakeCache.txt files).
To start the customization, you need to wait until their configuration is finished. You can restart the entire build by issuing `make` from the rood directory `TTK-demo-install`.

You can also update an existing demo that you installed through this project.
To do so execute `TTK-demo-install/install_or_update.sh`.

Known Issues
------------
**Directory Structure**  
The directory structure is different from the one assumed in the TTK tutorial.
When I tried to solve this problem, I hit the weird problem that CMake cannot create the directories automatically.

**Parallel Build**  
Compiling ParaView in parallel doesn't work, at least on Ubuntu 18.
As a workaround you may initially let ParaView compile in serial and switch to a parallel build afterwards. Actually, after hitting approximately 10% of the build process you can stop the build (hit ctrl-C) and manually issue make with parallelization enabled. The make command is `cd TTK-demo-install/ParaView-prefix/src/ParaView-build && make -jN`, where N shall be replaced with the number of threads you run for the build. After a successful build of your ParaView, go back to the root directory `TTK-demo-install`, and issue `make` to continue building the whole project.
