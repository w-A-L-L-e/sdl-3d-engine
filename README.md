# sdl-3d-engine
Port to c++ from my old turbo pascal 3d engine

# Installation

This works under macos big sur:
```
$ xcode-select --install
$ brew install sdl2
$ make
```

Running:

```
$ ./engine
```

Press F key to toggle fullscreen. And 'Q' to quit the demo.

The makefile statically links sdl2 and the binary for macos shows it uses 'Metal' under the hood. However
we only use it to draw to a texture with raw pixels r,g,b,a. Everything is basically drawn using pixel(x,y) and then
swapped to the screen at 60 FPS.

On mac this is the libs it is using (most should be present on basic systems):
```
$ otool -L engine   

engine:
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1311.0.0)
	/usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
	/System/Library/Frameworks/CoreAudio.framework/Versions/A/CoreAudio (compatibility version 1.0.0, current version 1.0.0)
	/System/Library/Frameworks/AudioToolbox.framework/Versions/A/AudioToolbox (compatibility version 1.0.0, current version 1000.0.0)
	/System/Library/Frameworks/CoreHaptics.framework/Versions/A/CoreHaptics (compatibility version 1.0.0, current version 1.0.0, weak)
	/System/Library/Frameworks/GameController.framework/Versions/A/GameController (compatibility version 1.0.0, current version 1.0.0, weak)
	/System/Library/Frameworks/ForceFeedback.framework/Versions/A/ForceFeedback (compatibility version 1.0.0, current version 1.0.2)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/System/Library/Frameworks/CoreVideo.framework/Versions/A/CoreVideo (compatibility version 1.2.0, current version 1.5.0)
	/System/Library/Frameworks/Cocoa.framework/Versions/A/Cocoa (compatibility version 1.0.0, current version 23.0.0)
	/System/Library/Frameworks/Carbon.framework/Versions/A/Carbon (compatibility version 2.0.0, current version 165.0.0)
	/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit (compatibility version 1.0.0, current version 275.0.0)
	/System/Library/Frameworks/QuartzCore.framework/Versions/A/QuartzCore (compatibility version 1.2.0, current version 1.11.0, weak)
	/System/Library/Frameworks/Metal.framework/Versions/A/Metal (compatibility version 1.0.0, current version 258.17.0, weak)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 1200.3.0)
	/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit (compatibility version 45.0.0, current version 2113.20.111)
	/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 150.0.0, current version 1856.105.0)
	/System/Library/Frameworks/CoreGraphics.framework/Versions/A/CoreGraphics (compatibility version 64.0.0, current version 1557.3.2)
	/System/Library/Frameworks/CoreServices.framework/Versions/A/CoreServices (compatibility version 1.0.0, current version 1141.1.0)
	/System/Library/Frameworks/Foundation.framework/Ve
```

