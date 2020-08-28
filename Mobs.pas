unit Mobs;

interface

uses
  GameObjects, Animation;

type

TEnemy = class (TNPC)
end;

TZombie = class (TEnemy)
    ResurectTimer:Word;
    isNearDeath:Boolean;
    procedure setHP(const val:integer);override;
    constructor Create;override;
    procedure Resurect;
    function isDead:boolean;override;
    //procedure Paint;override;
    procedure Logic;override;
end;
TOrc = class (TEnemy)
    constructor Create;override;
    procedure Logic;override;
end;
TGuard = class (TEnemy)
    constructor Create;override;
    procedure Logic;override;
end;
TEye = class (TEnemy)
    RandIndex:Word;
    constructor Create;override;
    procedure Logic;override;
end;
TNecromancer = class (TEnemy)
    constructor Create;override;
    procedure Logic;override;
end;
TSkeleton = class (TEnemy)
    constructor Create;override;
    procedure Logic;override;
end;
TMummy = class (TEnemy)
    constructor Create;override;
    procedure Logic;override;
end;

implementation

uses
  Levels, FX, SoundPlayer, Painter, system.UITypes;

constructor TZombie.Create;
begin
  if Random(3)=1 then
    Name := 'Zombie'
      else
        if Random(2)=1 then
        Name:='Zombie1'
          else
            Name:='Zombie2';
  TextName:='Зомби';
  Attack:=1;
  Speed:=0.3;
  fHp:=5;
  Desc:='Всё бы хорошо, если бы не его дурацкая привычка восставать из мёртвых';
  ResurectTimer:=0;
  inherited;
end;

constructor TOrc.Create;
begin
  Name := 'Orc';
  TextName:='Орк убийца';
  Attack:=2;
  Speed:=1;
  fHp:=3;
  Desc:='Быстрый и смертельный, будьте осторожны';
  inherited;
end;

constructor TGuard.Create;
begin
  Name := 'Guard';
  TextName:='Гвардеец';
  Attack:=1;
  Speed:=0.6;
  fHp:=10;
  Desc:='Закованы в тяжёлую броню, неповоротливы';
  inherited;
end;

constructor TEye.Create;
begin
  Name := 'Eye';
  TextName:='Зырик';
  Attack:=1;
  Speed:=0.2;
  fHp:=5;
  Desc:='Остерегайтесь его магических атак!';
  inherited;
end;

constructor TNecromancer.Create;
begin
  Name := 'Necromancer';
  TextName:='Некромант';
  Attack:=1;
  Speed:=0.4;
  fHp:=2;
  Desc:='Против вас лично ничего не имеет, просто воскрешает павших зомби';
  inherited;
end;

constructor TSkeleton.Create;
begin
  Name := 'Skeleton';
  TextName:='Скелет';
  Attack:=1;
  Speed:=0.8;
  fHp:=2;
  Desc:='Оживший скелет. Ничего необычного';
  inherited;
end;

constructor TMummy.Create;
begin
  Name := 'Mummy';
  TextName:='Мумия';
  Attack:=2;
  Speed:=0.5;
  fHp:=15;
  Desc:='Некогда опытный маг за века в погребении растерял часть своих способностей, но всё ещё может дать прикурить';
  inherited;
end;
{
procedure TZombie.Paint;
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
  if (isDead) and (AttachedFX.Count=0) then
    TMap.Remove(Self,TMap.NPCs);
end;
 }
procedure TZombie.setHP(const val: Integer);
begin
  if fHP-val>0 then fHP:=fHP-val
    else
      Begin
        isNearDeath:=true;
        fHP:=0;
        fcollidable:=false;
        Animation:=TTimeLineAnimation.GetAnimation(name,'Dead');
        TMap.NPCs.Move(TMap.NPCs.IndexOf(Self),0);
      End;
  if fHP>MaxHP then maxHP:=fHP;
end;

function TZombie.isDead:Boolean;
begin
  result:=fIsDead or isNearDeath
end;

procedure TZombie.Resurect;
begin
  if ResurectTimer>=100 then
    Begin
      if TMap.NotCollidable(Position) then
        Begin
          isNearDeath:=false;
          fcollidable:=true;
          ResurectTimer:=0;
          Animation:=TTimeLineAnimation.GetAnimation(name,GetDir(Direction));
          TSoundPlayer.PlaySound('Zombie-resurect.wav');
        End;
    End
      else
        ResurectTimer:=ResurectTimer+1;
end;

procedure TZombie.Logic;
begin
  if isNearDeath then
    Resurect
      else
        Begin
          while AllowedMove do
            Begin
                if not Approach(TGame.Hero.Position) then
                if Distance(TGame.Hero.Position)=1 then
                    DoAttack(TGame.Hero,TZombieBite, Attack);
            End;
          EndLogic;
        End;
end;

procedure TOrc.Logic;
begin
  while AllowedMove do
    Begin
        if not Approach(TGame.Hero.Position) then
        if Distance(TGame.Hero.Position)=1 then
          DoAttack(TGame.Hero,TClaws, Attack);
    End;
  EndLogic;
end;

procedure TGuard.Logic;
begin
  while AllowedMove do
    Begin
        if not Approach(TGame.Hero.Position) then
        if Distance(TGame.Hero.Position)=1 then
          DoAttack(TGame.Hero,TClaws,Attack);
    End;
  EndLogic
end;

procedure TEye.Logic;
begin
  while AllowedMove do
    if Rand.Get(RandIndex,5)=0 then DoAttack(TGame.Hero,TSlash);
  EndLogic
end;

procedure TNecromancer.Logic;
  var O:TGameObject;
begin
  while AllowedMove do
    Begin
      if Distance(TGame.Hero.Position)=1 then
            DoAttack(TGame.Hero,TClaws,Attack);
      //summon zombies
      for O in TMap.Objects do
        if O is TZombie then
          if (O as TZombie).isNearDeath then
             Begin
              (O as TZombie).ResurectTimer:=100;
              (O as TZombie).AttachFX(TDeath.Create);
              (O as TZombie).Resurect;
              break
             End;
    End;
  EndLogic
end;

procedure TSkeleton.Logic;
begin
  while AllowedMove do
    Begin
        if not Approach(TGame.Hero.Position) then
        if Distance(TGame.Hero.Position)=1 then
          DoAttack(TGame.Hero,TClaws, Attack);
    End;
  EndLogic;
end;

procedure TMummy.Logic;
begin
  while AllowedMove do
    Begin
        if Rand.Get(Rand.Index,10)<2 then
          //weaken hero
            Begin
            If TGame.Hero.Attack>0 then
              Begin
                TGame.Hero.Attack:=TGame.Hero.Attack-1;
                TMap.FadingTexts.Add(TFadingText.create(TGame.Hero.Position,'НЕМОЩЬ',14,TAlphaColorRec.Red));
                TSoundPlayer.PlaySound('confuse.ogg');
              End
            End
              else
                if not Approach(TGame.Hero.Position) then
                if Distance(TGame.Hero.Position)=1 then
                  DoAttack(TGame.Hero,TClaws, Attack);
    End;
  EndLogic;
end;

end.
