/*=============================================================================
author        : Walter Schreppers
filename      : turtlecube.h
created       : 3/5/2022 at 22:16:42
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#ifndef TURTLECUBE_H
#define TURTLECUBE_H

#include "object.h"

class TurtleCube: public Object {

  public:
    //constructor & destructor
    //==========================
    TurtleCube(Screen& scr);
    ~TurtleCube();

    //public members
    //==============
    std::string name(){return "Turtle cube";}

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


}; //end of class TurtleCube

#endif

