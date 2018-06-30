# CoreFoundation for PureDarwin

Based on Swift CoreFoundation from https://github.com/apple/swift-corelibs-foundation/tree/master/CoreFoundation.

Modified to work (more or less) when installed in a PureDarwin image.

(If you just want binary roots to add to a PureDarwin image, look [here](https://github.com/sjc/roots-for-puredarwin).)

#### Fixes

* Version set to 1348.28.0
* Removed `CFURLSession` and dependency on `libcurl` (and everything that depends on)
* Calls `CFInitialize()` at load time, so things actually work
* Adds an implementation of `CFFileDescriptor`
* Fixes issues with `CFMachPort` (ie. the fact the actual mach code was missing)
* Adds implementation of local, remote and Darwin notification centers
* Restored the Objective-C bridge
* Implemented (at least stubs of) Objective-C classes which are required to be found in CF

#### Dependencies

* `libxml2` (eg from the Darwin 10.10 roots)

#### Building

Create a folder called "include" at the same level as this README.md (and the CoreFoundation folder) and copy into it:

* the `/usr/local/include/unicode` folder from your macOS system
* the `mach-o` folder from the dyld Darwin root
* the `include` folder from `libxml2`
* `bootstrap_priv.h`

#### TODO

* Either write a script to set up the dependencies needed for building, or switch to using the Darwin SDK
* Keep up to date with recent changes from the swift corelibs project
* Add implementation of classes from [swift-corelibs-foundation](https://github.com/apple/swift-corelibs-foundation)
* Complete implementation of all bridged classes

#### Known Issues

* A crash if `CFRunLoopGetCurrent()` is called either before `CFRunLoopGetMain()` on the main thread, or at all on any other thread.
