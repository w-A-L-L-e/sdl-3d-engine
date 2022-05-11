program hankie;
uses fastvga,crt,pcxunit,picture;

var offset,i,j:integer;
    sinus: array [0..255] of integer;
    cosin: array [0..255] of integer;
    zoom,move:real;
    page3:^vscreen;
    p,black:palettetype;


procedure init;
var i:integer;
begin
     offset:=0;
     for i:=0 to 255 do begin
         sinus[i]:=round(sin(i*(pi/128))   *10);
         cosin[i]:=round(cos(i*(pi/128))   *10);
     end;
end;

procedure drawsurface;
var i,j,x,y:integer;
		z,color:byte;

begin
     {for i:=0 to 149 do begin
         vgacolor:=i+offset2;
         hlinepage2(0,i,319);
     end;}
     for j:=0 to 185 do
         for i:=10 to 308 do begin
             if page3^[j,i]>0 then begin
             		z:=i+j+offset;
                x:=i +sinus[z];
                y:=j +sinus[z];
                vgacolor:=page3^[j,i];
                boxpage2(x,y,x+1,y+1);
{                color:=page3^[j,i];
                page2^[y,x]:=color;
                page2^[y,x+1]:=color;
                page2^[y+1,x]:=color;
                page2^[y+1,x+1]:=color;}
             end;
         end;
     {for j:=0 to 39 do
         for i:=0 to 319 do
             page2^[j+149,i]:=page2^[160-j*4,i];}

end;


procedure initpalette;
var i:integer;
begin
	for i:=0 to 255 do begin
     black[i,1]:=0;
     black[i,2]:=0;
     black[i,3]:=0;
 end;
end;


procedure fadeinto(a,b:palettetype);
var i:integer;
    temp:boolean;
begin
 for i:=1 to maxpull(a,b,0,255) do begin
      PullToPalette (a,b,0,255,Temp); { Move P from Black }
      if (i mod 2)=0 then SetActivePalette (a,0,255); { Activate the new palette }
 end;
 SetActivePalette(a,0,255);
end;


begin
     govga256;
     clrvgascr;
     init;
     initpalette;
     new(page3);
     MemLoadPCXpage2 (@picture_PCX,picture_PCX_Size,p);
     setactivepalette(p,0,255);

     {logo stond iets te hoog}
     for i:=0 to 319 do
     for j:=0 to 219 do
     if j<15 then page3^[j,i]:=0
	     else page3^[j,i]:=page2^[j-15,i];


     offset:=0;
     repeat
           clrpage2scr;
           inc(offset,8);
           drawsurface;
           vsync;
           copyfrompage2;
     until keypressed;
		 fadeinto(p,black);
     dispose(page3);
     restoremode;
end.
