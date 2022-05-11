program Ws3dEngine;


uses
  Crt, fastvga, fastkeys,pcxunit,picture;


const
  maxtriangle=450;  {450}
  maxpoints=450;   {450}
  maxedge=620; {620}
 (*mijn datastructuur voor 3d stuff :)*)
 TYPE

 matrix=Array [0..3,0..3] OF real;
 vector=array [0..3] OF longint;
 normaal=array [0..3] of longint;

 Point = RECORD
          p   : vector;
          rotp: vector;
         end;

 {voor gouraud en phong shading moet je weten welke driehoeken behoren tot elk punt}
 vertexp = ^vertextriangle;
 vertextriangle = record
 										t:integer;
                    next:vertexp;
 								  end;

 Triangle = record
             p1,p2,p3  : integer;
             u1,v1,
             u2,v2,
             u3,v3     : integer;
             normaal , {vlak plus hoekpunten}
             rnormaal  : normaal;
             vertexp1,     {vertex verwijzingen voor normalen van andere driehoek}
						 vertexp2,
						 vertexp3	 : vertexp;
             middenz   : longint;
             color     : byte;
             visable	 : boolean;
            end;

 Edge = record
         pa,pb    :integer;
         t1,t2    :integer;
         middenz  :longint;
         color    :byte;
         internal :boolean;
        end;

 tmap   = record
        x1,x2,u1,v1,u2,v2:integer;
        end;
 xedges    = array [0..199] of tmap;
 trilist= array [0..maxtriangle] of triangle;
 pointlist= array [0..maxpoints] of point;
 edgelist= array [0..maxedge] of edge;

var

  COSIN       : ARRAY [0..255] OF real;
  SINUS       : ARRAY [0..255] OF real;
  COST        : ARRAY [0..255] OF INTEGER;
  SINT        : ARRAY [0..255] OF INTEGER;
  plast       : integer;
  tlast       : integer;
  elast       : integer;
  plist       : pointlist;
  tlist       : trilist;
  elist       : edgelist;
  CenterX     ,
  CenterY     ,
  SizeX       ,
  SizeY       : integer;
  page3       : vscreenptr;







procedure Titlescreen;
begin
  writeln('                          3D Engine v1.25 beta');
  writeln('                          ====================');
  writeln('');
  writeln('   By hOMebOy wAllE....');
  writeln;
  writeln('Some bugs where fixed... and Gouraud shading was added');
  writeln('I''m probably gonna convert everything into c++');
	writeln('reason... texturemapped and gouraud stuff is too fucking slow');
  writeln;
  writeln('  Now on with the good stuff:');
  writeln('  - in the first screen choose different pallettes with 1,2,3,4 keys');
  writeln('  - pressing enter during rotation will stop object rotation');
  writeln('  - pressing Right Shift will put object in original angle');
  writeln('  - r,t,y will increase the x,y and z rotation');
  writeln('  - f,g,h will decrease the x,y and z rotation');
  writeln('  - Space will let you go to the next screen :) ');
  writeln('');
  writeln;
  writeln(' after reading thiz the wize thing to do is ...');
  writeln(' SLAM THE SPACE BAR WITH A SLEDGE HAMMER');
  repeat until key[scSpace];
  repeat until not key[scSpace];
end; {titlescreen}


procedure initpalette1;
var i:byte;
    p:palettetype;
begin
 for i:=0 to 255 do begin
     p[i,1]:=i div 4;
     p[i,2]:=i div 4;
     p[i,3]:=i div 4;
 end;
     setactivepalette(p,0,255);
end;

procedure initpalette2;
var i:byte;
    p:palettetype;
begin
 for i:=0 to 255 do begin
     p[i,1]:=i div 4;
     p[i,2]:=i div 4;
     p[i,3]:=0 div 4;
 end;
     setactivepalette(p,0,255);
end;

procedure initpalette3;
var i:byte;
    p:palettetype;
begin
 for i:=0 to 255 do begin
     p[i,1]:=i div 4;
     p[i,2]:=0 div 4;
     p[i,3]:=i div 4;
 end;
     setactivepalette(p,0,255);
end;


procedure initpalette4;
var i:byte;
    p:palettetype;
begin
 for i:=0 to 255 do begin
     p[i,1]:=0 div 4;
     p[i,2]:=i div 4;
     p[i,3]:=i div 4;
 end;
     setactivepalette(p,0,255);
end;


procedure testpal;
var i:byte;
    t:triangle;
begin
 initpalette1;
 clrvgascr;
 for i:= 0 to 199 do begin
  vgacolor:=i;
  line(0,i,200,i);
 end;
 repeat
       if key[sc1] then initpalette1;
       if key[sc2] then initpalette2;
       if key[sc3] then initpalette3;
       if key[sc4] then initpalette4;
 until key[scSpace];
  repeat
  until not key[scSpace];
end;




procedure WaitToGo;
  var l,lb:integer;

begin
  {StatusLine('Esc aborts or press a key...'); }
  for l:=0 to 30000 do begin
      for lb:=0 to 300 do begin
      end;
  end;

  repeat until KeyPressed;
    clrvgascr;                      { clear screen, go on with demo }
end; { WaitToGo }





(* hier komt da 3d stufffff :)*)

PROCEDURE QuicksortTriangles(VAR tlist:trilist;l,r:integer);
VAR i,j:integer;
    key:longint;
    temp:Triangle;
begin
  while (l<r) do begin
    i:= 1; j:= r; key:= tlist[j].middenz;
    repeat
      while(i<j) and (tlist[i].middenz>=key) do i:=i+1;
      while(i<j) and (key>=tlist[j].middenz) do j:=j-1;
      if i<j then begin
         temp:=tlist[i];
         tlist[i]:=tlist[j];
         tlist[j]:=temp;
      end;
    until(i>=j);
    temp:=tlist[i];
    tlist[i]:=tlist[r];
    tlist[r]:=temp;
    if (i-l<r-i) then begin
       quicksorttriangles(tlist,l,i-1);
       l:=i+1;
       end
    else begin
       quicksorttriangles(tlist,i+1,r);
       r:=i-1;
    end;
  end;
end; {quicksorttriangles}


PROCEDURE QuicksortEdges(VAR elist:edgelist;l,r:integer);
VAR i,j:integer;
    key:longint;
    temp:Edge;
begin
  while (l<r) do begin
    i:= 1; j:= r; key:= elist[j].middenz;
    repeat
      while(i<j) and (elist[i].middenz>=key) do i:=i+1;
      while(i<j) and (key>=elist[j].middenz) do j:=j-1;
      if i<j then begin
         temp:=elist[i];
         elist[i]:=elist[j];
         elist[j]:=temp;
      end;
    until(i>=j);
    temp:=elist[i];
    elist[i]:=elist[r];
    elist[r]:=temp;
    if (i-l<r-i) then begin
       quicksortedges(elist,l,i-1);
       l:=i+1;
       end
    else begin
       quicksortedges(elist,i+1,r);
       r:=i-1;
    end;
  end;
end; {quicksortedges}


PROCEDURE DrawTriangle(VAR plist:pointlist; T:Triangle);

BEGIN
   vgacolor:=t.color;
   Drawpolypage2(plist[t.p3].rotp[0], plist[t.p3].rotp[1],
                       plist[t.p2].rotp[0],
                       plist[t.p2].rotp[1],
   MoveTo (plist[t.p1].rotp[0],
          plist[t.p1].rotp[1],closePoly));
END;




Procedure FillTriangle(VAR plist:pointlist; T:Triangle);
var r1,r2,r3,
    x1,x2       : real;

    xa,ya,
    xb,yb,
    xc,yc,
    y,temp      : longint;
    done        : boolean;

