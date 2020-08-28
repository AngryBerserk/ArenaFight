unit Levels;

interface

uses
  System.types, Sysutils, System.Generics.Collections,GameObjects, Hero, Upgrade, SoundPlayer, NewLevel, system.UITypes, Mobs, Log, FMX.Dialogs;

const
  maxX = 20;
  maxY = 20;
  waveLength=10;

Type
  TMap = class
{global list} class var Objects:GameObjectList;
    {layer 1} class var Background:GameObjectList;
    {layer 2} class var Doors:GameObjectList;
    {layer 3} class var BackgroundFX:GameObjectList;
    {layer 4} class var NPCs:GameObjectList;
    {layer 5} class var FX:GameObjectList;
    {layer 6} class var FadingTexts:TObjectList<TStaticText>;
    class function EnemyCount:Word;
    class function AsArray(const P:TPoint;Layer:GameObjectList=nil):GameObjectList;
    class function NotCollidable(const P:TPoint):Boolean;
    class Procedure MapAdd(O:TGameObject; const x,y:Word; Layer:GameObjectList; const forced:Boolean=false);
    class Procedure Remove(O:TGameObject; Layer:GameObjectList);
    class Procedure DoorAdd(O:TDoor; const Dir:Directions;const x:Word);
    class procedure CreateWalls;
    class procedure DoorsCreator;
    class constructor create;
    class destructor destroy;
  end;
  TLevel = class
    fwaveNum:Byte;
    waveFinal:Byte;
    turnN:Word;
    RandomIndex:Word;
    procedure Tick;virtual;
    class procedure Redraw;
    class constructor create;
    constructor create;virtual;
    function finalWave(const waveNumber:Byte = 3):Boolean;
    function waveNum:Byte;
    procedure EndLevel;
    procedure isEndLevel(const FinalTurn:Word = 20);
    procedure SpawnMonsterAtDoor(const O:TGameObjectClass; const count:Word; const DoorN:Byte = 255);
  end;
  TGame = class
    class var Hero:THero;
    class var Level:TLevel;
    class var LevelNum:Word;
    constructor create;
    destructor Destroy;override;
    class procedure Move(const Key:Word);
    class procedure Clicked(const X,Y:word);
    class procedure startGame;
    class function LevelConstructor(const L:Word):TLevel;
  end;
  TLevelFinal = class (TLevel)
    procedure Tick;override;
  end;
  TLevel1 = class (TLevel)
    procedure Tick;override;
    constructor create;override;
  end;
  TLevel2 = class (TLevel)
    procedure Tick;override;
    constructor create;override;
  end;
  TLevel3 = class (TLevel)
    procedure Tick;override;
  end;
  TLevel4 = class (TLevel)
    procedure Tick;override;
    constructor create;override;
  end;
  TLevel5 = class (TLevel)
    procedure Tick;override;
  end;
  TLevel6 = class (TLevel)
    procedure Tick;override;
    constructor create;override;
  end;
  TLevel7 = class (TLevel)
    procedure Tick;override;
    constructor create;override;
  end;
  TLevel8 = class (TLevel)
    procedure Tick;override;
  end;
  TLevel9 = class (TLevel)
    procedure Tick;override;
    constructor create;override;
  end;
  TLevel10 = class (TLevel)
    procedure Tick;override;
  end;
  TLevel11 = class (TLevel)
    procedure Tick;override;
    constructor create;override;
  end;
  TLevel12 = class (TLevel)
    procedure Tick;override;
  end;

implementation

uses
  Main,Perks;

class function TMap.AsArray(const P:TPoint;layer:GameObjectList=nil):GameObjectList;
  var O:TGameObject;
begin
  Result:=GameObjectList.create;
  if Layer=nil then Layer:=Objects; //global search
  for O in Layer do
    if O.Position = P then Result.Add(O)
end;

class function TMap.NotCollidable(const P: TPoint):Boolean;
  var O:TGameObject;
