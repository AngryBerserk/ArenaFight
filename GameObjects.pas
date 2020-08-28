unit GameObjects;

interface

uses
  System.Types, System.Generics.Collections, Animation, Painter, System.UITypes, sysutils, FMX.Dialogs, Log;

const
  RandomNums:Array of Byte=[31,94,80,1,75,6,72,48,67,51,21,47,57,40,97,55,82,21,38,4,97,76,21,98,67,53,18,85,26,39,81,90,6,96,39,
                            41,10,78,57,49,85,45,28,64,87,42,73,66,25,7,80,20,81,58,100,32,11,62,56,5,84,88,70,56,20,99,34,77,32,
                            83,18,66,91,9,39,91,34,51,76,0,88,65,84,75,25,27,51,88,7,93,77,60,76,87,55,10,75,89,49,88,77,5,87,27,
                            59,4,69,50,27,43,85,5,26,93,57,51,53,90,1,49,95,84,17,69,42,15,38,47,82,31,92,18,47,53,18,44,29,25,28,
                            85,61,50,9,69,33,98,47,46,59,20,89,80,30,70,62,73,95,84,38,96,89,22,71,88,77,71,9,19,37,72,71,36,3,1,
                            45,90,27,68,48,35,66,32,79,5,25,46,92,85,74,63,29,39,64,8,99,36,56,100,63,90,2,15,92,74,16,76,83,41,19,
                            63,33,44,99,97,40,10,60,81,86,94,28,45,45,17,12,78,72,1,19,37,53,42,72,29,8,78,16,35,12,16,10,43,98,5,
                            54,46,13,99,91,57,60,54,15,90,20,14,0,31,14,2,44,63,58,3,83,33,44,96,98,61,22,79,65,16,4,3,39,59,84,38,
                            7,31,37,34,6,77,62,64,10,28,58,32,2,96,35,28,36,69,21,18,74,81,100,36,50,11,23,24,47,30,24,43,6,13,61,
                            86,80,52,22,62,17,87,2,9,53,63,3,95,68,50,34,93,42,22,68,40,44,41,97,13,19,79,62,97,89,4,13,43,83,7,68,
                            86,70,26,36,27,14,57,51,45,61,23,17,52,54,93,94,65,55,86,75,46,12,65,65,38,30,94,8,94,6,71,32,91,99,59,
                            21,87,70,67,54,9,23,93,66,55,55,8,71,15,46,26,13,20,82,92,8,16,75,60,37,95,33,40,24,72,98,48,12,43,80,
                            73,79,81,58,17,100,78,64,67,56,82,54,0,11,35,70,52,37,100,74,73,79,41,1,89,68,11,83,40,29,7,33,58,61,14,
                            3,52,24,76,56,69,60,19,48,67,26,73,86,29,4,30,15,12,0,41,48,78,30,59,31,64,25,35,91,66,74,50,42,52,23,
                            95,23,24,22,49,96,82,34,14,92,0,2,11,49];

type

Directions=(dNone,dLeft,dRight,dUp,dDown,dRightUp,dRightDown,dLeftUp,dLeftDown);
wallType=(wtGround1,wtGround2,wtGround3,wtWallUp1,wtWallUp2,wtWallUp3,wtWallUp4,wtWallUp5,wtWallUp6,wtWallUp7,wtWallUp8,wtWallDown1,wtWallDown2,wtWallDown3);

Rand = class
    class var Index:Word;
    class function Get(var Ind:Word; Range:Byte):Byte;
end;

TStaticText = class
    Position:TPoint;
    text:String;
    Size:Byte;
    Color:TAlphaColorRec;
    procedure Paint;virtual;
    constructor create(const P:TPoint;const S:String; const siz:Byte; const C:LongWord);virtual;
end;

TFadingText = class (TStaticText)
    TTL:Single;
    //staticText:Boolean;
    constructor create(const P:TPoint;const S:String; const siz:Byte; const C:LongWord);override;
    procedure Paint;override;
end;

TGameObject = class
    name:String;
    textName:String;
    fcollidable:Boolean;
    Position:TPoint;
    Animation:TAnimation;
    Randitem:Word;
    class var Painter:TPainter;
    class function deltaP(const D: Directions):TPoint;
    procedure Paint;virtual;
    constructor Create;virtual;
    function Distance(P:TPoint):Word;
    function collidable:boolean;virtual;
  end;

GameObjectList = TObjectList<TGameObject>;
TGameObjectClass = class of TGameObject;

TFX = class (TGameObject)
    loop:boolean;
    toDelete:Boolean;
    procedure Paint;override;
end;

