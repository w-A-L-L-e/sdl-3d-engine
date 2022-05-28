/*=============================================================================
author        : Walter Schreppers
filename      : cube.cpp
created       : 4/5/2022 at 19:19:48
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#include "cube.h"

/*-----------------------------------------------------------------------------
name        : init
description : initialize private locals
parameters  : 
return      : void
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
void Cube::init(){
  init_points();
  init_edges();
  init_triangles();
}


/*-----------------------------------------------------------------------------
name        : Cube
description : constructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
Cube::Cube(Screen& scr): Object(scr){
  init();
}


/*-----------------------------------------------------------------------------
name        : ~Cube
description : destructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
Cube::~Cube(){

}

/*-----------------------------------------------------------------------------
name        : init_points
description : initialize a simple cube with 8 points
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
void Cube::init_points() {
  add_point(-100, 100, -100);
  add_point(-100, -100, -100);
  add_point(100, -100, -100);
  add_point(100, 100, -100);

  add_point(-100, 100, 100);
  add_point(-100, -100, 100);
  add_point(100, -100, 100);
  add_point(100, 100, 100);
}

/*-----------------------------------------------------------------------------
name        : init_edges
description : alles edge drawing also specify the cube edges
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
void Cube::init_edges() {
  add_edge(0, 1);
  add_edge(1, 2);
  add_edge(2, 3);
  add_edge(3, 0);
  add_edge(4, 5);
  add_edge(5, 6);
  add_edge(6, 7);
  add_edge(7, 4);
  add_edge(4, 0);
  add_edge(5, 1);
  add_edge(6, 2);
  add_edge(7, 3);
}


/*-----------------------------------------------------------------------------
name        : init_triangles
description : allows shaded drawing and texture mapping using triangles
parameters  : 
return      : 
exceptions  : 
algorithm   : manually add triangles in correct counter clockwize or clockwize directions
         back side:
         0    3

          1    2

         front side:
         4    7

          5    6
-----------------------------------------------------------------------------*/
void Cube::init_triangles(){
  // give clockwize
  // achteraan
  add_triangle(0,2,1);
  add_triangle(0,3,2);

  // vooraan
  add_triangle(4,5,6);
  add_triangle(4,6,7);

  // bottom
  add_triangle(0,4,7);
  add_triangle(0,7,3);

  //top
  add_triangle(1,6,5);
  add_triangle(1,2,6);

  //left 
  add_triangle(5,0,1);
  add_triangle(0,5,4);

  //right
  add_triangle(7,2,3);
  add_triangle(2,7,6);
} 

