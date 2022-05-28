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
  // give points in clockwize order from bottom to top
  add_point(0,0,0);
  add_point(-50,0,0);
  add_point(-10,10,0);
  add_point(-10,70,0);
  add_point(-30,70,0);
  add_point(-50,90,0);
  add_point(-50,120,0);
  add_point(-40,120,0);
  add_point(-40,100,0);
  add_point(-20,80,0);
  add_point(0,80,0);

  // now correct center of object in space
  for(unsigned int i=0; i<points.size(); i++){
    points[i].y = points[i].y - 60.0;
  }

  schil_size = points.size();
  rotate_schil(8); // 26 original, 16 or 8 is better

  //scale bigger a little
  float scale=1.8;
  for(unsigned int i=0; i<points.size(); i++){
    points[i].x = points[i].x * scale; 
    points[i].y = points[i].y * scale; 
    points[i].z = points[i].z * scale; 
  }
}

void WineGlass::init_triangles(){
  // std::cout<<"schil_size=" <<schil_size<<std::endl;
  
  int offset = 0;
  while(offset<=points.size()-schil_size){
    for(int i=offset;i<schil_size+offset;i++){
      // add clockwize triangles like blender does it
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

  std::cout<<"wine glass triangle size=" <<triangles.size()<<std::endl;
}