begin
  result:=false;
  if (P.X>0)and(P.X<maxX+1)and(P.Y>0)and(P.Y<maxY+1) then
    Begin
      result:=true;
      for O in TMap.AsArray(P) do
        if O.collidable then
          Begin
            result:=false;
            exit
          End;
    End;
end;

class procedure TMap.CreateWalls;
  var x,y:Word;
Begin
  for x := 2 to maxX-1 do
    Begin
      (AsArray(Point(x,1),Background).last as TFloor).Kind(wtWallUp3);
      (AsArray(Point(x,maxY),Background).last as TFloor).Kind(wtWallUp8);
    End;
  for y := 2 to maxY-1 do
    Begin
      (AsArray(Point(1,y),Background).last as TFloor).Kind(wtWallUp2);
      (AsArray(Point(maxX,y),Background).last as TFloor).Kind(wtWallUp1);
    End;
  for x := 2 to maxX-1 do
    Begin
      (AsArray(Point(x,2),Background).last as TFloor).Kind(wtWallDown2);
    End;
  (AsArray(Point(1,1),Background).last as TFloor).Kind(wtWallUp7);
  (AsArray(Point(maxX,1),Background).last as TFloor).Kind(wtWallUp6);
  (AsArray(Point(1,maxY),Background).last as TFloor).Kind(wtWallUp5);
  (AsArray(Point(maxX,maxY),Background).last as TFloor).Kind(wtWallUp4);
End;

class constructor TMap.Create;
  var x,y:Word;
Begin
  Objects:=GameObjectList.Create;
  Objects.OwnsObjects:=false;
  Background:=GameObjectList.create;
  BackgroundFX:=GameObjectList.create;
  FX:=GameObjectList.create;
  NPCs:=GameObjectList.create;
  FadingTexts:=TObjectList<TStaticText>.create;
  Doors:=GameObjectList.create;
  for x := 1 to maxX do
  for y := 1 to maxY do
    Begin
      TMap.MapAdd(TFloor.Create,X,Y,Background);
      if Random(10)=0 then
        (Background.Last as TFloor).Kind(wtGround2)
          else
            if Random(10)=0 then
              (Background.Last as TFloor).Kind(wtGround3)
    End;
  CreateWalls;
End;

class procedure TMap.MapAdd;
Begin
  if (x>0)and(x<=maxX)and(y>0)and(y<=maxY) then
    Begin
      if (NotCollidable(Point(X,Y)))or forced then
        Begin
          Objects.Add(O);
          Objects.Last.Position.X:=x;
          Objects.Last.Position.Y:=y;
          if Layer<>nil then Layer.Add(O)
        End;
    End;
End;

class procedure TMap.Remove(O: TGameObject; Layer: GameObjectList);
  var P:Word;
begin
  P:=Objects.IndexOf(O);
  Layer[Layer.IndexOf(O)]:=nil;
  Objects[P]:=nil;
  Layer.Pack;
  Layer.TrimExcess;
  Objects.Pack;
  Objects.TrimExcess;
end;

class procedure TMap.DoorsCreator;
Begin
  case TMap.Doors.Count of
    0:TMap.DoorAdd(TDoor.Create,dUp,5);
    1:TMap.DoorAdd(TDoor.Create,dDown,9);
    2:TMap.DoorAdd(TDoor.Create,dRight,5);
    3:TMap.DoorAdd(TDoor.Create,dLeft,7);
    4:TMap.DoorAdd(TDoor.Create,dUp,15);
    //5:TMap.DoorAdd(TDoor.Create,dUp,5);
  end;
End;

class procedure TMap.DoorAdd;
  var P:TPoint;
