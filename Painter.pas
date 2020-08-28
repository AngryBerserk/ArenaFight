unit Painter;

interface

uses
  sysutils, FMX.objects, FMX.Types, FMX.Graphics, Packer, System.Types, FMX.Forms, System.UITypes, Animation;

const
  spriteWidth=5;
  spriteHeight=5;

type
  TPainter=class
    public
      class var dx,
      dy:Single;
      class var screenPoint:Single;
      class var Surface:TImage;
      class constructor create;
      class destructor destroy;
      class procedure Init(Owner:TFMXObject;const w,h:Word);
      //GameObject
      class procedure Paint(const ResName:String;const Anim:String;const x,y:Single);overload;
      //NPC
      class procedure Paint(const ResName:String;const Anim:String;const x,y:Single;const HB:real);overload;
      //Perk
      class procedure Paint(const ResName:String;const Anim:String;const x,y:Single;const F:single; const C:TAlphaColorRec);overload;
      //StaticText
      class procedure Paint(const Text:String;const P:TPoint;const size:byte; const C:TAlphaColorRec);overload;
      //FadingText
      class procedure Paint(const Text:String;const P:TPoint;const TTL:Single;const size:byte; const C:TAlphaColorRec);overload;
  end;

implementation

class constructor TPainter.create;
Begin
  inherited;
End;

class procedure TPainter.Init(Owner: TFmxObject; const w: Word; const h: Word);
begin
  ScreenPoint:=(Owner as TForm).ClientWidth/100;
  //ScreenPoint:=1;
  dx:=spriteWidth*screenPoint;
  dy:=spriteHeight*screenPoint;
  Surface:=TImage.Create(nil);
  Surface.Parent:=Owner;
  Surface.BringToFront;
  Surface.width:=w*dx;
  Surface.Height:=h*dy;
  (Owner as TForm).ClientWidth:=Round(Surface.Width);
  (Owner as TForm).ClientHeight:=Round(Surface.Height);
  Surface.Position.X:=0;
  Surface.Position.Y:=0;
  Surface.WrapMode:=TImageWrapMode.Stretch;
  Surface.Bitmap:=TBitmap.Create;
  Surface.Bitmap.Width:=Round(w*dx);
  Surface.Bitmap.Height:=Round(h*dy);
  Surface.HitTest:=false;
end;

class procedure TPainter.Paint(const ResName:String;const Anim: String; const x: Single; const y: Single);
  var S:TBitmap;
      frr,tor:TRectF;
begin
 S:=TPackers.Packer(ResName).GetImage(Anim);
 if s<>nil then
  Begin
   frr:=TRectF.create(0,0,S.Width*ScreenPoint,S.Height*screenPoint);
   tor:=TRectF.create((x-1)*dx,(y-1)*dy,(x-1)*dx+dx+1,(y-1)*dy+dy+1);
   Surface.Bitmap.Canvas.BeginScene;
   Surface.Bitmap.Canvas.DrawBitmap(S,frr,tor,255,true);
   Surface.Bitmap.Canvas.EndScene;
  End;
end;

class procedure TPainter.Paint(const ResName:String;const Anim: String; const x: Single; const y: Single; const HB: real);
  var S:TBitmap;
      frr,tor:TRectF;
begin
 S:=TPackers.Packer(ResName).GetImage(Anim);
 if s<>nil then
  Begin
   frr:=TRectF.create(0,0,S.Width*dx,S.Height*dy);
   tor:=TRectF.create((x-1)*dx,(y-1)*dy,(x-1)*dx+dx+1,(y-1)*dy+dy+1);
   Surface.Bitmap.Canvas.BeginScene;
   Surface.Bitmap.Canvas.DrawBitmap(S,frr,tor,255,true);
   //draw hitpoints
   if (HB<1)and(HB>0) then
    Begin
     if HB>0.8 then
      Surface.Bitmap.Canvas.Stroke.Color:=TAlphaColorRec.Lime
        else
          if HB>0.4 then
            Surface.Bitmap.Canvas.Stroke.Color:=TAlphaColorRec.Yellow
              else
                Surface.Bitmap.Canvas.Stroke.Color:=TAlphaColorRec.Red;
                Surface.Bitmap.Canvas.Stroke.Thickness:=5;
     Surface.Bitmap.Canvas.DrawLine(PointF((x-1)*dx,
                                           (y-1)*dy),
                                    PointF((x-1)*dx+dx*HB,
                                           (y-1)*dy),
                                           1);
    End;
   Surface.Bitmap.Canvas.EndScene;
  End;
end;

