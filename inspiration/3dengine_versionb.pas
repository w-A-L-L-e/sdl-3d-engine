
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
 I can't include the fastkeys.tpu because it has copyrights... So
 you probably have to write you're own keyboard control stuff... If
 you succeed please also send me the result back.
 Any modifications will be put on my webpage and I'll include your
 name... Okay thats it cya and enjoy !!!!
}

program enginebeta;
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
      SHR AX, 1
      SHR AX, 1 {die stommerik had 2 keer een shr ax,1 gedaan}
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
  shl   ax, 8
  shl   di, 6
  add   di,ax
  add   di,x1

  mov   cx,x2
  sub   cx,x1
  {we tellen er 1 bij op want de pixels zitten nie goe}
  add   cx,1

  cmp   cx,0
  jle   @End
@Loop1 :
  mov   al,es:[di]
 { add   al,col    mooie variante je kijkt door het object}
  mov al, col
  {inc   al kompleet overbodig :-)}
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






procedure Titlescreen;
var c:char;
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
  writeln('  Keys you can use during execution:');
  writeln('  - 1,2,3,4 in the first screen choose different pallettes');
  writeln;
  writeln('  - r,t,y = increase the x,y and z rotation');
  writeln('  - f,g,h = decrease the x,y and z rotation');
  writeln('  - Enter = stop rotation');
  writeln('  - n     = put object in original angle x=0,y=0,z=0');
  writeln('  - Space = go to the next screen :) ');
  writeln;
  writeln(' after reading thiz the wize thing to do is ...');
  writeln(' SLAM THE SPACE BAR WITH A SLEDGE HAMMER');
  repeat
  until key[scSpace];
  repeat until not key[scspace];
end; {titlescreen}





procedure initpalette1;
var i:byte;
    p:palette;
begin
 for i:=0 to 255 do begin
     p[i,0]:=round(sin(i*pi/512)*sin(i*pi/512)*sin(i*pi/512) *58)+5;
     p[i,1]:=round(sin(i*pi/512)*sin(i*pi/512)*sin(i*pi/512) *58)+5;
     p[i,2]:=round(sin(i*pi/512)*sin(i*pi/512)*sin(i*pi/512) *58)+5;
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
     p[i,0]:=i div 4;
     p[i,1]:=i div 4;
     p[i,2]:=0 div 4;
 end;
   DisplayPalette(P, 0, 255);
end;

procedure initpalette3;
var i:byte;
    p:palette;
begin
 for i:=0 to 255 do begin
     p[i,0]:=i div 4;
     p[i,1]:=0 div 4;
     p[i,2]:=i div 4;
 end;
   DisplayPalette(P, 0, 255);
end;


procedure initpalette4;
var i:byte;
    p:palette;
begin
 for i:=0 to 255 do begin
     p[i,0]:=0 div 4;
     p[i,1]:=i div 4;
     p[i,2]:=i div 4;
 end;
   DisplayPalette(P, 0, 255);
end;


procedure testpal;
var i:byte;
    t:triangle;
    c:char;
begin
 initpalette1;
 {clrvgascr;}
 FillDW(db^, 16000, $00000000);
 MoveDW(db^, Ptr($A000, 0)^, 16000);

 for i:= 0 to 199 do begin
  hline(0,200,i,i);
 end;
 MoveDW(db^, Ptr($A000, 0)^, 16000);
 repeat
       if key[sc1] then initpalette1;
       if key[sc2] then initpalette2;
       if key[sc3] then initpalette3;
       if key[sc4] then initpalette4;
  until key[scSpace];
  repeat until not key[scspace];
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


{PROCEDURE DrawTriangle(VAR plist:pointlist; T:Triangle);

BEGIN
   vgacolor:=t.color;
   Drawpolypage2(plist[t.p3].rotp[0], plist[t.p3].rotp[1],
                       plist[t.p2].rotp[0],
                       plist[t.p2].rotp[1],
   MoveTo (plist[t.p1].rotsp[0],
          plist[t.p1].rotp[1],closePoly));
END;}




