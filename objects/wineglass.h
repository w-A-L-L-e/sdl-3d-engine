/*=============================================================================
author        : Walter Schreppers
filename      : wineglass.h
created       : 6/5/2022 at 18:21:12
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#ifndef WINEGLASS_H
#define WINEGLASS_H

#include "object.h"

class WineGlass : public Object {

  public:
    //constructor & destructor
    //==========================
    WineGlass(Screen& scr);
    ~WineGlass();

    //public members
    //==============
    std::string name(){return "Wine Glass";}

  private:
    //private members:
    //================
    void init();
    void put_circle(float radius, float outer_radius, int schil_rotate);
    void rotate_schil(int rot_amount);
    void init_points();
    void init_triangles();

    //private locals:
    //===============
    int schil_size;


}; //end of class WineGlass

#endif