class procedure TPainter.Paint(const Text: string; const P: TPoint; const TTL: Single; const size:byte; const C:TAlphaColorRec);
  var L:Single;R:TRectF;
  const
    sp=2;
    offset=15;
begin
  Surface.Bitmap.Canvas.BeginScene;
  Surface.Bitmap.Canvas.Fill.Color:=TAlphaColor(C);
  Surface.Bitmap.Canvas.Font.Family:='Bookman Old Style';
  Surface.Bitmap.Canvas.Font.Style:=[TFontStyle.fsBold];
  Surface.Bitmap.Canvas.Font.Size:=size;
  L:=Surface.Bitmap.Canvas.Font.Size;
  R:=TRectF.Create((P.X-1)*dx+offset+TTL*sp,
                   (P.y-1)*dy+offset-TTL*sp,
                   (P.X-1)*dx+offset+L*(Text.Length)+TTL*sp,
                   (P.y-1)*dy+offset+L-TTL*sp);
  Surface.Bitmap.Canvas.FillText(R,Text,false,1/(TTL/4),[TFillTextFlag.RightToLeft],TTextAlign.Trailing,TTextAlign.Center);
  Surface.Bitmap.Canvas.EndScene;
end;

class procedure TPainter.Paint(const Text: string; const P: TPoint; const size:byte; const C:TAlphaColorRec);
  var L:Single;R:TRectF;
  const
    sp=2;
    offset=15;
begin
  Surface.Bitmap.Canvas.BeginScene;
  Surface.Bitmap.Canvas.Fill.Color:=TAlphaColor(C);
  Surface.Bitmap.Canvas.Font.Family:='Bookman Old Style';
  Surface.Bitmap.Canvas.Font.Style:=[TFontStyle.fsBold];
  Surface.Bitmap.Canvas.Font.Size:=size;
  L:=Surface.Bitmap.Canvas.Font.Size;
  R:=TRectF.Create((P.X-1)*dx+offset,
                   (P.y-1)*dy+offset,
                   (P.X-1)*dx+offset+L*(Text.Length),
                   (P.y-1)*dy+offset+L);
  Surface.Bitmap.Canvas.FillText(R,Text,false,1,[TFillTextFlag.RightToLeft],TTextAlign.Trailing,TTextAlign.Center);
  Surface.Bitmap.Canvas.EndScene;
end;

class procedure TPainter.Paint(const ResName:String;const Anim: String; const x: Single; const y: Single; const F: single; const C:TAlphaColorRec);
  var S:TBitmap;
      frr,tor,tor2:TRectF;
begin
 S:=TPackers.Packer(ResName).GetImage(Anim);
 if s<>nil then
  Begin
   frr:=TRectF.create(0,0,S.Width*dx,S.Height*dy);
   tor:=TRectF.create((x-1)*dx,(y-1)*dy,(x-1)*dx+dx+1,(y-1)*dy+dy+1);
   Surface.Bitmap.Canvas.BeginScene;
   Surface.Bitmap.Canvas.DrawBitmap(S,frr,tor,255,true);
   //draw fill
   if F>0 then
    Begin
      Surface.Bitmap.Canvas.Stroke.Color:=TAlphaColor(C);
      Surface.Bitmap.Canvas.Fill.Color:=TAlphaColor(C);
      Surface.Bitmap.Canvas.Fill.Kind:=TBrushKind.Solid;
	  
      Surface.Bitmap.Canvas.Stroke.Thickness:=1;
      tor2:=TRectF.create(
                          (x-1)*dx,
                          (y-1)*dy+(dy+1)*(1-F/100),
                          (x-1)*dx+dx+1,
                          (y-1)*dy+dy+1
                          );
      Surface.Bitmap.Canvas.FillRect(tor2,0,0,[TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight],0.7);
      //draw 'Charged'
      if F=100 then
        Begin
          Surface.Bitmap.Canvas.Fill.Color:=TAlphaColorRec.White;
          Surface.Bitmap.Canvas.Font.Family:='Bookman Old Style';
          Surface.Bitmap.Canvas.Font.Style:=[TFontStyle.fsBold];
          Surface.Bitmap.Canvas.Font.Size:=13;
          Surface.Bitmap.Canvas.FillText(tor,'готово',false,1,[TFillTextFlag.RightToLeft],TTextAlign.Trailing,TTextAlign.Center);
        End;
    End;
   Surface.Bitmap.Canvas.EndScene;
  End;
end;

class destructor TPainter.destroy;
begin
  //Surface.Parent:=nil;
  //Surface.Bitmap.Destroy;
  inherited
end;

end.
