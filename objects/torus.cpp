/*=============================================================================
author        : Walter Schreppers
filename      : torus.cpp
created       : 6/5/2022 at 22:52:26
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#include "torus.h"
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
void Torus::init(){
  init_points();
  init_triangles();
}


/*-----------------------------------------------------------------------------
name        : Torus
description : constructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
Torus::Torus(Screen& screen): Object(screen){
  init();
}


/*-----------------------------------------------------------------------------
name        : ~Torus
description : destructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
Torus::~Torus(){

}

void Torus::put_circle(float radius=60, float second_radius=120, int schil_rotate=16){
  // 10 points evenly in a circle here
  int i = 255;
  while(i>0){
    add_point(
      std::sin((float)i * (PI/128.0)) * radius + second_radius,
      std::cos((float)i * (PI/128.0)) * radius,
      0.0
    );    
    i-=schil_rotate; // 26 is original value, but 16 divides better and is higher res
  }
}


void Torus::rotate_schil(int rot_amount=8){
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

void Torus::init_points(){
  // put first circle of points
  // put_circle(60, 120, 26); //original
  put_circle(60, 120, 16);
  schil_size = points.size();

  // rotate_schil(16); //original like pascal engine
  rotate_schil(8);
  // rotate_schil(4); // still works and looks way cool ;)
}

void Torus::init_triangles(){
  // std::cout<<"schil_size=" <<schil_size<<std::endl;
  
  int offset = 0;
  while(offset<=points.size()-schil_size){
    for(int i=offset;i<schil_size+offset;i++){
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

  std::cout<<"torus triangle size=" <<triangles.size()<<std::endl;
}
