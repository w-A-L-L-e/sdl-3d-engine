/*=============================================================================
author        : Walter Schreppers
filename      : palette.cpp
created       : 26/5/2022 at 14:58:40
modified      :
version       :
copyright     : Walter Schreppers
bugreport(log):
=============================================================================*/

#include "palette.h"

/*-----------------------------------------------------------------------------
name        : init
description : initialize private locals
parameters  :
return      : void
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
void Palette::init() {
  this->palette_index = -1;  // default uninitialised
  this->setGreyPalette(); 
}

/*-----------------------------------------------------------------------------
name        : Palette
description : constructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
Palette::Palette() { init(); }

/*-----------------------------------------------------------------------------
name        : ~Palette
description : destructor
parameters  :
return      :
exceptions  :
algorithm   : trivial
-----------------------------------------------------------------------------*/
Palette::~Palette() {}

Color Palette::getColor(int index) {
  if (index < 0)   index = 0;
  if (index > 255) index = 255;
  return colors[index];
}

// 0-9 allowed here, best use enum here
void Palette::setActivePalette(int palette_index) {
  if (palette_index < 0) palette_index = 0;
  if (palette_index > 6) palette_index = 6;

  // only re-init palette if it differs
  if(this->palette_index == palette_index) return;
  
  switch (palette_index) {
    case 0: setGreyPalette();     break;
    case 1: setRedPalette();      break;
    case 2: setGreenPalette();    break;
    case 3: setBluePalette();     break;
    case 4: setYellowPalette();   break;
    case 5: setCyanPalette();     break;
    case 6: setPurplePalette();   break;
    default: setFlashyPalette();  break;
  }
}

void Palette::setGreyPalette() {
  this->palette_index = 0;

  for (int i = 0; i < 256; i++) {
    colors[i].red = i;
    colors[i].green = i;
    colors[i].blue = i;
  }
}

void Palette::setRedPalette() {
  this->palette_index = 1;

  for (int i = 0; i < 256; i++) {
    colors[i].red = i;
    colors[i].green = 0;
    colors[i].blue = 0;
  }
}

void Palette::setGreenPalette() {
  this->palette_index = 2;

  for (int i = 0; i < 256; i++) {
    colors[i].red = 0;
    colors[i].green = i;
    colors[i].blue = 0;
  }
}

void Palette::setBluePalette() {
  this->palette_index = 3;

  for (int i = 0; i < 256; i++) {
    colors[i].red = 0;
    colors[i].green = 0;
    colors[i].blue = i;
  }
}

void Palette::setYellowPalette() {
  this->palette_index = 4;

  for (int i = 0; i < 256; i++) {
    colors[i].red = i;
    colors[i].green = i;
    colors[i].blue = 0;
  }
}

void Palette::setCyanPalette() {
  this->palette_index = 5;

  for (int i = 0; i < 256; i++) {
    colors[i].red = 0;
    colors[i].green = i;
    colors[i].blue = i;
  }
}

void Palette::setPurplePalette() {
  this->palette_index = 6;

  for (int i = 0; i < 256; i++) {
    colors[i].red = i;
    colors[i].green = 0;
    colors[i].blue = i;
  }
}

// palette_index 7 , but use grey palette until we have a solution for this...
void Palette::setFlashyPalette() {
  setGreyPalette();
  this->palette_index = 7;

  //TODO: implement this when we got time...
  /* normally we have this in tp
  procedure initpal;
  var i:integer;
      p:palettetype;
  begin
      for i:=192 to 255 do begin {64 greyscales}
        p[i,1]:=i-192;
        p[i,2]:=i-192;
        p[i,3]:=0;{i-192;}
      end;
      setactivepalette(p,192,255);
  end;
  */
}

// TODO:    setCustomPalette(colors, version);
