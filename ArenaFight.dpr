program ArenaFight;



uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {Form2},
  Animation in 'Animation.pas',
  Packer in 'Packer.pas',
  GameObjects in 'GameObjects.pas',
  Painter in 'Painter.pas',
  Hero in 'Hero.pas',
  Levels in 'Levels.pas',
  Upgrade in 'Upgrade.pas' {FUpgrade},
  Log in 'Log.pas',
  SoundPlayer in 'SoundPlayer.pas',
  NewLevel in 'NewLevel.pas' {FNewLevel},
  Perks in 'Perks.pas',
  Mobs in 'Mobs.pas',
  FX in 'FX.pas';

{$R *.res}

begin
  //System.ReportMemoryLeaksOnShutdown:=true;
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TFNewLevel, FNewLevel);
  Application.CreateForm(TFUpgrade, FUpgrade);
  Application.Run;
end.
