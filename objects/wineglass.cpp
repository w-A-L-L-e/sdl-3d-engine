/*=============================================================================
author        : Walter Schreppers
filename      : wineglass.cpp
created       : 6/5/2022 at 18:21:12
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#include "wineglass.h"
#include <numeric>
#include <iostream>

#define PI 3.14159265358979323846


/*-----------------------------------------------------------------------------
name        : init
description : initialize private locals
parameters  : 
return      : void
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
void WineGlass::init(){
  init_points();
  init_triangles();
  init_edges();

  std::cout<< this->name() << " points    = " << points.size() << std::endl;
  std::cout<< this->name() << " triangles = " << triangles.size() <<std::endl;
  std::cout<< this->name() << " edges     = " << edges.size() << std::endl;
}


/*-----------------------------------------------------------------------------
name        : WineGlass
description : constructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
WineGlass::WineGlass(Screen &scr) : Object(scr){
  init();
}


/*-----------------------------------------------------------------------------
name        : ~WineGlass
description : destructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
WineGlass::~WineGlass(){

}

void WineGlass::rotate_schil(int rot_amount=16){ // 26 is original
  // rotates the schil multiple times and creates new points in a circle
  int i = rot_amount; 
  while(i<255){
    // rotate around Y ax
    fast_rotateXYZ(rotMatrix, 0,(float)i * (PI/128.0), 0);

    for(int j=0; j<schil_size; j++){
      point newpoint;
      rotate_point(points[j], newpoint, rotMatrix);
      add_point( newpoint.x, newpoint.y, newpoint.z);      
    }
    i+=rot_amount; 
  }
}


void WineGlass::init_points(){
  // glass shape (important, needs to be drawn clockwise)

  // original 
  // add_point(0,  40, 0); //inside glass, where wine normally is ;)
  // add_point(20, 40, 0); 
  // add_point(40, 20, 0);
  // add_point(40, 0,  0); // top edge
  // add_point(50, 0,  0);
  // add_point(50, 30, 0);
  // add_point(30, 50, 0);
  // add_point(10, 50, 0); // stem of glass
  // add_point(10, 110,0);
  // add_point(50, 120,0); //foot of glass
  // add_point(0, 120,0);  

  // improved version
  add_point(0,  45, 0); // inside glass
  add_point(20, 40, 0); 
  add_point(40, 25, 0);
  add_point(45, 0,  0); // top edge
  add_point(50, 0,  0);
  add_point(50, 30, 0);
  add_point(30, 50, 0);
  add_point(10, 55, 0); // stem of glass
  add_point(10, 110,0);
  add_point(50, 120,0); // foot of glass
  add_point(0, 115,0);   


  float scale=1.8;
  for(unsigned int i=0; i<points.size(); i++){
    // move the center of object in space
    points[i].y = points[i].y - 60.0;

    // make it a little bigger
    points[i].x = points[i].x * scale; 
    points[i].y = points[i].y * scale; 
    //points[i].z = points[i].z * scale; 
  }

  schil_size = points.size();
  rotate_schil(16); // 26 original, 16 or 8 is better

}


void WineGlass::init_triangles(){
  int offset = 0;
  while(offset<=points.size()-schil_size){
    for(int i=offset;i<schil_size+offset;i++){
      // add clockwise triangles, but filter flat ones
      add_triangle(
        i%points.size(),
        (schil_size+i)%points.size(),
        (i+1)%points.size()
      );

      add_triangle(
        (schil_size+i)%points.size(),
        (schil_size+i+1)%points.size(),
        (i+1)%points.size()
      );
    }
    offset+=schil_size;
  }
}


void WineGlass::add_edges_square(int a, int b, int c, int d){
  add_edge(a,b);
  add_edge(b,c);
  add_edge(c,d);
  add_edge(d,a);
}

void WineGlass::init_edges(){
  int offset = 0;
  while(offset<=points.size()-schil_size){
    for(int i=offset;i<schil_size+offset;i++){
      // add clockwise squares
      add_edges_square(
        i%points.size(),
        (schil_size+i)%points.size(),
        (schil_size+i+1)%points.size(),
        (i+1)%points.size()
      );
    }
    offset+=schil_size;
  } 
}

