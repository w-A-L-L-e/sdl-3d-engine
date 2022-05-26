# Tiny 3D Engine
Port to c++ from my old turbo pascal 3d engine using sdl and drawing raw pixels without any GPU or frameworks.
Will most likely make another port with actual vulkan or opengl someday. For now I wanted my old engine to run
again on my macbook pure out of nostalgia ;).

# Some screenshots of what is already working
This all rotates real time at 60FPS on my 2014 macbook with less than 10% cpu usage so not bad at all.
The torus has over 1000 triangles and still easily does 60fps. Ofcourse that still is peanuts compared to what you can do when using 
hardware accellerated OpenGL or Volkan. Still, it's already way better than what was possible 
on my pentium in the 90's in turbo pascal ;).

Title screen that also shows a menu with alpha blending:
![Menu screen](screens/3dlogo.png?raw=true "Simple logo drawn in 3d")

Torus generated as rotation object and rendered with shading (+1000 triangles here).
![Torus](screens/torus.png?raw=true "Torus with backface culling and shading with normals")

Glass generated as rotation object and rendered using triangle lines
![Glass](screens/rotation_generated_glass.png?raw=true "Glass generated as rotation object, rendered with hollow triangles")

Some free supercar model from the internet, cleaned up and exported with blender
![Menu screen](screens/car_object_render.png?raw=true "Detailed car object exported with blender")


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

# Menu keys
Press F key to toggle fullscreen. And 'Q' to quit the demo.
M toggles the menu on/off. A,W,S,D for x+y rotation Z,X for z rotation speed change.
Space for next demo object and P to go to previous.
My favorite feature here: R change render mode which can be triangles, filled triangles, edges or points (the torus looks nice as a point cloud ;)).


The makefile statically links sdl2 and the binary for macos shows it uses 'Metal' under the hood. However
we only use it to draw to a texture with raw pixels r,g,b,a. Everything is basically drawn using pixel(x,y) and then
swapped to the screen at 60 FPS.

On mac this is the libs it is using (most should be present on basic systems):
```
$ otool -L engine   
```

# Loading .OBJ files.
Implemented limited .obj file loading (it has to contain triangles). However you can use blender to read any .obj file
then go to edit mode and export triangles with cmd+T. Then export the triangulated .obj file and that mostly works fine for any
example I tried. (Look in assets folder for some neat examples).

## Example buckyball
Soccer ball or bucky ball or truncated_icosahedron (courtesy of https://polyhedra.tessera.li)
```
./engine assets/truncated_icosahedron.obj
```

## Example icosahedron
```
./engine assets/icosahedron.obj
```

## Example teapot
```
./engine assets/teapot.obj
```

## Example race car
```
./engine assets/car.obj
```


# TODOS / Work in progress
Object file loader needs further work, and most likely add an STL loader as well.
Then work on camera in world position and making a world of multiple objects etc.
We only use SDL to open a screen and then plot pixels to a texture we use as double buffer so it should be pretty portable by just
rewriting the screen class.

For educational purposes this is nice to learn how it all works under the hood. Especially for beginners the simple_cube_rotation.cpp example
is the least amount of code to get a 3d cube animated on screen.

Most effort was spent on getting sdl to render pixels fast enough to have 60fps without any cpu load. 

# Added features 26-05-2022
Palettes (press keys 0-8 for different colors)
Distance with up/down arrows (no true walking but this zooms in/out already).

