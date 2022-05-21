/*=============================================================================
author        : Walter Schreppers
filename      : torus.h
created       : 6/5/2022 at 22:52:26
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#ifndef TORUS_H
#define TORUS_H

#include "object.h"

class Torus : public Object {

  public:
    //constructor & destructor
    //==========================
    Torus(Screen&);
    ~Torus();

    //public members
    //==============
    std::string name(){return "Torus";}

    // this object can't use edge drawing
    void draw_edges(bool shaded){
      if(shaded) draw(1);
      else draw(0);
    }



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

}; //end of class Torus

#endif