TFloor = class (TGameObject)
    constructor Create;override;
    procedure Kind(const W:wallType);
end;

TLogicObject = class (TGameObject)
      Direction:Directions;
      AttachedFX:GameObjectList;
    public
      procedure AttachFX(FX:TFX);
      procedure Logic;virtual;
      function collidable:Boolean;override;
      constructor Create;override;
      destructor Destroy;override;
end;

TNPC = class (TLogicObject)
    public
      fHP:Integer;
      MaxHP:Word;
      Attack:Integer;
      fisDead:Boolean;
      Speed:Single;
      CurrentSpeed:Single;
      Desc:String;
      class var dodgeChances:Word;
      function isDead:Boolean;virtual;
      function Speed100:Word;
      constructor Create;override;
      destructor Destroy;override;
      procedure Paint;override;
      procedure setHP(const val:integer);virtual;
      property HP:integer read fHP write setHP;
    public
      function Approach(const P:TPoint):Boolean;
      function getDir(const D:Directions):String;
      function WalkTo(const D: Directions):Boolean;
      function SpeedCoef:Single;
      function AllowedMove:Boolean;
      procedure EndLogic;
      procedure DoAttack(O:TNPC; FX:TGameObjectClass; const S:Integer=-9999);
      function Dodged(const s1,s2:Single):Boolean;
  end;

TDoor = class (TLogicObject)
    State:Word;
    DoorLight:Byte;
    SpawnQuerry:GameObjectList;
    procedure Logic;override;
    procedure Spawn;
    procedure AttachLight;
    procedure RemoveLight;
    constructor Create;override;
    destructor Destroy;override;
    procedure Paint;override;
end;

implementation

uses
  Levels, Hero, Mobs, SoundPlayer, FX;

class function Rand.Get(var Ind:Word; Range:Byte):Byte;
begin
  if Ind=0 then Ind:=1;
  if Ind>High(RandomNums) then Ind:=1;
  Result:=Round((Range-1)*RandomNums[Ind]/100);
  TLog.writeLog(IntToStr(Result)+' '+IntToStr(Range));
  Ind:=Ind+1
end;

constructor TStaticText.Create;
Begin
  Text:=S;
  Position:=P;
  Size:=siz;
  Color:=TAlphaColorRec.Create(C);
End;

constructor TFadingText.Create;
Begin
  inherited;
  TTL:=0;
  Size:=siz;
End;

procedure TStaticText.Paint;
begin
  TPainter.Paint(Text,Position,size,Color);
end;

procedure TFadingText.Paint;
begin
  TPainter.Paint(Text,Position,TTL,size,Color);
  TTL:=TTL+0.4;
  if TTL>=20 then
    TMap.FadingTexts.Remove(Self)
end;

constructor TGameObject.Create;
begin
  fcollidable:=false;
  Randitem:=0;
end;

constructor TFloor.Create;
begin
  Name := 'Floor';
  //Name := 'FX';
  Animation:=TTimeLineAnimation.getAnimation(name,name);
  Kind(wtGround1);
  //Animation:=TTimeLineAnimation.getAnimation(name,'Pyro');
  inherited;
end;

procedure TFloor.Kind(const W: wallType);
begin
  case w of
    wtGround1:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'Floor');  fCollidable:=false end;
    wtGround2:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'Floor2'); fCollidable:=false end;
    wtGround3:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'Floor3'); fCollidable:=false end;
    wtWallUp1:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallUp1');fCollidable:=true end;
    wtWallUp2:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallUp2');fCollidable:=true end;
    wtWallUp3:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallUp3');fCollidable:=true end;
    wtWallUp4:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallUp4');fCollidable:=true end;
    wtWallUp5:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallUp5');fCollidable:=true end;
    wtWallUp6:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallUp6');fCollidable:=true end;
    wtWallUp7:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallUp7');fCollidable:=true end;
    wtWallUp8:   Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallUp8');fCollidable:=true end;
    wtWallDown1: Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallDown1');fCollidable:=true end;
    wtWallDown2: Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallDown2');fCollidable:=true end;
    wtWallDown3: Begin Animation:=TTimeLineAnimation.getAnimation(name,'WallDown3');fCollidable:=true end;
  end;
end;

constructor TNPC.Create;
begin
  inherited;
  Animation:=TTimeLineAnimation.getAnimation(name,getDir(Direction));
  fcollidable:=true;
  MaxHP:=fHP;
  currentSpeed:=0;
  fIsDead:=false;
end;

destructor TNPC.Destroy;
begin
  inherited;
end;

destructor TLogicObject.Destroy;
begin
  //AttachedFX.Destroy;
  inherited;
