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

You can also download a basic root filesystem with `libgpiod` installed
from [here](https://drive.google.com/drive/folders/10CfrDEREHTsbUF-FdUp1ihx1mSFhUTRM?usp=sharing).

## Linux Host

Set up a sysroot folder on the local host machine. Make sure the SSH connection to
the BBB is working without issues. Then perform the following steps

```sh
cd $HOME
mkdir beaglebone
cd beaglebone
mkdir rootfs
cd rootfs
pwd
```

Store the result of `pwd`, it is going to be used by `rsync` later.

Now use `rsync` to clone the BBB sysroot to the local host machine.
You can replace `<ip-address>` with `beaglebone.local` to use DNS.
Use the rootfs location stored from the previous steps as `<rootfs-path>`.

```sh
rsync -avHAXR --delete-after --info=progress2 --numeric-ids <user_name>@<ip_address>:/{usr,lib} <rootfs_path>
```

On Linux, it is recommended to repair some symlinks which can be problematic:
Navigate to the folder containing the symlinks first:

```sh
cd <rootfs_path>/usr/lib/arm-linux-gnueabihf
```

You can now use

```sh
readlink libpthread.so
```

which will show an absolute location of a shared library the symlinks points to. This location
needs to be converted into a relative path.

Run the following command to create a relative symlinks instead of an absolute ones. The pointed
to location might change to check it with `readlink` first before removing the symlinks:

```sh
rm libpthread.so
rm librt.so
ln -s ../../../lib/arm-linux-gnueabihf/libpthread.so.0 libpthread.so
ln -s ../../../lib/arm-linux-gnueabihf/librt.so.1 librt.so
```

For more information on issues which can occur when cloning the root filesystem,
see the [troubleshooting](#troubleshooting) section.

## Windows Host

This requires [MSYS2](https://www.msys2.org/) installed. All command line steps shown here
were performed in the MSYS2 MinGW64 shell (not the default MSYS2, use MinGW64!).
Replace `<UserName>` with respectively. It is recommended to set up
aliases in the `.bashrc` file to allow quick navigation to the `fsfw_example`
repository and to run `git config --global core.autocrlf true` for git in
MinGW64.

Set up a sysroot folder on the local host machine. Make sure the SSH connection to
the BBB is working without issues. Then perform the following steps

```sh
cd /c/Users/<UserName>
mkdir beaglebone
cd beaglebone
mkdir rootfs
cd rootfs
pwd
```

Store the result of `pwd`, it is going to be used by `rsync` later.

Now use rsync to clone the BBB sysroot to the local host machine.
You can replace `<ip-address>` with `beaglebone.local` to use DNS.
Use the rootfs location stored from the previous steps as `<rootfs-path>`.

```sh
rsync -avHAXR --numeric-ids --info=progress2 <username>@<ip-address>:/{lib,usr} <rootfs-path>
```

Please note that `rsync` sometimes does not copy shared libraries or symlinks properly,
which might result in errors when cross-compiling and cross-linking. It is recommended to run
the following commands in addition to the `rsync` command on Windows:

```sh
scp <user_name>@<ip-address>:/lib/arm-linux-gnueabihf/{libc.so.6,ld-linux-armhf.so.3,libm.so.6} <rootfs_path>/lib/arm-linux-gnueabihf
scp <user_name>@<ip-address>:/usr/lib/arm-linux-gnueabihf/{libpthread.so,libc.so,librt.so} <rootfs_path>/usr/lib/arm-linux-gnueabihf
```

For more information on issues which can occur when cloning the root filesystem,
see the [troubleshooting](#troubleshooting) section.

# <a id="tcfagent"></a> Installing the TCF agent on the Beaglebone Black

The [TCF agent](https://wiki.eclipse.org/TCF) allows comfortable
Eclipse remote debugging and other features like a remote  file explorer in Eclipse.
The following steps show how to setup the TCF agent on the BBB and add it to the
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

# Using Eclipse

1. Install Eclipse for C/C++ with the 
   [installer](https://www.eclipse.org/downloads/packages/installer)
2. Install the TCF agent plugin in Eclipse from the 
   [releases](https://www.eclipse.org/tcf/downloads.php). Go to 
   Help &rarr; Install New Software and use the download page, for 
   example https://download.eclipse.org/tools/tcf/releases/1.6/1.6.2/ to search 
   for the plugin and install it.
3. Eclipse project files were supplied to get started. You can copy the `.cproject` and `.project`
   files to the system root and then add the repository as an Eclipse project to get started.
   The build system still needs to be generated from command line, but you can build the project
   in Eclipse after that. 
4. Set the `BBB_ROOTFS` Eclipse variable and the toolchain binary path correctly in the project
   settings to make full use of the Eclipse indexer. After building the project, you can perform
   remote debugging by right-clicking on the
5. If the `tcf-agent` is running on the BBB, you should be able to connect to it using
   the TCF plugin.
6. If you are connected, right click on the generated image in the build tree and select
   `Debug As` &rarr; `Remote Application` to perform remote debugging