Begin
  case Dir of
    dLeft: if (x>2)and(x<maxY) then
            Begin
              P.X:=1;
              P.Y:=X;
            End;
    dRight: if (x>2)and(x<maxY) then
              Begin
                P.X:=maxX;
                P.Y:=X
              End;
    dUp: if (x>2)and(x<maxX) then
          Begin
            P.X:=x;
            P.Y:=2
          End;
    dDown: if (x>2)and(x<maxX) then
              Begin
                P.X:=x;
                P.Y:=maxY
              End;
  end;
  O.Direction:=Dir;
  MapAdd(O,P.X,P.Y,Doors,true);
End;

class constructor TLevel.create;
Begin
  inherited
End;

constructor TLevel.create;
Begin
  fwaveNum:=1;
  turnN := 0;
  inherited
End;

constructor TGame.create;
Begin
  Hero:=THero.Create;
  TMap.MapAdd(TGame.Hero,9,9,TMap.NPCs);
  //TMap.FadingTexts.Add(TStaticText.create(Point(1,maxY),'Hello world!',25,TAlphaColorRec.White));
  LevelNum:=1;
  //TSoundPlayer.PlaySound('Dungeon.ogg',Music,true);
  StartGame;
End;

destructor TGame.destroy;
begin
  Level.Destroy;
  inherited
end;

class function TGame.LevelConstructor(const L: Word):TLevel;
begin
  case L of
     1:Result:=TLevel1.create;
     2:Result:=TLevel2.create;
     3:Result:=TLevel3.create;
     4:Result:=TLevel4.create;
     5:Result:=TLevel5.create;
     6:Result:=TLevel6.create;
     7:Result:=TLevel7.create;
     8:Result:=TLevel8.create;
     9:Result:=TLevel9.create;
    10:Result:=TLevel10.create;
    11:Result:=TLevel11.create;
    12:Result:=TLevel12.create;
    else
      Result:=TLevelFinal.create;
  end;
  TGame.Hero.HPatLevelStart:=TGame.Hero.HP;
  TGame.Hero.UpdatePerks;
end;

class procedure TGame.startGame;
begin
  Level:=LevelConstructor(LevelNum);
  Level.Tick;
end;

class procedure TGame.Clicked(const X: word; const Y: word);
begin
  if Hero.Clicked(TMap.AsArray(Point(X,Y)),Point(X,Y)) then
      Level.Tick;
  //Level.isEndLevel
end;

class procedure TGame.Move;
begin
  if TGame.Hero.Key(Key) then
    Level.Tick;
end;

class destructor TMap.destroy;
  var O:TGameObject;T:TStaticText;
begin
  for O in Objects Do
    O.Destroy;
  for T in FadingTexts Do
    Fadingtexts.Remove(T);
End;

class procedure TLevel.Redraw;
  var O:TGameObject;T:TStaticText;
begin
  for O in TMap.Background Do
    O.Paint;
  for O in TMap.BackgroundFX Do
    O.Paint;
  for O in TMap.Doors Do
    O.Paint;
  for O in TMap.NPCs Do
    O.Paint;
  for O in TMap.FX Do
      O.Paint;
  for T in TMap.FadingTexts Do
      T.Paint;
end;

function TLevel.waveNum:Byte;
begin
  if (turnN mod waveLength)=0 then result:=turnN div waveLength
    else result:=0;
end;

function TLevel.finalWave(const waveNumber:Byte = 3):Boolean;
Begin
  if (turnN div waveLength)>=waveNumber then result:=true
    else result:=false
End;

procedure TLevel.Tick;
  var O:TGameObject;
begin
  for O in TMap.Objects Do
    if O is TLogicObject then
      (O as TLogicObject).Logic;
  turnN := turnN + 1;
  //TMap.FadingTexts[0].text:=IntToStr(TurnN);
  TGame.Hero.AccumulatePerks(ptMove);
End;

procedure TLevel.EndLevel;
  var Z:Word;
begin
  for z := TMap.NPCs.Count-1 downto 0 do
    if (TMap.NPCs[z] is TNPC)and(TMap.NPCs[z] as TNPC).isDead then
      TMap.Remove(TMap.NPCs[z],TMap.NPCs);
  TMap.NPCs.Pack;
  TMap.NPCs.TrimExcess;
  TMap.Objects.Pack;
  TMap.Objects.TrimExcess;
  FUpgrade.ShowModal;