end;

procedure TLogicObject.Logic;
begin
  //
end;

function TLogicObject.collidable:Boolean;
begin
  result:=(AttachedFX.Count>0) or fCollidable
end;

constructor TLogicObject.Create;
begin
  AttachedFX:=GameObjectList.create;
  Direction:=dDown;
end;

function TNPC.Dodged(const s1: Single; const s2: Single):Boolean;
  var dx:Single;Chance:Byte;
begin
  Result:=false;
  dx:=s2-s1;
  if dx>0 then
    Begin
      if dx<=2 then
        Chance:=Round(dx*45)
          else
            Chance:=90;
      if Rand.Get(TNPC.dodgeChances,100)<Chance then
        Result:=true
    End
end;

function TNPC.Speed100:Word;
begin
  result:=Round((speed-1)*100+1)
end;

function TNPC.isDead:Boolean;
begin
  result:=fIsDead;
end;

procedure TNPC.DoAttack(O: TNPC; FX:TGameObjectClass; const S:Integer);
  var A:Integer;
begin
  //try to dodge
if not Dodged(Speed,O.Speed) then
    Begin
      O.AttachFX(FX.create as TFX);
      if S=-9999 then
        A:=Attack
          else
            A:=S;
      O.HP:=A;
      //burn zombie to death
      if (O is TZombie)and(O.isDead)and(FX=TFireball) then O.fisDead:=true;
      TMap.FadingTexts.Add(TFadingText.create(O.Position,IntToStr(A),16,TAlphaColorRec.Red));
    End
      else
        Begin
          TSoundPlayer.PlaySound('Evasion.ogg');
          if O is TEnemy then
            TMap.FadingTexts.Add(TFadingText.create(O.Position,'ÌÈÌÎ',14,TAlphaColorRec.Red))
              else
                TMap.FadingTexts.Add(TFadingText.create(O.Position,'ÌÈÌÎ',14,TAlphaColorRec.Lime));
        End;
end;

function TNPC.SpeedCoef:Single;
begin
 result:=2-TGame.Hero.Speed;
end;

procedure TNPC.EndLogic;
begin
  CurrentSpeed:=CurrentSpeed+Speed*SpeedCoef;
end;

function TNPC.AllowedMove:Boolean;
begin
  Result:=false;
  if not isDead then
    Begin
      if CurrentSpeed>=1 then
        Begin
          Result:=true;
          CurrentSpeed:=CurrentSpeed-1;
        End
    End
end;

procedure TGameObject.Paint;
begin
  TPainter.Paint(name,Animation.getFrame,Position.X,Position.Y);
end;

function TNPC.getDir(const D:Directions):String;
Begin
  case D of
    dNone: Result:='';
    dLeft: Result:='Left';
    dRight: Result:='Right';
    dUp: Result:='Up';
    dDown: Result:='Down';  end;
End;

procedure TNPC.Paint;
  var FX:TGameObject;
begin
  TPainter.Paint(name,Animation.getFrame,Position.X,Position.Y,HP/MaxHP);
  for FX in AttachedFX do
    Begin
      FX.Position:=position;
      if (FX.Animation.frameN>FX.Animation.framesCount-1)and(not (FX as TFX).loop) then
          AttachedFX.Remove(FX)
          else
            FX.Paint
    End;
  if (fisDead) and (AttachedFX.Count=0) then
    TMap.Remove(Self,TMap.NPCs);
end;

procedure TLogicObject.AttachFX(FX: TFX);
begin
  //TMap.MapAdd(FX,Position.X,Position.Y,AttachedFX,true);
  AttachedFX.Add(FX);
end;

procedure TFX.Paint;
begin
  TPainter.Paint(name,Animation.getFrame,Position.X,Position.Y);
end;

function CreateObject(const n: TGameObjectClass):TGameObject;
begin
  Result:=n.create
end;

function TGameObject.Distance(P: TPoint):Word;
begin
  Result:=Round(Position.Distance(P));
end;

function TGameObject.collidable:boolean;
begin
  Result:=fCollidable;
end;

class function TGameObject.deltaP(const D: Directions):TPoint;
Begin
  case D of
    dLeft: Begin Result.x:=-1;Result.y:=0 end;
    dRight: Begin Result.x:=1;Result.y:=0 end;
    dUp: Begin Result.x:=0;Result.y:=-1 end;
    dDown: Begin Result.x:=0;Result.y:=1 end;
    dRightUp: Begin Result.x:=1;Result.y:=-1 end;
    dRightDown: Begin Result.x:=1;Result.y:=1 end;
    dLeftUp: Begin Result.x:=-1;Result.y:=-1 end;
    dLeftDown: Begin Result.x:=-1;Result.y:=1 end;
    else Begin Result.x:=0;Result.y:=0 end;
  end;
