unit Packer;

interface

uses
  Classes, SysUtils, System.Generics.Collections, FMX.Graphics, FMX.Dialogs;

Type
  TRes = class
    private
      procedure LoadBitmap(const F:TStream);
      procedure LoadName(const F:TStream);
      procedure SaveBitmap(const F:TStream);
      procedure SaveName(const F:TStream);
    public
      Name:AnsiString;
      Image:TBitmap;
      procedure Save(const F:TStream);
      procedure LoadFromRes(const F:TStream);
      procedure LoadFromFile(const F:String);
      constructor Create;
      destructor Destroy;override;
  end;
  TPacker = class
    public
      Resources:TObjectList<TRes>;
      name:String;
      constructor Create(const ResName:String='Res');
      destructor Destroy;override;
      procedure Load(const F:String);
      function GetImage(const s:String):TBitmap;
    private
      procedure Save(const F:String);
      function LoadRes(const F:TStream):TRes;
      function AddResource(const F:String):TRes;
  end;
  TPackers = class
        class function Packer(const N:String='default'):TPacker;
      private
        class var Packers:TObjectList<TPacker>;
        class constructor Create;
        class destructor destroy;
  end;

implementation

class constructor TPackers.Create;
begin
  Packers:=TObjectList<TPacker>.Create;
  Packers.OwnsObjects:=true;
end;

class function TPackers.Packer(const N: string = 'default'):TPacker;
  var P:TPacker;
begin
  for P in Packers do
    if P.name=N then
      Begin
        Result:=P;
        Exit
      End;
  Packers.Add(TPacker.Create(N));
  Result:=Packers.Last;
end;

procedure TRes.SaveName(const F: TStream);
  var
    NameBuff:TBytes;
    x:Word;
Begin
  SetLength(NameBuff,Length(name)+1);
  for x := 1 to Length(name) do
    NameBuff[x-1]:=Ord(Name[x]);
  NameBuff[Length(Name)]:=Ord(#13);
  F.Write(NameBuff,Length(NameBuff));
End;

procedure TRes.SaveBitmap(const F: TStream);
  var
      M:TMemoryStream;
      IR:Int64Rec;
Begin
  M:=TMemoryStream.Create;
  Image.SaveToStream(M);
  Int64(IR):=M.Size;
  F.Write(IR.Bytes,8);
  Image.SaveToStream(F);
  M.Destroy;
End;

procedure TRes.Save(const F: TStream);
begin
  SaveName(F);
  SaveBitmap(F);
end;

procedure TRes.LoadName(const F: TStream);
  var
    c:Byte;

Begin
  c:=0;
  Repeat
    F.Read(c,1);
    name:=name+Chr(c);
  Until c=ord(#13);
  Delete(name,length(name),1);
End;

procedure TRes.LoadBitmap(const F: TStream);
  var
    SizeBuffer:TBytes;
    c:Byte;
    Size:Int64;
    MS:TStream;
Begin
  SetLength(SizeBuffer,8);
  F.Read(SizeBuffer,8);
  for c := 0 to 7 do
    Int64Rec(size).Bytes[c]:=SizeBuffer[c];
  MS:=TMemoryStream.Create;
  MS.CopyFrom(F,size);
  Image.LoadFromStream(MS);
  MS.Destroy;
End;

procedure TRes.LoadFromRes(const F: TStream);
begin
  if F.Position<F.Size then
    Begin
      LoadName(F);
      LoadBitmap(F);
    End;
end;

procedure TRes.LoadFromFile(const F: string);
begin
  Image.LoadFromFile(F);
  Name:=AnsiString(ExtractFileName(F));
end;

constructor TRes.Create;
begin
  Image:=TBitmap.Create;
end;

destructor TRes.destroy;
begin
  Image.Destroy;
  inherited
end;

constructor TPacker.Create;
begin
  Resources:=TObjectList<TRes>.Create;
  Load('RES\Objects\'+ResName+'\Res.dat');
  Name:=ResName
end;

destructor TPacker.Destroy;
  //var R:TRes;
begin
  //for R in Resources do
  //  R.destroy;
  Resources.Destroy;
end;

procedure TPacker.Save(const F: string);
  var R:TRes;S:TFileStream;
begin
  try
    S:=TFileStream.Create(F,fmCreate);
    for R in Resources do
      R.Save(S);
    S.Destroy;
  except
    else ShowMessage('Unable to create File "'+F+'"')
  end;
end;

function TPacker.AddResource(const F: string):TRes;
begin
  try
    Result:=TRes.Create;
    Result.LoadFromFile(F);
    Resources.Add(Result)
  except
    else
      ShowMessage('Unable to load File "'+F+'"');
  end;
end;

function TPacker.LoadRes(const F: TStream):TRes;
  var R:TRes;
begin
  R:=TRes.Create;
  R.LoadFromRes(F);
  if R.Name<>'' then
    Begin
      Result:=R;
      Resources.Add(Result);
    End
      else Result:=nil;
end;

procedure TPacker.Load(const F: string);
  var Res:TFileStream;
begin
  Res:=TFileStream.Create(F, fmOpenRead);
  Repeat
  until LoadRes(Res)=nil;
  Res.Destroy;
end;

function TPacker.GetImage(const s: string):TBitmap;
 var Spr:TRes;
begin
  Result:=nil;
  for Spr in Resources do
    if Spr.Name=s then
      Begin
        Result:=Spr.Image;
        Exit
      End;
end;

class destructor TPackers.destroy;
  //var P:TPAcker;
Begin
  //for P in Packers do
  //    P.Destroy;
  Packers.Destroy;
End;

end.
