unit Animation;

interface

uses
  sysutils, FMX.Graphics, Packer, System.Generics.Collections,IniFiles, system.Classes;

type
  TAnimation=class
    private
      lastTime:TTime;
      frame:integer;
      frames:TStringList;
    public
      speed:Word;//1 - fastest
      framesCount:Word;
      name:String;
      function frameN:integer;
      function getFrame(const N:integer=-1):String;
      constructor Create(const N:String;Values:TStringList);
      destructor Destroy;override;
  end;
  TGlobalAnimation=class
      name:String;
      Animations:TObjectList<TAnimation>;
      constructor Create(const N:String);
      destructor Destroy;override;
    private
      procedure Parse(Ini:TIniFile);
  end;
  TTimeLineAnimation = class
      class function getAnimation(const Anim,Kind:String):TAnimation;
    private
      class var Animations:TObjectList<TGlobalAnimation>;
      class constructor Create;
      class destructor Destroy;
  end;

implementation

function TAnimation.frameN:integer;
Begin
  result:=frame;
End;

function TAnimation.getFrame(const N:integer=-1):String;
  var T:TTime;
begin
  //if FramesCount>0 then
   Begin
    T:=Time();
    if N=-1 then result:=Frames.values[IntToStr(frame)] else result:=Frames.values[IntToStr(N)];
    if (T-lastTime)>Speed/100000000 then
      Begin
        if frame=framesCount then
          frame:=0
            else
              frame:=frame+1;
        lastTime:=T;
      End;
   End
//    else
//      result:=name;
end;

constructor TAnimation.Create;
Begin
  name:=N;
  Frames:=Values;
  framesCount:=Frames.Count-1;
  speed:=200;
End;

destructor TAnimation.destroy;
Begin
  Frames.Destroy
End;

class function TTimeLineAnimation.getAnimation(const Anim,Kind: string):TAnimation;
  var A:TGlobalAnimation;B:TAnimation;
begin
  for A in Animations do
    if A.name = Anim then
      Begin
        for B in A.Animations do
          if B.name = Kind then
            Begin
              result:=B;
              B.frame:=0;
              Exit
            End;
      End;
  Begin
    Animations.Add(TGlobalAnimation.Create(Anim));
    Animations.Last.Parse(TIniFile.Create('RES\Objects\'+Anim+'\animation.dat'));
    Result:=getAnimation(Anim,Kind)
  End;
end;

class constructor TTimeLineAnimation.Create;
Begin
  Animations:=TObjectList<TGlobalAnimation>.create;
End;

constructor TGlobalAnimation.Create;
Begin
  Name:=N;
  Animations:=TObjectList<TAnimation>.create;
End;

procedure TGlobalAnimation.Parse(Ini: TIniFile);
  var Sections,values:TStringList;S:String;
begin
  Sections:=TStringList.Create;
  Ini.ReadSections(Sections);
  for S in Sections do
    Begin
      values:=TStringList.Create;
      Ini.ReadSectionValues(S,values);
      Animations.add(TAnimation.Create(S,values));
    End;
  Ini.Destroy;
  Sections.Destroy;
end;

class destructor TTimeLineAnimation.Destroy;
  var A:TGlobalAnimation;
begin
  For A in Animations do
    Animations.Remove(A);
  Animations.Destroy;
  inherited
End;

destructor TGlobalAnimation.Destroy;
  var A:TAnimation;
begin
  For A in Animations do
    Animations.Remove(A);
  Animations.Destroy;
  inherited;
end;

end.
