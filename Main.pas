unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, System.Generics.Collections,FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Levels, Painter, GameObjects;

const
  kUp=['w','W'];
  kDown=['s','S'];
  kLeft=['a','A'];
  kRight=['d','D'];
  kRest=[' '];

type
  TForm2 = class(TForm)
    Timer1: TTimer;
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Game:TGame;
    { Private declarations }
  public
    Painter:TPainter;
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Game.Destroy;
end;

procedure TForm2.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  //Logic Loop
 // Map
  if CharInSet(keyChar,kUp) then  Key:=vkUp;
  if CharInSet(keyChar,kDown) then  Key:=vkDown;
  if CharInSet(keyChar,kLeft) then  Key:=vkLeft;
  if CharInSet(keyChar,kRight) then  Key:=vkRight;
  if CharInSet(keyChar,kRest) then  Key:=vkSpace;
  Game.Move(Key)
end;

procedure TForm2.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
  var rX,rY:Word;
begin
  if ssLeft in Shift then
    Begin
      rX:=Round(x)div Round(Painter.dx)+1;
      rY:=Round(y)div Round(Painter.dy)+1;
      TGame.Clicked(rX,rY);
    End;
end;

procedure FormRandomArray;
  var Ar:Array[1..505] of byte;
      i,fr,t:word;
      z:LongWord;
      f:Textfile;
Begin
  //fill
  for i := 1 to 5 do
    for z := 0 to 100 do
      Ar[z+(101*(i-1))+1]:=z;
  //toss
  for z := 1 to 1000000 do
    Begin
      fr:=Random(505)+1;
      t:=Random(505)+1;
      if fr<>t then
        Begin
          Ar[fr]:=Ar[fr]+Ar[t];
          Ar[t]:=Ar[fr]-Ar[t];
          Ar[fr]:=Ar[fr]-Ar[t];
        End;
    End;
  AssignFile(F,'c:\rand.txt');
  Rewrite(F);
  for z := 1 to 505 do
    write(F,IntToStr(Ar[z])+',');
  CloseFile(F)
End;

procedure TForm2.FormShow(Sender: TObject);
begin
  TPainter.Init(Form2,maxX,maxY);
  Game:=TGame.create;
  Timer1.Enabled:=true;
  //secret
  //FormRandomArray;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  //Paint Loop
  TLevel.Redraw
end;

end.
