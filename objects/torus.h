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
    void init_triangles();

  private:
    //private members:
    //================
    void init();
    void put_circle(float radius, float outer_radius, int schil_rotate);
    void rotate_schil(int rot_amount);
    void init_points();
    void init_edges();
    void add_true_triangle(int a, int b, int c);
    void add_true_edge(int a, int b);
    void add_edges_square(int a, int b, int c, int d);


    //private locals:
    //===============
    int schil_size;

}; //end of class Torus

#endif

