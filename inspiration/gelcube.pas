
{
 Author : Walter Schreppers
 email  : walle@mail.dma.be
 If you like/use this code please leave me an email
 I'm currently busy with porting this to C++ so you're free
 to use any of this anywhere you like... The problem with pascal
 is that its 16 bit and slow... hmm If you would like to convert
 some more stuff to asm to speed things up you're welcome... please
 mail me the results :-)
 The hardest things were finding a good/fast rotation matrix
 (i calculated it myself with pen and paper ) and getting the
 Gauraud to work and the flatshading to work fast :-)
 Things to do : Cohen sutherland clipping would be nice.
 the fastkeys.tpu i cant include because its copywrited... So
 you prob have to write you're own keyboard control stuff... if
 you succeed please also send me the result back.
 Any modifications will be put on my webpage and i'll include your
 name... Okay thats it cya and enjoy !!!!
}

program gelcube;
uses fastkeys;

Const
	MaxX = 319; MaxY = 199; MinX=0; MinY=0; GetMaxX = 319; GetMaxY = 199;

	_OR     = 0;	_AND    = 1;	_PRESET = 2;	_PSET   = 3;
	_XOR    = 4;   _NOT    = 5;   _ADD    = 6;   _SUB    = 7;
	_Hollow = 0;	_Filled = 1;

	Red     = 0;	Green   = 1;	Blue    = 2;

	Left_B    		= $0001;	Right_B   		= $0002;	Center_B  		= $0004;
	Pos_Changed    = $0001;	Left_Press     = $0002;	Left_Release   = $0004;
	Right_Press    = $0008;	Right_Release  = $0010;	Center_Press   = $0020;
	Center_Release = $0040;
	Num_Color_Pixels = 256;

type Palette 		 = Array[0..255, Red..Blue] Of BYTE;

var
    Segment, Ofset : WORD;
  	db             : pointer;



{mode 13 for gfx 3 for text ... no more explaining to do i guess}
Procedure SetVideoMode(Mode : BYTE);
begin
   Asm
      MOV AH, $0
      MOV AL, Mode
      INT $10
   End
End;


{if your gonna use double buffering set this pointer to the
buffer db... see below in the main}
Procedure SetScreenPtr(Var Ptr);
Begin
   	Segment := Seg(Ptr);
      Ofset := Ofs(Ptr);
End;


Procedure SetScreenPtrTo(Sgmt, Ofst : WORD);
	Begin
   	Segment := Sgmt;
    Ofset := Ofst;
   End;

Procedure ResetScreenPtr;
	Begin
   	Segment := $A000;
      Ofset := $0000;
   End;



Procedure Fill(Var A; L : WORD; B : BYTE);
begin
	Asm
   	CLI
      CLD
      LES DI, A
      MOV CX, L
   	MOV AL, BYTE PTR B
      REP STOSB
      STI
   End;
end;

Procedure FillW(Var A; L : Word; W : Word);
begin
	Asm
   	CLI
      CLD
      LES DI, A
      MOV CX, L
   	MOV AX, WORD PTR W
      REP STOSW
      STI
   End;
end;


{with this you can clear the buffer quickly...}
Procedure FillDW(Var A; L : Word; Dw : LongInt);
begin
	Asm
   	CLI
      CLD
      LES DI, A
      MOV CX, L
      DB $66; MOV AX, WORD PTR Dw
      DB $66; REP STOSW
      STI
   End;
end;


Procedure Move(Var A, B; L : Word);
begin
   Asm
      CLI
      CLD
      PUSH DS
      LDS SI, A
      LES DI, B
      MOV CX, L
      REP MOVSB
      POP DS
      STI
   End;
end;


Procedure MoveW(Var A, B; L : Word);
begin
   Asm
      CLI
      CLD
      PUSH DS
      LDS SI, A
      LES DI, B
      MOV CX, L
      REP MOVSW
      POP DS
      STI
   End;
end;


Procedure MoveDW(Var A, B; L : Word);
begin
	Asm
   	CLI
      CLD
      PUSH DS
      LDS SI, A
      LES DI, B
      MOV CX, L
      DB $66; REP MOVSW
      POP DS
      STI
   End;
end;




{activate the palette}
Procedure DisplayPalette(P : Palette; First, Last : Word);assembler;
		Asm
      	CLI
      	PUSH DS
      	PUSH SI
         LDS SI, P
         MOV CX, First
         ADD SI, CX
         ADD SI, CX
         ADD SI, CX

         MOV AX, Last
         SUB AX, First
         INC AX
         MOV CX, AX
         SHL CX, 1
         ADD CX, AX

         MOV AX, First
         MOV DX, $3C8
         OUT DX, AL
         INC DX
         REP OUTSB
         POP SI
         POP DS
         STI
		End;


