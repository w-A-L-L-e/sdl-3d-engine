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

#include "turbotext.h"
#include "menu.h"
#include "screen.h"
#include "cube.h"
#include "torus.h"
#include "turtlecube.h"
#include "wallelogo.h"
#include "wineglass.h"

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


//work in progress, menu is not fully functional, and some ugly code that needs refactoring in this main...
int main(int argc, char **argv) {
  showAbout();

  Screen screen(640, 400, "Tiny 3D Engine", true);
  SDL_ShowCursor(SDL_DISABLE);

  TurboText out(screen);
  
  WalleLogo logo(screen);
  Cube cube(screen);
  Torus torus(screen);
  WineGlass beker(screen);
  TurtleCube turtle_cube(screen);

  std::vector<Object*> objects;
  objects.push_back(&logo);
  objects.push_back(&cube);
  objects.push_back(&torus);
  objects.push_back(&beker);
  objects.push_back(&turtle_cube);

  Menu menu(screen, objects.size());
  float ax = 0, ay = 0, az = 0;
  int object_pos = 0;
  int timeout_seconds = 7;
  int next_screen_timeout = 60*timeout_seconds; //fps*seconds (this is to be re-done with timing instead...)

  while (screen.opened()) {
    // screen.printFPS();
    menu.handle_events();
    screen.clear();

    if(next_screen_timeout-- == 0){
      next_screen_timeout = 60*timeout_seconds; //yes ugly, needs fixing here...
      object_pos = (object_pos+1) % objects.size();

      if(object_pos == 0) menu.appear();
      if(object_pos == 1) menu.hide(); 
    }

    //TODO: get current object and rotation speed and draw mode from menu
    ax += 0.03;
    ay += 0.02;
    az += 0.01;

    Object* current_object = objects[object_pos];
    current_object->rotate(ax, ay, az);

    //TODO: allow menu to steer this...
    if(object_pos == 0) current_object->draw_edges(true); // edges with shading 
    if(object_pos == 1) current_object->draw(1); // filled triangles; 
    if(object_pos == 2) current_object->draw(1); // filled triangles;
    if(object_pos == 3) current_object->draw(0); // unfilled triangles;
    if(object_pos == 4) current_object->draw_edges(true); 

    screen.draw(false); // don't present just yet
    menu.draw();        // overlay menu on top of screen surface

    // now present on screen
    SDL_RenderPresent(screen.getRenderer());
    // SDL_Delay(200); // delay is not needed, renderpresent waits for 60fps
  }

  return 0;
}
