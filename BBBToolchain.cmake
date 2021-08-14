# BBB_ROOTFS should point to the local directory which contains all the 
# libraries and includes from the target raspi.
# The following command can be used to do this, replace <ip-address> and the
# local <rootfs-path> accordingly:
# rsync -avHAXR --delete-after --info=progress2 --numeric-ids <user_name>@<ip_address>:/{usr,lib} <rootfs_path>
# BBB_ROOTFS needs to be passed to the CMake command or defined in the
# application CMakeLists.txt before loading the toolchain file.

# CROSS_COMPILE also needs to be set accordingly or passed to the CMake command

if(NOT DEFINED ENV{BBB_ROOTFS})
	message(FATAL_ERROR 
		"Define the BBB_ROOTFS variable to point to the Beagle Bone Black rootfs."
	)
else()
	set(SYSROOT_PATH "$ENV{BBB_ROOTFS}")
	message(STATUS "Beagle Bone Black sysroot: ${SYSROOT_PATH}")
endif()

if(NOT DEFINED ENV{CROSS_COMPILE})
	set(CROSS_COMPILE "arm-linux-gnueabihf")
	message(STATUS 
		"No CROSS_COMPILE environmental variable set, using default ARM linux "
		"cross compiler name ${CROSS_COMPILE}"
	)
else()
	set(CROSS_COMPILE "$ENV{CROSS_COMPILE}")
	message(STATUS 
		"Using environmental variable CROSS_COMPILE as cross-compiler: "
		"$ENV{CROSS_COMPILE}"
	)
endif()

message(STATUS "Using sysroot path: ${SYSROOT_PATH}")

set(CROSS_COMPILE_CC "${CROSS_COMPILE}-gcc")
set(CROSS_COMPILE_CXX "${CROSS_COMPILE}-g++")
set(CROSS_COMPILE_LD "${CROSS_COMPILE}-ld")
set(CROSS_COMPILE_AR "${CROSS_COMPILE}-ar")
set(CROSS_COMPILE_RANLIB "${CROSS_COMPILE}-ranlib")
set(CROSS_COMPILE_STRIP "${CROSS_COMPILE}-strip")
set(CROSS_COMPILE_NM "${CROSS_COMPILE}-nm")
set(CROSS_COMPILE_OBJCOPY "${CROSS_COMPILE}-objcopy")
set(CROSS_COMPILE_SIZE "${CROSS_COMPILE}-size")

# At the very least, cross compile gcc and g++ have to be set!
find_program (CROSS_COMPILE_CC_FOUND ${CROSS_COMPILE_CC} REQUIRED)
find_program (CROSS_COMPILE_CXX_FOUND ${CROSS_COMPILE_CXX} REQUIRED)

set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSROOT "${SYSROOT_PATH}")

# Define name of the target system
set(CMAKE_SYSTEM_NAME "Linux")
set(CMAKE_SYSTEM_PROCESSOR "arm")

# Define the compiler
set(CMAKE_C_COMPILER ${CROSS_COMPILE_CC})
set(CMAKE_CXX_COMPILER ${CROSS_COMPILE_CXX})

set(CMAKE_PREFIX_PATH 
	"${CMAKE_PREFIX_PATH}"
	"${SYSROOT_PATH}/usr/lib/${CROSS_COMPILE}"
)

set(CMAKE_C_FLAGS 
	"-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard ${COMMON_FLAGS}" 
	CACHE STRING "Flags for Beagle Bone Black"
)
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" 
	CACHE STRING "Flags for Beagle Bone Black"
)

set(CMAKE_FIND_ROOT_PATH 
	"${CMAKE_INSTALL_PREFIX};${CMAKE_PREFIX_PATH};${CMAKE_SYSROOT}"
)

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
