/*=============================================================================
author        : Walter Schreppers
filename      : benchmarks/pixeldemo.cpp
created       : 10/5/2022 at 18:21:12
modified      : 
version       : 
copyright     : Walter Schreppers
description   : Show full screen filled with random pixels and circle drawn
                and some lines. This was optimized so that 60FPS can be done
                with < 10% cpu load.
=============================================================================*/


#include <cstring>
#include <iomanip>
#include <iostream>
#include <vector>
#include "screen.h"

int colors[200];

int random_color(int i) {
  return colors[i % 200]; 
}

void init_random_colors(){
  for (int i = 0; i < 200; i++) {
    colors[i] = rand() % 256;
  }
}

int main(int argc, char **argv) {
  Screen screen(640,400);
  init_random_colors();
  unsigned int count=0;

  while (screen.opened()) {
    screen.printFPS();
    screen.handle_events();
    screen.clear();

    for (unsigned int x = 0; x < screen.width; x++) {
      for (unsigned int y = 0; y < screen.height; y++) {
        int col_offset = rand()%2048;
        Uint32 red    = random_color(col_offset * 7);
        Uint32 green  = random_color(col_offset * 2);
        Uint32 blue   = random_color(col_offset * 4);

        screen.pixel(x, y, red, green, blue); 
      }
    }
    
    screen.setColor(255,20,20);
    screen.circle(320,200,count++%200);

    screen.setColor(20,255,20);
    screen.line(0,0,screen.width, screen.height);
    screen.line(0,screen.height, screen.width, 0);

    screen.draw();
  }

  return 0;
}
