# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

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
CMAKE_SOURCE_DIR = /home/pi/picam_gpu_col5

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/pi/picam_gpu_col5

# Include any dependencies generated for this target.
include CMakeFiles/picam.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/picam.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/picam.dir/flags.make

CMakeFiles/picam.dir/picam.cpp.o: CMakeFiles/picam.dir/flags.make
CMakeFiles/picam.dir/picam.cpp.o: picam.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /home/pi/picam_gpu_col5/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/picam.dir/picam.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/picam.dir/picam.cpp.o -c /home/pi/picam_gpu_col5/picam.cpp

CMakeFiles/picam.dir/picam.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/picam.dir/picam.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/pi/picam_gpu_col5/picam.cpp > CMakeFiles/picam.dir/picam.cpp.i

CMakeFiles/picam.dir/picam.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/picam.dir/picam.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/pi/picam_gpu_col5/picam.cpp -o CMakeFiles/picam.dir/picam.cpp.s

CMakeFiles/picam.dir/picam.cpp.o.requires:
.PHONY : CMakeFiles/picam.dir/picam.cpp.o.requires

CMakeFiles/picam.dir/picam.cpp.o.provides: CMakeFiles/picam.dir/picam.cpp.o.requires
	$(MAKE) -f CMakeFiles/picam.dir/build.make CMakeFiles/picam.dir/picam.cpp.o.provides.build
.PHONY : CMakeFiles/picam.dir/picam.cpp.o.provides

CMakeFiles/picam.dir/picam.cpp.o.provides.build: CMakeFiles/picam.dir/picam.cpp.o

CMakeFiles/picam.dir/camera.cpp.o: CMakeFiles/picam.dir/flags.make
CMakeFiles/picam.dir/camera.cpp.o: camera.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /home/pi/picam_gpu_col5/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/picam.dir/camera.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/picam.dir/camera.cpp.o -c /home/pi/picam_gpu_col5/camera.cpp

CMakeFiles/picam.dir/camera.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/picam.dir/camera.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/pi/picam_gpu_col5/camera.cpp > CMakeFiles/picam.dir/camera.cpp.i

CMakeFiles/picam.dir/camera.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/picam.dir/camera.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/pi/picam_gpu_col5/camera.cpp -o CMakeFiles/picam.dir/camera.cpp.s

CMakeFiles/picam.dir/camera.cpp.o.requires:
.PHONY : CMakeFiles/picam.dir/camera.cpp.o.requires

CMakeFiles/picam.dir/camera.cpp.o.provides: CMakeFiles/picam.dir/camera.cpp.o.requires
	$(MAKE) -f CMakeFiles/picam.dir/build.make CMakeFiles/picam.dir/camera.cpp.o.provides.build
.PHONY : CMakeFiles/picam.dir/camera.cpp.o.provides

CMakeFiles/picam.dir/camera.cpp.o.provides.build: CMakeFiles/picam.dir/camera.cpp.o

CMakeFiles/picam.dir/cameracontrol.cpp.o: CMakeFiles/picam.dir/flags.make
CMakeFiles/picam.dir/cameracontrol.cpp.o: cameracontrol.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /home/pi/picam_gpu_col5/CMakeFiles $(CMAKE_PROGRESS_3)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/picam.dir/cameracontrol.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/picam.dir/cameracontrol.cpp.o -c /home/pi/picam_gpu_col5/cameracontrol.cpp

CMakeFiles/picam.dir/cameracontrol.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/picam.dir/cameracontrol.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/pi/picam_gpu_col5/cameracontrol.cpp > CMakeFiles/picam.dir/cameracontrol.cpp.i

CMakeFiles/picam.dir/cameracontrol.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/picam.dir/cameracontrol.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/pi/picam_gpu_col5/cameracontrol.cpp -o CMakeFiles/picam.dir/cameracontrol.cpp.s

CMakeFiles/picam.dir/cameracontrol.cpp.o.requires:
.PHONY : CMakeFiles/picam.dir/cameracontrol.cpp.o.requires

CMakeFiles/picam.dir/cameracontrol.cpp.o.provides: CMakeFiles/picam.dir/cameracontrol.cpp.o.requires
	$(MAKE) -f CMakeFiles/picam.dir/build.make CMakeFiles/picam.dir/cameracontrol.cpp.o.provides.build
.PHONY : CMakeFiles/picam.dir/cameracontrol.cpp.o.provides

CMakeFiles/picam.dir/cameracontrol.cpp.o.provides.build: CMakeFiles/picam.dir/cameracontrol.cpp.o

CMakeFiles/picam.dir/graphics.cpp.o: CMakeFiles/picam.dir/flags.make
CMakeFiles/picam.dir/graphics.cpp.o: graphics.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /home/pi/picam_gpu_col5/CMakeFiles $(CMAKE_PROGRESS_4)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/picam.dir/graphics.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/picam.dir/graphics.cpp.o -c /home/pi/picam_gpu_col5/graphics.cpp

CMakeFiles/picam.dir/graphics.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/picam.dir/graphics.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/pi/picam_gpu_col5/graphics.cpp > CMakeFiles/picam.dir/graphics.cpp.i

CMakeFiles/picam.dir/graphics.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/picam.dir/graphics.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/pi/picam_gpu_col5/graphics.cpp -o CMakeFiles/picam.dir/graphics.cpp.s

