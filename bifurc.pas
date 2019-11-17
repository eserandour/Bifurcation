PROGRAM Bifurcation;

{ Ecrit avec Turbo Pascal 7 }
{ Version du 17/11/2019 a 15h14 }

USES
  Dos, Crt, Graph, BgiDriv;

VAR
  OrigMode                        : INTEGER;
  GraphDriver                     : INTEGER;
  GraphMode                       : INTEGER;
  MaxX, MaxY                      : INTEGER;
  Code                            : CHAR;
  i                               : INTEGER;

{######################################################################}

PROCEDURE Abort(Msg : STRING);
BEGIN
  Writeln(Msg, ' : ', GraphErrorMsg(GraphResult));
  Halt(1);
END; { Abort }

{######################################################################}

PROCEDURE Recording;
BEGIN
  IF RegisterBGIdriver(@CGADriverProc)    < 0 THEN Abort('CGA');
  IF RegisterBGIdriver(@EGAVGADriverProc) < 0 THEN Abort('EGA/VGA');
  IF RegisterBGIdriver(@HercDriverProc)   < 0 THEN Abort('Herc');
  IF RegisterBGIdriver(@ATTDriverProc)    < 0 THEN Abort('AT&T');
  IF RegisterBGIdriver(@PC3270DriverProc) < 0 THEN Abort('PC 3270');
END; { Recording }

{######################################################################}

PROCEDURE OpenGraph;
BEGIN
  Recording;
  GraphDriver:=Detect;
  InitGraph(GraphDriver, GraphMode, '');
  IF GraphResult<>grOk THEN Abort('Erreur graphique');
  MaxX:=GetMaxX;
  MaxY:=GetMaxY;
END; { OpenGraph }

{######################################################################}

PROCEDURE InitClavier;
BEGIN
  IF KeyPressed THEN
    REPEAT
      Code:=ReadKey;
      IF Code=#0 THEN Code:=ReadKey;
    UNTIL Not KeyPressed;
END; { InitClavier }

{######################################################################}

PROCEDURE WaitLectClavier;
BEGIN
  REPEAT UNTIL KeyPressed;
  Code:=ReadKey;
  IF Code=#0 THEN Code:=ReadKey;
END; { WaitLectClavier }

{######################################################################}

FUNCTION Suite(R: REAL; U:REAL): REAL;
BEGIN
  Suite:=Cos(R*U);
END;

{######################################################################}

PROCEDURE BifurcationPlay;
CONST
  { Le parametre R varie de (Xmax-Xmin) sur une largeur d'ecran }
  Xmin = 0;
  Xmax = 0.5;
  { Un cosinus varie de -1 a 1. On laisse un peu de place en haut et en bas }
  Ymin = -1.15;
  Ymax = 1.02;
  { Premier terme de la suite }
  Y0 = 0;
VAR
  R, Y                       : REAL;
  Xunit, Yunit, Xorig, Yorig : REAL;
  Xscreen, Yscreen           : WORD;
  NbEcran                    : INTEGER;
  Chaine                     : STRING;
  NbTermes, NbPoints         : INTEGER;
BEGIN
  ClearDevice;
  SetBkColor(Black);
  SetColor(White);
  SetViewPort(0, 0, MaxX, MaxY, ClipOn);
  SetTextStyle(DefaultFont, HorizDir, 1);
  Xunit:=MaxX/(Xmax-Xmin); { L'unite selon X en pixels }
  Yunit:=MaxY/(Ymax-Ymin); { L'unite selon Y en pixels }
  Xorig:=(0-Xmin)*Xunit;
  Yorig:=MaxY-((0-Ymin)*Yunit);
  NbEcran:=0;
  R:=Xmin;
  Y:=Y0;
  REPEAT
    InitClavier;
    NbTermes:=100; { Nombre de termes de la suite a calculer }
    NbPoints:=8; { Nombre de points a afficher }
    FOR i:=1 TO NbTermes DO
    BEGIN
      Y:=Suite(R, Y);
      IF i>(NbTermes-NbPoints) THEN
      BEGIN
        Xscreen:=Round(Xorig+Xunit*R-NbEcran*MaxX);
        Yscreen:=Round(Yorig-Yunit*Y);
        SetTextJustify(CenterText, CenterText);
        OutTextXY(Xscreen, Yscreen, '.');
      END;
    END;
    IF Xscreen=MaxX THEN
    BEGIN
      Inc(NbEcran);
      Str(NbEcran, Chaine);
      Chaine:=Concat('Ecran ', Chaine);
      SetTextJustify(LeftText, CenterText);
      OutTextXY(15, MaxY-15, Chaine);
      Delay(2000);
      ClearDevice;
      Y:=Y0;
    END;
    R:=R+0.0001;
  UNTIL (KeyPressed);
END; { BifurcationPlay }

{#################### CORPS PRINCIPAL DU PROGRAMME ####################}

BEGIN
  OrigMode:=LastMode;
  Randomize;
  OpenGraph;
  BifurcationPlay;
  CloseGraph;
  TextMode(OrigMode);
END.

{######################################################################}
