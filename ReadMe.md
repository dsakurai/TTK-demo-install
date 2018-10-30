Author: Daisuke Sakurai @ Zuse Institute Berlin (2018 Oct.)
Email: d.sakurai@computer.org

What's This Project?
--------------------

A semi-automatic script that installs a demo enviroment of [TTK](https://topology-tool-kit.github.io/installation.html).

How To
------

On Unix, run the shell command below.
This creates a new project named `TTK-demo-install` under the current directory.
~~~
$ source <(curl -Ls https://github.com/dsakurai/TTK-demo-install/raw/master/utils/one_line_install.sh)
~~~

You are going to be asked several questions before TTK as well as ParaView are installed.
The default installation directory is `TTK-demo-install/local`.
On Linux, the ParaView executable will be installed as `installation_directory/bin/paraview` (`installation_directory` is the the installation directory you have chosen.)