end;

procedure TLevel.SpawnMonsterAtDoor(const O: TGameObjectClass; const count:Word; const DoorN:Byte = 255);
  var z:Word;
begin
  if DoorN<255 then
    if TMap.Doors.Count<DoorN-1 then
      for z := 1 to DoorN-TMap.Doors.Count do
        TMap.DoorsCreator;
  if TMap.Doors.Count>0 then
    for z := 1 to count do
      Begin
        if DoorN<255 then
          (TMap.Doors[DoorN-1] as TDoor).SpawnQuerry.Add(O.Create)
            else
              (TMap.Doors[Rand.Get(RandomIndex,TMap.Doors.Count)] as TDoor).SpawnQuerry.Add(O.Create);
      End;
end;

procedure TLevelFinal.tick;
begin
  ShowMessage('Вам удалось выйти победителем из этой битвы, поздравляем!');
  Halt
end;

procedure TLevel.isEndLevel;
Begin
  if (TMap.EnemyCount = 0)and(turnN>FinalTurn) then
    EndLevel;
End;

class function TMap.EnemyCount:Word;
  var O:TGameObject;
Begin
  Result:=0;
  for O in TMap.NPCs do
    if (O is TEnemy) and (not (O as TEnemy).isDead) then
      result:=result+1;
  for O in Doors do
    result:=result+ (O as TDoor).SpawnQuerry.Count
End;

//  LEVEL 1

constructor TLevel1.create;
Begin
  FNewLevel.HeroOfTheDay:=TSkeleton.Create;
  TLevel.Redraw;
  FNewLevel.ShowModal;
End;

procedure TLevel1.Tick;
begin
  inherited;
  if TurnN = 2 then TMap.DoorsCreator;
  if TurnN = 7 then SpawnMonsterAtDoor(TSkeleton,2);
  if TurnN = 20 then SpawnMonsterAtDoor(TSkeleton,2);
  if TurnN = 35 then SpawnMonsterAtDoor(TSkeleton,4);
  isEndLevel(35);
End;

//  LEVEL 2

constructor TLevel2.create;
Begin
  FNewLevel.HeroOfTheDay:=TZombie.Create;
  TLevel.Redraw;
  FNewLevel.ShowModal;
End;

procedure TLevel2.Tick;
begin
  inherited;
  if TurnN = 5 then SpawnMonsterAtDoor(TSkeleton,4);
  if TurnN = 10 then SpawnMonsterAtDoor(TZombie,3);
  if TurnN = 15 then SpawnMonsterAtDoor(TSkeleton,3);
  if TurnN = 25 then SpawnMonsterAtDoor(TZombie,3);
  if TurnN = 30 then SpawnMonsterAtDoor(TSkeleton,4);
  isEndLevel(30);
End;

//  LEVEL 3
procedure TLevel3.Tick;
begin
  inherited;
  if TurnN = 3 then TMap.DoorsCreator;
  if TurnN = 1 then SpawnMonsterAtDoor(TZombie,5);
  if TurnN = 5 then SpawnMonsterAtDoor(TSkeleton,5);
  if TurnN = 10 then SpawnMonsterAtDoor(TZombie,5);
  if TurnN = 25 then SpawnMonsterAtDoor(TSkeleton,5);
  if TurnN = 30 then SpawnMonsterAtDoor(TZombie,5);
  if TurnN = 40 then SpawnMonsterAtDoor(TSkeleton,5);
  if TurnN = 45 then SpawnMonsterAtDoor(TZombie,5);
  isEndLevel(45);
End;

//  LEVEL 4

constructor TLevel4.create;
Begin
  FNewLevel.HeroOfTheDay:=TGuard.Create;
  FNewLevel.ShowModal;
End;

