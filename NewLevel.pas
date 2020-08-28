unit NewLevel;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, Packer, GameObjects;

type
  TFNewLevel = class(TForm)
    Button1: TButton;
    LLevelNum: TLabel;
    LAttack: TLabel;
    LHP: TLabel;
    LName: TLabel;
    LDesc: TLabel;
    Timer1: TTimer;
    RHeroOfTheDay: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    HeroOfTheDay:TNPC;
    { Public declarations }
  end;

var
  FNewLevel: TFNewLevel;

implementation

{$R *.fmx}

procedure TFNewLevel.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFNewLevel.FormDestroy(Sender: TObject);
begin
  if HeroOfTheDay<>nil then HeroOfTheDay.Destroy;
end;

procedure TFNewLevel.FormShow(Sender: TObject);
begin
  RHeroOfTheDay.WrapMode:=TImageWrapMode.Stretch;
  LName.Text:=HeroOfTheDay.Textname;
  LAttack.Text:='Атака: '+IntToStr(HeroOfTheDay.Attack);
  LHP.Text:='Здоровье: '+IntToStr(HeroOfTheDay.HP);
  LDesc.Text:=HeroOfTheDay.Desc;
  Timer1.Enabled:=true;
end;

procedure TFNewLevel.Timer1Timer(Sender: TObject);
begin
  RHeroOfTheDay.Bitmap.Assign(TPackers.Packer(HeroOfTheDay.name).getImage(HeroOfTheDay.animation.getFrame));
end;

end.
