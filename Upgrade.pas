unit Upgrade;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, Hero, System.Actions, FMX.ActnList, SoundPlayer, GameObjects,
  Perks;

type
  TFUpgrade = class(TForm)
    LLevelNum: TLabel;
    BNextLevel: TButton;
    LXP: TLabel;
    LAttack: TLabel;
    LHP: TLabel;
    BAttackP: TButton;
    BAttackM: TButton;
    ActionList1: TActionList;
    APoints: TAction;
    BHPM: TButton;
    BHPP: TButton;
    AAttack: TAction;
    AHP: TAction;
    AArchery: TAction;
    LSpeed: TLabel;
    BSpeedM: TButton;
    BSpeedP: TButton;
    ASpeed: TAction;
    LBow: TLabel;
    BBowM: TButton;
    BBowP: TButton;
    LRanged: TLabel;
    LMagic: TLabel;
    LVamp: TLabel;
    BVampP: TButton;
    BVampM: TButton;
    AVamp: TAction;
    LPyro: TLabel;
    BPyroP: TButton;
    BPyroM: TButton;
    APyro: TAction;
    procedure FormShow(Sender: TObject);
    procedure BNextLevelClick(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure BAttackPClick(Sender: TObject);
    procedure BAttackMClick(Sender: TObject);
    procedure BHPMClick(Sender: TObject);
    procedure BHPPClick(Sender: TObject);
    procedure APointsExecute(Sender: TObject);
    procedure AAttackExecute(Sender: TObject);
    procedure AHPExecute(Sender: TObject);
    procedure AArcheryExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ASpeedExecute(Sender: TObject);
    procedure BSpeedPClick(Sender: TObject);
    procedure BSpeedMClick(Sender: TObject);
    procedure BBowPClick(Sender: TObject);
    procedure BBowMClick(Sender: TObject);
    procedure AVampExecute(Sender: TObject);
    procedure BVampPClick(Sender: TObject);
    procedure BVampMClick(Sender: TObject);
    procedure BPyroPClick(Sender: TObject);
    procedure BPyroMClick(Sender: TObject);
    procedure APyroExecute(Sender: TObject);
  private
    PointsLeft:Word;
    HP:Word;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FUpgrade: TFUpgrade;

implementation

uses
  Levels;

{$R *.fmx}

procedure TFUpgrade.AArcheryExecute(Sender: TObject);
begin
  if (not (TGame.Hero.getPerk(TSlingshotPerk).Enabled)) and (not (TGame.Hero.getPerk(TBowPerk).Enabled)) then
    Begin
      LBow.Text:='Ничего';
      BBowM.Enabled:=false
    End
      else
        Begin
          LBow.Text:='Рогатка';
          BBowM.Enabled:=true
        End;
  if (TGame.Hero.getPerk(TBowPerk).Enabled)or(PointsLeft<15) then
    BBowP.Enabled:=false
      else
        BBowP.Enabled:=true;
  if TGame.Hero.getPerk(TBowPerk).Enabled then
    LBow.Text:='Лук';
end;

procedure TFUpgrade.AAttackExecute(Sender: TObject);
begin
  if PointsLeft<5 then
    BAttackP.visible:=False
      else
        BAttackP.visible:=True;
  if TGame.Hero.Attack = 0 then
    BAttackM.visible:=False
      else
        BAttackM.visible:=True
end;

procedure TFUpgrade.AHPExecute(Sender: TObject);
begin
  if PointsLeft=0 then
    BHPP.visible:=False
      else
        BHPP.visible:=True;
  if HP = 1 then
    BHPM.visible:=False
      else
        BHPM.visible:=True
end;

procedure TFUpgrade.APointsExecute(Sender: TObject);
begin
  LXP.Text:='Очков осталось: '+IntToStr(PointsLeft);
  AAttack.Execute;
  AHP.Execute;
  AArchery.Execute;
  ASpeed.Execute;
  AVamp.Execute;
  APyro.Execute;
  TGame.Hero.UpdatePerks;
  Invalidate
end;

procedure TFUpgrade.APyroExecute(Sender: TObject);
begin
  if PointsLeft<5 then
  BPyroP.visible:=False
    else
      BPyroP.visible:=True;
if TGame.Hero.getPerk(TPyroPerk).level = 0 then
  BPyroM.visible:=False
    else
      BPyroM.visible:=True
end;

procedure TFUpgrade.ASpeedExecute(Sender: TObject);
begin
  if (PointsLeft=0)or(TGame.Hero.Speed=2) then
    BSpeedP.visible:=False
      else
        BSpeedP.visible:=True;
  if TGame.Hero.Speed = 1 then
    BSpeedM.visible:=False
      else
        BSpeedM.visible:=True
end;

procedure TFUpgrade.AVampExecute(Sender: TObject);
begin
  if PointsLeft<5 then
  BVampP.visible:=False
    else
      BVampP.visible:=True;
if TGame.Hero.getPerk(TVampirismPerk).level = 0 then
  BVampM.visible:=False
    else
      BVampM.visible:=True
end;

procedure TFUpgrade.BNextLevelClick(Sender: TObject);
begin
  Hide;
  Close;
end;

procedure TFUpgrade.BPyroMClick(Sender: TObject);
begin
  TGame.Hero.getPerk(TPyroPerk).level:=TGame.Hero.getPerk(TPyroPerk).level-1;
  PointsLeft:=PointsLeft+5;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BPyroPClick(Sender: TObject);
begin
  TGame.Hero.getPerk(TPyroPerk).level:=TGame.Hero.getPerk(TPyroPerk).level+1;
  PointsLeft:=PointsLeft-5;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BBowMClick(Sender: TObject);
begin
  //sell bow
  if TGame.Hero.getPerk(TBowPerk).Enabled then
    Begin
      TGame.Hero.getPerk(TBowPerk).Enabled:=false;
      TGame.Hero.getPerk(TSlingShotPerk).Enabled:=true;
      PointsLeft:=PointsLeft+15
    End
      else
        Begin
          TGame.Hero.getPerk(TSlingshotPerk).Enabled:=false;
          PointsLeft:=PointsLeft+15
        End;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BBowPClick(Sender: TObject);
begin
  //buy bow
  if TGame.Hero.getPerk(TSlingshotPerk).Enabled then
    Begin
      TGame.Hero.getPerk(TBowPerk).Enabled:=true;
      TGame.Hero.getPerk(TSlingshotPerk).Enabled:=false;
    End
      else
        Begin
          TGame.Hero.getPerk(TSlingshotPerk).Enabled:=true;
        End;
  PointsLeft:=PointsLeft-15;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BAttackMClick(Sender: TObject);
begin
  TGame.Hero.Attack:=TGame.Hero.Attack-1;
  PointsLeft:=PointsLeft+5;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BAttackPClick(Sender: TObject);
begin
  PointsLeft:=PointsLeft-5;
  TGame.Hero.Attack:=TGame.Hero.Attack+1;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BHPMClick(Sender: TObject);
begin
  PointsLeft:=PointsLeft+1;
  HP:=HP-1;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BHPPClick(Sender: TObject);
begin
  HP:=HP+1;
  PointsLeft:=PointsLeft-1;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BSpeedMClick(Sender: TObject);
begin
  PointsLeft:=PointsLeft+1;
  TGame.Hero.Speed:=TGame.Hero.Speed-0.01;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BSpeedPClick(Sender: TObject);
begin
  TGame.Hero.Speed:=TGame.Hero.Speed+0.01;
  PointsLeft:=PointsLeft-1;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BVampMClick(Sender: TObject);
begin
  TGame.Hero.getPerk(TVampirismPerk).level:=TGame.Hero.getPerk(TVampirismPerk).level-1;
  PointsLeft:=PointsLeft+5;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.BVampPClick(Sender: TObject);
begin
  TGame.Hero.getPerk(TVampirismPerk).level:=TGame.Hero.getPerk(TVampirismPerk).level+1;
  PointsLeft:=PointsLeft-5;
  APoints.Execute;
  TSoundPlayer.PlaySound('Shop.ogg');
end;

procedure TFUpgrade.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TGame.Hero.fHP:=HP;
  TGame.Hero.HP:=0;
  TGame.LevelNum:=TGame.LevelNum+1;
  TGame.StartGame;
end;

procedure TFUpgrade.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  LAttack.Text:='Атака: '+IntToStr(TGame.Hero.Attack);
  LHP.Text:='Здоровье: '+IntToStr(HP);
  LXP.Text:='Очков осталось: '+IntToStr(PointsLeft);
  LSpeed.Text:='Скорость: '+IntToStr(TGame.Hero.Speed100);
  LVamp.Text:='Вампиризм: '+IntToStr(TGame.Hero.getPerk(TVampirismPerk).level);
  LPyro.Text:='Пирокинез: '+IntToStr(TGame.Hero.getPerk(TPyroPerk).level);
end;

procedure TFUpgrade.FormShow(Sender: TObject);
begin
  PointsLeft:=5;
  HP:=TGame.Hero.HP;
  APoints.Execute;
  LLevelNum.Text:='Уровень '+IntToStr(TGame.LevelNum)+' пройден';
end;

end.
