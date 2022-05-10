/*=============================================================================
author        : Walter Schreppers
filename      : wallelogo.cpp
created       : 6/5/2022 at 18:31:48
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#include "wallelogo.h"

/*-----------------------------------------------------------------------------
name        : init
description : initialize private locals
parameters  : 
return      : void
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
void WalleLogo::init(){
  init_points();
  init_edges();
}


/*-----------------------------------------------------------------------------
name        : WalleLogo
description : constructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
WalleLogo::WalleLogo(Screen& scr) : Object(scr){
  init();
}


/*-----------------------------------------------------------------------------
name        : ~WalleLogo
description : destructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
WalleLogo::~WalleLogo(){

}

void WalleLogo::init_points(){
  add_point(40,63,0);
  add_point(40,114,0);
  add_point(40,114,0);
  add_point(87,114,0);
  add_point(87,114,0);
  add_point(87,76,0);
  add_point(87,76,0);
  add_point(235,76,0);
  add_point(40,62,0);
  add_point(58,62,0);
  add_point(58,62,0);
  add_point(58,94,0);
  add_point(59,74,0);
  add_point(72,74,0);
  add_point(73,63,0);
  add_point(73,101,0);
  add_point(73,62,0);
  add_point(254,62,0);
  add_point(254,62,0);
  add_point(235,75,0);
  add_point(124,76,0);
  add_point(124,136,0);
  add_point(124,136,0);
  add_point(106,136,0);
  add_point(106,136,0);
  add_point(106,97,0);
  add_point(88,114,0);
  add_point(105,114,0);
  add_point(102,85,0);
  add_point(111,85,0);
  add_point(111,85,0);
  add_point(111,89,0);
  add_point(111,89,0);
  add_point(102,89,0);
  add_point(102,89,0);
  add_point(102,85,0);
  add_point(140,77,0);
  add_point(140,103,0);
  add_point(140,103,0);
  add_point(162,97,0);
  add_point(162,97,0);
  add_point(162,113,0);
  add_point(162,113,0);
  add_point(124,113,0);
  add_point(156,77,0);
  add_point(156,97,0);
  add_point(171,77,0);
  add_point(171,101,0);
  add_point(171,101,0);
  add_point(191,94,0);
  add_point(191,94,0);
  add_point(191,113,0);
  add_point(191,113,0);
  add_point(163,113,0);
  add_point(188,77,0);
  add_point(188,94,0);
  add_point(235,77,0);
  add_point(235,85,0);
  add_point(235,85,0);
  add_point(210,85,0);
  add_point(215,86,0);
  add_point(215,96,0);
  add_point(211,97,0);
  add_point(236,97,0);
  add_point(236,97,0);
  add_point(258,114,0);
  add_point(258,114,0);
  add_point(188,114,0);


  //change center of rotation
  for(unsigned int i=0; i<points.size();i++){
    points[i].x = points[i].x - 145;
    points[i].y = points[i].y - 90;
  }
}

void WalleLogo::init_edges(){
  add_edge(0,1);
  add_edge(2,3);
  add_edge(4,5);
  add_edge(6,7);
  add_edge(8,9);
  add_edge(10,11);
  add_edge(12,13);
  add_edge(14,15);
  add_edge(16,17);
  add_edge(18,19);
  add_edge(20,21);
  add_edge(22,23);
  add_edge(24,25);
  add_edge(26,27);
  add_edge(28,29);
  add_edge(30,31);
  add_edge(32,33);
  add_edge(34,35);
  add_edge(36,37);
  add_edge(38,39);
  add_edge(40,41);
  add_edge(42,43);
  add_edge(44,45);
  add_edge(46,47);
  add_edge(48,49);
  add_edge(50,51);
  add_edge(52,53);
  add_edge(54,55);
  add_edge(56,57);
  add_edge(58,59);
  add_edge(60,61);
  add_edge(62,63);
  add_edge(64,65);
  add_edge(66,67);

  int last_logo_point = points.size();

  // copy flat logo to -10 and translate current points in plane 10 up
  for(unsigned int i=0; i<last_logo_point; i++ ){
    points[i].z = -10;
    add_point(points[i].x, points[i].y, 10);
  }

  // use same edges on new points
  int edges_size = edges.size();
  for(unsigned int i=0; i<edges_size; i++){
    add_edge(
      edges[i].a + last_logo_point,
      edges[i].b + last_logo_point
    );
  }

  //connect the 2 planes
  for(unsigned int i=0; i<edges_size; i++){
    add_edge(
      edges[i].a,
      edges[i+edges_size].a
    );

    add_edge(
      edges[i].b,
      edges[i+edges_size].b
    );
  }

}


