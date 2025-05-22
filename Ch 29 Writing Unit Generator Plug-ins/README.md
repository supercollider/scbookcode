Flanger
=======

This an example unit generator plugin for Chapter 29 ("Writing Unit Generator Plug-Ins") of the SuperCollider book (2nd edition).


### Build instructions:

This project is built with CMake, supported compilers are GCC, Clang and MSVC.
(On Windows, you can also compile with MinGW; it is recommended to use Msys2: https://www.msys2.org/)

#### CMake variables:

- `SC_PATH`: the folder containing the SuperCollider source code (https://github.com/supercollider/supercollider)
  with the subfolders `common` and `include`.

- `SC_INSTALLDIR` (optional): Set the installation directory. By default, this is the SC extension folder.

- `SUPERNOVA` (optional): Set to `ON` if you want to also build the Supernova version.

- `CMAKE_BUILD_TYPE`: Set the build type. By default, the project is built in release mode.
  You can change it from `Release` to `Debug` if you want a debug build, for example.


#### Build project:

1)	create a build directory, e.g. `build`, next to the `CMakeLists.txt`

2)	`cd` into the build directory and run `cmake ..` + the necessary variables (see above)

    *or* set the variables in `cmake-gui` and click "Configure" + "Generate"

3)	build with `cmake --build . -j -v`

4)	install with `cmake --build . -v -t install`


