unit Perks;

interface

uses
  GameObjects, Animation, System.UITypes, sysutils;

type
PerkType=(ptMove,ptAttack,ptAttacked,ptInstant,ptRanged,ptRest);
TPerk = class (TGameObject)
    fEnabled:Boolean;
    FillColor:TAlphaColorRec;
    FillPercent:Single;
    Num:Byte;
    Charged:Boolean;
    ActivationType:PerkType;
    Level:Integer;
    AccumulationType:perkType;
    procedure Fill;virtual;
    function getEnabled:Boolean;virtual;abstract;
    property Enabled:Boolean read getEnabled write fEnabled;
    procedure Paint;override;
    function Activate(O:TNPC):Boolean;virtual;
    constructor Create;override;
end;

TCritPerk = class (TPerk)
    constructor Create;override;
    procedure Fill;override;
    function getEnabled:Boolean;override;
    function Activate(O:TNPC):Boolean;override;
end;

TSwordPerk = class (TPerk)
    class var HasSword:Boolean;
    constructor Create;override;
    function getEnabled:Boolean;override;
    function Activate(O:TNPC):Boolean;override;
end;

TBowPerk = class (TPerk)
    constructor Create;override;
    function getEnabled:Boolean;override;
    function Activate(O:TNPC):Boolean;override;
end;

TSlingshotPerk = class (TPerk)
    constructor Create;override;
    function getEnabled:Boolean;override;
    function Activate(O:TNPC):Boolean;override;
end;

TVampirismPerk = class (TPerk)
    constructor Create;override;
    procedure Fill;override;
    function getEnabled:Boolean;override;
    function Activate(O:TNPC):Boolean;override;
end;

TPyroPerk = class (TPerk)
    constructor Create;override;
    procedure Fill;override;
    function getEnabled:Boolean;override;
    function Activate(O:TNPC):Boolean;override;
end;

implementation

uses
  Levels, FX, Painter, SoundPlayer, Mobs;

  constructor TPerk.Create;
begin
  Num:=1;
  Enabled:=false;
  FillPercent:=0;
  Charged:=false;
  FillColor:=TAlphaColorRec.Create(TAlphaColorRec.Lime);
  inherited;
end;

function TPerk.Activate(O: TNPC):Boolean;
begin
  result:=false;
end;

procedure TPerk.Paint;
begin
  if Enabled then
    TPainter.Paint(name,Animation.getFrame,Num,1,FillPercent,FillColor);
end;

procedure TPerk.Fill;
begin
  if Enabled and (AccumulationType<>ptInstant) then
    Begin
      if FillPercent>=100 then
        Begin
          FillPercent:=100;
          Charged:=true;
        End;
    End;
end;

constructor TCritPerk.Create;
begin
  Name := 'Perks';
  Animation:=TTimeLineAnimation.getAnimation(name,'Crit');
  ActivationType:=ptAttack;
  AccumulationType:=ptAttack;
  inherited;
end;

constructor TSwordPerk.Create;
begin
  Name := 'Perks';
  Animation:=TTimeLineAnimation.getAnimation(name,'Sword');
  ActivationType:=ptAttack;
  AccumulationType:=ptInstant;
  TSwordPerk.HasSword:=true;
  inherited;
end;

function TSwordPerk.Activate(O: TNPC):boolean;
begin
  result:=false;
  if Enabled then
    Begin
      TGame.Hero.DoAttack(O,TSlash,TGame.Hero.Attack);
      result:=true
    End;
end;

function TSwordPerk.getEnabled;
begin
  result:=TGame.Hero.Attack>0;
  TSwordPerk.HasSword:=Result;
end;

procedure TCritPerk.Fill;
begin
  FillPercent:=FillPercent+TGame.Hero.Speed100 div 2;
  inherited
end;

function TCritPerk.getEnabled:Boolean;
begin
  result:=(TGame.Hero.Speed>1)and(TSwordPerk.HasSword);
end;

