echo "Building debug"
scons p=iphone target=release_debug tools=no arch=arm bits=32 -j4
scons p=iphone target=release_debug tools=no arch=arm64 bits=64 -j4
scons p=iphone target=debug tools=no arch=x86 bits=32 -j4
scons p=iphone target=debug tools=no arch=x86_64 bits=64 -j4
lipo -create bin/libgodot.iphone.opt.debug.arm.a bin/libgodot.iphone.opt.debug.arm64.a -output bin/godot_ios_xcode/libgodot.iphone.debug.fat.a
lipo -create bin/libgodot.iphone.debug.x86.a bin/libgodot.iphone.debug.x86_64.a -output bin/godot_ios_xcode/libgodot.iphone.debug.simulator.fat.a

echo "Building release"
scons p=iphone target=release tools=no arch=arm bits=32 -j4
scons p=iphone target=release tools=no arch=arm64 bits=64 -j4
lipo -create bin/libgodot.iphone.opt.arm.a bin/libgodot.iphone.opt.arm64.a -output bin/godot_ios_xcode/libgodot.iphone.release.fat.a