begin
     vgacolor:=t.color;
     xa:=(plist[t.p1].rotp[0]);
     ya:=(plist[t.p1].rotp[1]);
     xb:=(plist[t.p2].rotp[0]);
     yb:=(plist[t.p2].rotp[1]);
     xc:=(plist[t.p3].rotp[0]);
     yc:=(plist[t.p3].rotp[1]);

     (*sorteren van klein naar groot ya=kleinste*)
     {we moeten hebben ya<=yb and yb<=yc}

     if ya>yb then
     begin
          temp:=ya;ya:=yb;yb:=temp; {swap(ya,yb)}
          temp:=xa;xa:=xb;xb:=temp;
     end;
     if yb>yc then
     begin
          temp:=yb;yb:=yc;yc:=temp; {swap(yb,yc);}
          temp:=xb;xb:=xc;xc:=temp;
     end;
     if ya>yb then
     begin
         temp:=ya;ya:=yb;yb:=temp; {swap(ya,yb);}
         temp:=xa;xa:=xb;xb:=temp;
     end;

     if not(((ya=yb) or (ya=yc)) or (yb=yc)) then begin
          r1:=(xb-xa)/(yb-ya); (*richt co van ab*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          r3:=(xc-xa)/(yc-ya); (*richt co van ac*)
          x1:=xa;
          x2:=xa;
          for y:=ya to yb-1 do begin
              hlinepage2(round(x1),y,round(x2));
              x1:=x1+r1;  (*x'en van ab*)
              x2:=x2+r3;  (*x'en van ac*)
          end;
          for y:=yb to yc do begin
              hlinepage2(round(x1),y,round(x2));
              x1:=x1+r2;   (*x'en van bc*)
              x2:=x2+r3;   (*x'en van ac*)
          end;
     end
     else if (ya=yc) then begin
        hlinepage2(xa,ya,xc); (*drie combinaties mogelijk om driehoek te hebben dat een lijnstuk is*)
        hlinepage2(xa,ya,xb);
        hlinepage2(xb,ya,xc);
        end
     else if (ya=yb) then begin  (* x coord van lijnstukken ac en bc op array zetten*)
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          x1:=xa;
          x2:=xb;
          for y:=ya to yc do begin
              hlinepage2(round(x1),y,round(x2));
              x1:=x1+r1;
              x2:=x2+r2;
          end;
      end
     else begin
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xb-xa)/(yb-ya); (*richt co van ab*)
          x1:=xa;
          x2:=xa;
          for y:=ya to yc do begin
              hlinepage2(round(x1),y,round(x2));
              x1:=x1+r1;
              x2:=x2+r2;
          end;
      end;
end; {FillTriangle}



Procedure FillTriangleClipped(VAR plist:pointlist; T:Triangle);
var r1,r2,r3,
    x1,x2       : real;

    xa,ya,
    xb,yb,
    xc,yc,
    y,temp      : longint;
    done        : boolean;



procedure hlin(x1,y1,x2:integer);
    begin
         if x1<0 then x1:=0;
         if x2<0 then x2:=0;
         if x1>319 then x1:=319;
         if x2>319 then x2:=319;
         if ((y1>0) and (y1<199)) and (x1<>x2) then
            hlinepage2(x1,y1,x2);
    end;


begin
     vgacolor:=t.color;
     xa:=(plist[t.p1].rotp[0]);
     ya:=(plist[t.p1].rotp[1]);
     xb:=(plist[t.p2].rotp[0]);
     yb:=(plist[t.p2].rotp[1]);
     xc:=(plist[t.p3].rotp[0]);
     yc:=(plist[t.p3].rotp[1]);

     (*sorteren van klein naar groot ya=kleinste*)
     {we moeten hebben ya<=yb and yb<=yc}

     if ya>yb then
     begin
          temp:=ya;ya:=yb;yb:=temp; {swap(ya,yb)}
          temp:=xa;xa:=xb;xb:=temp;
     end;
     if yb>yc then
     begin
          temp:=yb;yb:=yc;yc:=temp; {swap(yb,yc);}
          temp:=xb;xb:=xc;xc:=temp;
     end;
     if ya>yb then
     begin
         temp:=ya;ya:=yb;yb:=temp; {swap(ya,yb);}
         temp:=xa;xa:=xb;xb:=temp;
     end;

     if not(((ya=yb) or (ya=yc)) or (yb=yc)) then begin
          r1:=(xb-xa)/(yb-ya); (*richt co van ab*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          r3:=(xc-xa)/(yc-ya); (*richt co van ac*)
          x1:=xa;
          x2:=xa;
          for y:=ya to yb-1 do begin
              hlin(round(x1),y,round(x2));
              x1:=x1+r1;  (*x'en van ab*)
              x2:=x2+r3;  (*x'en van ac*)
          end;
          for y:=yb to yc do begin
              hlin(round(x1),y,round(x2));
              x1:=x1+r2;   (*x'en van bc*)
              x2:=x2+r3;   (*x'en van ac*)
          end;
     end
     else if (ya=yc) then begin
        hlin(xa,ya,xc); (*drie combinaties mogelijk om driehoek te hebben dat een lijnstuk is*)
        hlin(xa,ya,xb);
        hlin(xb,ya,xc);
        end
     else if (ya=yb) then begin  (* x coord van lijnstukken ac en bc op array zetten*)
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          x1:=xa;
          x2:=xb;
          for y:=ya to yc do begin
              hlin(round(x1),y,round(x2));
              x1:=x1+r1;
              x2:=x2+r2;
          end;
      end
     else begin
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xb-xa)/(yb-ya); (*richt co van ab*)
          x1:=xa;
          x2:=xa;
          for y:=ya to yc do begin
              hlin(round(x1),y,round(x2));
              x1:=x1+r1;
              x2:=x2+r2;
          end;
      end;
end; {FillTriangleClipped}




Procedure FillTriangleGouraud(VAR plist:pointlist; T:Triangle);
var r1,r2,r3,r4,r5,r6,
    x1,x2,c1,c2       : real;

    xa,ya,
    xb,yb,
    xc,yc,
    y,temp      : longint;
    ca,cb,cc	  : longint;
    done        : boolean;



    procedure hlin(x1:real;y:integer;x2,c1,c2:real);
    var i:integer;
        t:integer;
        r1,r2:real;
        xa,xb:integer;
    begin
    			xa:=round(x1);
          xb:=round(x2);
         if xa<0 then xa:=0; {opgepast kleuren ook aanpassen!}
         if xb<0 then xb:=0;
         if xa>319 then xa:=319;
         if xb>319 then xb:=319;
         if ((y>0) and (y<199)) and (xa<>xb) then
         begin
              r1:=((c2-c1)/(x2-x1));
              for i:=xa to xb do begin
                 page2^[y,i]:=round(c1);
                 c1:=c1+r1;
              end;
              for i:=xb to xa do begin
                  page2^[y,i]:=round(c2);
                  c2:=c2+r1;
              end;
         end;
    end;

	function getcolor(vnorm:vertexp):byte;
  var i:integer;
  		gemiddelde,count:integer;

  begin
  	count:=0;
    gemiddelde:=0;
    if vnorm<>nil then
  	while vnorm^.next<>nil do
    begin
      {if tlist[vnorm^.t].visable then
			begin}
        gemiddelde:=gemiddelde+tlist[vnorm^.t].color;
        inc(count);
     { end;}
      vnorm:=vnorm^.next
    end;
    gemiddelde:=round((gemiddelde+t.color)/(count+1));
  	if gemiddelde>255 then gemiddelde:=255;
    if gemiddelde<0 then gemiddelde:=0;
    getcolor:=gemiddelde;
  end;
begin
     vgacolor:=t.color;
     xa:=(plist[t.p1].rotp[0]);
     ya:=(plist[t.p1].rotp[1]);
     ca:=-round((plist[t.p1].rotp[2])/1.5) +80;{getcolor(t.vertexp1);}
     xb:=(plist[t.p2].rotp[0]);
     yb:=(plist[t.p2].rotp[1]);
     cb:=-round((plist[t.p2].rotp[2])/1.5)+80;{getcolor(t.vertexp2);}
     xc:=(plist[t.p3].rotp[0]);
     yc:=(plist[t.p3].rotp[1]);
     cc:=-round((plist[t.p3].rotp[2])/1.5) +80;{getcolor(t.vertexp3);}
     (*sorteren van klein naar groot ya=kleinste*)
     {we moeten hebben ya<=yb and yb<=yc}

     if ya>yb then
     begin
          temp:=ya;ya:=yb;yb:=temp; {swap(ya,yb)}
          temp:=xa;xa:=xb;xb:=temp;
          temp:=ca;ca:=cb;cb:=temp;
     end;
     if yb>yc then
     begin
          temp:=yb;yb:=yc;yc:=temp; {swap(yb,yc);}
          temp:=xb;xb:=xc;xc:=temp;
          temp:=cb;cb:=cc;cc:=temp;
     end;
     if ya>yb then
     begin
         temp:=ya;ya:=yb;yb:=temp; {swap(ya,yb);}
         temp:=xa;xa:=xb;xb:=temp;
         temp:=ca;ca:=cb;cb:=temp;
     end;

     if not(((ya=yb) or (ya=yc)) or (yb=yc)) then begin
          r1:=(xb-xa)/(yb-ya); (*richt co van ab*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          r3:=(xc-xa)/(yc-ya); (*richt co van ac*)
          x1:=xa;
          x2:=xa;

          r4:=(cb-ca)/(yb-ya); (*z richt co van ab*)
          r5:=(cc-cb)/(yc-yb); (*z richt co van bc*)
          r6:=(cc-ca)/(yc-ya); (*z richt co van ac*)
          c1:=ca;
          c2:=ca;
          for y:=ya to yb-1 do begin
              hlin(x1,y,x2,c1,c2);
              x1:=x1+r1;  (*x'en van ab*)
              x2:=x2+r3;  (*x'en van ac*)
              c1:=c1+r4;
              c2:=c2+r6;
          end;
          for y:=yb to yc do begin
              hlin(x1,y,x2,c1,c2);
              x1:=x1+r2;   (*x'en van bc*)
              x2:=x2+r3;   (*x'en van ac*)
              c1:=c1+r5;
              c2:=c2+r6;
          end;
     end
     else if (ya=yc) then begin
        hlin(xa,ya,xc,ca,cc); (*drie combinaties mogelijk om driehoek te hebben dat een lijnstuk is*)
        hlin(xa,ya,xb,ca,cb);
        hlin(xb,ya,xc,cb,cc);
        end
     else if (ya=yb) then begin  (* x coord van lijnstukken ac en bc op array zetten*)
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          x1:=xa;
          x2:=xb;

          r3:=(cc-ca)/(yc-ya); (*richt co van ac*)
          r4:=(cc-cb)/(yc-yb); (*richt co van bc*)
          c1:=ca;
          c2:=cb;
          for y:=ya to yc do begin
              hlin(x1,y,x2,c1,c2);
              x1:=x1+r1;
              x2:=x2+r2;
              c1:=c1+r3;
              c2:=c2+r4;
          end;
      end
     else begin
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xb-xa)/(yb-ya); (*richt co van ab*)
          x1:=xa;
          x2:=xa;

          r3:=(cc-ca)/(yc-ya); (*richt co van ac*)
          r4:=(cb-ca)/(yb-ya); (*richt co van ab*)
          c1:=ca;
          c2:=ca;
          for y:=ya to yc do begin
              hlin(x1,y,x2,c1,c2);
              x1:=x1+r1;
              x2:=x2+r2;
              c1:=c1+r3;
              c2:=c2+r4;
          end;
     end;
end; {FillTriangleGouraud}











Procedure GetXTri(var plist:pointlist;t:Triangle; VAR E:xedges ;
                      var ya,yb,yc:longint) ;

var
    r1,r2,r3,step1x,step2x,step1y,step2y,u1r,v1r,u2r,v2r,
    x1,x2       : real;
    sp    	: array [1..3,0..3] of longint;  {3* 0=x 1 =y value}
    unsorted,loc : integer;
    done         : boolean;
    y		 : integer;
    xa,xb,xc   :longint;
    ua,va,
    ub,vb,uc,vc         :integer;
begin

     sp[1,0]:=(plist[t.p1].rotp[0]);
     sp[1,1]:=(plist[t.p1].rotp[1]);
     sp[1,2]:=t.u1;
     sp[1,3]:=t.v1;

     sp[2,0]:=(plist[t.p2].rotp[0]);
     sp[2,1]:=(plist[t.p2].rotp[1]);
     sp[2,2]:=t.u2;
     sp[2,3]:=t.v2;


     sp[3,0]:=(plist[t.p3].rotp[0]);
     sp[3,1]:=(plist[t.p3].rotp[1]);
     sp[3,2]:=t.u3;
     sp[3,3]:=t.v3;


     (*sorteren van klein naar groot ya=kleinste*)
     (*selection sort met *)

     for unsorted:=2 to 3 do begin
         ya:=sp[unsorted,1];
         xa:=sp[unsorted,0];
         ua:=sp[unsorted,2];
         va:=sp[unsorted,3];
         loc:=unsorted;
         done:=false;
         while (loc>1) and (not done) do begin
           if sp[loc-1,1]>ya then begin
              sp[loc,1]:=sp[loc-1,1];
              sp[loc,0]:=sp[loc-1,0];
              sp[loc,2]:=sp[loc-1,2];
              sp[loc,3]:=sp[loc-1,3];

              loc:=loc-1;
           end
           else done:=true;
         end;
         sp[loc,1]:=ya;
         sp[loc,0]:=xa;
         sp[loc,2]:=ua;
         sp[loc,3]:=va;
     end;
     xa:=sp[1,0];
     ya:=sp[1,1];
     xb:=sp[2,0];
     yb:=sp[2,1];
     xc:=sp[3,0];
     yc:=sp[3,1];


     ua:=sp[1,2];
     va:=sp[1,3];

     ub:=sp[2,2];
     vb:=sp[2,3];

     uc:=sp[3,2];
     vc:=sp[3,3];

     if not(((ya=yb) or (ya=yc)) or (yb=yc)) then begin
          r1:=(xb-xa)/(yb-ya); (*richt co van ab*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          r3:=(xc-xa)/(yc-ya); (*richt co van ac*)
          step1x:=(ub-ua)/(yb-ya); (*zie r1*)
          step2x:=(uc-ua)/(yc-ya); (*zie r3*)
          step1y:=(vb-va)/(yb-ya);
          step2y:=(vc-va)/(yc-ya);
          u1r:=ua;
          u2r:=ua;
          v1r:=va;
          v2r:=va;
          x1:=xa;
          x2:=xa;
          for y:=ya to yb-1 do begin
              if x1<x2 then begin
      	        E[y].x1:=round(x1);
                E[y].x2:=round(x2);
                E[y].u1:=round(u1r);
                E[y].v1:=round(v1r);
                E[y].u2:=round(u2r);
                E[y].v2:=round(v2r);

              end
          	else begin
                E[y].x1:=round(x2);
                E[y].x2:=round(x1);
                E[y].u1:=round(u2r);
                E[y].v1:=round(v2r);
                E[y].u2:=round(u1r);
                E[y].v2:=round(v1r);
              end;
              x1:=x1+r1;  (*x'en van ab*)
              x2:=x2+r3;  (*x'en van ac*)
              u1r:=u1r+step1x;
              u2r:=u2r+step2x;
              v1r:=v1r+step1y;
              v2r:=v2r+step2y;
          end;
          step1x:=((uc-ub)/(yc-yb));
          step2x:=((uc-ua)/(yc-ya));
          step1y:=((vc-vb)/(yc-yb));
          step2y:=((vc-va)/(yc-ya));
          x1:=xb;
          x2:=(r3*(yb-yc))+xc;
          for y:=yb to yc do begin
              if x1<x2 then begin
      	        E[y].x1:=round(x1);
                E[y].x2:=round(x2);
                E[y].u1:=round(u1r);
                E[y].v1:=round(v1r);
                E[y].u2:=round(u2r);
                E[y].v2:=round(v2r);
              end
              else begin
                E[y].x1:=round(x2);
                E[y].x2:=round(x1);
                E[y].u1:=round(u2r);
                E[y].v1:=round(v2r);
                E[y].u2:=round(u1r);
                E[y].v2:=round(v1r);
              end;
              x1:=x1+r2;   (*x'en van bc*)
              x2:=x2+r3;   (*x'en van ac*)
              u1r:=u1r+step1x;
              u2r:=u2r+step2x;
              v1r:=v1r+step1y;
              v2r:=v2r+step2y;
          end;
     end
     else if (ya=yc) then begin
        {hlinepage2(xa,ya,xc); (*drie combinaties mogelijk om driehoek te hebben dat een lijnstuk is*)
        hlinepage2(xa,ya,xb);
        hlinepage2(xb,ya,xc); }
        end
     else if (ya=yb) then begin  (* x coord van lijnstukken ac en bc op array zetten*)
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          step1x:=(uc-ua)/(yc-ya);
          step2x:=(uc-ub)/(yc-yb);
          step1y:=(vc-va)/(yc-ya);
          step2y:=(vc-vb)/(yc-yb);
          u1r:=ua;
          u2r:=ub;
          v1r:=va;
          v2r:=vb;
          x1:=xa;
          x2:=xb;
          for y:=ya to yc do begin
              if x1<x2 then begin
      	        E[y].x1:=round(x1);
                E[y].x2:=round(x2);
                E[y].u1:=round(u1r);
                E[y].v1:=round(v1r);
                E[y].u2:=round(u2r);
                E[y].v2:=round(v2r);
              end
              else begin
                E[y].x1:=round(x2);
                E[y].x2:=round(x1);
                E[y].u1:=round(u2r);
                E[y].v1:=round(v2r);
                E[y].u2:=round(u1r);
                E[y].v2:=round(v1r);
              end;
              x1:=x1+r1;
              x2:=x2+r2;
              u1r:=u1r+step1x;
              u2r:=u2r+step2x;
              v1r:=v1r+step1y;
              v2r:=v2r+step2y;
          end;
      end
     else begin    (*yb=yc*)
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xb-xa)/(yb-ya); (*richt co van ab*)
          step1x:=(uc-ua)/(yc-ya);
          step2x:=(ub-ua)/(yb-ya);
          step1y:=(vc-va)/(yc-ya);
          step2y:=(vb-va)/(yb-ya);
          u1r:=ua;
          u2r:=ua;
          v1r:=va;
          v2r:=va;
          x1:=xa;
          x2:=xa;
          for y:=ya to yc do begin
              if x1<x2 then begin
      	        E[y].x1:=round(x1);
                E[y].x2:=round(x2);
                E[y].u1:=round(u1r);
                E[y].v1:=round(v1r);
                E[y].u2:=round(u2r);
                E[y].v2:=round(v2r);
              end
              else begin
                E[y].x1:=round(x2);
                E[y].x2:=round(x1);
                E[y].u1:=round(u2r);
                E[y].v1:=round(v2r);
                E[y].u2:=round(u1r);
                E[y].v2:=round(v1r);
              end;
              x1:=x1+r1;
              x2:=x2+r2;
              u1r:=u1r+step1x;
              u2r:=u2r+step2x;
              v1r:=v1r+step1y;
              v2r:=v2r+step2y;
          end;
      end;
end;{GetXTri}





Procedure TextureTriangle(VAR plist:pointlist; VAR T:Triangle;
                                               VAR color:byte);
var

    r1,r2,r3,
    x1,x2       : real;
    xa,ya,
    xb,yb,
    xc,yc,y     : longint;
    xta,yta,
    xtb,ytb,
    xtc,ytc     : longint;
    E           : xedges;
    stepx,stepy,xt,yt : real;
    yd,xd             :integer;
    u1,v1,u2,v2, u3,v3:integer;

begin

      GetXTri( plist,T,E,ya,yb,yc);

      (*hier is het eigenlijke mappen van de texture in de driehoek*)
          (*
           stepx:=(E[yb].u2-E[yd].u1)/(E[yb].x2-E[yb].x1);
           stepy:=(E[yb].v2-E[yb].v1)/(E[yb].x2-E[yb].x1);
            *)
        for yd:=ya to yc do begin
            if not(E[yd].x1=E[yd].x2) then begin
                  stepx:=(E[yd].u2-E[yd].u1)/(E[yd].x2-E[yd].x1);
                  stepy:=(E[yd].v2-E[yd].v1)/(E[yd].x2-E[yd].x1);
                  xt:=E[yd].u1;
                  yt:=E[yd].v1;
                  for xd:=E[yd].x1 to E[yd].x2 do begin
                     page2^[yd,xd]:=page3^[round(yt),round(xt)];
                     xt:=xt+stepx;
                     yt:=yt+stepy;
                  end;
            end;
        end;
end; {texturetriangle}




Procedure FillTriangleZClipped(VAR plist:pointlist; T:Triangle);
var r1,r2,r3,
    r4,r5,r6,
    x1,x2,
    z1,z2       : real;

    xa,ya,za,
    xb,yb,zb,
    xc,yc,zc,

    y,temp      : longint;
    done        : boolean;



    procedure hlin(x1,y1,x2:integer;z1,z2:real);
    var i:integer;
        t:integer;
        r:real;
    begin
         if x1<0 then x1:=0;
         if x2<0 then x2:=0;
         if x1>319 then x1:=319;
         if x2>319 then x2:=319;
         if ((y1>0) and (y1<199)) and (x1<>x2) then
         begin
              r:=((z2-z1)/(x2-x1));
              for i:=x1 to x2 do begin
                 if z1<0 then page2^[y1,i]:=vgacolor;
                 z1:=z1+r;
              end;
              for i:=x2 to x1 do begin
                  if z2<0 then page2^[y1,i]:=vgacolor;
                  z2:=z2+r;
              end;
         end;
    end;


begin
     vgacolor:=t.color;
     xa:=(plist[t.p1].rotp[0]);
     ya:=(plist[t.p1].rotp[1]);
     za:=(plist[t.p1].rotp[2]);
     xb:=(plist[t.p2].rotp[0]);
     yb:=(plist[t.p2].rotp[1]);
     zb:=(plist[t.p2].rotp[2]);
     xc:=(plist[t.p3].rotp[0]);
     yc:=(plist[t.p3].rotp[1]);
     zc:=(plist[t.p3].rotp[2]);

     (*sorteren van klein naar groot ya=kleinste*)
     {we moeten hebben ya<=yb and yb<=yc}

     if ya>yb then
     begin
          temp:=ya;ya:=yb;yb:=temp; {swap(ya,yb)}
          temp:=xa;xa:=xb;xb:=temp;
          temp:=za;za:=zb;zb:=temp;
     end;
     if yb>yc then
     begin
          temp:=yb;yb:=yc;yc:=temp; {swap(yb,yc);}
          temp:=xb;xb:=xc;xc:=temp;
          temp:=zb;zb:=zc;zc:=temp;
     end;
     if ya>yb then
     begin
         temp:=ya;ya:=yb;yb:=temp; {swap(ya,yb);}
         temp:=xa;xa:=xb;xb:=temp;
         temp:=za;za:=zb;zb:=temp;
     end;

     if not(((ya=yb) or (ya=yc)) or (yb=yc)) then begin
          r1:=(xb-xa)/(yb-ya); (*richt co van ab*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          r3:=(xc-xa)/(yc-ya); (*richt co van ac*)
          x1:=xa;
          x2:=xa;

          r4:=(zb-za)/(yb-ya); (*z richt co van ab*)
          r5:=(zc-zb)/(yc-yb); (*z richt co van bc*)
          r6:=(zc-za)/(yc-ya); (*z richt co van ac*)
          z1:=za;
          z2:=za;
          for y:=ya to yb-1 do begin
              hlin(round(x1),y,round(x2),z1,z2);
              x1:=x1+r1;  (*x'en van ab*)
              x2:=x2+r3;  (*x'en van ac*)
              z1:=z1+r4;
              z2:=z2+r6;
          end;
          for y:=yb to yc do begin
              hlin(round(x1),y,round(x2),z1,z2);
              x1:=x1+r2;   (*x'en van bc*)
              x2:=x2+r3;   (*x'en van ac*)
              z1:=z1+r5;
              z2:=z2+r6;
          end;
     end
     else if (ya=yc) then begin
        hlin(xa,ya,xc,za,zc); (*drie combinaties mogelijk om driehoek te hebben dat een lijnstuk is*)
        hlin(xa,ya,xb,za,zb);
        hlin(xb,ya,xc,zb,zc);
        end
     else if (ya=yb) then begin  (* x coord van lijnstukken ac en bc op array zetten*)
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          x1:=xa;
          x2:=xb;

          r3:=(zc-za)/(yc-ya); (*richt co van ac*)
          r4:=(zc-zb)/(yc-yb); (*richt co van bc*)
          z1:=za;
          z2:=zb;
          for y:=ya to yc do begin
              hlin(round(x1),y,round(x2),z1,z2);
              x1:=x1+r1;
              x2:=x2+r2;
              z1:=z1+r3;
              z2:=z2+r4;
          end;
      end
     else begin
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xb-xa)/(yb-ya); (*richt co van ab*)
          x1:=xa;
          x2:=xa;

          r3:=(zc-za)/(yc-ya); (*richt co van ac*)
          r4:=(zb-za)/(yb-ya); (*richt co van ab*)
          z1:=za;
          z2:=za;
          for y:=ya to yc do begin
              hlin(round(x1),y,round(x2),z1,z2);
              x1:=x1+r1;
              x2:=x2+r2;
              z1:=z1+r3;
              z2:=z2+r4;
          end;
      end;
end; {FillTriangleZClipped}






Procedure VecMaalMat(v:vector ;m:matrix;var res:vector);
var i,j:INTEGER;
temp   :longint;
begin
 for i:=0 to 3 do begin
     res[i]:=0;
 end;
 temp:=0;
   for j:=0 TO 3 DO begin
     for i:=0 TO 3 DO begin
       temp:=round(v[i]*m[j,i]);
       res[j]:=res[j]+temp;
     end;
   end;
end; {vecmaalmat}

Procedure VecMaalMatNorm(v:normaal ;m:matrix;var res:normaal);
var i,j:INTEGER;
temp   :integer;
begin
 for i:=0 to 3 do begin
     res[i]:=0;
 end;
 temp:=0;
   for j:=0 TO 3 DO begin
     for i:=0 TO 3 DO begin
       temp:=round(v[i]*m[j,i]);
       res[j]:=res[j]+temp;
     end;
   end;
end; {vecmaalmatnorm}

Procedure MatMaalMat(m1,m2:matrix; VAR res:matrix);
var i,j,k:INTEGER;
    hulp: real;
BEGIN
 for i:=0 to 3 do begin
  for j:=0 to 3 do begin
   res[i,j]:=0;
  end;
 end;
 hulp:=0;
 for i:=0 to 3 do begin
  for j:=0 to 3 do begin
   for k:=0 to 3 do begin
     hulp:=m1[i,k]*m2[k,j];
     res[i,j]:=res[i,j]+hulp;
   end;
  end;
 end;
end; {matmaalmat}

procedure putpoint(VAR plist:pointlist; punt:Point);
BEGIN
  if plast<maxpoints then begin
   plist[plast]:=punt;
   plast:=plast+1;
  end;
end; { putpoint}

procedure putedge(VAR elist:edgelist; e:edge);
begin
 if elast<maxedge then begin
   elist[elast]:=e;
   elast:=elast+1;
 end;
end;



{
procedure StandHom(VAR v:vector);
VAR i:integer;
begin
  for i:=0 TO 2 do begin
   v[i]:=round((v[i] / v[3])*256);
  end;
  v[3]:=1;
end;
}




procedure remove(var v:vertexp);
var temp:vertexp;
		loper:vertexp;
begin

 	while v<>nil do
 	begin
    new(temp);
 		temp:=v;
    dispose(temp);
 		v:=v^.next;
 	end;
end;

procedure removenorms;
var i:integer;
temp:vertexp;
begin
	for i:=0 to tlast-1 do
  begin
  	remove(tlist[i].vertexp1);
		remove(tlist[i].vertexp2);
		remove(tlist[i].vertexp3);
  end;
end;


{we gaan voor elk hoekpunt van een driehoek al de normalen bijhouden van
de driehoeken die dat punt ook bevatten hiervoor zal een gemiddelde color
kunnen berkent worden voor gouraud shading, ofwel phong shading is nu
ook mogelijk (dan wordt gemiddelde normaal gebruikt)}
procedure calcnorms;
var
		i,j,k,
		vertex	: integer;
    loper1,
		loper2,
		loper3	: vertexp;
	{function aanliggend(ta,tb:triangle;var vertex:integer):boolean;
  var k:byte;
  begin
  	k:=0;
  	if (ta.p1=tb.p1) then begin inc(k); vertex:=1; end;
    if (ta.p1=tb.p2) then begin inc(k); vertex:=1; end;
		if (ta.p1=tb.p3) then begin inc(k); vertex:=1; end;
		if (ta.p2=tb.p1) then begin inc(k); vertex:=2; end;
		if (ta.p2=tb.p2) then begin inc(k); vertex:=2; end;
		if (ta.p2=tb.p3) then begin inc(k); vertex:=2; end;
		if (ta.p3=tb.p1) then begin inc(k); vertex:=3; end;
		if (ta.p3=tb.p2) then begin inc(k); vertex:=3; end;
		if (ta.p3=tb.p3) then begin inc(k); vertex:=3; end;

  	if k>1 then aanliggend:=true  {enkel aanliggende}
    {else aanliggend:=false;

  end; }
  function samevertex(vertex:integer; t:triangle ):boolean;
  var temp:boolean;
  begin
  		temp:=false;
  		if (vertex=t.p1) then begin temp:=true; end;
      if (vertex=t.p2) then begin temp:=true; end;
		  if (vertex=t.p3) then begin temp:=true; end;
  		samevertex:=temp;
  end;


begin
  {alles initialiseren}
  {removenorms;}
  for i:=0 to tlast-1 do
  begin
    new(tlist[i].vertexp1);
    new(tlist[i].vertexp2);
		new(tlist[i].vertexp3);
  end;
	for i:=0 to tlast-1 do
  begin
    loper1:=tlist[i].vertexp1;
    loper2:=tlist[i].vertexp2;
    loper3:=tlist[i].vertexp3;
    {nu voor elke vertex normaal zijn driehoeken vinden}
  	for j:=1 to tlast-1 do
    begin
			if samevertex(tlist[i].p1,tlist[(i+j)mod tlast]) then
		  begin
				loper1^.t:=(i+j)mod tlast;
				new(loper1^.next);
        loper1:=loper1^.next;
			end;

			if samevertex(tlist[i].p2,tlist[(i+j)mod tlast]) then
			begin
      	loper2^.t:=(i+j)mod tlast;
				new(loper2^.next);
        loper2:=loper2^.next;
			end;

			if samevertex(tlist[i].p3,tlist[(i+j)mod tlast]) then
			begin
      	loper3^.t:=(i+j)mod tlast;
				new(loper3^.next);
        loper3:=loper3^.next;
			end;
    end;
  end;
end;


procedure GetNormaal(a,b,c:vector ;VAR N:normaal);
var afstand:real;
    i:integer;
begin
  N[0]:=-( ((b[1]-a[1])*(c[2]-a[2])) - ((c[1]-a[1])*(b[2]-a[2])) );
  N[1]:= ( ((b[0]-a[0])*(c[2]-a[2])) - ((c[0]-a[0])*(b[2]-a[2])) );
  N[2]:=-( ((b[0]-a[0])*(c[1]-a[1])) - ((c[0]-a[0])*(b[1]-a[1])) );
  (*in homogene coordinaat steken we de lengte van deze normaal*)
  afstand:=SQRT((N[0]*N[0])+(N[1]*N[1])+(N[2]*N[2]));
  for i:=0 to 2 do begin
    n[i]:=round((n[i]/afstand)*100); (*we leggen punten tussen 0 en 100*)
  end;
  n[3]:=1;
end; {getnormaal}


procedure puttriangle(VAR plist:pointlist;
                          VAR tlist: trilist; ptri:Triangle);

begin
  if tlast<maxtriangle then begin
     GetNormaal(plist[ptri.p1].p,plist[ptri.p2].p,plist[ptri.p3].p,ptri.normaal);
     tlist[tlast]:=ptri;
     tlast:=tlast+1;
  end;
end;{puttriangle}


procedure Inittables;
var i:byte;
begin
 for i:=0 to 255 do begin
  SINUS[i]:=( Sin((Pi/128)*i));
  COSIN[i]:=( Cos((Pi/128)*i));
  SINT[i]:= round( Sin((Pi/128)*i)*256);
  COST[i]:= round( Cos((Pi/128)*i)*256);
  end;
end;



procedure ActiveRotZ(hoek:byte;VAR m:matrix);
begin
  m[0,0]:=COSIN[hoek]; m[0,1]:=-SINUS[hoek]; m[0,2]:=0; m[0,3]:=0;
  m[1,0]:=SINUS[hoek]; m[1,1]:=COSIN[hoek]; m[1,2]:=0; m[1,3]:=0;
  m[2,0]:=0          ; m[2,1]:=0          ; m[2,2]:=1; m[2,3]:=0;
  m[3,0]:=0          ; m[3,1]:=0          ; m[3,2]:=0; m[3,3]:=1;
end;

procedure ActiveRotX(hoek:byte;VAR m:matrix);
begin
  m[0,0]:=1;    m[0,1]:=0;  m[0,2]:=0;  m[0,3]:=0;
  m[1,0]:=0;    m[1,1]:=COSIN[hoek]; m[1,2]:=-SINUS[hoek]; m[1,3]:=0;
  m[2,0]:=0;    m[2,1]:=SINUS[hoek]; m[2,2]:=COSIN[hoek]; m[2,3]:=0;
  m[3,0]:=0;    m[3,1]:=0;           m[3,2]:=0;         m[3,3]:=1;
end;

procedure ActiveRotY(hoek:byte;VAR m:matrix);
begin
  m[0,0]:=COSIN[hoek];  m[0,1]:=0;  m[0,2]:=SINUS[hoek]; m[0,3]:=0;
  m[1,0]:=0;            m[1,1]:=1;   m[1,2]:=0;           m[1,3]:=0;
  m[2,0]:=-SINUS[hoek]; m[2,1]:=0;   m[2,2]:=COSIN[hoek]; m[2,3]:=0;
  m[3,0]:=0;    m[3,1]:=0;           m[3,2]:=0;         m[3,3]:=1;
end;


procedure makepoint(x,y,z:longint; VAR punt:Point);
begin
 punt.p[0]:=x;
 punt.p[1]:=y;
 punt.p[2]:=z;
 Punt.p[3]:=1;
end; {makepoint}


procedure maketriangle(bitmap:byte;a,b,c:integer; var t:triangle);
const ytop=40;
begin
     t.p1:=a;
     t.p2:=b;
     t.p3:=c;
     if bitmap=1 then begin
      t.u1:=0   ; t.v1:=0;
      t.u2:=0   ; t.v2:=159;
      t.u3:=319  ; t.v3:=0 ;
      end
     else begin
      t.u1:=0  ; t.v1:=159 ;
      t.u2:=319 ; t.v2:=159 ;
      t.u3:=319 ; t.v3:=0 ;
     end;

end;

procedure InitCube(VAR plist:pointlist; VAR tlist:trilist);
var punt,punt1,punt2,punt3:Point;
    t:Triangle;
    i:integer;
begin
 makepoint(0,100,100,punt);
 putpoint(plist,punt);
 makepoint(0,0,100,punt);
 putpoint(plist,punt);
 makepoint(100,0,100,punt);
 putpoint(plist,punt);
 makepoint(100,100,100,punt);
 putpoint(plist,punt);
 makepoint(0,100,0,punt);
 putpoint(plist,punt);
 makepoint(0,0,0,punt);
 putpoint(plist,punt);
 makepoint(100,0,0,punt);
 putpoint(plist,punt);
 makepoint(100,100,0,punt);
 putpoint(plist,punt);
 for i:=0 to plast-1 do begin
     plist[i].p[0]:=plist[i].p[0]-50;
     plist[i].p[1]:=plist[i].p[1]-50;
     plist[i].p[2]:=plist[i].p[2]-50;
 end;

 maketriangle(1,0,1,3,t);    (*achter*)
 puttriangle(plist,tlist,t);

 maketriangle(2,1,2,3,t);      (**)
 puttriangle(plist,tlist,t);

 maketriangle(1,3,2,7,t);       (*rechts*)
 puttriangle(plist,tlist,t);

 maketriangle(2,2,6,7,t);
 puttriangle(plist,tlist,t);

 maketriangle(1,7,6,4,t);    (*voorvlak*)
 puttriangle(plist,tlist,t);

 maketriangle(2,6,5,4,t);    (**)
 puttriangle(plist,tlist,t);

 maketriangle(2,5,1,0,t);     (*links*)
 puttriangle(plist,tlist,t);

 maketriangle(1,4,5,0,t);
 puttriangle(plist,tlist,t);

 maketriangle(2,0,3,7,t);     (*boven*)
 puttriangle(plist,tlist,t);

 maketriangle(1,4,0,7,t);
 puttriangle(plist,tlist,t);

 maketriangle(1,1,5,2,t);     (*onder *)
 puttriangle(plist,tlist,t);

 maketriangle(2,5,6,2,t);
 puttriangle(plist,tlist,t);

end;{initcube:)}



{ hier is iets eigenaardigs aan de hand ik mag geen var nemen voor plist
   er wordt een bepaald punt verandert!!! waaakooooo maarja zo werkt het
   nadeel plist zal helemaal op stack gezet worden kan voor stack overflow
   zorgen dus zorg dat je stack memory goed hoog zet :)
	blijkbaar is het probleem bij BORLAND PASCAL opgelost :)
}
procedure BuildEdges(VAR tlist:trilist;VAR elist:edgelist;var plist:pointlist);

  function samepoints(a,b:integer):boolean;
  var j   :integer;
      hulp:boolean;
  begin
   hulp:=true;
   j:=0;
   while (j<=2) and hulp do begin
     if plist[a].p[j]<>plist[b].p[j] then begin
        hulp:=false;
     end;
     j:=j+1;
   end;
   samepoints:=hulp;
  end; {samepoints}


  function Duplicate(e:edge; var dupplaats:integer):boolean;
  var j    : integer;
      hulp : boolean;
  begin
    j:=0;
    hulp:=false;
    while ((j<=elast-1) and (not hulp)) do begin
        if samepoints(elist[j].pa,e.pa) then begin
          if samepoints(elist[j].pb,e.pb) then begin
            hulp:=true;
            dupplaats:=j;
          end;
        end;
        if samepoints(elist[j].pa,e.pb) then begin
          if samepoints(elist[j].pb,e.pa) then begin
            hulp:=true;
            dupplaats:=j;
          end;
        end;
      j:=j+1;
    end;
    duplicate:=hulp;
  end; {duplicate}


  function samenorm(a,b:normaal):boolean;
  var i    :integer;
      done :boolean;
  begin
    i:=0;
    done:=true;
    while (i<=3) and (done) do begin
      if abs(abs(a[i])-abs(b[i])) > 2 then done:=false;
      i:=i+1;
    end;
    samenorm:=done;
  end; {samenorm}


var i,dupplaats:integer;
    e:edge;
begin
 for i:=0 to tlast-1 do begin
   e.pa:=tlist[i].p1;
   e.pb:=tlist[i].p2;
   e.t1:=i;
   e.t2:=-1;
   e.internal:=false;
   if duplicate(e,dupplaats) then begin
     elist[dupplaats].t2:=e.t1;
     if samenorm(tlist[elist[dupplaats].t1].normaal,tlist[elist[dupplaats].t2].normaal) then begin
        elist[dupplaats].internal:=true;
     end;
    end
   else begin
     putedge(elist,e);
   end;
   e.pa:=tlist[i].p2;
   e.pb:=tlist[i].p3;
   e.t1:=i;
   e.t2:=-1;
   e.internal:=false;
   if duplicate(e,dupplaats) then begin
     elist[dupplaats].t2:=e.t1;
     if samenorm(tlist[elist[dupplaats].t1].normaal,tlist[elist[dupplaats].t2].normaal) then begin
        elist[dupplaats].internal:=true;
     end;
    end
   else begin
     putedge(elist,e);
   end;
   e.pa:=tlist[i].p3;
   e.pb:=tlist[i].p1;
   e.t1:=i;
   e.t2:=-1;
   e.internal:=false;
   if duplicate(e,dupplaats) then begin
     elist[dupplaats].t2:=e.t1;
     if samenorm(tlist[elist[dupplaats].t1].normaal,tlist[elist[dupplaats].t2].normaal) then begin
        elist[dupplaats].internal:=true;
     end;
    end
   else begin
     putedge(elist,e);
   end;
 end;
end; {buildedges}

function verschillend(a,b:vector):boolean;
var i:integer;
    hulp:boolean;
begin
  hulp:=false;
  for i:=0 to 3 do begin
     if a[i]<>b[i] then hulp:=true;
  end;
  verschillend:=hulp;
end;



PROCEDURE buildtriangles(VAR plist:pointlist; aantal:integer;
                                              VAR tlist:trilist);
VAR loper,daar2,daar,welkvlak,i:integer;
    Tvlak1,Tvlak2:Triangle;
    done:boolean;
begin
 welkvlak:=1;
 loper:=0;
 done:=false;
 while not done do begin
  if (welkvlak mod aantal)<>0 THEN begin
   daar2:=loper+aantal;
   if (daar2 > (plast-1)) or ((daar2+1)>(plast-1)) then begin
     done:=true;
   end;
   if not done then begin
      if verschillend(plist[loper].p,plist[daar2+1].p)
         and verschillend(plist[daar2].p,plist[daar2+1].p)
         and verschillend(plist[daar2].p,plist[loper].p) then begin
           Tvlak1.p1:=loper;
           Tvlak1.p3:=daar2+1;
           Tvlak1.p2:=daar2;
           puttriangle(plist,tlist,Tvlak1);
      end;
      if verschillend(plist[loper].p,plist[loper+1].p)
         and verschillend(plist[daar2+1].p,plist[loper+1].p)
         and verschillend(plist[daar2].p,plist[loper+1].p) then begin
           Tvlak2.p1:=loper;
           Tvlak2.p3:=loper+1;
           Tvlak2.p2:=daar2+1;
           puttriangle(plist,tlist,Tvlak2);
      end;
    end;{if not done}
   end; {if welkvlak}
    inc(welkvlak,1);
    inc(loper,1);
 end; {while}
 (*laatste schil nog*)
 for i:=0 to aantal-2 do begin
     Tvlak1.p1:=(plast-aantal)+i;
     Tvlak1.p3:=(plast-aantal)+1+i;
     Tvlak1.p2:=i;
     puttriangle(plist,tlist,Tvlak1);
     Tvlak1.p1:=i;
     Tvlak1.p2:=1+i;
     Tvlak1.p3:=(plast-aantal)+1+i;
     puttriangle(plist,tlist,Tvlak1);
 end;
end;


procedure triangletextco(var t:triangle);
const ytop=40;
begin
  {
     if bitmap=1 then begin
      t.u1:=60   ; t.v1:=100 ;
      t.u2:=60   ; t.v2:=140 ;
      t.u3:=180  ; t.v3:=100 ;
      end
     else begin
      t.u1:=30  ; t.v1:=155+ytop ;
      t.u2:=180 ; t.v2:=155+ytop ;
      t.u3:=180 ; t.v3:=0+ytop ;
     end;}

end;

procedure puttextureobject(var tlist:trilist);
var i:integer;
begin
     for i:=0 to tlast-1 do begin
        triangletextco(tlist[i]);
     end;
end;


PROCEDURE putcircle(VAR plist:pointlist);
var i:integer;
    c:point;
begin
  i:=255;
  while i>=10 do begin
     makepoint(round((SINUS[i]*60)+120),round(COSIN[i]*60),0,c);
     putpoint(plist,c);
     dec(i,26);
  end;
  putpoint(plist,plist[0]);
end;

PROCEDURE maketorus(var plist:pointlist;var tlist:trilist);
var i,j,k,schil:integer;
    m:matrix;
    temp:point;
begin
 putcircle(plist);
 schil:=plast;
 i:=26;        {26 is mooier}
 while i<255 do begin
   ActiveRotY(i,m);
   for j:=0 to schil-1 do begin
     vecmaalmat(plist[j].p,m,temp.p);
     putpoint(plist,temp);
   end;
   inc(i,26);
 end;

 buildtriangles(plist,schil,tlist);
end;



PROCEDURE putcigarette(VAR plist:pointlist);
var
    c:point;
begin
     (*geef punten in clockwize van onder naar boven*)
     makepoint(-1,-100,0,c);
     putpoint(plist,c);

     makepoint(-20,-100,0,c);
     putpoint(plist,c);

     makepoint(-20,100,0,c);
     putpoint(plist,c);


     makepoint(-1,100,0,c);
     putpoint(plist,c);


     (*putpoint(plist,plist[0]); *)
end;

PROCEDURE makecigarette(var plist:pointlist;var tlist:trilist);
var i,j,k,schil:integer;
    m:matrix;
    temp:point;
begin
 putcigarette(plist);
 elast:=1;
 schil:=plast;
 i:=26  ;
 while i<255 do begin
   ActiveRotY(i,m);
   for j:=0 to schil-1 do begin
     vecmaalmat(plist[j].p,m,temp.p);
     putpoint(plist,temp);
   end;
   inc(i,26);
 end;

 buildtriangles(plist,schil,tlist);
end;




PROCEDURE putbeker(VAR plist:pointlist);
var
    c:point;
begin
     (*geef punten in clockwize van onder naar boven*)
     makepoint(-1,0,0,c);
     putpoint(plist,c);

     makepoint(-50,0,0,c);
     putpoint(plist,c);

     makepoint(-10,10,0,c);
     putpoint(plist,c);

     makepoint(-10,70,0,c);
     putpoint(plist,c);

     makepoint(-30,70,0,c);
     putpoint(plist,c);

     makepoint(-50,90,0,c);
     putpoint(plist,c);

     makepoint(-50,120,0,c);
     putpoint(plist,c);

     makepoint(-40,120,0,c);
     putpoint(plist,c);

     makepoint(-40,100,0,c);
     putpoint(plist,c);

     makepoint(-20,80,0,c);
     putpoint(plist,c);

     makepoint(-1,80,0,c);
     putpoint(plist,c);


     (*putpoint(plist,plist[0]); *)
end;

PROCEDURE makebeker(var plist:pointlist;var tlist:trilist);
var i,j,k,schil:integer;
    m:matrix;
    temp:point;
begin
 putbeker(plist);
 (*beetje korrigeren*)
 for i:=0 to plast-1 do begin
     plist[i].p[1]:=plist[i].p[1]-60; (*zet centrum rot in midden*)
 end;
 elast:=1;
 schil:=plast;
 i:=26  ;
 while i<255 do begin
   ActiveRotY(i,m);
   for j:=0 to schil-1 do begin
     vecmaalmat(plist[j].p,m,temp.p);
     putpoint(plist,temp);
   end;
   inc(i,26);
 end;
 buildtriangles(plist,schil,tlist);
end;




procedure putwalle2(var plist:pointlist;var elist:edgelist; var tlist:trilist);
const
objpoints : ARRAY [0..67] OF point =
((p:(40,63,0,1)),
(p:(40,114,0,1)),
(p:(40,114,0,1)),
(p:(87,114,0,1)),
(p:(87,114,0,1)),
(p:(87,76,0,1)),
(p:(87,76,0,1)),
(p:(235,76,0,1)),
(p:(40,62,0,1)),
(p:(58,62,0,1)),
(p:(58,62,0,1)),
(p:(58,94,0,1)),
(p:(59,74,0,1)),
(p:(72,74,0,1)),
(p:(73,63,0,1)),
(p:(73,101,0,1)),
(p:(73,62,0,1)),
(p:(254,62,0,1)),
(p:(254,62,0,1)),
(p:(235,75,0,1)),
(p:(124,76,0,1)),
(p:(124,136,0,1)),
(p:(124,136,0,1)),
(p:(106,136,0,1)),
(p:(106,136,0,1)),
(p:(106,97,0,1)),
(p:(88,114,0,1)),
(p:(105,114,0,1)),
(p:(102,85,0,1)),
(p:(111,85,0,1)),
(p:(111,85,0,1)),
(p:(111,89,0,1)),
(p:(111,89,0,1)),
(p:(102,89,0,1)),
(p:(102,89,0,1)),
(p:(102,85,0,1)),
(p:(140,77,0,1)),
(p:(140,103,0,1)),
(p:(140,103,0,1)),
(p:(162,97,0,1)),
(p:(162,97,0,1)),
(p:(162,113,0,1)),
(p:(162,113,0,1)),
(p:(124,113,0,1)),
(p:(156,77,0,1)),
(p:(156,97,0,1)),
(p:(171,77,0,1)),
(p:(171,101,0,1)),
(p:(171,101,0,1)),
(p:(191,94,0,1)),
(p:(191,94,0,1)),
(p:(191,113,0,1)),
(p:(191,113,0,1)),
(p:(163,113,0,1)),
(p:(188,77,0,1)),
(p:(188,94,0,1)),
(p:(235,77,0,1)),
(p:(235,85,0,1)),
(p:(235,85,0,1)),
(p:(210,85,0,1)),
(p:(215,86,0,1)),
(p:(215,96,0,1)),
(p:(211,97,0,1)),
(p:(236,97,0,1)),
(p:(236,97,0,1)),
(p:(258,114,0,1)),
(p:(258,114,0,1)),
(p:(188,114,0,1)));


objedges : ARRAY [0..33,0..1] OF integer =
((0,1),
(2,3),
(4,5),
(6,7),
(8,9),
(10,11),
(12,13),
(14,15),
(16,17),
(18,19),
(20,21),
(22,23),
(24,25),
(26,27),
(28,29),
(30,31),
(32,33),
(34,35),
(36,37),
(38,39),
(40,41),
(42,43),
(44,45),
(46,47),
(48,49),
(50,51),
(52,53),
(54,55),
(56,57),
(58,59),
(60,61),
(62,63),
(64,65),
(66,67));


nrpoints=67;
nredges=33 ;

var i:integer;
    e:edge;
    p:point;
begin
     for i:=0 to nrpoints do begin
         putpoint(plist,objpoints[i]);
     end;
     {centrum rotatie zetten}
     for i:=0 to plast-1 do begin
         plist[i].p[0]:=plist[i].p[0]-145;
         plist[i].p[1]:=plist[i].p[1]-90;
      end;

     for i:=0 to nredges do begin
         e.pa:=objedges[i,0];
         e.pb:=objedges[i,1];
         e.internal:=false;
         putedge(elist,e);
     end;

        {een plat vlak wordt gekopierd en verschoven}
   for i:=0 to plast-1 do begin
       p:=plist[i];
       plist[i].p[2]:=-10;
       p.p[2]:=10;
       putpoint(plist,p);
   end;
   for i:=0 to nredges do begin
         e.pa:=objedges[i,0]+nrpoints+1;
         e.pb:=objedges[i,1]+nrpoints+1;
         e.internal:=false;
         putedge(elist,e);
     end;
   {nu gaan we de twee vlakken verbinden met edges}
   for i:=0 to nredges do begin
       e.pa:=elist[i].pa;
       e.pb:=elist[i+nredges+1].pa;
       e.internal:=false;
       putedge(elist,e);
       e.pa:=elist[i].pb;
       e.pb:=elist[i+nredges+1].pb;
       e.internal:=false;
       putedge(elist,e);
   end;
end;


procedure project(var plist:pointlist;var elist:edgelist;var tlist:trilist);
var i:integer;
    p:point;
begin
   {een plat vlak wordt gekopierd en verschoven}
   for i:=0 to plast-1 do begin
       p:=plist[i];
       plist[i].p[2]:=-20;
       p.p[2]:=20;
       putpoint(plist,p);
   end;
end;



procedure rotedges(var plist:pointlist;
                        var elist:edgelist;
                        var tlist:trilist;
                        hoekx,hoeky,hoekz:byte);
var
    m1,m2,m3,m:matrix;
    temp:longint;
    i:integer;
    tempcol:integer;
begin
  ActiveRotx(hoekx,m1);
  ActiveRoty(hoeky,m2);
  ActiveRotz(hoekz,m3);
  Matmaalmat(m2,m1,m);
  Matmaalmat(m3,m,m);
  for i:= 0 to plast-1 do begin
      vecmaalmat(plist[i].p,m,plist[i].rotp);
      plist[i].rotp[0]:=(plist[i].rotp[0]*SizeX)div(plist[i].rotp[2]+350) +160;
      plist[i].rotp[1]:=(plist[i].rotp[1]*SizeY)div(plist[i].rotp[2]+350) +100;
      (*die laatste +300 en +200 zijn voor verschuiving!*)
  end;
  for i:=0 to tlast-1 do begin
      vecmaalmatnorm(tlist[i].normaal,m,tlist[i].rnormaal);
      (*we nemen even gewogen gemiddelde van z waardes oops quicksort
      sorteert verkeert om oh wel we zetten er maar een minneke voor :)*)
      tlist[i].middenz:=-(plist[tlist[i].p1].rotp[2]+
                         plist[tlist[i].p2].rotp[2]+
                          plist[tlist[i].p3].rotp[2]);

      tlist[i].color:=round(tlist[i].rnormaal[2]*254); {(i mod 4)+1;}

  end;
  for i:=0 to elast-1 do begin
      elist[i].middenz:=plist[elist[i].pa].rotp[2]+
                           plist[elist[i].pb].rotp[2];
      if (elist[i].t2>-1) then begin
        tempcol:=127+round((tlist[elist[i].t1].rnormaal[2]*127));
        if tlist[elist[i].t2].rnormaal[2]>0 then begin
           tempcol:=tempcol+(127+round((tlist[elist[i].t2].rnormaal[2]*127)));
           tempcol:=tempcol div 2;
        end;
        elist[i].color:=tempcol;
       end
      else begin
       elist[i].color:=0; {round((tlist[elist[i].t1].rnormaal[2]*15));}
      end;
  end;
end;{rotedges}



function clockwize(t:triangle):boolean;
var xa,ya,xb,yb,xc,yc:integer;
begin
	xa:=plist[t.p1].rotp[0];
	ya:=plist[t.p1].rotp[1];
	xb:=plist[t.p2].rotp[0];
	yb:=plist[t.p2].rotp[1];
	xc:=plist[t.p3].rotp[0];
	yc:=plist[t.p3].rotp[1];
  clockwize:=(xb*yc-yb*xc-xa*yc+ya*xc+xa*yb-ya*xb)<=0;
end;


procedure Rotfast(var plist:pointlist;
                  var tlist:trilist;
                  hoekx,hoeky,hoekz:byte);
const
   FixPoint=255;
var

   Ai,Bi,Ci,
   Di,Ei,Fi,
   Gi,Hi,Ii,
   i,tempcol : integer;

begin
   (*doin it the fast way with 9 multiplies! *)
  Ai:=round(COSIN[hoekz]*COSIN[hoeky]*FixPoint);
  Bi:=round(SINUS[hoekz]*COSIN[hoeky]*FixPoint);
  Ci:=round(-SINUS[hoeky]*FixPoint);
  Di:=round(((SINUS[hoekx]*SINUS[hoeky]*COSIN[hoekz])-(COSIN[hoekx]*SINUS[hoekz]))*FixPoint);
  Ei:=round(((SINUS[hoekx]*SINUS[hoeky]*SINUS[hoekz])+(COSIN[hoekx]*COSIN[hoekz]))*FixPoint);
  Fi:=round(SINUS[hoekx]*COSIN[hoeky]*FixPoint);
  Gi:=round(((COSIN[hoekx]*SINUS[hoeky]*COSIN[hoekz])+(SINUS[hoekx]*SINUS[hoekz]))*FixPoint);
  Hi:=round(((COSIN[hoekx]*SINUS[hoeky]*SINUS[hoekz])-(SINUS[hoekx]*COSIN[hoekz]))*FixPoint);
  Ii:=round(COSIN[hoekx]*COSIN[hoeky]*FixPoint);

   (*x y and z rotation in once!!!*)

   for i:= 0 to plast-1 do begin
      plist[i].rotp[0]:=(Ai*plist[i].p[0]+(Bi*plist[i].p[1])+(Ci*plist[i].p[2]))div fixpoint;
      plist[i].rotp[1]:=(Di*plist[i].p[0]+(Ei*plist[i].p[1])+(Fi*plist[i].p[2]))div fixpoint;
      plist[i].rotp[2]:=(Gi*plist[i].p[0]+(Hi*plist[i].p[1])+(Ii*plist[i].p[2]))div fixpoint;

      plist[i].rotp[0]:=(plist[i].rotp[0]*SizeX) div (plist[i].rotp[2]+350) + CenterX;
      plist[i].rotp[1]:=(plist[i].rotp[1]*SizeY) div (plist[i].rotp[2]+350) + CenterY;


      (*die laatste +centerx en +centery zijn voor verschuiving!*)
  end;
   for i:=0 to tlast-1 do begin
   	if clockwize(tlist[i]) then
    begin
      tlist[i].visable:=true;
      tlist[i].rnormaal[2]:=(Gi*tlist[i].normaal[0])+(Hi*tlist[i].normaal[1])+(Ii*tlist[i].normaal[2]);
       (*we nemen even gewogen gemiddelde van z waardes *)
      tlist[i].middenz:=plist[tlist[i].p1].rotp[2]+
                         plist[tlist[i].p2].rotp[2]+
                          plist[tlist[i].p3].rotp[2];

      tempcol:=tlist[i].rnormaal[2] div 100;
      if tempcol>255 then tlist[i].color:=255
      else if tempcol<0 then tlist[i].color:=0
      else tlist[i].color:=tempcol;
  	end
    else tlist[i].visable:=false;
  end;
end; (*rotfast*)




procedure tekenobject(VAR plist:pointlist;var tlist:trilist);
var i:integer;
begin
   for i:=0 to tlast-1 do begin
    if  tlist[i].visable THEN
    FillTriangle(plist,tlist[i]);
  end;
end;


procedure tekenclipped(VAR plist:pointlist;var tlist:trilist);
var i:integer;
begin
   for i:=0 to tlast-1 do begin
    if tlist[i].visable THEN
    FillTriangleClipped(plist,tlist[i]);
  end;
end;


procedure tekengouraud(VAR plist:pointlist;var tlist:trilist);
var i:integer;
begin
   for i:=0 to tlast-1 do begin
    if  tlist[i].visable THEN
    FillTriangleGouraud(plist,tlist[i]);
  end;
end;


procedure tekenZclipped(VAR plist:pointlist;var tlist:trilist);
var i:integer;
begin
   for i:=0 to tlast-1 do begin
    if tlist[i].visable THEN
    FillTriangleclipped(plist,tlist[i]);
  end;
end;

procedure tekentextobject(VAR plist:pointlist;var tlist:trilist);
var i:integer;
begin
   for i:=0 to tlast-1 do begin
    if tlist[i].visable THEN
       texturetriangle(plist,tlist[i],tlist[i].color);
  end;
end;



function max(a,b:integer):integer;
begin
     if a>b then max:=a
     else max:=b;
end;

function min(a,b:integer):integer;
begin
     if a<b then min:=a
     else min:=b;
end;


procedure clippedline(xa,ya,xb,yb:integer);
begin
     if (max(xa,xb)<320) and (min(xa,xb)>=0)
        and (max(ya,yb)<200) and (min(ya,yb)>=0) then linepage2(xa,ya,xb,yb);
end;

procedure tekenedges(var plist:pointlist;var elist:edgelist;var tlist:trilist);
var i:integer;
    x1,y1,x2,y2:integer;
    tempcol:integer;
begin
   for i:=0 to elast-1 do begin
     if not(elist[i].internal) then begin
       x1:=plist[elist[i].pa].rotp[0];
       y1:=plist[elist[i].pa].rotp[1];
       x2:=plist[elist[i].pb].rotp[0];
       y2:=plist[elist[i].pb].rotp[1];

       tempcol:=(-(elist[i].middenz div 2)+170);
       if tempcol>255 then vgacolor:=255
       else if tempcol<0 then vgacolor:=0
       else vgacolor:=tempcol;
       {linepage2(x1,y1,x2,y2);}
       clippedline(x1,y1,x2,y2);
     end;
   end;
end;



PROCEDURE WaitVBL;
 var i:integer;

    label l1,l2;
begin
    Asm
               mov  dx,3dah
            l1:
               in   al,dx
               and  al,08h
               jnz  l1
            l2:
              in   al,dx
              and  al,08h
              jz   l2
          End;
end; {WaitVbl}

procedure RotateFillObject;
var x,y,z:byte;
    a,b,c:integer;
begin
   x:=0;
   y:=0;
   z:=0;
   a:=1;
   b:=1;
   c:=1;
   repeat
       clrpage2scr;
       tekenclipped(plist,tlist);
       vsync;
       copyfrompage2;
       x:=x+a;
       y:=y+b;
       z:=z+c;
       rotfast(plist,tlist,x,y,z);
       quicksortTriangles(tlist,0,tlast-1);
       if key[scR] then inc(a);
       if key[scT] then inc(b);
       if key[scY] then inc(c);
       if key[scF] then dec(a);
       if key[scG] then dec(b);
       if key[scH] then dec(c);
       if key[scEnter] then begin
          a:=0;
          b:=0;
          c:=0;
       end;
       if key[scRShift] then begin
          x:=0;
          y:=0;
          z:=0;
       end;
   until key[scSpace];
   repeat
   until not key[scSpace];
end; (*rotatefillobject*)






procedure RotateGouraud;
var x,y,z:byte;
    a,b,c:integer;
begin
   x:=0;
   y:=0;
   z:=0;
   a:=1;
   b:=1;
   c:=1;
   repeat
       clrpage2scr;
       tekengouraud(plist,tlist);
 {      vsync;}
       copyfrompage2;
       x:=x+a;
       y:=y+b;
       z:=z+c;
       rotfast(plist,tlist,x,y,z);
       quicksortTriangles(tlist,0,tlast-1);
       if key[scR] then inc(a);
       if key[scT] then inc(b);
       if key[scY] then inc(c);
       if key[scF] then dec(a);
       if key[scG] then dec(b);
       if key[scH] then dec(c);
       if key[scEnter] then begin
          a:=0;
          b:=0;
          c:=0;
       end;
       if key[scRShift] then begin
          x:=0;
          y:=0;
          z:=0;
       end;
   until key[scSpace];
   repeat
   until not key[scSpace];
end; (*rotatefillobject*)


procedure RotateFillObjectFast;
var x,y,z:byte;
    a,b,c:integer;
begin
   x:=0;
   y:=0;
   z:=0;
   a:=1;
   b:=1;
   c:=1;
   repeat
       clrpage2scr;
       tekenobject(plist,tlist);
       vsync;
       copyfrompage2;
       x:=x+a;
       y:=y+b;
       z:=z+c;
       rotfast(plist,tlist,x,y,z);
       quicksortTriangles(tlist,0,tlast-1);
       if key[scR] then inc(a);
       if key[scT] then inc(b);
       if key[scY] then inc(c);
       if key[scF] then dec(a);
       if key[scG] then dec(b);
       if key[scH] then dec(c);
       if key[scEnter] then begin
          a:=0;
          b:=0;
          c:=0;
       end;
       if key[scRShift] then begin
          x:=0;
          y:=0;
          z:=0;
       end;
   until key[scSpace];
   repeat
   until not key[scSpace];
end; (*rotatefillobjectfast*)


procedure RotateTextObject;
var x,y,z:byte;
    a,b,c:integer;
    i,j:integer;
begin
   x:=0;
   y:=0;
   z:=256 div 2;
   a:=1;
   b:=1;
   c:=1;
   repeat
       clrpage2scr;
       tekentextobject(plist,tlist);
       copyfrompage2;
       x:=x+a;
       y:=y+b;
       z:=z+c;
       rotfast(plist,tlist,x,y,z);
       quicksortTriangles(tlist,0,tlast-1);
       if key[scR] then inc(a);
       if key[scT] then inc(b);
       if key[scY] then inc(c);
       if key[scF] then dec(a);
       if key[scG] then dec(b);
       if key[scH] then dec(c);
       if key[scEnter] then begin
          a:=0;
          b:=0;
          c:=0;
       end;
       if key[scRShift] then begin
          x:=0;
          y:=0;
          z:=256 div 2;
       end;
   until key[scSpace];
   repeat
   until not key[scSpace];
end; (*rotateTextobject*)


procedure RotateEdgeObject;
var
   x,y,z:byte;
   a,b,c:integer;
begin
   x:=0;y:=0;z:=0;
   a:=1;b:=1;c:=1;
   repeat
       clrpage2scr;
       tekenedges(plist,elist,tlist);
       waitvbl;
       copyfrompage2;
       x:=x+a;
       y:=y+b;
       z:=z+c ;
       rotedges(plist,elist,tlist,x,y,z);
       quicksortEdges(elist,0,elast-1);
       if key[scR] then inc(a);
       if key[scT] then inc(b);
       if key[scY] then inc(c);
       if key[scF] then dec(a);
       if key[scG] then dec(b);
       if key[scH] then dec(c);
       if key[scEnter] then begin
          a:=0;
          b:=0;
          c:=0;
       end;
       if key[scRShift] then begin
          x:=0;
          y:=0;
          z:=0;
       end;
   until key[scSpace];
   repeat until not key[scSpace];
end; (*rotateedgeobject*)






procedure playtorus;
var i:integer;
begin
  CenterX:=160;   CenterY:=100;
  SizeX:=160;     SizeY:=160;
  elast:=0;       plast:=0;     tlast:=0;

   {deze zal iets initialiseren wat ik niet weet}
	 rotedges(plist,elist,tlist,0,0,0);
   {doe die rotedges weg en het zal crashen indien je playtorus als 1e oproept}

   maketorus(plist,tlist);
   buildedges(tlist,elist,plist);


   RotateFillObjectfast;
   RotateGouraud;
   RotateEdgeObject;
   sizeX:=350; sizey:=350;
	 RotateFillObject;

end;{playtorus}


Procedure playcube;
var p:palettetype;
begin
   CenterX:=160; CenterY:=100;
   SizeX:=350;   SizeY:=350;
   plast:=0;     tlast:=0;     elast:=0;
   initcube(plist,tlist);
   buildedges(tlist,elist,plist);
   RotateFillObjectfast;
   RotateGouraud;
   RotateEdgeObject;
   sizex:=450;sizey:=450;
   RotateFillObject;
   new(page3);
   MemLoadPCXpage2 (@picture_PCX,picture_PCX_Size,p);
   setactivepalette(p,0,255);
   page3^:=page2^;
    SizeX:=350;   SizeY:=350;
   rotatetextobject;
   dispose(page3);
end ;{playcube;}



Procedure playwalle;

var i:integer;
begin
   CenterX:=160; CenterY:=100;
   SizeX:=340;   SizeY:=round(340 * (280/320));
   plast:=0;     tlast:=0;     elast:=0;
   putwalle2(plist,elist,tlist);
   RotateEdgeObject;
end ;{playcube;}



procedure playtextcube;
var pcxpal:palettetype;
    i : integer;
begin
   CenterX:=240;   CenterY:=100;
   SizeX:=240;     SizeY:=240;
   plast:=0;       tlast:=0;     elast:=0;
   initcube(plist,tlist);
   buildedges(tlist,elist,plist);
   clrvgascr;
   clrpage2scr;
   loadpcxpage2('babe2.pcx',pcxpal);
   new(page3);
   page3^:=page2^;

   for i:=255 to 255 do begin
       pcxpal[i,1]:=0;pcxpal[i,2]:=0;pcxpal[i,3]:=0;
   end;
   setactivepalette(pcxpal,0,255);
   RotateTextObject;
   (*RotateEdgeObject;*)
   dispose(page3);
end;




procedure playtexttorus;
var pcxpal:palettetype;
    i : integer;
begin
   CenterX:=240;   CenterY:=100;
   SizeX:=90;     SizeY:=90;
   plast:=0;       tlast:=0;     elast:=0;
   maketorus(plist,tlist);
   puttextureobject(tlist);
   buildedges(tlist,elist,plist);
   clrvgascr;
   clrpage2scr;
   loadpcxpage2('babe2.pcx',pcxpal);
   new(page3);
   page3^:=page2^;
   (*initpalette;
   RotateFillObject; *)
   (*texturepalette;*)
   for i:=255 to 255 do begin
       pcxpal[i,1]:=0;pcxpal[i,2]:=0;pcxpal[i,3]:=0;
   end;
   setactivepalette(pcxpal,0,255);
   RotateTextObject;
   (*RotateEdgeObject;*)
   dispose(page3);
end;



procedure playcigarette;

begin
  CenterX:=160;   CenterY:=100;
  SizeX:=250;     SizeY:=250;
  elast:=0;       plast:=0;     tlast:=0;

   rotedges(plist,elist,tlist,0,0,0);
   makecigarette(plist,tlist);
   buildedges(tlist,elist,plist);

   RotateFillObjectfast;
   RotateFillObject;
   RotateGouraud;
   RotateEdgeObject;
end;{playcigarette}


procedure playbeker;

begin
  CenterX:=160;   CenterY:=100;
  SizeX:=250;     SizeY:=250;
  elast:=0;       plast:=0;     tlast:=0;
   makebeker(plist,tlist);
   buildedges(tlist,elist,plist);

   RotateFillObjectfast;
   RotateGouraud;
   RotateEdgeObject;
   sizex:=500; sizey:=500;
   Rotatefillobject;
end;{playbeker}


procedure view(v:vertexp);
begin
  if v<>nil then
	while v^.next<>nil do
  begin
  	write(v^.t,',');
    v:=v^.next;
  end;
end;

procedure printnorms;
var i,j:integer;
begin
 write(plast);write('  punten,');
 write(elast);write('  edges,');
 write(tlast);writeln('  triangles');
 for i:=0 to tlast-1 do begin
    write(' v1=');view(tlist[i].vertexp1);
    write(' v2=');view(tlist[i].vertexp2);
		write(' v3=');view(tlist[i].vertexp3);writeln;
 end;
end;



begin { program body }
  installfastkeys;
  Titlescreen;
  govga256;
  testpal ;
  inittables;
  (*playtexttorus;*)
  playwalle;
  Playcigarette;
  Playbeker;
  Playtorus;
  Playcube;

(*  Playtextcube; *)

  restorekeyboard;
  restoremode;
{  printnorms;}
end.
