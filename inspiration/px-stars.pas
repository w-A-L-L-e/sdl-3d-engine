program stars;

uses fastvga,pcxunit,crt,pxpcx;
const
  maxpoints=500;
  maxedge=620;
 (*mijn datastructuur voor 3d stuff :)*)
 TYPE

 vector=array [0..3] OF longint;
 normaal=array [0..3] of longint;

 Point = RECORD
          p   : vector;
          rotp: vector;
         end;

 pointlist= array [0..maxpoints] of point;

 var
 p,black:palettetype;
 pal	:palettetypeptr;
 page3:vscreenptr;
 plist  :pointlist;
 plast,
 i,offset      :integer;
  COSIN       : ARRAY [0..255] OF real;
  SINUS       : ARRAY [0..255] OF real;
	SINT				: array [0..255] of integer;




procedure Inittables;
var i:byte;
begin
 for i:=0 to 255 do begin
  SINUS[i]:=( Sin((Pi/128)*i));
  COSIN[i]:=( Cos((Pi/128)*i));
  SINT[i]:=round( sin((pi/128)*i)*10);
  end;
end;



procedure putpoint(VAR plist:pointlist; punt:Point);
BEGIN
  if plast<maxpoints then begin
   plist[plast]:=punt;
   plast:=plast+1;
  end;
end; { putpoint}

procedure makepoint(x,y,z:longint);
var p:point;
begin
   p.p[0]:=x;
   p.p[1]:=y;
   p.p[2]:=z;
   p.p[3]:=1;
   putpoint(plist,p);
end;


procedure initpalette1;
var i:byte;
begin
 for i:=0 to 127 do begin
     p[i+128,1]:=i div 2;
     p[i+128,2]:=i div 2;
     p[i+128,3]:=i div 2;
 end;
     setactivepalette(p,128,255);
     getactivepalette(p,0,255);
 for i:=0 to 255 do begin
     black[i,1]:=0;
     black[i,2]:=0;
     black[i,3]:=0;
 end;

end;




procedure Rotfast(var plist:pointlist;
                  hoekx,hoeky,hoekz:real);
const
   FixPoint=255;
var

   Ai,Bi,Ci,
   Di,Ei,Fi,
   Gi,Hi,Ii  : real;
   i,tempcol : integer;

begin
   (*doin it the fast way with 9 multiplies! *)
  Ai:=cos(hoekz)*cos(hoeky);
  Bi:=sin(hoekz)*cos(hoeky);
  Ci:=-sin(hoeky);
  Di:=(sin(hoekx)*sin(hoeky)*cos(hoekz))-(cos(hoekx)*sin(hoekz));
  Ei:=((sin(hoekx)*sin(hoeky)*sin(hoekz))+(cos(hoekx)*cos(hoekz)));
  Fi:=sin(hoekx)*cos(hoeky);
  Gi:=((cos(hoekx)*sin(hoeky)*cos(hoekz))+(sin(hoekx)*sin(hoekz)));
  Hi:=((cos(hoekx)*sin(hoeky)*sin(hoekz))-(sin(hoekx)*cos(hoekz)));
  Ii:=cos(hoekx)*cos(hoeky);

   (*x y and z rotation in once!!!*)

   for i:= 0 to plast-1 do begin
      plist[i].rotp[0]:=round(Ai*plist[i].p[0]+(Bi*plist[i].p[1])+(Ci*plist[i].p[2]));
      plist[i].rotp[1]:=round(Di*plist[i].p[0]+(Ei*plist[i].p[1])+(Fi*plist[i].p[2]));
      plist[i].rotp[2]:=round(Gi*plist[i].p[0]+(Hi*plist[i].p[1])+(Ii*plist[i].p[2]));

      if plist[i].rotp[2]=-130 then plist[i].rotp[2]:=-131;
      plist[i].rotp[0]:=(plist[i].rotp[0]*150) div (plist[i].rotp[2]+130) + 160;
      plist[i].rotp[1]:=(plist[i].rotp[1]*150) div (plist[i].rotp[2]+130) + 100;
      (*die laatste +centerx en +centery zijn voor verschuiving!*)
  end;
end; (*rotfast*)

procedure createpoints;
var i,x,y,z:integer;

begin
     for i:=1 to maxpoints-1 do begin
         x:=round((random*200)-100);
         y:=round((random*200)-100);
         z:=round((random*200)-100);
         makepoint(x,y,z);
     end;
end;

procedure movepoints;
var i:integer;
begin
     for i:=0 to plast-1 do begin
         plist[i].p[2]:=plist[i].p[2]+4;
         if plist[i].p[2]>100 then plist[i].p[2]:=-100;
     end;
end;


procedure drawpoints;
var i:integer;
    temp:integer;
begin
     for i:=0 to plast-1 do begin
         temp:=(250-(plist[i].rotp[2]+100))div 2+128;
         if temp>255 then vgacolor:=255
         else if temp<128 then vgacolor:=128
         else vgacolor:=temp;
         if
         (plist[i].rotp[0]>0) and
         (plist[i].rotp[0]<319) and
         (plist[i].rotp[1]>0) and
         (plist[i].rotp[1]<199)
         then page2^[plist[i].rotp[1],plist[i].rotp[0]]:=vgacolor;
     end;
end;



procedure drawlogo;
var x,y:integer;
begin
  	for x:=0 to 319 do
  	for y:=0 to 46 do begin
  		page2^[y+75,x]:=page3^[y,x];
  	end;
end;

procedure zoomlogo;
var
	x,y:integer;
  zoomx,zoomy:real;
begin

	zoomy:=offset *(1/40);
  zoomx:=offset *(1/40);
  if zoomx<1 then
		for x:=0 to 319 do
  	for y:=0 to 46 do begin
  		page2^[round(zoomy*(y-23))+98,round(zoomx*(x-160))+160]:=page3^[y,x];
  	end
  else drawlogo;
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


procedure play;
var x,y,z,a,b,c:real;
begin
     x:=pi;
     y:=0;
     z:=0;
     a:=0;
     b:=0;
     c:=0;
     offset:=0;
     repeat
           inc(offset,1);
           offset:=offset mod 30000;
           x:=x+a;
           y:=y+b;
           z:=z+c;
           clrpage2scr;
           rotfast(plist,x,y,z);
           movepoints;
           drawpoints;
           zoomlogo;
           vsync;
           copyfrompage2;
     until keypressed or (offset>=140);
     repeat
     			inc(offset,1);
           x:=x+a;
           y:=y+b;
           z:=z+c;
           clrpage2scr;
           rotfast(plist,x,y,z);
           movepoints;
           drawpoints;
           drawlogo;
                a:=sin(offset*(pi/801))*(pi/180);
                b:=cos(offset*(pi/647))*(pi/180);
                c:=sin(offset*(pi/723))*(pi/180);
           {if key[scenter] then begin
              a:=0;b:=0;c:=0;
           end;}
           vsync;
           copyfrompage2;
     until keypressed;
		fadeinto(p,black);
end;

begin
     govga256;
     inittables;
     MemLoadPCXpage2 (@pxstars_PCX,pxstars_PCX_Size,p);
     setactivepalette(p,0,127);

     new(page3);
     page3^:=page2^;
     initpalette1;
     clrpage2scr;
     plast:=0;
     createpoints;
     play;

     restoremode;
     dispose(page3);
end.