function TCritPerk.Activate(O: TNPC):boolean;
begin
  result:=false;
  if Enabled and Charged then
    Begin
      TGame.Hero.DoAttack(O,TSlash,O.HP);
      Charged:=false;
      FillPercent:=-1*TGame.Hero.Speed100 div 2;
      TMap.FadingTexts.Add(TFadingText.create(O.Position,'Крит',14,TAlphaColorRec.Red));
      result:=true
    End;
end;

constructor TSlingshotPerk.Create;
begin
  Name := 'Perks';
  Animation:=TTimeLineAnimation.getAnimation(name,'Slingshot');
  ActivationType:=ptRanged;
  AccumulationType:=ptInstant;
  inherited;
end;

constructor TBowPerk.Create;
begin
  Name := 'Perks';
  Animation:=TTimeLineAnimation.getAnimation(name,'Bow');
  ActivationType:=ptRanged;
  AccumulationType:=ptInstant;
  inherited;
end;

function TBowPerk.Activate(O: TNPC):boolean;
begin
  result:=false;
  if Enabled then
    Begin
      TGame.Hero.DoAttack(O as TNPC,TSlash,2);
      TSoundPlayer.PlaySound('Bow.ogg');
      result:=true
    End;
end;

function TBowPerk.getEnabled;
begin
  result:=fEnabled
end;

function TSlingshotPerk.Activate(O: TNPC):boolean;
begin
  result:=false;
  if Enabled then
    Begin
      TGame.Hero.DoAttack(O as TNPC,TSlash,1);
      TSoundPlayer.PlaySound('Bow.ogg');
      result:=true
    End;
end;

function TSlingshotPerk.getEnabled;
begin
  result:=fEnabled
end;

constructor TVampirismPerk.Create;
begin
  Name := 'Perks';
  Animation:=TTimeLineAnimation.getAnimation(name,'Vampiric');
  ActivationType:=ptAttack;
  AccumulationType:=ptAttack;
  Level:=0;
  inherited;
end;

procedure TVampirismPerk.Fill;
begin
 FillPercent:=FillPercent+TGame.Hero.Attack;
 inherited
end;

function TVampirismPerk.Activate(O:TNPC):boolean;
  var dHP:Word;
Begin
  result:=false;
  if Enabled and Charged then
    Begin
      if TGame.Hero.HP<TGame.Hero.HPatLevelStart then
        Begin
          dHP:=TGame.Hero.HPatLevelStart-TGame.Hero.HP;
          if dHP>Level then dHP:=Level;
          TMap.FadingTexts.Add(TFadingText.create(Position,'+'+IntToStr(dHP),14,TAlphaColorRec.Lime));
          TSoundPlayer.PlaySound('Heal.ogg');
          TGame.Hero.HP:=-1*dHP;
        End;
      FillPercent:=-1*TGame.Hero.Attack;
      Charged:=false;
      result:=true;
    End;
End;

function TVampirismPerk.getEnabled;
begin
  result:=Level>0
end;

constructor TPyroPerk.Create;
begin
  Name := 'Perks';
  Animation:=TTimeLineAnimation.getAnimation(name,'Pyro');
  ActivationType:=ptRanged;
  AccumulationType:=ptRest;
  Level:=0;
  inherited;
end;

procedure TPyroPerk.Fill;
begin
 FillPercent:=FillPercent+Level/3;
 inherited
end;

function TPyroPerk.Activate(O: TNPC):boolean;
begin
  result:=false;
  if Enabled and (O is TZombie) and ((O as TZombie).isNearDeath) then
    Begin
      O.AttachFX(TFireball.Create);
      O.fisDead:=True;
      result:=true
    End
      else
        if Enabled and (FillPercent>0) then
          Begin
            TGame.Hero.DoAttack(O as TNPC,TFireball,Round(FillPercent));
            Charged:=false;
            FillPercent:=0;
            result:=true
          End;
end;

function TPyroPerk.getEnabled;
begin
  result:=Level>0
end;

end.
