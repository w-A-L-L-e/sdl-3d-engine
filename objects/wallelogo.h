/*=============================================================================
author        : Walter Schreppers
filename      : wallelogo.h
created       : 6/5/2022 at 18:31:48
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#ifndef WALLELOGO_H
#define WALLELOGO_H

#include "object.h"

class WalleLogo : public Object {

  public:
    //constructor & destructor
    //==========================
    WalleLogo(Screen& scr);
    ~WalleLogo();

    //public members
    //==============
    std::string name(){return "Walle logo";}

    // this object can't use triangle drawing
    void draw(int filled){
      draw_edges(filled);
    }

  private:
    //private members:
    //================
    void init();
    void init_points();
    void init_edges();

    //private locals:
    //===============


}; //end of class WalleLogo

#endif

