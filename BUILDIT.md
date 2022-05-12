# BUILDING THE SYSTEM

## Prerequisites
- Python 3.x
- Ocaml 4.x (at least 4.10)
- C++ compiler
  * Linux: g++ or clang
  * MacOS: clang
  * Windows: MSVC++ 64 bit

If you want Felix to do graphics you also need to install
- SDL2
- SDL2_image
- SDL2_ttf

and you will need to adjust the configuration database if 
they're not in the standard locations.

## Initialise Submodules
```
git submodule init
git submodule fetch
```
## Build Felix
This is required even if you have a separate Felix install,
in order to unpack literate packages.
```
cd felix
make
cd ..
```

The build is very long. First it builds a bootstrap
version of Felix using fbuild build system written in Python.

Then the resulting Felix system is used to rebuild itself,
this time using the full build system code written in Felix.

Finally, a huge suite of regression tests is run. 
This is automatic and should not be aborted.
Some errors may occur, expecially with optional components
including SDL.

# Install Felix
Skip this if you have an separate Felix install.

It is recommended you DO NOT actually install Felix.
Instead you need to set some variables.
On Linux with bash:
```
  export PATH=$PWD/felix/build/release/host/bin:$PATH
  export LD_LIBRARY_PATH=$PWD/felix/build/release/host/lib/rtl:$LD_LIBRARY_PATH
```
On MacOS:
```
  export PATH=$PWD/felix/build/release/host/bin:$PATH
  export DYLD_LIBRARY_PATH=$PWD/felix/build/release/host/lib/rtl:$DYLD_LIBRARY_PATH
```
On Windows:
```
  set PATH=%CD%\felix\build\release\host/bin;%CD%\felix\build\release\host\lib\rtl;%PATH%
```

This allows the Felix tools including *flx* to be located, and shared libraries (DLLs)
linked automatically. For most purposes the *flx* build prelinks any required plugins
and is built statically so no shared libraries are required. *flx* itself runs
programs under its control with the required dynamic loader paths, so the library
path is only needed to run Felix generated static link executables in standalone mode,
if they happen to load shared libraries at run time. 

Note that by default Felix generates shared libraries NOT static link executables,
programs in dynamic mode are run by a loader thunk.

Felix needs to find its own libraries. This is best done with environment variable
```
FLX_INSTALL_DIR=$PWD/felix/build/release
```
or easier, a control file:
```
mkdir -p $HOME/.felix/config
echo "FLX_INSTALL_DIR: $PWD/felix/build/release" > $HOME/.felix/config/felix.fpc
```

On Windows, use USER_PROFILE instead of HOME. The *flx* tool will
look for `felix.fpc` to find various variables, the installation
directory is enough for most purposes.

Note if you have several Felix installs, you can use the command line
switch to select another profile file
```
flx --felix=local_config.fpc hello.flx
```

# Build

Now you can just do
```
make
```
in the top level of the repository. There's no Makefile 
for Windows at the moment. You will need to look at the
GNUmakefile to see various targets: at the moment

```
make parser
make small-test
make big-test
```
are the only targets. `small-test` parses `hello.flx` whilst
`big-test` parses the parser build script `flx_build_flxg.flx`.

