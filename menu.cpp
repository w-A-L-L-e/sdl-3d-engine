/*=============================================================================
author        : Walter Schreppers
filename      : menu.cpp
created       : 14/5/2022 at 15:23:32
modified      :
version       :
copyright     : Walter Schreppers
bugreport(log):
=============================================================================*/

#include "menu.h"

/*-----------------------------------------------------------------------------
name        : init
description : initialize private locals
parameters  :
return      : void
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
void Menu::init() {}

/*-----------------------------------------------------------------------------
name        : Menu
description : constructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
Menu::Menu(Screen &scr, int object_count) {
  init();
  screen = &scr;
  menu_height = 100;
  menu_width = screen->width - 40;
  yOffset = screen->height;
  menufont = new TurboText(*screen);
  this->object_count = object_count;
  appear();
  this->bFullscreen = true; //TODO: make a getter on screen and set correct initial val
}

/*-----------------------------------------------------------------------------
name        : ~Menu
description : destructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
Menu::~Menu() { delete (menufont); }

void Menu::appear() {
  bAppearing = true;
  bHiding = false;
}

void Menu::hide() {
  bAppearing = false;
  bHiding = true;
  bShow = false;
}

void Menu::box(int x, int y, int w, int h) {
  screen->setColor(40, 110, 150, 50);
  screen->line(x, y, x + w, y);
  screen->line(x, y, x, y + h);

  screen->setColor(20, 40, 85, 50);
  screen->line(x, y + h, x + w, y + h);
  screen->line(x + w, y, x + w, y + h);

  // Draw alpha blended box
  SDL_SetRenderDrawColor(screen->getRenderer(), 20, 140, 240, 155);
  SDL_Rect box_rect;
  box_rect.x = (x + 1) * screen->x_scale;
  box_rect.y = (y + 1) * screen->y_scale;
  box_rect.w = (w - 1) * screen->x_scale;
  box_rect.h = (h - 1) * screen->y_scale;
  SDL_RenderFillRect(screen->getRenderer(), &box_rect);

  // this works, but no alpha blend here as we're using raw pixels on
  // surface
  // for(int i=y+1;i<y+h; i++){
  //  screen->line(x+1, i, x+w-1, i);
  //}
}

void Menu::draw() {
  int appear_speed = 5;
  if (!bShow) {
    if (bAppearing) {
      yOffset -= appear_speed;
      if (yOffset < screen->height - menu_height) {
        yOffset = screen->height - menu_height - 1;
        bAppearing = false;
        bShow = true;
      }
    }
    if (bHiding) {
      yOffset += appear_speed;
      if (yOffset > screen->height) {
        bHiding = false;
      }
    }
  }

  SDL_SetRenderDrawBlendMode(screen->getRenderer(), SDL_BLENDMODE_BLEND);
  box(20, yOffset, menu_width, menu_height);

  screen->setColor(250, 250, 255);
  
  menufont->print(30, yOffset + 15, "M      : Toggle menu");
  menufont->print(30, yOffset + 30, "Up     : increase X rotation");
  menufont->print(30, yOffset + 40, "Down   : decrease X rotation");
  menufont->print(30, yOffset + 60, "Left   : decrease Y rotation");
  menufont->print(30, yOffset + 70, "Right  : increase Y rotation");
  menufont->print(30, yOffset + 85, "Space  : Next object");

  menufont->print(450, yOffset + 15, "F  : Toggle Fullscreen mode");

  menufont->print_wavy(screen->center_x - 50, yOffset + 10, "Tiny 3d Engine");
  menufont->print(screen->width - 180, yOffset + 85,
                  "Author: Walter Schreppers");
}

void Menu::handle_events() {
  while (SDL_PollEvent(&event)) {
    switch (event.type) {
    case SDL_QUIT:
      screen->quit();
      break;
    case SDL_KEYDOWN: // SDL_KEYUP also exists
      if (event.key.keysym.scancode == SDL_SCANCODE_F) {
        bFullscreen = !bFullscreen;
        screen->setFullscreen(bFullscreen);
      }
      if (event.key.keysym.scancode == SDL_SCANCODE_Q) {
        screen->quit();
      }

      if (event.key.keysym.scancode == SDL_SCANCODE_M) {
        if (bShow) {
          hide();
        } else {
          if (bAppearing) {
            hide();
          } else {
            appear();
          }
        }
      }

      break;
    default:
      break;
    }
  }
}
