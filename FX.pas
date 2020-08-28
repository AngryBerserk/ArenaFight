unit FX;

interface

uses
  GameObjects, Animation, SoundPlayer, Painter;

type
TSlash = class (TFX)
  constructor Create;override;
end;
TFireball = class (TFX)
  constructor Create;override;
end;
TDeath = class (TFX)
  constructor Create;override;
end;
TClaws = class (TFX)
  constructor Create;override;
end;
TZombieBite = class (TFX)
  constructor Create;override;
end;
TDoorLight = class (TFX)
  counter:Byte;
  //procedure Paint;override;
  constructor Create;override;
end;

implementation

constructor TSlash.Create;
begin
  name:='Attack';
  TSoundPlayer.PlaySound('Slash.ogg');
  inherited;
  Animation:=TTimeLineAnimation.getAnimation(name,'Slash');
  animation.speed:=10;
end;

constructor TFireball.Create;
begin
  name:='FX';
  TSoundPlayer.PlaySound('Fire.ogg');
  inherited;
  Animation:=TTimeLineAnimation.getAnimation(name,'fire');
  animation.speed:=50;
end;

constructor TDeath.Create;
begin
  name:='FX';
  TSoundPlayer.PlaySound('Confuse.ogg');
  inherited;
  Animation:=TTimeLineAnimation.getAnimation(name,'death');
  animation.speed:=50;
end;

constructor TClaws.Create;
begin
  name:='Attack';
  TSoundPlayer.PlaySound('Slash.ogg');
  inherited;
  Animation:=TTimeLineAnimation.getAnimation(name,'Attack');
  animation.speed:=50;
end;

constructor TZombieBite.Create;
begin
  name:='Attack';
  if Random(2)=0 then
    TSoundPlayer.PlaySound('zombieAttack1.mp3')
      else
        TSoundPlayer.PlaySound('zombieAttack2.mp3');
  inherited;
  Animation:=TTimeLineAnimation.getAnimation(name,'Attack');
  animation.speed:=50;
end;

constructor TDoorLight.Create;
begin
  name:='Door';
  inherited;
  Counter:=0;
  Animation:=TTimeLineAnimation.getAnimation(name,'DangerUp');
  animation.speed:=1000;
end;

end.