procedure TLevel4.Tick;
begin
  inherited;
  if TurnN = 1 then SpawnMonsterAtDoor(TZombie,4);
  if TurnN = 10 then SpawnMonsterAtDoor(TSkeleton,5);
  if TurnN = 10 then Begin SpawnMonsterAtDoor(TZombie,6);SpawnMonsterAtDoor(TGuard,2);End;
  isEndLevel(11);
End;

//  LEVEL 5
procedure TLevel5.Tick;
begin
  inherited;
  if TurnN = 5 then TMap.DoorsCreator;
  if TurnN = 1 then SpawnMonsterAtDoor(TZombie,4);
  if TurnN = 1 then SpawnMonsterAtDoor(TSkeleton,2);
  if TurnN = 10 then Begin SpawnMonsterAtDoor(TZombie,3);SpawnMonsterAtDoor(TSkeleton,3);SpawnMonsterAtDoor(TGuard,2);End;
  if TurnN = 35 then Begin SpawnMonsterAtDoor(TSkeleton,4);SpawnMonsterAtDoor(TZombie,3);SpawnMonsterAtDoor(TGuard,3);End;
  isEndLevel(36);
End;

//  LEVEL 6

constructor TLevel6.create;
Begin
  FNewLevel.HeroOfTheDay:=TOrc.Create;
  FNewLevel.ShowModal;
End;

procedure TLevel6.Tick;
begin
  inherited;
  if TurnN = 1 then SpawnMonsterAtDoor(TSkeleton,7);
  if TurnN = 10 then Begin SpawnMonsterAtDoor(TZombie,3);SpawnMonsterAtDoor(TGuard,3);End;
  if TurnN = 35 then Begin SpawnMonsterAtDoor(TZombie,8);SpawnMonsterAtDoor(TGuard,2);SpawnMonsterAtDoor(TOrc,3);End;
  isEndLevel(36);
End;

//  LEVEL 7

constructor TLevel7.create;
Begin
  FNewLevel.HeroOfTheDay:=TEye.Create;
  FNewLevel.ShowModal;
End;

procedure TLevel7.Tick;
begin
  inherited;
  if TurnN = 1 then SpawnMonsterAtDoor(TGuard,3);
  if TurnN = 10 then Begin SpawnMonsterAtDoor(TGuard,3);SpawnMonsterAtDoor(TOrc,2);End;
  if TurnN = 15 then TMap.DoorsCreator;
  if TurnN = 30 then Begin SpawnMonsterAtDoor(TOrc,2) End;
  if TurnN = 45 then Begin SpawnMonsterAtDoor(TZombie,5);SpawnMonsterAtDoor(TEye,1,1);SpawnMonsterAtDoor(TEye,1,2);SpawnMonsterAtDoor(TEye,1,3);SpawnMonsterAtDoor(TEye,1,4);SpawnMonsterAtDoor(TZombie,8);End;
  isEndLevel(46);
End;

//  LEVEL 8
procedure TLevel8.Tick;
begin
  inherited;
  if TurnN = 1 then SpawnMonsterAtDoor(TZombie,4);
  if TurnN = 2 then SpawnMonsterAtDoor(TSkeleton,4);
  if TurnN = 3 then TMap.DoorsCreator;
  if TurnN = 5 then SpawnMonsterAtDoor(TZombie,4);
  if TurnN = 15 then SpawnMonsterAtDoor(TGuard,1);
  if TurnN = 16 then SpawnMonsterAtDoor(TGuard,1);
  if TurnN = 17 then SpawnMonsterAtDoor(TGuard,1);
  if TurnN = 18 then SpawnMonsterAtDoor(TGuard,1);
  if TurnN = 25 then SpawnMonsterAtDoor(TOrc,1);
  if TurnN = 35 then SpawnMonsterAtDoor(TOrc,1);
  if TurnN = 45 then SpawnMonsterAtDoor(TOrc,1);
  if TurnN = 55 then SpawnMonsterAtDoor(TOrc,1);
  if TurnN = 65 then SpawnMonsterAtDoor(TEye,1);
  if TurnN = 75 then SpawnMonsterAtDoor(TEye,1);
  isEndLevel(76);
