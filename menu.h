/*=============================================================================
author        : Walter Schreppers
filename      : menu.h
created       : 14/5/2022 at 15:23:32
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#ifndef MENU_H
#define MENU_H

#include "screen.h"
#include "fonts/turbotext.h"
#include <string>

class Menu {

  public:
    //constructor & destructor
    //==========================
    Menu(Screen& screen, int object_count);
    ~Menu();

    //public members
    //==============
    void box(int x, int y, int w, int h);
    void draw();
    void appear();
    void hide();
    void handle_events();


    //public locals
    //=============
    float x_speed, y_speed, z_speed;
    std::string x_speed_str, y_speed_str, z_speed_str;

    int current_object;
    int current_viewmode;
    int render_mode;
    int palette_index;
    bool keypressed;
    float distance;


  private:
    //private members:
    //================
    void init();
    void update_speed_strings();

    //private locals:
    //===============
    Screen* screen;
    int yOffset, menu_width, menu_height, object_count;
    bool bAppearing, bHiding, bFullscreen, bShow;

    SDL_Event event;
    TurboText* menufont;
}; //end of class Menu

#endif

