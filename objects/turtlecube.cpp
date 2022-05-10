/*=============================================================================
author        : Walter Schreppers
filename      : turtlecube.cpp
created       : 3/5/2022 at 22:16:42
modified      :
version       :
copyright     : Walter Schreppers
bugreport(log):
=============================================================================*/

#include "turtlecube.h"

/*-----------------------------------------------------------------------------
name        : TurtleCube
description : constructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
TurtleCube::TurtleCube(Screen &scr) : Object(scr) { 
  init_points();
  init_edges();
}

/*-----------------------------------------------------------------------------
name        : ~TurtleCube
description : destructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
TurtleCube::~TurtleCube() {

}

void TurtleCube::init_points() {
  add_point(-50, 50, -50);
  add_point(-50, -50, -50);
  add_point(50, -50, -50);
  add_point(50, 50, -50);

  add_point(-50, 50, 50);
  add_point(-50, -50, 50);
  add_point(50, -50, 50);
  add_point(50, 50, 50);

  // add turtinside ;)
  add_point(-40, -20, 0); // 8
  add_point(-30, -20, 0); // 9
  add_point(-35, -20, 0);
  add_point(-35, -10, 0);

  // U
  add_point(-25, -20, 0); // 12
  add_point(-25, -10, 0);
  add_point(-15, -10, 0);
  add_point(-15, -20, 0);
  add_point(-15, -10, 0);
  // R
  add_point(-10, -20, 0); // 17
  add_point(-10, -10, 0); // 18
  add_point(-10, -20, 0); // 19
  add_point(0, -20, 0);   // 20
  add_point(0, -15, 0);
  add_point(-10, -15, 0); // 22
  add_point(-10, -15, 0); // 23
  add_point(0, -10, 0);   // 24
                        //
  // T
  add_point(5, -20, 0);  // 25
  add_point(15, -20, 0); // 26
  add_point(10, -20, 0);
  add_point(10, -10, 0);

  // L
  add_point(19, -20, 0); // 29
  add_point(19, -10, 0);
  add_point(28, -10, 0); // 31

  // E
  add_point(32, -20, 0); // 32
  add_point(32, -10, 0);
  add_point(40, -10, 0);

  add_point(32, -15, 0); // 35
  add_point(36, -15, 0); // 36

  add_point(32, -20, 0);
  add_point(38, -20, 0);

  float zoom = 1.2;
  for(int i=0;i<points.size();i++){
    points[i].x = zoom * points[i].x;
    points[i].y = zoom * points[i].y;
    points[i].z = zoom * points[i].z;
  }
}

void TurtleCube::init_edges() {
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

  // turtle part
  add_edge(8, 9);
  add_edge(10, 11);
  add_edge(12, 13);
  add_edge(13, 14);
  add_edge(15, 16);
  add_edge(17, 18);
  add_edge(19, 20);
  add_edge(20, 21);
  add_edge(21, 22);
  add_edge(22, 23);
  add_edge(23, 24);
  add_edge(25, 26);
  add_edge(27, 28);
  add_edge(29, 30);
  add_edge(30, 31);
  add_edge(32, 33);
  add_edge(33, 34);
  add_edge(35, 36);
  add_edge(37, 38);
}
