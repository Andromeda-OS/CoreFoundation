# CF-1348.28
Built from CoreFoundation found in https://github.com/apple/swift-corelibs-foundation/tree/master/CoreFoundation

Modified to work (more or less) when installed in a PureDarwin images (eg. the 10.10.5 PoC).

* Version set to 1348.28.0
* Removed CFURLSession and dependency on libcurl (and everything that depends on)
* Calls CFInitialize() at load time, so things actually work

Dependencies:

* libxml2 (eg from the Darwin 10.10 roots)

To build:

Create a folder called "include" at the same level as this README.md (and the CoreFoundation folder) and copy into it:

* the /url/local/include/unicode folder from your macOS system
* the mach-o folder from the dyld Darwin root

(TODO: I'll write a script to set these up one day)