Procedure FillTriangle(VAR plist:pointlist; T:Triangle);
var r1,r2,r3,
    x1,x2       : real;

    xa,ya,
    xb,yb,
    xc,yc,
    y,temp      : longint;
    done        : boolean;

begin
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
              hline(round(x1),round(x2),y,t.color);
              x1:=x1+r1;  (*x'en van ab*)
              x2:=x2+r3;  (*x'en van ac*)
          end;
          for y:=yb to yc do begin
              hline(round(x1),round(x2),y,t.color);
              x1:=x1+r2;   (*x'en van bc*)
              x2:=x2+r3;   (*x'en van ac*)
          end;
     end
     else if (ya=yc) then begin
        hline(xa,xc,ya,t.color); (*drie combinaties mogelijk om driehoek te hebben dat een lijnstuk is*)
        hline(xa,xb,ya,t.color);
        hline(xb,xc,ya,t.color);
        end
     else if (ya=yb) then begin  (* x coord van lijnstukken ac en bc op array zetten*)
          r1:=(xc-xa)/(yc-ya); (*richt co van ac*)
          r2:=(xc-xb)/(yc-yb); (*richt co van bc*)
          x1:=xa;
          x2:=xb;
          for y:=ya to yc do begin
              hline(round(x1),round(x2),y,t.color);
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
              hline(round(x1),round(x2),y,t.color);
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
            hline(x1,x2,y1,t.color);
    end;


begin
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
                 pixel(i,y,round(c1));
                 c1:=c1+r1;
              end;
              for i:=xb to xa do begin
                  pixel(i,y,round(c2));
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
                     pixel(xd,yd,200);{page3^[round(yt),round(xt)];}
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
                 if z1<0 then pixel(i,y1,vgacolor);
                 z1:=z1+r;
              end;
              for i:=x2 to x1 do begin
                  if z2<0 then pixel(i,y1,vgacolor);
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
								hline(sx1 shr 8,sx2 shr 8,y,t.color);
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
                hline(sx1 shr 8 ,sx2 shr 8,y,t.color);
                inc(sx1,step1);
                inc(sx2,step2);
            end;
          end;
				end;
end;

procedure RenderPhong(T:Triangle);
type vertex=record
				x,y,z:longint;
		 end;

var
        p,p1,p2,p3			:vertex;

        y,
        step1,step2,
        sx1,sx2,
        tx1,tx2,tx3,ty1,ty2,ty3,
        steptx1,steptx2,
        stepty1,stepty2,
        stx1,stx2,stx3,
        sty1,sty2,sty3,

        height,temp,longest,width,
        dudx,dvdx	:longint;
        destptr,
        dest: ^char;

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

        if(p2.y<p1.y) then begin  p:=p1;   p1:=p2;  p2:=p;   end;
        if(p3.y<p1.y) then begin  p:=p1;   p1:=p3;  p3:=p;   end;
        if(p3.y<p2.y) then begin  p:=p2;   p2:=p3;  p3:=p;   end;
{        tx1=128+p1.p_x/2;       ty1=128+p1.p_y/2;
        tx2=128+p2.p_x/2;       ty2=128+p2.p_y/2;
        tx3=128+p3.p_x/2;       ty3=128+p3.p_y/2;

        if((height=p3.y-p1.y)==0) return;
        temp=((p2.y-p1.y)<<16)/height;
        if((longest = temp * (p3.x - p1.x) + ((p1.x - p2.x) << 16))==0) return;

 {       if(longest>0){  if(longest < 0x1000)    longest = 0x1000;       }
 {       else{           if(longest > -0x1000)   longest = -0x1000;      }

{        dudx = shl16idiv((temp*(tx3 - tx1)+((tx1 - tx2)<<16)),longest) >>8;
        dvdx = shl16idiv((temp*(ty3 - ty1)+((ty1 - ty2)<<16)),longest) >>8;

        destptr=(char *)(p1.y*ScreenX+prev);

        sx1=p1.x*256;
        sx2=p1.x*256;
        stx1=tx1*256;
        stx2=tx1*256;
        sty1=ty1*256;
        sty2=ty1*256;

        if(p1.y!=p3.y)step1=(p3.x-p1.x)*256/(p3.y-p1.y);
        else return;
        steptx1=(tx3-tx1)*256/(p3.y-p1.y);
        stepty1=(ty3-ty1)*256/(p3.y-p1.y);

{        if(p1.y!=p2.y)
        {
                step2=(p2.x-p1.x)*256/(p2.y-p1.y);
                steptx2=(tx2-tx1)*256/(p2.y-p1.y);
                stepty2=(ty2-ty1)*256/(p2.y-p1.y);
        } {else
        {
                step2=0;
                steptx2=0;
                stepty2=0;
        }
{
        for(y=p1.y;y<p2.y;y++)
        {
                if((width=sx2-sx1)>0)
                {
                        stx3=stx1;
                        sty3=sty1;
                        dest=destptr+sx1/256;
                        for(width=width/256;width!=0;width--)
                        {
                                *dest++=bitmap[(sty3&0xff00)+stx3/256];
                                stx3+=dudx;
                                sty3+=dvdx;
                        }
{                        stx1+=steptx1;
                        sty1+=stepty1;
                } {else
                {
                        stx3=stx2;
                        sty3=sty2;
                        dest=destptr+sx2/256;
                        for(width=width/256;width!=0;width++)
                        {
                                *dest++=bitmap[(sty3&0xff00)+stx3/256];
                                stx3+=dudx;
                                sty3+=dvdx;
                        }
{                        stx2+=steptx2;
                        sty2+=stepty2;
                }
{                sx1+=step1;
                sx2+=step2;
                destptr+=ScreenX;
        }
{
        if(p2.y!=p3.y)step2=(p3.x-p2.x)*256/(p3.y-p2.y);
        else return;
        sx2=p2.x*256;
        stx2=tx2*256;
        sty2=ty2*256;
        steptx2=(tx3-tx2)*256/(p3.y-p2.y);
        stepty2=(ty3-ty2)*256/(p3.y-p2.y);

        for(y=p2.y;y<p3.y;y++)
        {
                if((width=sx2-sx1)>0)
                {
                        stx3=stx1;
                        sty3=sty1;
                        dest=destptr+sx1/256;
                        for(width=width/256;width!=0;width--)
                        {
                                *dest++=bitmap[(sty3&0xff00)+stx3/256];
                                stx3+=dudx;
                                sty3+=dvdx;
                        }
{                        stx1+=steptx1;
                        sty1+=stepty1;
                }{ else
                {
                        stx3=stx2;
                        sty3=sty2;
                        dest=destptr+sx2/256;
                        for(width=width/256;width!=0;width++)
                        {
                                *dest++=bitmap[(sty3&0xff00)+stx3/256];
                                stx3+=dudx;
                                sty3+=dvdx;
                        }
{                        stx2+=steptx2;
                        sty2+=stepty2;
                }
{                sx1+=step1;
                sx2+=step2;
                destptr+=ScreenX;
        }

end; {render phong}











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
 i:=16;        {26 is mooier}
 while i<255 do begin
   ActiveRotY(i,m);
   for j:=0 to schil-1 do begin
     vecmaalmat(plist[j].p,m,temp.p);
     putpoint(plist,temp);
   end;
   inc(i,16);
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
    {FillTriangle(plist,tlist[i]);}
    renderflat(tlist[i]);
  end;
end;


{

procedure cliptriangle(var t:triangle);
function outside(p:point):boolean;
begin
	if (p.rotp[0] < MinX) or (p.rotp[0]>MaxX) then outside:=true
  else if (p.rotp[1]<MinY) or (p.rotp[1]>MaxY) then outside:=true
  else outside:=false;
end;

begin
	if not (outside(plist[t.p1]) and outside(plist[t.p2]) and outside(plist[t.p3])) then
		FillTriangleClipped(plist,t);
end;
}

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
    FillTrianglezclipped(plist,tlist[i]);
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
        and (max(ya,yb)<200) and (min(ya,yb)>=0) then line(xa,ya,xb,yb,vgacolor);
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




procedure RotateFillObject;
var x,y,z:byte;
    a,b,c:integer;
    k:char;
begin
   x:=0;
   y:=0;
   z:=0;
   a:=1;
   b:=1;
   c:=1;
   repeat
       {clrpage2scr;}
       FillDW(db^, 16000, $00000000);
       tekenclipped(plist,tlist);
       waitvbl;
       MoveDW(db^, Ptr($A000, 0)^, 16000);
       x:=x+a;
       y:=y+b;
       z:=z+c;
       rotfast(plist,tlist,x,y,z);
       quicksortTriangles(tlist,0,tlast-1);
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
   until key[scSpace];
   repeat until not key[scspace];
end; (*rotatefillobject*)






procedure RotateGouraud;
var x,y,z:byte;
    a,b,c:integer;
		k:char;
begin
   x:=0;
   y:=0;
   z:=0;
   a:=1;
   b:=1;
   c:=1;
   repeat
        FillDW(db^, 16000, $00000000);
       tekengouraud(plist,tlist);
 {      vsync;}
       MoveDW(db^, Ptr($A000, 0)^, 16000);
       x:=x+a;
       y:=y+b;
       z:=z+c;
       rotfast(plist,tlist,x,y,z);
       quicksortTriangles(tlist,0,tlast-1);
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
   until key[scSpace];
   repeat until not key[scspace];
end; (*rotategouraud*)


procedure RotateFillObjectFast;
var x,y,z:byte;
    a,b,c:integer;
    k:char;
begin
   x:=0;
   y:=0;
   z:=0;
   a:=1;
   b:=1;
   c:=1;
   repeat
        FillDW(db^, 16000, $00000000);
       tekenobject(plist,tlist);
       waitvbl;
       MoveDW(db^, Ptr($A000, 0)^, 16000);
       x:=x+a;
       y:=y+b;
       z:=z+c;
       rotfast(plist,tlist,x,y,z);
       quicksortTriangles(tlist,0,tlast-1);
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
   until key[scSpace];
   repeat until not key[scspace];
end; (*rotatefillobjectfast*)


procedure RotateTextObject;
var x,y,z:byte;
    a,b,c:integer;
    i,j:integer;
    k:char;
begin
   x:=0;
   y:=0;
   z:=256 div 2;
   a:=1;
   b:=1;
   c:=1;
   repeat
        FillDW(db^, 16000, $00000000);
       tekentextobject(plist,tlist);
       MoveDW(db^, Ptr($A000, 0)^, 16000);
       x:=x+a;
       y:=y+b;
       z:=z+c;
       rotfast(plist,tlist,x,y,z);
       quicksortTriangles(tlist,0,tlast-1);
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
   until key[scSpace];
   repeat until not key[scspace];
end; (*rotateTextobject*)


procedure RotateEdgeObject;
var
   x,y,z:byte;
   a,b,c:integer;
   k:char;
begin
   x:=0;y:=0;z:=0;
   a:=1;b:=1;c:=1;
   repeat
        FillDW(db^, 16000, $00000000);
       tekenedges(plist,elist,tlist);
       waitvbl;
       MoveDW(db^, Ptr($A000, 0)^, 16000);
       x:=x+a;
       y:=y+b;
       z:=z+c ;
       rotedges(plist,elist,tlist,x,y,z);
       quicksortEdges(elist,0,elast-1);
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
   until key[scSpace];
   repeat until not key[scspace];
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
var p:palette;
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
   {new(page3);
   MemLoadPCXpage2 (@picture_PCX,picture_PCX_Size,p);
   setactivepalette(p,0,255);
   page3^:=page2^;
    SizeX:=350;   SizeY:=350;
   rotatetextobject;
   dispose(page3);}
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





{------------------ main program body -------------------------------}

begin
  installfastkeys;
  Titlescreen;
  setvideomode($13);

  GetMem(db, 64000);
  SetScreenPtr(db^); {draw everything in db}
  FillDW(db^, 16000, $00000000);    {clear db}
  MoveDW(db^, Ptr($A000, 0)^, 16000);    {copy db to active screen}

  testpal ;
  inittables;
  (*playtexttorus;*)
  playwalle;
  Playcigarette;
  Playbeker;
  Playtorus;
  Playcube;

  setvideomode($03);
  restorekeyboard;
  freemem(db,64000);
end.






