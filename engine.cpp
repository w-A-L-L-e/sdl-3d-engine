/*=============================================================================
author        : Walter Schreppers
filename      : engine.cpp
created       : 30/4/2022 at 22:50:23
modified      : 1/5/2022
version       :
copyright     : Walter Schreppers
description   : Rewrite of my old pascal code into C++ showing off a fast
rotation matrix I calculated by hand in the 90's. Other various effects I've
made as a hobby was z-clipping and generating 3d objects using rotation (like
torus) and various texture mapping and shading algorithms. Which I will port to
this SDL/c++ version as a hobby/preservation of old code ;).
=============================================================================*/

#include <iostream>
#include <numeric>
#include <vector>

#include "fonts/turbotext.h"
#include "cube.h"
#include "screen.h"
#include "torus.h"
#include "turtlecube.h"
#include "wallelogo.h"
#include "wineglass.h"
#include "menu.h"

void showAbout() {
  std::cout << "                     <<<  Tiny 3D engine >>> " << std::endl;
  std::cout
      << "================================================================"
      << std::endl;
  std::cout << "Ported from turbo pascal written in 90's to c++ " << std::endl;
  std::cout << "by Walter Schreppers aka wALLe back then ;)." << std::endl
            << std::endl;
  std::cout << "This version uses only SDL to have 640x400 buffered screen. "
            << std::endl;
  std::cout << "Everything you see is coded from scratch using only pixel(x,y)."
            << std::endl;
  std::cout << "Most likely will extend this soon to use opengl or metal."
            << std::endl
            << std::endl;
  std::cout << "Press 'f' to toggle fullscreen and 'q' to quit." << std::endl;
  std::cout
      << "----------------------------------------------------------------"
      << std::endl;
  std::cout << std::endl;
}

int main(int argc, char **argv) {
  showAbout();

  Screen screen(640, 400, "Tiny 3D Engine", true);
  TurboText out(screen);
  WalleLogo logo(screen);
  TurtleCube turtle_cube(screen);
  Cube cube(screen);
  WineGlass beker(screen);
  Torus torus(screen);
  Menu menu(screen);

  float ax = 0, ay = 0, az = 0;
  while (screen.opened()) {
    // screen.printFPS();
    menu.handle_events();
    screen.clear();

    // ax = 0.52;
    ax += 0.03;
    ay += 0.02;
    az += 0.01;

    // turtle_cube.rotate(ax, ay, -az);
    // turtle_cube.draw_edges(true);

    // cube.rotate(ax,ay,az);
    // cube.draw(1); //1 is filled triangles
    // out.print(10,10, "Cube");

    torus.rotate(ax, ay, az);
    torus.draw(1);
    // torus.draw_rotated_points();

    // beker.rotate(ax,ay,az);
    // beker.draw(1);
    // out.print(10,10, "Wine Glass ");

    // logo.rotate(ax,ay,az);
    // logo.draw_edges();

    // SDL_Delay(200);

    menu.draw();
    screen.draw();
  }

  return 0;
}
