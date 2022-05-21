# Tiny 3D Engine
Port to c++ from my old turbo pascal 3d engine using sdl and drawing raw pixels without any GPU or frameworks.
Will most likely make another port with actual vulkan or opengl someday. For now I wanted my old engine to run
again on my macbook pure out of nostalgia ;).

# Some screenshots of what is already working
This all rotates real time at 60FPS on my 2014 macbook with less than 10% cpu usage so not bad at all.
The torus has over 1000 triangles. Ofcourse it peanuts to what you can do when using OpenGL or Volkan. Still
it's already way better than what was possible on my pentium in the 90's in turbo pascal ;).

Title screen that also shows a menu with alpha blending:
![Menu screen](screens/3dlogo.png?raw=true "Simple logo drawn in 3d")

Torus generated as rotation object and rendered with shading (+1000 triangles here).
![Torus](screens/torus.png?raw=true "Torus with backface culling and shading with normals")

Glass generated as rotation object and rendered using triangle lines
![Glass](screens/rotation_generated_glass.png?raw=true "Glass generated as rotation object, rendered with hollow triangles")

Some free supercar model from the internet, cleaned up and exported with blender
![Menu screen](screens/car_object_render.png?raw=true "Detailed car object exported with blender")


# TODOS / Work in progress
Object file loader needs further work, and most likely add an STL loader as well.
Then work on camera in world position and making a world of multiple objects etc.
We only use SDL to open a screen and then plot pixels to a texture we use as double buffer so it should be pretty portable by just
rewriting the screen class.

For educational purposes this is nice to learn how it all works under the hood. Especially for beginners the simple_cube_rotation.cpp example
is the least amount of code to get a 3d cube animated on screen.

Most effort was spent on getting sdl to render pixels fast enough to have 60fps without any cpu load. 

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

