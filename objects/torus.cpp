/*=============================================================================
author        : Walter Schreppers
filename      : torus.cpp
created       : 6/5/2022 at 22:52:26
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log):  TODO remove code duplication with wineglass, by either
a base class rotateobject or composition ...
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
  init_edges();

  std::cout<< this->name() << " points    = " << points.size() << std::endl;
  std::cout<< this->name() << " triangles = " << triangles.size() <<std::endl;
  std::cout<< this->name() << " edges     = " << edges.size() << std::endl;

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
  put_circle(60, 120, 16); //26 original
  schil_size = points.size();

  // rotate_schil(16); // original like pascal engine
  rotate_schil(8);  // double triangles 
  // rotate_schil(4); 
}


// TODO refactor duplication, and also use these in wineglass render
// this version is better because we handle last face on schil
// seperately so the orientation of triangle slanted edge is uniform
void Torus::init_triangles(){
  int i=0;
  for( int offset=0; offset < points.size(); offset+=schil_size){
    for(i=offset; i < schil_size+offset-1; i++){
      // add clockwise triangles, but filter flat ones
      add_triangle(
        i,
        (i + schil_size) % points.size(),
        (i + 1)
      );

      add_triangle(
        (i + schil_size) % points.size(),
        (i + schil_size + 1) % points.size(),
        (i + 1)
      );
    }

    // last square of 2 tris wraps around shell
    add_triangle(
      (i + schil_size) % points.size(),
      (offset+schil_size) % points.size(),
      offset
    );

    add_triangle(
      offset, 
      i,
      (i+schil_size) % points.size()
    );

  }
}



void Torus::add_edges_square(int a, int b, int c, int d){
  add_edge(a,b); // top line
  add_edge(b,c); // left side

  // for torus we only need 2 edges to form squares (because it wraps around)
  // however, if we want to not fully rotate it and have partial torus drawing
  // in animation, we would add these back for nicer effect:
  // add_edge(c,d); // bottom line
  // add_edge(d,a); // right line
}

void Torus::init_edges(){
  int i = 0;
  for( int offset=0; offset < points.size(); offset+=schil_size){
    for(i=offset; i < schil_size+offset-1; i++){
      add_edges_square(
        i,
        (i + schil_size) % points.size(),
        (i + schil_size + 1) % points.size(),
        (i+1)
      );
    }

    // last square of shell wraps around
    add_edges_square(
      i,
      (i + schil_size) % points.size(),
      (offset+schil_size) % points.size(),
      offset
    );

    //if(offset == 2*schil_size) return;
  }
}

