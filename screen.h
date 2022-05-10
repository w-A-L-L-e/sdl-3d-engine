/*=============================================================================
author        : Walter Schreppers
filename      : screen.h
created       : 30/4/2022 at 22:50:23
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#ifndef SCREEN_H
#define SCREEN_H

#include <SDL2/SDL.h>

class Screen {

  public:
    //constructor & destructor
    //==========================
    Screen(Uint32 width=640, Uint32 height=480);
    ~Screen();

    //public members
    //==============
    void handle_events();
    void clear();
    void draw(bool present=true);
    SDL_Renderer* getRenderer(){ return renderer; }

    // fast pixel with color and alpha
    void pixel(Uint32 x, Uint32 y, Uint32 red, Uint32 green, Uint32 blue, Uint32 alpha=SDL_ALPHA_OPAQUE);

    void setColor(Uint32 red, Uint32 green, Uint32 blue, Uint32 alpha=SDL_ALPHA_OPAQUE);
    void pixel(Uint32 x, Uint32 y);
    void circle(Uint32 centreX, Uint32 centreY, Uint32 radius);
    void line(int x0, int y0, int x1, int y1);
    void triangle(int x0, int y0, int x1, int y1, int x2, int y2);
    void fill_triangle(int x0, int y0, int x1, int y1, int x2, int y2);

    void printFPS();
    void showRenderInfo();

    bool opened(){ return running; }
    bool closed(){ return !running; }

    //public locals
    //=============
    SDL_Event event;
    Uint32 width, height, center_x, center_y;

  private:
    //private members
    //===============
    void init();
    int abs(int);
    void _troj_line(int *pl,int *pr,int x0,int y0,int x1,int y1);

    //private locals
    //==============
    bool fullscreen;
    bool running;
    SDL_Window *window;
    SDL_Renderer *renderer;
    SDL_Texture *texture;
    unsigned char *pixels;

    Uint32 red;
    Uint32 green;
    Uint32 blue;
    Uint32 alpha;
}; //end of class Screen

#endif

