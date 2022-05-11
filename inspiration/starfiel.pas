program starfield;
uses fastvga,crt,fastkeys;


var p:palettetype;
    i:integer;
    offset:byte;
    movex,movey:integer;
    speedup:real;
type
    star=
    object
          x,y,
          dx,dy:real;
          exists:boolean;
          color:byte;
          procedure move;
    end;

procedure star.move;
begin
     if exists then
     begin
       dy:=dy*(1.0037567+speedup);
       y:=y+dy;
       dx:=dx*(1.0037445+speedup);
       x:=x+dx;
       {if random<0.1 then dx:=dx+random(3)-1;}
       if (y<10) or (y>190) or (x<10) or (x>310) then exists:=false;
     end;
end;

var
   stars:array[1..400] of star;

procedure addstar(xx,yy:integer);
var
   i,j,nr:integer;
begin
     i:=1;
     nr:=0;
     while (i<400) and (nr=0) do
     begin
           if not stars[i].exists then
              nr:=i;
           inc(i);
     end;
     if nr<>0 then
     with stars[nr] do
     begin
          x:=xx;
          y:=yy;
          dx:=random(100)/175;
          if random<0.5 then dx:=-dx;
          dy:=random(100)/175;
          if random<0.5 then dy:=-dy;
          exists:=true;
          color:=0;
     end;
end;


function abs(a:integer):integer;
begin
     if a<0 then a:=-a;
     abs:=a;
end;

procedure drawstars;
var i,x,y,c:integer;
begin
     for i:=1 to 400 do begin
         x:=round(stars[i].x);
         y:=round(stars[i].y);
         c:=round((abs(x-(160+movex))+abs(y-(100+movey)))*3);
         if c>255 then c:=255;
         if stars[i].exists then page2^[round(stars[i].y),round(stars[i].x)]:=c;
     end;
end;


procedure initpalette;
var i:integer;
begin
     for i:=0 to 255 do begin
         p[i,1]:=i div 4;
         p[i,2]:=i div 4;
         p[i,3]:=i div 4;
     end;
     setactivepalette(p,0,255);
end;

begin
     govga256;
     installfastkeys;
     initpalette;
     clrpage2scr;
     movex:=0;
     movey:=0;
     speedup:=0;
     repeat
         inc(offset);
         speedup:=speedup+0.0001;
         if speedup>0.05 then
         begin
           speedup:=0.05;
           {make it swirl
           movex:=round(sin(offset*(pi/128))*20);
           movey:=round(sin(offset*(pi/128))*20);}
         end;
         addstar(160+movex,100+movey);
         addstar(160+movex,100+movey);
         addstar(160+movex,100+movey);


         for i:=1 to 400 do stars[i].move;
         clrpage2scr;
         drawstars;
         copyfrompage2;
         vsync;
     until key[scspace];
     restorekeyboard;
     restoremode;
end.