/*=============================================================================
author        : Walter Schreppers
filename      : blenderobject.cpp
created       : 21/5/2022 at 00:41:44
modified      : 
version       : 
copyright     : Walter Schreppers
bugreport(log): 
=============================================================================*/

#include "blenderobject.h"
#include <fstream>
#include <sstream>
#include <iostream>


/*-----------------------------------------------------------------------------
name        : init
description : initialize private locals
parameters  : 
return      : void
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
void BlenderObject::init(){
  file_name="";
  object_name="blender object";
}


/*-----------------------------------------------------------------------------
name        : BlenderObject
description : constructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
BlenderObject::BlenderObject(Screen& scr) : Object(scr){
  init();
}


/*-----------------------------------------------------------------------------
name        : ~BlenderObject
description : destructor
parameters  : 
return      : 
exceptions  : 
algorithm   : trivial
-----------------------------------------------------------------------------*/
BlenderObject::~BlenderObject(){

}


/*-----------------------------------------------------------------------------
name        : normalize_object
description : make loaded file display nicely with tiny engine
parameters  : 
return      : 
exceptions  : 
algorithm   : compute bounding box and then translate + scale object so it
displays nicely 
-----------------------------------------------------------------------------*/
void BlenderObject::normalize_object(){

  //bounding box
  float max_x=0, max_y=0, max_z=0;
  float min_x=0, min_y=0, min_z=0;

  for(int i=0; i<points.size(); i++){
    if(points[i].x > max_x) max_x = points[i].x;
    if(points[i].y > max_y) max_y = points[i].y;
    if(points[i].z > max_z) max_z = points[i].z;

    if(points[i].x < min_x) min_x = points[i].x;
    if(points[i].y < min_y) min_y = points[i].y;
    if(points[i].z < min_z) min_z = points[i].z;
  }

  float delta_x = max_x - min_x;
  float delta_y = max_y - min_y;
  float delta_z = max_z - min_z;

  float max_dim = delta_x;
  if(delta_y > max_dim) max_dim = delta_y;
  if(delta_z > max_dim) max_dim = delta_z;

  float scale = 250/max_dim;


  for(int i=0; i<points.size(); i++){
    points[i].x = points[i].x * scale;
    points[i].y = points[i].y * scale;
    points[i].z = points[i].z * scale ;
  }
}



/*-----------------------------------------------------------------------------
name        : ~BlenderObject
description : destructor
parameters  : 
return      : 
exceptions  : 
algorithm   : 
 https://en.wikipedia.org/wiki/Wavefront_.obj_file
 blender use %T to make triangles and then export plain object without texture
 mtl file we're not using yet (is for textures or shading)

 read file line per line.
   o object_name
   v x y z (vertex x,y,z)
   f v1//vn1 v2//vn2 v3//vn3  --> triangle v1, v2, v3 and then // then the normal
-----------------------------------------------------------------------------*/
void BlenderObject::load(const std::string& filename){
  this->file_name = filename;
  this->object_name = filename; //in case obj file does not have an o line
  points.clear();
  triangles.clear();
 
  using namespace std;
  ifstream obf;
  obf.open(filename);

  string k;
  string line = "";
  while(getline(obf, line)){
    if(line[0]=='#') continue;

    istringstream iss(line);
    iss >> k;
    if(k=="o"){
      iss >> this->object_name;
    }
    else if(k=="v"){
      float x,y,z;
      iss >> x >> y >> z;
      add_point(x,y,z);
    }
    else if(k=="vn"){
      //for now skip these. 
      float vx,vy,vz;
      iss >> vx >> vy >> vz;
    }
    else if(k=="f"){
      int a,b,c;
      int na, nb, nc;   // normals, we don't use yet
      char s;           // slash
      iss >> a >> s >> s >> na;
      iss >> b >> s >> s >> nb;
      iss >> c >> s >> s >> nc;
      // cout << "triange a="<< a-1 <<" b=" << b-1 << " c=" << c-1 << endl;
      // cout << "triange na="<< na-1 <<" nb=" << nb-1 << " nc=" << nc-1 << endl;
      add_triangle(a-1,c-1, b-1);
    }
    // else cout << "skipping line=" << line <<endl;
  }

  normalize_object();
}

void BlenderObject::save(const std::string& filename){
  //TODO save obj file here
}
