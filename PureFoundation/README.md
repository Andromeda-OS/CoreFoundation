# PureFoundation in CoreFoundation

Many Foundation classes are actually implemented in CoreFoundation.framework. This can be found by examining the framework with `nm`. It is also obvious as Swift binaries (probably most binaries) look for certain classes in specific location.

The file `cf-objc.txt` in this directory lists all of the `NS...` symobols which appear in CoreFoundation, but which have not been included in any of the other files here.
