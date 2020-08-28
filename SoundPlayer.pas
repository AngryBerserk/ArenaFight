unit SoundPlayer;

interface

uses Windows,system.Generics.collections, inifiles, Bass;

Type
  TSoundType=(Sound,Music);
  TSoundClip=class
    name:String;
    SoundType:TSoundType;
    value:HSAMPLE;
    constructor Create(const s:String; const iM:TSoundType=Sound);
  end;
  TSoundPlayer=class
    private
      class var SoundBank:TList<TSoundClip>;
      class function SoundLoaded(const s:String):Integer;
      class function LoadSound(const s:String; const isMusic:TSoundType=Sound):Integer;
    public
      class var isMuteSound:Boolean;
      class var isMuteMusic:Boolean;
      class var MusicVolume:byte;
      class var SoundVolume:byte;
      class constructor Create;
      class destructor Destroy;
      class procedure PlaySound(const s:String; const isMusic:TSoundType=Sound; const Loop:Boolean=false);
      class procedure Mute(v:TSoundType);
      class procedure VolumeUP(v:TSoundType);
      class procedure MuteAll;
  end;

implementation

constructor TSoundClip.Create(const s: string; const iM:TSoundType=Sound);
 var P:PChar;
begin
  name:=s;
  SoundType:=iM;
  P:=PChar(s);
  value:=BASS_StreamCreateFile(False, P, 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
end;

class constructor TSoundPlayer.Create;
 var I:TIniFile;
Begin
  I:=TINIFile.Create('settings.ini');
  SoundVolume:=I.ReadInteger('AUDIO','SoundVolume',100);
  MusicVolume:=I.ReadInteger('AUDIO','MusicVolume',100);
  isMuteSound:=I.ReadBool('AUDIO','isMuteSound',false);
  isMuteMusic:=I.ReadBool('AUDIO','isMuteMusic',false);
  I.Destroy;
  SoundBank:=TList<TSoundClip>.create;
  if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
	begin
		MessageBox(0,'An incorrect version of BASS.DLL was loaded',nil,MB_ICONERROR);
		Halt;
	end;
	// Initialize audio - default device, 44100hz, stereo, 16 bits
	if not BASS_Init(-1, 44100, 0, 0, nil) then
    begin
		  MessageBox(0,'Error initializing audio!',nil,MB_ICONERROR);
		  Halt;
	  end;
End;

class destructor TSoundPlayer.Destroy;
 var T:TSoundClip;I:TIniFile;
Begin
  I:=TIniFile.Create('settings.ini');
  I.WriteInteger('AUDIO','SoundVolume',SoundVolume);
  I.WriteInteger('AUDIO','MusicVolume',MusicVolume);
  I.WriteBool('AUDIO','isMuteSound',isMuteSound);
  I.WriteBool('AUDIO','isMuteMusic',isMuteMusic);
  I.Destroy;
  for T in SoundBank do
   T.Destroy;
  SoundBank.Clear;
  SoundBank.Destroy;

End;

class function TSoundPlayer.SoundLoaded(const s: string):Integer;
 var T:TSoundClip;
begin
 result:=-1;
 for T in SoundBank do
  if T.name=s then
    Begin
      result:=SoundBank.IndexOf(T);
      exit
    End;
end;

class function TSoundPlayer.LoadSound(const s: string; const isMusic:TSoundType=Sound):Integer;
 var T:TSoundClip;
begin
  T:=TSoundClip.Create(s,isMusic);
  SoundBank.Add(T);
  result:=SoundBank.Count-1
end;

class procedure TSoundPlayer.PlaySound(const s: string; const isMusic:TSoundType=Sound;const Loop:Boolean=false);
 var i:Integer;filename:String;
begin
  filename:='RES\Sound\'+s;
  i:=SoundLoaded(filename);
  if i=-1 then i:=LoadSound(filename, isMusic);
  if ((isMusic=Music) and (not isMuteMusic))then
    Begin
      if Loop then
           BASS_ChannelFlags(SoundBank[i].value,BASS_SAMPLE_LOOP,BASS_SAMPLE_LOOP);
      BASS_ChannelSetAttribute(SoundBank[i].value,BASS_ATTRIB_VOL,MusicVolume*0.4/100);
      BASS_ChannelPlay(SoundBank[i].value, False);
    End;
  if ((isMusic=Sound) and (not isMuteSound)) then
    Begin
      BASS_ChannelSetAttribute(SoundBank[i].value,BASS_ATTRIB_VOL,SoundVolume*0.4/100);
      BASS_ChannelPlay(SoundBank[i].value, False);
    End;
end;

class procedure TSoundPlayer.Mute(v:TSoundType);
 var T:TSoundClip;
begin
  if v=Sound then
   Begin
      isMuteSound:=not isMuteSound;
      if isMuteSound then
        Begin
          for T in SoundBank do
            if T.SoundType=Sound then BASS_ChannelPause(SoundBank[SoundBank.IndexOf(T)].value);
        End
          //else
            //Begin
              //for T in SoundBank do
                //if T.SoundType=Sound then BASS_ChannelPlay(SoundBank[SoundBank.IndexOf(T)].value,false);
            //End;
   End
    else
      Begin
        isMuteMusic:=not isMuteMusic;
        if isMuteMusic then
          Begin
            for T in SoundBank do
              if T.SoundType=Music then BASS_ChannelPause(SoundBank[SoundBank.IndexOf(T)].value);
          End
            else
              Begin
                for T in SoundBank do
                  if T.SoundType=Music then BASS_ChannelPlay(SoundBank[SoundBank.IndexOf(T)].value,false);
              End;
     End
end;

class procedure TSoundPlayer.VolumeUP(v: TSoundType);
 var T:TSoundClip;
begin
  if v=Music then
    Begin
      if MusicVolume=100 then MusicVolume:=0 else
        MusicVolume:=MusicVolume+10;
      for T in SoundBank do
        if T.SoundType=Music then
          BASS_ChannelSetAttribute(SoundBank[SoundBank.IndexOf(T)].value,BASS_ATTRIB_VOL,MusicVolume*0.4/100);
    End
      else
        Begin
          if SoundVolume=100 then SoundVolume:=0 else
            SoundVolume:=SoundVolume+10;
          for T in SoundBank do
            if T.SoundType=Sound then
              BASS_ChannelSetAttribute(SoundBank[SoundBank.IndexOf(T)].value,BASS_ATTRIB_VOL,SoundVolume*0.4/100);
        End;
end;

class procedure TSoundPlayer.MuteAll;
begin
  if BASS_GetVolume>0 then
    BASS_SetVolume(0)
      else BASS_SetVolume(1)
end;

end.
