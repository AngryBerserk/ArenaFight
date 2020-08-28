unit Log;

interface

uses
  SysUtils,System.classes;

type
  TLogMessagesType=(lmError,lmSQLQuery,lmGeneral,lmSQLGeneral);
  TLog=class
      class var f:TextFile;
    public
      class var LogData:set of TLogMessagesType;
      class procedure writeLog(const s:String;const Level:TLogMessagesType=lmGeneral);overload;
      class procedure writeLog(const s:Integer;const Level:TLogMessagesType=lmGeneral);overload;
      class procedure writeLog(const s:TStrings;const Level:TLogMessagesType=lmGeneral);overload;
      class constructor Create;
      class destructor Destroy;
  end;

implementation

class constructor TLog.create;
Begin
 AssignFile(f,'app.log');
 LogData:=[lmError,lmSQLQuery,lmGeneral,lmSQLGeneral];
 Rewrite(f);
End;

class procedure TLog.writeLog(const s: string;const Level:TLogMessagesType=lmGeneral);
begin
 if Level in LogData then
    writeln(f,DateToStr(Now)+' '+TimeToStr(Now)+' :  '+s);
end;

class procedure TLog.writeLog(const s: integer;const Level:TLogMessagesType=lmGeneral);
begin
 if Level in LogData then
    writeln(f,DateToStr(Now)+' '+TimeToStr(Now)+' :  '+IntToStr(s));
end;

class procedure TLog.writeLog(const s: TStrings;const Level:TLogMessagesType=lmGeneral);
 var St:String;
begin
 for St in S do
  writeLog(St,Level);
end;

class destructor TLog.Destroy;
Begin
  CloseFile(f);
End;

end.
