/*=============================================================================
author        : Walter Schreppers
filename      : palette.h
created       : 26/5/2022 at 14:58:40
modified      :
version       :
copyright     : Walter Schreppers
description   : We define 10 palettes for using in drawing objects and letters
=============================================================================*/

#ifndef PALETTE_H
#define PALETTE_H

struct Color {
  unsigned int red;
  unsigned int green;
  unsigned int blue;
};

class Palette {

public:
  // constructor & destructor
  //==========================
  Palette(); // default greyscale palette, 0
  ~Palette();

  // public members
  //==============
  void
  setActivePalette(int palette_index); // 0-9 allowed here, best use enum here

  // TODO: use enum here instead soon
  void setGreyPalette();   // 0
  void setRedPalette();    // 1
  void setGreenPalette();  // 2
  void setBluePalette();   // 3
  void setYellowPalette(); // 4
  void setCyanPalette();   // 5
  void setPurplePalette(); // 6
  void setFlashyPalette(); // 7

  // TODO:    setCustomPalette(colors, version);

  Color getColor(int index);

private:
  // private members:
  //================
  void init();

  // private locals:
  //===============
  Color colors[256];
  int palette_index;

}; // end of class Palette

#endif
