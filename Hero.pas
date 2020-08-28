unit Hero;

interface

uses
  system.types, GameObjects, System.UITypes, System.Generics.Collections,SoundPlayer, Animation,
  FMX.Dialogs, Perks, Mobs;

type
  THero = class (TNPC)
    HPatLevelStart:Integer;
    Perks:TObjectList<TPerk>;
    constructor Create;override;
    destructor Destroy;override;
    procedure Paint;override;
    function MouseMove(const P:TPoint):Boolean;
    procedure setHP(const val:integer);override;
    function Key(Key:Word):Boolean;
    function Clicked(Objects:GameObjectList; P:TPoint):Boolean;
    procedure UpdatePerks;
    function ActivatePerks(O:TNPC;PT:PerkType):Boolean;
    procedure AccumulatePerks(PT:PerkType);
    procedure CreatePerks;
    function getPerk(T:TClass):TPerk;
  end;

implementation

uses
  Levels;

constructor THero.Create;
begin
  fHP:=10;
  name:='Hero';
  Attack:=1;
  Speed:=1;
  CreatePerks;
  //GetPerk(TPyroPerk).Level:=10;
  inherited;
end;

procedure THero.setHP(const val: Integer);
begin
  if fHP-val>0 then fHP:=fHP-val
    else
      Begin
        TSoundPlayer.PlaySound('Disappointment.ogg');
        ShowMessage('Вы были повержены!');
        Halt;
      End;
  if fHP>MaxHP then maxHP:=fHP
end;

destructor THero.Destroy;
begin
  Perks.Destroy;
  inherited
end;

function THero.getPerk(T: TClass):TPerk;
  var P:TPerk;
begin
  Result:=nil;
  for P in Perks do
    if P is T then
      Begin
        result:=P;
        Exit
      End;
end;

procedure THero.CreatePerks;
begin
  Perks:=TObjectList<TPerk>.create;
  Perks.Add(TSwordPerk.Create);
  Perks.Add(TBowPerk.Create);
  Perks.Add(TSlingshotPerk.Create);
  Perks.Add(TCritPerk.Create);
  Perks.Add(TVampirismPerk.Create);
  Perks.Add(TPyroPerk.Create);
end;

procedure THero.Paint;
  var P:TPerk;
begin
  inherited;
  for P in Perks do
    P.Paint
end;

function THero.Key(Key: Word):Boolean;
begin
  result:=false;
  if Key=vkUp then Result:=walkTo(dUp);
  if Key=vkDown then Result:=walkTo(dDown);
  if Key=vkLeft then Result:=walkTo(dLeft);
  if Key=vkRight then Result:=walkTo(dRight);
  if Key=vkSpace then Begin AccumulatePerks(ptRest);result:=true end;
  UpdatePerks;
end;

function THero.MouseMove(const P: TPoint):Boolean;
begin
  result:=false;
  if Distance(P)=1 then
    Begin
      if (P.X=Position.X)and(P.Y=Position.Y+1) then result:=walkTo(dDown);
      if (P.X=Position.X)and(P.Y=Position.Y-1) then result:=walkTo(dUp);
      if (P.X=Position.X+1)and(P.Y=Position.Y) then result:=walkTo(dRight);
      if (P.X=Position.X-1)and(P.Y=Position.Y) then result:=walkTo(dLeft);
    End;
end;

procedure THero.UpdatePerks;
  var P:TPerk;curPos:Byte;
begin
  curPos:=1;
  for P in Perks do
    if P.Enabled then
      Begin
        P.Num:=curPos;
        inc(curPos)
      End;
end;

function THero.Clicked(Objects: GameObjectList; P:TPoint):Boolean;
  var O:TGameObject;
begin
  Result:=false;
  //if Objects.Count=0 then
      //Result:=MouseMove(P);
  for O in Objects do
    if (O is TEnemy){and(not (O as TEnemy).isDead)} then
       //Attack enemy
       Begin
        if Distance(O.Position)=1 then
          Begin
            Result:=ActivatePerks(O as TNPC,ptAttack);
            if Result then AccumulatePerks(ptAttack);
          End
            else
              Begin
                Result:=ActivatePerks(O as TNPC,ptRanged);
                if Result then AccumulatePerks(ptRanged);
              End;
       End;
  if Result then AccumulatePerks(ptAttack);
end;

function THero.ActivatePerks(O: TNPC;PT:PerkType):Boolean;
  var P:TPerk;
begin
  Result:=false;
  for P in Perks do
    if P.ActivationType=PT then
      result:=P.Activate(O) or result;
end;

procedure THero.AccumulatePerks(PT: PerkType);
  var P:TPerk;
begin
  for P in Perks do
    if P.Enabled and (P.AccumulationType=PT) then
      P.Fill
end;

end.