CMakeFiles/picam.dir/graphics.cpp.o.requires:
.PHONY : CMakeFiles/picam.dir/graphics.cpp.o.requires

CMakeFiles/picam.dir/graphics.cpp.o.provides: CMakeFiles/picam.dir/graphics.cpp.o.requires
	$(MAKE) -f CMakeFiles/picam.dir/build.make CMakeFiles/picam.dir/graphics.cpp.o.provides.build
.PHONY : CMakeFiles/picam.dir/graphics.cpp.o.provides

CMakeFiles/picam.dir/graphics.cpp.o.provides.build: CMakeFiles/picam.dir/graphics.cpp.o

CMakeFiles/picam.dir/lodepng.cpp.o: CMakeFiles/picam.dir/flags.make
CMakeFiles/picam.dir/lodepng.cpp.o: lodepng.cpp
	$(CMAKE_COMMAND) -E cmake_progress_report /home/pi/picam_gpu_col5/CMakeFiles $(CMAKE_PROGRESS_5)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object CMakeFiles/picam.dir/lodepng.cpp.o"
	/usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/picam.dir/lodepng.cpp.o -c /home/pi/picam_gpu_col5/lodepng.cpp

CMakeFiles/picam.dir/lodepng.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/picam.dir/lodepng.cpp.i"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/pi/picam_gpu_col5/lodepng.cpp > CMakeFiles/picam.dir/lodepng.cpp.i

CMakeFiles/picam.dir/lodepng.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/picam.dir/lodepng.cpp.s"
	/usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/pi/picam_gpu_col5/lodepng.cpp -o CMakeFiles/picam.dir/lodepng.cpp.s

CMakeFiles/picam.dir/lodepng.cpp.o.requires:
.PHONY : CMakeFiles/picam.dir/lodepng.cpp.o.requires

CMakeFiles/picam.dir/lodepng.cpp.o.provides: CMakeFiles/picam.dir/lodepng.cpp.o.requires
	$(MAKE) -f CMakeFiles/picam.dir/build.make CMakeFiles/picam.dir/lodepng.cpp.o.provides.build
.PHONY : CMakeFiles/picam.dir/lodepng.cpp.o.provides

CMakeFiles/picam.dir/lodepng.cpp.o.provides.build: CMakeFiles/picam.dir/lodepng.cpp.o

# Object files for target picam
picam_OBJECTS = \
"CMakeFiles/picam.dir/picam.cpp.o" \
"CMakeFiles/picam.dir/camera.cpp.o" \
"CMakeFiles/picam.dir/cameracontrol.cpp.o" \
"CMakeFiles/picam.dir/graphics.cpp.o" \
"CMakeFiles/picam.dir/lodepng.cpp.o"

# External object files for target picam
picam_EXTERNAL_OBJECTS =

picam: CMakeFiles/picam.dir/picam.cpp.o
picam: CMakeFiles/picam.dir/camera.cpp.o
picam: CMakeFiles/picam.dir/cameracontrol.cpp.o
picam: CMakeFiles/picam.dir/graphics.cpp.o
picam: CMakeFiles/picam.dir/lodepng.cpp.o
picam: CMakeFiles/picam.dir/build.make
picam: /usr/lib/libopencv_calib3d.so
picam: /usr/lib/libopencv_contrib.so
picam: /usr/lib/libopencv_core.so
picam: /usr/lib/libopencv_features2d.so
picam: /usr/lib/libopencv_flann.so
picam: /usr/lib/libopencv_highgui.so
picam: /usr/lib/libopencv_imgproc.so
picam: /usr/lib/libopencv_legacy.so
picam: /usr/lib/libopencv_ml.so
picam: /usr/lib/libopencv_objdetect.so
picam: /usr/lib/libopencv_photo.so
picam: /usr/lib/libopencv_stitching.so
picam: /usr/lib/libopencv_ts.so
picam: /usr/lib/libopencv_video.so
picam: /usr/lib/libopencv_videostab.so
picam: CMakeFiles/picam.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable picam"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/picam.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/picam.dir/build: picam
.PHONY : CMakeFiles/picam.dir/build

CMakeFiles/picam.dir/requires: CMakeFiles/picam.dir/picam.cpp.o.requires
CMakeFiles/picam.dir/requires: CMakeFiles/picam.dir/camera.cpp.o.requires
CMakeFiles/picam.dir/requires: CMakeFiles/picam.dir/cameracontrol.cpp.o.requires
CMakeFiles/picam.dir/requires: CMakeFiles/picam.dir/graphics.cpp.o.requires
CMakeFiles/picam.dir/requires: CMakeFiles/picam.dir/lodepng.cpp.o.requires
.PHONY : CMakeFiles/picam.dir/requires

CMakeFiles/picam.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/picam.dir/cmake_clean.cmake
.PHONY : CMakeFiles/picam.dir/clean

CMakeFiles/picam.dir/depend:
	cd /home/pi/picam_gpu_col5 && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/pi/picam_gpu_col5 /home/pi/picam_gpu_col5 /home/pi/picam_gpu_col5 /home/pi/picam_gpu_col5 /home/pi/picam_gpu_col5/CMakeFiles/picam.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/picam.dir/depend

