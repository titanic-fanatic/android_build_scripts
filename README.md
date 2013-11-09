CM-11.0 Build Script for the SGH-I757M
========================================

This build script has been put together to make the build process easier. just run the following from the root of your build directory and it will start the build process without clobbering, syncing repositories or syncing pre-builts:

```````````````````
$ ./start_build.sh
```````````````````
  
That should get you started.

If you need to clobber, sync repos and/or sync pre-builts, use the following command line options:

**Usage:**
```````````````````
./start_build.sh [OPTION(s)]
    -c    Clobber out directory before build
    -s    Sync repositories before build
    -p    Sync pre-builts before build
```````````````````

In future versions of this build script you may be able to define the clobber options at the command line as a set of arguments to the start_build.sh script.
