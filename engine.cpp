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

#include "menu.h"
#include "screen.h"
#include "turbotext.h"

#include "blenderobject.h"
#include "cube.h"
#include "torus.h"
#include "turtlecube.h"
#include "wallelogo.h"
#include "wineglass.h"

void showAbout() {
  std::cout << "                     <<<  Tiny 3D engine >>> " << std::endl;
  std::cout << "================================================================" << std::endl;
  std::cout << "Ported from turbo pascal written in 90's to c++ " << std::endl;
  std::cout << "by Walter Schreppers aka wALLe back then ;)." << std::endl 
            << std::endl;
  std::cout << "This version uses only SDL to have 640x400 buffered screen. " << std::endl;
  std::cout << "Everything you see is coded from scratch using only pixel(x,y)." << std::endl;
  std::cout << "Most likely will extend this soon to use opengl or metal." << std::endl
            << std::endl;
  std::cout << "Press 'f' to toggle fullscreen and 'q' to quit." << std::endl;
  std::cout << "----------------------------------------------------------------" << std::endl;
  std::cout << std::endl;
}


// This main function has grown a bit large, needs some refactoring soon...
int main(int argc, char **argv) {
  showAbout();

  // Screen screen(1280, 800, "Tiny 3D Engine", true); //still works, at 50% cpu though ;)
  // Screen screen(320, 200, "Tiny 3D Engine", true); // how it ran in pascal, pfew phat pixels here
  Screen screen(640, 400, "Tiny 3D Engine", true); // best middleground, low cpu and detailed enough
  SDL_ShowCursor(SDL_DISABLE);
 
  TurboText ttext(screen);

  BlenderObject dodecahedron(screen);
  dodecahedron.load("./assets/dodecahedron.obj", 270);

  BlenderObject teapot(screen);
  teapot.load("./assets/teapot.obj",300);

  WalleLogo logo(screen);
  Cube cube(screen);
  Torus torus(screen);
  WineGlass beker(screen);
  // TurtleCube turtle_cube(screen);
  BlenderObject cmdObject(screen); //user given commandline object (optional)

  std::vector<Object*> objects;

  // load optional user specified object on commandline as first object 
  if(argc>1){
    cmdObject.load(argv[1], 300); // todo make scale also a command arg
    objects.push_back(&cmdObject);
  }

  objects.push_back(&cube);
  objects.push_back(&logo);
  objects.push_back(&torus);
  objects.push_back(&beker);
  objects.push_back(&dodecahedron);
  objects.push_back(&teapot);
  //objects.push_back(&turtle_cube);

  Menu menu(screen, objects.size());
  float ax = 0, ay = 0, az = 0;
  int object_pos = 0;
  int timeout_seconds = 7;

  //fps*seconds (this is to be re-done with timing instead...)
  int next_screen_timeout = 60*timeout_seconds;

  while (screen.opened()) {
    // screen.printFPS();
    menu.handle_events();
    screen.clear();

    // little hackish but a quick way to animate and change objects without keypresses
    if(!menu.keypressed){ //once you press a key we stop auto switching objects
      if(next_screen_timeout-- == 0){
        next_screen_timeout = 60*timeout_seconds; //yes ugly, needs fixing here...
        object_pos = (object_pos+1) % objects.size();
        menu.current_object = object_pos;

        if(object_pos == 0) menu.appear();
        if(object_pos == 1) menu.hide(); 
      }
    }

    ax += menu.x_speed;
    ay += menu.y_speed;
    az += menu.z_speed;

    Object* current_object = objects[menu.current_object];
    current_object->rotate(ax, ay, az);

    switch(menu.render_mode){
      case 1: current_object->draw(0); break;
      case 2: current_object->draw_edges(true); break;
      case 3: current_object->draw_edges(false); break;
      case 4: current_object->draw_rotated_points(); break;
      //case 5: current_object->draw_points(); break; -> need to recenter these 
      default: current_object->draw(1); break; // 0  draw filled shaded triangles
    }

    screen.setColor(20, 140, 240);
    ttext.print_wavy(10,20, current_object->name());

    screen.draw(false); // don't present just yet
    menu.draw();        // overlay menu on top of screen surface

    // now present on screen
    SDL_RenderPresent(screen.getRenderer());
    // SDL_Delay(200); // delay for debugging
  }

  return 0;
}
