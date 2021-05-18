Cross-Compiling for the Beaglebone Black
=====

This repository shows how to cross-compile a simple Hello World program and run it on
a Beaglebone Black. It also shows how to install and setup a TCF agent on the Beaglebone Black
for remote debugging with Eclipse.

# Prerequisites for cross-compiling

1. `CMake` installed
2. ARM Linux cross compiler installed
3. Beagle Bone Black sysroot folder mirrored on the host machine, using `rsync` and `scp`.
   See the related [chapter](#rootfs) for more information.
4. Optional: `tcf-agent` running on the BBB for remote debugging with Eclipse. See the
   related [chapter](#tcfagent) for more information.

# Windows

There are  two options to cross-compile on Windows: Use the native tools and the Unix environment
provided by MinGW64 or perform the Linux steps in WSL2. If you want to use WLS2, follow the Linux
instructions (not tested yet, but should work). The following instructions show
how to cross-compile using MinGW64. It is still recommended to clone the sysroot with Linux
tools, using WSL2, because cloning with the MinGW64 can be problematic.

Install [MSYS2](https://www.msys2.org/) first.

Prepare MSYS2 by running the following commands in MinGW64

```
pacman -S mingw-w64-x86_64-cmake mingw-w64-x86_64-make rsync
```

You can also run `pacman -S mingw-w64-x86_64-toolchain` to install the full build chain with
`gcc` and `g++`

1. Install the correct [ARM Linux cross-compile toolchain](https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/)
   provided by Linaro and unzip it somewhere. Copy the path to the `bin` folder.

2. Navigate into the toolchain folder inside MinGW64.

   ```sh
   cd <toolchainPath>/bin
   pwd
   ```

   Copy the path and run the following command to add the tool binary path to the MinGW64 path

   ```sh
   export PATH=$PATH:"<copied path>"
   ```

3. It is assumed the root filesystem is located somewhere on the host machine (see [rootfs](#rootfs)
   chapter for more information how to do this). Set in in an environmental variable which 
   `CMake` can use

   ```sh
   export BBB_ROOTFS="<pathToRootfs>"
   ```

   Note that you can add the commands in step 2 and step 3 to the `~/.bashrc` to set the path
   and the environment variable up permanently

4. Build the application using CMake. Run the following commands inside the repository

   ```sh
   mkdir build && cd build
   cmake -G "MinGW Makefiles" ..
   cmake --build . -j
   chmod +x hello
   ```
 
5. Transfer to application to the Beaglebone Black and run it to test it

   ```sh
   scp hello <username>@beaglebone.local:/tmp
   ssh <username>@beaglebone.local
   cd /tmp
   ./hello
   ```

# Linux

Instructions for an Ubuntu host

1. Install the correct [ARM Linux cross-compile toolchain](https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/)
   provided by Linaro and unzip it somewhere. Copy the path to the `bin` folder.

2. Navigate into the toolchain folder.

   ```sh
   cd <toolchainPath>/bin
   pwd
   ```

   Copy the path and run the following command to add the tool binary path to the MinGW64 path

   ```sh
   export PATH=$PATH:"<copied path>"
   ```

3. It is assumed the root filesystem is located somewhere on the host machine (see [rootfs](#rootfs)
   chapter for more information how to do this). Set in in an environmental variable which 
   `CMake` can use

   ```sh
   export BBB_ROOTFS="<pathToRootfs>"
   ```

   Note that you can add the commands in step 2 and step 3 to the `~/.bashrc` to set the path
   and the environment variable up permanently.

4. Build the application using CMake. Run the following commands inside the repository

   ```sh
   mkdir build && cd build
   cmake ..
   cmake --build . -j
   chmod +x hello
   ```

5. Transfer to application to the Beaglebone Black and run it to test it

   ```sh
   scp hello <username>@beaglebone.local:/tmp
   ssh <username>@beaglebone.local
   cd /tmp
   ./hello
   ```

# <a id="rootfs"></a> Cloning the root filesystem

# <a id="tcfagent"></a> Installing the TCF agent on the Beaglebone Black

The [TCF agent](https://wiki.eclipse.org/TCF) allows comfortable
Eclipse remote debugging and other features like a remote  file explorer in Eclipse.
The following steps show how to setup the TCF agent on the Raspberry Pi and add it to the
auto-startup applications. The steps are based
on [this guide](https://wiki.eclipse.org/TCF/Raspberry_Pi)

1. Install required packages on the BBB

   ```sh
   sudo apt-get install git uuid uuid-dev libssl-dev
   ```

2. Clone the repository and perform some preparation steps
   ```sh
   git clone git://git.eclipse.org/gitroot/tcf/org.eclipse.tcf.agent.git
   cd org.eclipse.tcf.agent.git/agent
   ```

3. Build the TCF agent
   ```sh
   make
   ```

   and then test it by running

   ```sh
   obj/GNU/Linux/arm/Debug/agent –S
   ```

4. Finally install the agent for auto-start with the following steps. And set it up for 
   auto-start.

   ```sh
   cd org.eclipse.tcf.agent/agent
   make install
   sudo make install INSTALLROOT=
   sudo update-rc.d tcf-agent defaults
   ```

5. Restart the BBB and verify the tcf-agent is running with the following command

   ```sh
   systemctl status tcf-agent
   ```