End;

//  LEVEL 9

constructor TLevel9.create;
Begin
  FNewLevel.HeroOfTheDay:=TNecromancer.Create;
  FNewLevel.ShowModal;
End;

procedure TLevel9.Tick;
begin
  inherited;
  if TurnN = 1 then Begin SpawnMonsterAtDoor(TOrc,2); SpawnMonsterAtDoor(TZombie,5); End;
  if TurnN = 5 then Begin SpawnMonsterAtDoor(TOrc,2); SpawnMonsterAtDoor(TZombie,5); End;
  if TurnN = 20 then Begin SpawnMonsterAtDoor(TGuard,3);SpawnMonsterAtDoor(TZombie,5);End;
  if TurnN = 25 then Begin SpawnMonsterAtDoor(TNecromancer,1,4);SpawnMonsterAtDoor(TNecromancer,1,2) end;
  isEndLevel(26);
End;

//  LEVEL 10

procedure TLevel10.Tick;
begin
  inherited;
  if TurnN = 1 then Begin SpawnMonsterAtDoor(TGuard,5); End;
  if TurnN = 15 then Begin SpawnMonsterAtDoor(TOrc,4); SpawnMonsterAtDoor(TZombie,10); End;
  if TurnN = 25 then Begin SpawnMonsterAtDoor(TEye,1);SpawnMonsterAtDoor(TEye,1);SpawnMonsterAtDoor(TNecromancer,1);End;
  if TurnN = 45 then Begin SpawnMonsterAtDoor(TNecromancer,1);SpawnMonsterAtDoor(TSkeleton,10); end;
  if TurnN = 65 then Begin SpawnMonsterAtDoor(TEye,1);SpawnMonsterAtDoor(TEye,1);SpawnMonsterAtDoor(TOrc,3); end;
  isEndLevel(66);
End;

//  LEVEL 11

constructor TLevel11.create;
Begin
  FNewLevel.HeroOfTheDay:=TMummy.Create;
  FNewLevel.ShowModal;
End;

procedure TLevel11.Tick;
begin
  inherited;
  if TurnN = 1  then Begin SpawnMonsterAtDoor(TZombie,10);SpawnMonsterAtDoor(TSkeleton,10); End;
  if TurnN = 20 then Begin SpawnMonsterAtDoor(TGuard,5);SpawnMonsterAtDoor(TOrc,4); End;
  if TurnN = 40 then Begin SpawnMonsterAtDoor(TEye,5);SpawnMonsterAtDoor(TNecromancer,4); End;
  if TurnN = 50 then SpawnMonsterAtDoor(TMummy,1);
  if TurnN = 60 then Begin SpawnMonsterAtDoor(TZombie,10);SpawnMonsterAtDoor(TOrc,4); End;
  isEndLevel(61);
End;

//  LEVEL 12

procedure TLevel12.Tick;
begin
  inherited;
  if TurnN = 1  then Begin SpawnMonsterAtDoor(TZombie,10);SpawnMonsterAtDoor(TSkeleton,10); End;
  if TurnN = 10 then Begin SpawnMonsterAtDoor(TGuard,10);SpawnMonsterAtDoor(TOrc,10); End;
  if TurnN = 20 then Begin SpawnMonsterAtDoor(TEye,4);SpawnMonsterAtDoor(TNecromancer,4); End;
  if TurnN = 40 then Begin SpawnMonsterAtDoor(TZombie,10);SpawnMonsterAtDoor(TOrc,10); End;
  if TurnN = 50 then Begin SpawnMonsterAtDoor(TMummy,2);SpawnMonsterAtDoor(TZombie,10);SpawnMonsterAtDoor(TNecromancer,2); End;
  isEndLevel(51);
End;

end.
