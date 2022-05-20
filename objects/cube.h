/*=============================================================================
author        : Walter Schreppers
filename      : cube.h
created       : 4/5/2022 at 19:19:48
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#ifndef CUBE_H
#define CUBE_H

#include "object.h"

class Cube : public Object {

  public:
    //constructor & destructor
    //==========================
    Cube(Screen&);
    ~Cube();

    //public members
    //==============
    std::string name(){return "Cube";}

  private:
    //private members:
    //================
    void init();
    void init_points();
    void init_edges();
    void init_triangles();

    //private locals:
    //===============


}; //end of class Cube

#endif

