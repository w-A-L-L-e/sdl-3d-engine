/*=============================================================================
author        : Walter Schreppers
filename      : benchmarks/pixeldemo.cpp
created       : 10/5/2022 at 18:21:12
modified      : 
version       : 
copyright     : Walter Schreppers
description   : Triangles made by just plotting pixels. Optimized horizontal
                line drawing. Still compared to opengl or metal triangle draw
                this is slow. But for our current tiny demo's it works fine.
                We can have a torus with 1000 triangles drawn without much cpu
                usage
=============================================================================*/


#include <iostream>
#include <numeric>
#include <vector>

#include "turbotext.h"
#include "screen.h"
#include "turtlecube.h"

// limit for edged triangles with 1000 we just reach 60fps
// #define TRIANGLE_COUNT 1000 

// random filled triangle, we set it to 120, as at 150 we can't reach 60fps :(
#define TRIANGLE_COUNT 120

// using small triangle, we can however also draw 1000 not bad, however vs GPU this is slooooow.
// #define TRIANGLE_COUNT 1000

// This seems really low, but also it are pretty big triangles
// so screen is covered pixelwise multiple times
// just the pixel plot barely reaches 60fps with 80% cpu
// However in practice later on we notice the Torus example we can easily bump it up to above
// 2000 triangles and not have much cpu load. (so apparantly this benchmark is a bit too aggressive
// by making large triangles we are effectively re-filling the entire screen many times).

int main(int argc, char **argv) {
  Screen screen(640, 400);
  TurboText out(screen);

  int xcoords[1000];
  for (int i = 0; i < 1000; i++)
    xcoords[i] = rand() % screen.width;

  int ycoords[1000];
  for (int i = 0; i < 1000; i++)
    ycoords[i] = rand() % screen.height;

  int colors[1000];
  for (int i = 0; i < 1000; i++)
    colors[i] = rand() % 256;

  int offset = 0;
  while (screen.opened()) {
    screen.printFPS();
    screen.handle_events();
    screen.clear();

    //screen.setColor(240, 255, 255);
    //out.print(10, 10, "Triangle speed test");
    //out.print_wavy(screen.center_x - 110, screen.height - 20,
    //               "Tiny 3D Engine by Walter Schreppers");

    offset+=1;
    for (int tricount = 0; tricount < TRIANGLE_COUNT; tricount++) {
      int p1 = (offset + tricount) % 1000;
      int p2 = (offset + tricount + 2) % 1000;
      int p3 = (offset + tricount + 3) % 1000;

      int x0 = xcoords[p1];
      int y0 = ycoords[p2];

      int x1 = xcoords[p2];
      int y1 = ycoords[p3];
      
      int x2 = xcoords[p3];
      int y2 = ycoords[p1];

      screen.setColor(colors[p1], // red
                      colors[p2], // green
                      colors[p3]  // blue
      );

      screen.fill_triangle(x0,y0,x1,y1,x2,y2);

      //draw a white triangle around it to check
      //screen.setColor(255,255,255);
      //screen.triangle(x0,y0,x1,y1,x2,y2);
    }

    screen.draw();
  }

  return 0;
}