End;

function TNPC.WalkTo(const D: Directions):Boolean;
  var P:TPoint;
begin
  result:=false;
  P:=Position+deltaP(D);
  //check offscreen
  if (P.X>0) and (P.X<maxX+1) and (P.Y>0) and (P.Y<maxY+1) then
    //check collisions
    Begin
      result:=TMap.NotCollidable(P);
      if Result then
        Begin
          Position:=P;
          Animation:=TTimeLineAnimation.getAnimation(name,GetDir(D));
          Direction:=D;
        End;
    End;
end;

procedure TNPC.setHP(const val: Integer);
begin
  if fHP-val>0 then fHP:=fHP-val
    else
      Begin
        fIsDead:=true;
        fcollidable:=false;
      End;
  if fHP>MaxHP then maxHP:=fHP
end;

function TNPC.Approach(const P:TPoint):Boolean;
Begin
  Result:=false;
  if Position.X>P.X then if WalkTo(dLeft) then Result:=true;
  if Position.X<P.X then if WalkTo(dRight) then Result:=true;
  if Position.Y>P.Y then if WalkTo(dUp) then Result:=true;
  if Position.Y<p.Y then if WalkTo(dDown) then Result:=true;
End;

constructor TDoor.Create;
begin
  inherited;
  State:=0;
  DoorLight:=0;
  Name := 'Door';
  Direction:=dUp;
  SpawnQuerry:=GameObjectList.create;
  Animation:=TTimeLineAnimation.getAnimation(name,'Crack');
  TSoundPlayer.PlaySound('Earth1.ogg');
  TSoundPlayer.PlaySound('Earth2.ogg');
end;

destructor TDoor.Destroy;
Begin
  //SpawnQuerry.Destroy;
  inherited
End;

procedure TDoor.Logic;
Begin
  if state<7 then
    Begin
      //make a breach
      State:=State+1;
      if State=3 then
        Begin
          Animation:=TTimeLineAnimation.getAnimation(name,'Crack2');
          TSoundPlayer.PlaySound('Earth1.ogg');
          TSoundPlayer.PlaySound('Earth2.ogg');
        End;
      if State=6 then
        Begin
          Animation:=TTimeLineAnimation.getAnimation(name,'Crack3');
          TSoundPlayer.PlaySound('Earth1.ogg');
          TSoundPlayer.PlaySound('Earth2.ogg');
        End;
    End
      else
        if DoorLight<10 then Spawn
End;

procedure TDoor.AttachLight;
  var DL:TDoorLight;
begin
  DoorLight:=1;
  if Direction<>dUp then
    Begin
      DL:=TDoorLight.create;
      AttachFX(DL);
      DL.Position:=Position;
      case Direction of
        dLeft:  Begin DL.Position.X:=Position.X+1;DL.Animation:=TTimeLineAnimation.getAnimation(name,'DangerLeft') end;
        dRight: Begin DL.Position.X:=Position.X-1;DL.Animation:=TTimeLineAnimation.getAnimation(name,'DangerRight') end;
        dUp:    Begin DL.Position.Y:=Position.Y+1;DL.Animation:=TTimeLineAnimation.getAnimation(name,'DangerUp') end;
        dDown:  Begin DL.Position.Y:=Position.Y-1;DL.Animation:=TTimeLineAnimation.getAnimation(name,'DangerDown') end;
      end;
    End;
end;

procedure TDoor.RemoveLight;
begin
  AttachedFX.Clear;
end;

procedure TDoor.Spawn;
  var T,O:TGameObject;
      I: Directions;
      P:TPoint;
begin
  if DoorLight=0 then
    AttachLight;
  for O in SpawnQuerry do
    Begin
      for I := dNone to dLeftDown do
        Begin
          P:=Position+deltaP(I);
          if TMap.NotCollidable(P) then
            Begin
              T:=SpawnQuerry.Extract(SpawnQuerry.First);
              TMap.MapAdd(T,P.X,P.Y,TMap.NPCs);
              SpawnQuerry.Pack;
              SpawnQuerry.TrimExcess;
              Break;
            End;
        End;
    End;
end;

procedure TDoor.Paint;
  var FX:TGameObject;
begin
  if Direction=dUp then
    TPainter.Paint(name,Animation.getFrame,Position.X,Position.Y);
  for FX in AttachedFX do
    FX.Paint
end;


end.
