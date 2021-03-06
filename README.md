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

Torus generated as rotation object and rendered with shading (+1000 triangles here). Palette changed by pressing '4'
![Torus](screens/torus.png?raw=true "Torus with backface culling and shading with normals")

Glass generated as rotation object and rendered using triangle lines
![Glass](screens/rotation_generated_glass.png?raw=true "Glass generated as rotation object, rendered with hollow triangles")

Some free supercar model from the internet, cleaned up and exported with blender
![Menu screen](screens/car_object_render.png?raw=true "Detailed car object exported with blender")

Dodecahedron exported with blender (and changed to green palette by pressing '2'):
![Menu screen](screens/dodecahedron.png?raw=true "Dodecahedron")


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
- Press F key to toggle fullscreen. 
- 'Q' to quit the demo.
- M toggles the menu on/off. 
- A,W,S,D for x+y rotation
- Z,X for z rotation speed change.
- 0-7 change color palette
- arrows up/down : zoom in/out (later on this will be walk mode)
- Space: next demo object and 'P' to go to previous.
- R: change render mode which can be triangles, filled triangles, edges or points (the torus looks nice as a point cloud ;)).


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

# Limitations
Because we're not using the GPU for drawing triangles, loading more complex objects like the plane.obj example slows down a lot.
```
./engine assets/plane.obj
                     <<<  Tiny 3D engine >>> 
================================================================
Ported from turbo pascal written in 90's to c++ 
by Walter Schreppers aka wALLe back then ;).

This version uses only SDL to have 640x400 buffered screen. 
Everything you see is coded from scratch using only pixel(x,y).
Most likely will extend this soon to use opengl or metal.

Press 'f' to toggle fullscreen and 'q' to quit.
----------------------------------------------------------------

dodecahedron triangle size=36
./assets/teapot.obj triangle size=6320
torus triangle size=1024
wine glass triangle size=704
11803_Airplane_v1_l1 triangle size=161962
```
So that's roughly 162 thousand triangles and then we slow down considerably and get less than 20fps here.
Still, it looks pretty nice rendered in wireframe mode ;). Also when loading the model in blender it too suffers from low fps
when rotating it in the editor. So even with GPU acceleration on my old laptop it doesn't rotate smoothly anymore.

Plane exported with blender:
![Menu screen](screens/plane.png?raw=true "Jet plane model")

However we can use blender to simplify it.
Plane decimated to 0.1 (90% lesss triangles) and re-exported with blender:
![Menu screen](screens/plane_simplified.png?raw=true "Jet plane simplified/lower poly")

Plane rendered with hollow triangles (wireframe mode):
![Menu screen](screens/plane_wireframe.png?raw=true "Jet plane model in wireframe render mode")

Simplified plane rendered with hollow triangles (wireframe mode):
![Menu screen](screens/plane_simplified_wireframe.png?raw=true "Jet plane model simplified in wireframe render mode")


So 162000 triangles is too much. However when we simplified the object to 'just' 16000 triangles using blender and the 'decimate' option
even this complex model spins again verry smoothly at 60fps. When we get to Guaraud shading or phong shading and texture mapping. 
The simplified end result will most likely still be more than smooth enough (also the plane object has other defects, some triangles are missing or flipped, we see the same in blender, so it's just not that a good candidate either).

# TODOS / Work in progress
- Object files are fully supported, but we only load the triangles (we don't use the normals and texture triangles yet, the engine calculates it's own normals when loading in the triangles and texture mapping is not implemented yet).
- Work on camera in world position and making a world of multiple objects etc.
- We only use SDL to open a screen and then plot pixels to a texture we use as double buffer so it should be pretty portable by just
rewriting the screen class. In a later version I'm planning to use either Metal or OpenGL to have hardware accelleration but this will
be on a different fork or branch as I want to keep the original 'an entire engine only using put pixel x,y' concept

For educational purposes this is nice to learn how it all works under the hood. Especially for beginners the simple_cube_rotation.cpp example
is the least amount of code to get a 3d cube animated on screen.

Most effort was spent on getting sdl to render pixels fast enough to have 60fps without any cpu load. Once we had a nice screen and fast pixel
drawing done with SDL the porting of the old turbo pascal code was pretty easy and done in a couple of spare evenings. I did however have a nice shortcut by using wolfram to calculate the 3d xyz combined rotatation matrix. The first time I wrote the engine I did this for fixed point arithmetic and all by hand and that took me weeks. And most likely I made some mistakes or 'forgot some optimization shortcuts' I took. However the corrected matrix is included in the Object class. It seems to work well with floats. The original engine had an extra layer of complexity by multiplying everything by 256 and then shifting down to do only integer arithmetic to squeeze out a few more frames per second. However modern cpu's can rotate 16k points or more easily. The majority of render time is actually spent drawing triangles here. And most likely when the GPU/OpenGL or Metal port is made this thing should be pretty snappy ;).


