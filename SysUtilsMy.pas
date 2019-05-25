// -------------------------------------- //
// SysUtilsMy by Yoti, Copyright (c) 2019 //
// -------------------------------------- //

unit SysUtilsMy;

interface

uses
  SysUtils;

function IntToStrMy(Value: Integer; Digits: Integer): string; overload;
function IntToStrMy(Value: Int64; Digits: Integer): string; overload;

function ExtractDirName(const DirPath: String): String;
function ExtractFileNameLink(const Link: String): String;

implementation

function IntToStrMy(Value: Integer; Digits: Integer): string;
begin
  FmtStr(Result, '%.*d', [Digits, Value]);
end;
function IntToStrMy(Value: Int64; Digits: Integer): string;
begin
  FmtStr(Result, '%.*d', [Digits, Value]);
end;

function ExtractDirName(const DirPath: String): String;
var
  s: String;
  i: Integer;
begin
  s:=DirPath;
  if (s[Length(s)] = '\')
  then s:=Copy(s, 1, Length(s) - 1);

  i:=LastDelimiter('\', s);
  Result:=Copy(s, i + 1, Length(s) - i);
end;
function ExtractFileNameLink(const Link: String): String;
var
  s: String;
  i: Integer;
begin
  s:=Link;
  if (s[Length(s)] = '/')
  then s:=Copy(s, 1, Length(s) - 1);

  i:=LastDelimiter('/', s);
  Result:=Copy(s, i + 1, Length(s) - i);
end;

end.