Procedure DisplayPaletteSlow(P : Palette; First, Last : Byte);
	Var count : byte;
   Begin
		 count:=port[$3DA];
		 while $8 and count<>0 do
		 count:=port[$3DA];
		 while $8 and count=0 do
		 count:=port[$3DA];
		 port[$3C8]:=first;
			for count:=first to last do
				begin
					port[$3C9]:=P[count,0];
					port[$3C9]:=P[count,1];
					port[$3C9]:=P[count,2];
				end;
	End;

PROCEDURE WaitVBL; {wait for vertical retrace, giving smooth gfx}
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

procedure pixel(x,y:word;col:byte);  {put pixel in segment which can be active screen or the buffer}
begin
asm
     {MOV AX, Segment ...allee eerst segment in ax steken dan ax in es steken
		 hmm dat is optimaal ... dus gewoon segment in es is gemakkelijker en sneller}
     {yes i'm a belgian... sorry for the flamisch comment b.t.w. the song suxx}
	   MOV ES, Segment

      MOV AX, y
      MOV BX, x
      XCHG AH, AL
      ADD BX, AX
      SHR AX, 2
      {SHR AX, 1 die stommerik had 2 keer een shr ax,1 gedaan}
      ADD BX, AX

	   {MOV AX, col     ... hiervoor moet color een word zijn maar een byte is genoog zenne}
	   {MOV ES:[BX], AL}
     MOV DL,col
     MOV ES:[BX],DL
end;
end;

Procedure Hline (x1,x2,y:word;col:byte);
var s:word;
begin  { This draws a horizontal line from x1 to x2 on line y in color col }

{zorgen dat x1<x2}
if x1>x2 then begin s:=x1;x1:=x2;x2:=s; end;

asm
 { mov   ax,segment weer zoiet raar waarom segment eerst in ax dan ax in es???
  mov   es,ax      }

  mov   es,segment
  mov   ax,y
  mov   di,ax
  shl   ax,8
  shl   di,6
  add   di,ax
  add   di,x1

  mov   cx,x2
  sub   cx,x1

  {we tellen er 1 bij driehoeken sluiten niet goed aan
  add   cx,1    {hoeft niet als je doorkijk variant doet}

  cmp   cx,0
  jle   @End
@Loop1 :
  mov   al,es:[di]
  add   al,col    {mooie variante je kijkt door het object }
{  mov al, col}
  {inc   al {kompleet overbodig :-)}
  stosb
  loop  @loop1
@End:
end;
end;

Function KeyPressed : Boolean;
begin
	ASM
    	PUSH DS
    	MOV AX, $0040
    	MOV DS, AX
    	CLI
    	MOV AX, [$001A]     { Buffer head }
    	CMP AX, [$001C]     { Buffer tail }
    	STI
    	MOV AX, 0
    	JZ @NoKeyPress
    	INC AX
    	@NoKeyPress:
    	POP DS
	END;
end;

Procedure Line(X1, Y1, X2, Y2, C : Integer); Assembler;
   Asm
      CLI

      MOV AX, X2
      CMP AX, X1
      JNE @Sk
      MOV AX, Y2
      CMP AX, Y1
      JE @NoLine
      @Sk:

      MOV AX, X2
      CMP AX, X1
      JG @Skip
      MOV BX, X1
      MOV X2, BX
      MOV X1, AX
      MOV AX, Y2
      MOV BX, Y1
      MOV Y2, BX
      MOV Y1, AX
      @Skip:
      MOV DX, C      { Set DX To _GetColor }
      MOV AX, Segment
      MOV ES, AX     { Set ES To $A000 }
      MOV BX, Y1
      XCHG BH, BL
      MOV AX, BX
      SHR BX, 1
      SHR BX, 1
      ADD BX, AX
      ADD BX, X1   { Set BX == X + (Y*320) }
      ADD BX, Ofset

      MOV SI, X2
      MOV DI, Y2
      SUB SI, X1
      SUB DI, Y1

      @ABCD:
      CMP DI, $8888
      JB @CD
      @AB:
      NEG DI
      CMP SI, DI
      JB @A
      @B:
      MOV CX, SI
      MOV AX, SI
      SHR AX, 1
      @Loopa:
      MOV ES:[BX], DL
      INC BX
      ADD AX, DI
      CMP AX, SI
      JLE @Skipa
      SUB BX, 320
      SUB AX, SI
      @Skipa:
      LOOP @Loopa
      JMP @Exit
      @A:
      MOV CX, DI
      MOV AX, DI
      SHR AX, 1
      @Loopb:
      MOV ES:[BX], DL
      SUB BX, 320
      ADD AX, SI
      CMP AX, DI
      JLE @Skipb
      ADD BX, 1
      SUB AX, DI
      @Skipb:
      LOOP @Loopb
      JMP @Exit
      @CD:
      CMP SI, DI
      JB @D
      @C:
      MOV CX, SI
      MOV AX, SI
      SHR AX, 1
      @Loopc:
      MOV ES:[BX], DL
      INC BX
      ADD AX, DI
      CMP AX, SI
      JLE @Skipc
      ADD BX, 320
      SUB AX, SI
      @Skipc:
      LOOP @Loopc
      JMP @Exit
      @D:
      MOV CX, DI
      MOV AX, DI
      SHR AX, 1
      @Loopd:
      MOV ES:[BX], DL
      ADD BX, 320
      ADD AX, SI
      CMP AX, DI
      JLE @Skipd
      ADD BX, 1
      SUB AX, DI
      @Skipd:
      LOOP @Loopd
      JMP @Exit
      @NoLine:
      MOV AX, X2
      MOV BX, Y2
      MOV DX, C
      MOV BX, Y1
      XCHG BH, BL
      MOV AX, BX
      SHR BX, 1
      SHR BX, 1
      ADD BX, AX
      ADD BX, X1
      MOV AX, Segment
      MOV ES, AX

      @Exit:
      MOV ES:[BX], DL
      STI
   End;



{---------------------------------END ASM STUFF----------------------------}


const
  maxtriangle=500;  {450}
  maxpoints=450;   {450}
  maxedge=620; {620}
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
  page3       : pointer;
  vgacolor	  : byte;




procedure initpalette1;
var i:byte;
    p:palette;
begin
 for i:=0 to 255 do begin
     p[i,2]:=0;
     p[i,0]:=(i)mod 64;
     p[i,1]:=(i)mod 64;
     if i=0 then begin
     	p[i,0]:=0;p[i,1]:=0;p[i,2]:=0;
     end;
 end;
   DisplayPalette(P, 0, 255);
end;


procedure initpalette2;
var i:byte;
    p:palette;
begin
 for i:=0 to 255 do begin
     p[i,2]:=0;
     p[i,0]:=(i)mod 64;
     p[i,1]:=0;
     if i=0 then begin
     	p[i,0]:=0;p[i,1]:=0;p[i,2]:=0;
     end;
 end;
   DisplayPalette(P, 0, 255);
end;

procedure initpalette3;
var i:byte;
    p:palette;
begin
 for i:=0 to 255 do begin
     p[i,2]:=0;
     p[i,0]:=0;
     p[i,1]:=(i)mod 64;
     if i=0 then begin
     	p[i,0]:=0;p[i,1]:=0;p[i,2]:=0;
     end;
 end;
   DisplayPalette(P, 0, 255);
end;


procedure initpalette4;
var i:byte;
    p:palette;
begin
 for i:=0 to 255 do begin
     p[i,0]:=0;
     p[i,1]:=0;
     p[i,2]:=(i)mod 64;
     if i=0 then begin
     	p[i,0]:=0;p[i,1]:=0;p[i,2]:=0;
     end;
 end;
   DisplayPalette(P, 0, 255);
end;


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



procedure RenderFlat(t:triangle);
type vertex = record
			x,y,z:longint;
      end;
var
        c,y,
        step1,step2,
        sx1,sx2			:longint;
        p,p1,p2,p3	:vertex;

begin
     		p1.x:=(plist[t.p1].rotp[0]);
     		p1.y:=(plist[t.p1].rotp[1]);
        p1.z:=(plist[t.p1].rotp[2]);

     		p2.x:=(plist[t.p2].rotp[0]);
     		p2.y:=(plist[t.p2].rotp[1]);
        p2.z:=(plist[t.p2].rotp[2]);

     		p3.x:=(plist[t.p3].rotp[0]);
     		p3.y:=(plist[t.p3].rotp[1]);
        p3.z:=(plist[t.p3].rotp[2]);

        {color=(RotLight.x*(p1.p_x+p2.p_x+p3.p_x)/3+RotLight.y*(p1.p_y+p2.p_y+p3.p_y)/3+
				RotLight.z*(p1.p_z+p2.p_z+p3.p_z)/3)/RotLight.lenght;}
        {if(color>254)color=254;
        if(color<1)color=1;}

        if(p2.y<p1.y) then begin  p:=p1;   p1:=p2;  p2:=p;   end;
        if(p3.y<p1.y) then begin  p:=p1;   p1:=p3;  p3:=p;   end;
        if(p3.y<p2.y) then begin  p:=p2;   p2:=p3;  p3:=p;   end;

        sx1:=p1.x shl 8;
        sx2:=p1.x shl 8;
        if(p1.y<>p3.y) then
				begin
					step1:=(p3.x-p1.x)*256 div (p3.y-p1.y);
  	      if(p1.y<>p2.y)then step2:=(p2.x-p1.x)*256 div(p2.y-p1.y)
   		    else step2:=0;

	 	      for y:=p1.y to p2.y-1 do begin
                  {if((c=sx1-sx2)<0)memset(prev+y*ScreenX+sx1/256,color,-c/256+1);
                else memset(prev+y*ScreenX+sx2/256,color,c/256+1);}
								if y in [0..199] then hline(sx1 shr 8,sx2 shr 8,y,t.color);
                inc(sx1,step1);
                inc(sx2,step2);
          end;

        	sx2:=p2.x shl 8;
        	if(p2.y<>p3.y) then
					begin
						step2:=(p3.x-p2.x)*256 div (p3.y-p2.y);
        		for y:=p2.y to p3.y-1 do begin
                {if((c=sx1-sx2)<0)memset(prev+y*ScreenX+sx1/256,color,-c/256+1);
                else memset(prev+y*ScreenX+sx2/256,color,c/256+1);}
                if y in [0..199] then hline(sx1 shr 8 ,sx2 shr 8,y,t.color);
                inc(sx1,step1);
                inc(sx2,step2);
            end;
          end;
				end;
end;




procedure putpoint(VAR plist:pointlist; punt:Point);
BEGIN
  if plast<maxpoints then begin
   plist[plast]:=punt;
   plast:=plast+1;
  end;
end; { putpoint}



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
  end;
end; (*rotfast*)




procedure tekenobject(VAR plist:pointlist;var tlist:trilist);
var i:integer;
begin
{   for i:=0 to tlast-1 do begin
    renderflat(tlist[i]);
  end;}
  {for i:=0 to plast-1 do begin
  	plist[i].rotp[0]:=plist[i].rotp[0]+50;
  end;}
   for i:=0 to tlast-1 do begin
    renderflat(tlist[i]);
  end;

end;
procedure RotateFillObject;
var x,y,z:real;
    a,b,c:integer;
    k:char;
begin
   x:=0;
   y:=0;
   z:=0;
   a:=2;
   b:=1;
   c:=1;
   repeat
       {clrpage2scr;}
       FillDW(db^, 16000, $00000000);
       tekenobject(plist,tlist);
       waitvbl;
       MoveDW(db^, Ptr($A000, 0)^, 16000);
       x:=x+(a);
       y:=y+(b);
       z:=z+(c);
       rotfast(plist,tlist,round(x),round(y),round(z));
       {quicksortTriangles(tlist,0,tlast-1);}
       if key[scr] then inc(a);
       if key[sct] then inc(b);
       if key[scy] then inc(c);
       if key[scf] then dec(a);
       if key[scg] then dec(b);
       if key[sch] then dec(c);
       if key[scEnter] then begin
          a:=0;
          b:=0;
          c:=0;
       end;
       if key[scn] then begin
          x:=0;
          y:=0;
          z:=0;
       end;
       if key[sc1] then initpalette1;
       if key[sc2] then initpalette2;
			 if key[sc3] then initpalette3;
			 if key[sc4] then initpalette4;

   until key[scSpace];
   repeat until not key[scspace];
end; (*rotatefillobject*)



Procedure playcube;
var p:palette;
	i:integer;
begin

   CenterX:=160; CenterY:=100;
   SizeX:=450;   SizeY:=450;
   plast:=0;     tlast:=0;     elast:=0;
   initcube(plist,tlist);
   for i:=0 to tlast-1 do begin
      tlist[i].color:=i div 2+15;
  end;

   RotateFillObject;
end ;{playcube;}


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

{------------------ main program body -------------------------------}

begin
  installfastkeys;
  setvideomode($13);

  GetMem(db, 64000);
  SetScreenPtr(db^); {draw everything in db}
  FillDW(db^, 16000, $00000000);    {clear db}
  MoveDW(db^, Ptr($A000, 0)^, 16000);    {copy db to active screen}

  initpalette3;
  inittables;

  Playcube;

  setvideomode($03);
  restorekeyboard;
  freemem(db,64000);
end.
