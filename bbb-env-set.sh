#!/bin/bash -i
echo "Entering BeagleBoneBlack environment"
export PATH=$PATH:"$HOME/x-tools/arm-cortex_a8-linux-gnueabihf-debian/bin"
export CROSS_COMPILE="arm-cortex_a8-linux-gnueabihf"
export BBB_ROOTFS="${HOME}/beaglebone/rootfs"
# Can be used in new shell to set up a prefix for the console command line
export CONSOLE_PREFIX="[BBB]"

exec /bin/bash
