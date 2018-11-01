Author: Daisuke Sakurai
Email: d.sakurai@computer.org

About
-----

You can install a demo enviroment of [Topology ToolKit](https://topology-tool-kit.github.io/installation.html) (TTK) semi-automatically with this project. OpenMP is enabled when detected, but the installation contains only minimal features in order for the install to succeed in various environments.

There's no warranty as usual; utilize this project at your own risk and back up your files frequently.

How-To
------

On a Unix system, run the one-liner shell command below.
~~~
$ source <(curl -Ls https://github.com/dsakurai/TTK-demo-install/raw/master/utils/one_line_install.sh)
~~~
This creates a new project named `TTK-demo-install` under your current directory.
The script will automatically download this project and start the installation wizard.

You are going to be asked several questions before TTK as well as ParaView are installed.

The default installation directory for the demo binaries is `TTK-demo-install/local`.
On Linux, the ParaView executable will be installed as `installation_directory/bin/paraview` (`installation_directory` is the installation directory you will have chosen.)

Tips & Tricks
-------------
ParaView is built inside the directory `ParaView-prefix/src/ParaView-build`, while TTK inside `TTK-prefix/src/TTK-build`. This means that you can customize your build by going into these directories and then issuing `ccmake .` (or by directly editing the CMakeCache.txt files).
To start the customization, you need to wait until their configuration is finished. You can restart the entire build by issuing `make` from the rood directory `TTK-demo-install`.

You can also update an existing demo that you installed through this project.
To do so execute `TTK-demo-install/install_or_update.sh`. It doesn't matter in which directory you are in.

Known Issues
------------
**Qt Version**  
Some Qt versions do not work with particular ParaView versions. Qt 5.9 is recommended for ParaView 5.5. If your build fails with an error message like `member access into incomplete type 'QAbstractItemView'`, make sure that CMake is pointing to the right Qt installation.
Modify the variable `Qt5_DIR` in CMake to specify a Qt cmake configuration.
The value should be something like `~/Qt/5.9.7/clang_64/lib/cmake/Qt5` if you installed Qt using the official Qt installer.
Other Qt directories s.a. `QtWidgets_DIR` should be left empty so that CMake finds the directories properly.

**Directory Structure is Odd**  
The directory structure differs from the one assumed in the TTK tutorial.
When I tried to solve this problem, I hit the weird problem that CMake cannot create the directories automatically.

**Building ParaView is not Parallelized**  
Compiling ParaView in parallel doesn't work, at least on Ubuntu 18.
As a workaround you may initially let ParaView compile in serial and switch to a parallel build afterwards. Actually, after hitting approximately 10% of the build process you can stop the build (hit ctrl-C) and manually issue make with parallelization enabled. The make command is `cd TTK-demo-install/ParaView-prefix/src/ParaView-build && make -jN`, where N shall be replaced with the number of threads you run for the build. After a successful build of your ParaView, go back to the root directory `TTK-demo-install` and issue `make` to continue building the whole project.

**Help Documentations is Missing**  
I disabled the help system of ParaView as the required Qt help mechanism is hard to install on Ubuntu 18 if you don't have administrative rights.

It is a good idea to activate the help, though. You need to switch on `PARAVIEW_USE_QTHELP` and `PARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION` by issuing `ccmake .` from `ParaView-prefix/src/ParaView-build/` after the installation has finished. After the ccmake, issue `make` from the root directory, `TTK-demo-install`, to apply the change.
