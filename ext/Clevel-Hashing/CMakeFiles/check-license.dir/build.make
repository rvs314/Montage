# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.14

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /localdisk/rsanna/Montage/ext/Clevel-Hashing

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /localdisk/rsanna/Montage/ext/Clevel-Hashing

# Utility rule file for check-license.

# Include the progress variables for this target.
include CMakeFiles/check-license.dir/progress.make

CMakeFiles/check-license:
	utils/check_license/check-headers.sh /localdisk/rsanna/Montage/ext/Clevel-Hashing /localdisk/rsanna/Montage/ext/Clevel-Hashing/check_license /localdisk/rsanna/Montage/ext/Clevel-Hashing/LICENSE -a

check-license: CMakeFiles/check-license
check-license: CMakeFiles/check-license.dir/build.make

.PHONY : check-license

# Rule to build all files generated by this target.
CMakeFiles/check-license.dir/build: check-license

.PHONY : CMakeFiles/check-license.dir/build

CMakeFiles/check-license.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/check-license.dir/cmake_clean.cmake
.PHONY : CMakeFiles/check-license.dir/clean

CMakeFiles/check-license.dir/depend:
	cd /localdisk/rsanna/Montage/ext/Clevel-Hashing && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /localdisk/rsanna/Montage/ext/Clevel-Hashing /localdisk/rsanna/Montage/ext/Clevel-Hashing /localdisk/rsanna/Montage/ext/Clevel-Hashing /localdisk/rsanna/Montage/ext/Clevel-Hashing /localdisk/rsanna/Montage/ext/Clevel-Hashing/CMakeFiles/check-license.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/check-license.dir/depend
