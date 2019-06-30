// ------------------------------------- //
// ClassesMy by Yoti, Copyright (c) 2019 //
// ------------------------------------- //

unit ClassesMy;

interface

uses
  Classes, // TStream
  SysUtils; // fmOpenWrite, fmShareExclusive, fmShareDenyWrite

procedure AddFileToStream(const FileName: String; const Stream: TMemoryStream); Overload;
procedure AddFileToStream(const FileName: String; const Stream: TFileStream); Overload;

procedure AddFileToStreamSafe(const FileName: String; const Stream: TMemoryStream); Overload;
procedure AddFileToStreamSafe(const FileName: String; const Stream: TFileStream); Overload;

function GetFileSize(FileName: String): Int64;
function GetFileSizeEx(FileName: String): Int64;

procedure SaveStreamToFile(const Stream: TMemoryStream; const FileName: String; const Offset, Size: Cardinal); Overload;
procedure SaveStreamToFile(const Stream: TFileStream; const FileName: String; const Offset, Size: Cardinal); Overload;

procedure SaveStreamToFileSafe(const Stream: TMemoryStream; const FileName: String; const Offset, Size: Cardinal); Overload;
procedure SaveStreamToFileSafe(const Stream: TFileStream; const FileName: String; const Offset, Size: Cardinal); Overload;

procedure WriteStringToFile(const FileName, TextString: String);
function ReadStringFromFile(const FileName: String): String;

implementation

procedure AddFileToStream(const FileName: String; const Stream: TMemoryStream);
var
  InputFile: TFileStream;
begin
  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Stream.CopyFrom(InputFile, InputFile.Size);
  InputFile.Free;
end;
procedure AddFileToStream(const FileName: String; const Stream: TFileStream);
var
  InputFile: TFileStream;
begin
  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Stream.CopyFrom(InputFile, InputFile.Size);
  InputFile.Free;
end;

function GetFileSize(FileName: String): Int64;
var
  InputFile: TFileStream;
begin
  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Result:=InputFile.Size;
  InputFile.Free;
end;
function GetFileSizeEx(FileName: String): Int64;
var
  InputFile: File of Byte;
begin
  AssignFile(InputFile, FileName);
  Reset(InputFile);
  Result:=FileSize(InputFile);
  CloseFile(InputFile);
end;

procedure AddFileToStreamSafe(const FileName: String; const Stream: TMemoryStream);
var
  InputFile: TFileStream;
begin
  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Stream.Seek(0, soFromEnd);
  Stream.CopyFrom(InputFile, InputFile.Size);
  InputFile.Free;
end;
procedure AddFileToStreamSafe(const FileName: String; const Stream: TFileStream);
var
  InputFile: TFileStream;
begin
  InputFile:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  Stream.Seek(0, soFromEnd);
  Stream.CopyFrom(InputFile, InputFile.Size);
  InputFile.Free;
end;

procedure SaveStreamToFile(const Stream: TMemoryStream; const FileName: String; const Offset, Size: Cardinal);
var
  OutputFile: TFileStream;
begin
  OutputFile:=TFileStream.Create(FileName, fmCreate or fmOpenWrite or fmShareExclusive);
  Stream.Seek(Offset, soFromBeginning);
  OutputFile.CopyFrom(Stream, Size);
  OutputFile.Free;
end;
procedure SaveStreamToFile(const Stream: TFileStream; const FileName: String; const Offset, Size: Cardinal);
var
  OutputFile: TFileStream;
begin
  OutputFile:=TFileStream.Create(FileName, fmCreate or fmOpenWrite or fmShareExclusive);
  Stream.Seek(Offset, soFromBeginning);
  OutputFile.CopyFrom(Stream, Size);
  OutputFile.Free;
end;

procedure SaveStreamToFileSafe(const Stream: TMemoryStream; const FileName: String; const Offset, Size: Cardinal);
var
  TempOffset: Cardinal;
  OutputFile: TFileStream;
begin
  OutputFile:=TFileStream.Create(FileName, fmCreate or fmOpenWrite or fmShareExclusive);
  TempOffset:=Stream.Position;
  Stream.Seek(Offset, soFromBeginning);
  OutputFile.CopyFrom(Stream, Size);
  Stream.Seek(TempOffset, soFromBeginning);
  OutputFile.Free;
end;
procedure SaveStreamToFileSafe(const Stream: TFileStream; const FileName: String; const Offset, Size: Cardinal);
var
  TempOffset: Cardinal;
  OutputFile: TFileStream;
begin
  OutputFile:=TFileStream.Create(FileName, fmCreate or fmOpenWrite or fmShareExclusive);
  TempOffset:=Stream.Position;
  Stream.Seek(Offset, soFromBeginning);
  OutputFile.CopyFrom(Stream, Size);
  Stream.Seek(TempOffset, soFromBeginning);
  OutputFile.Free;
end;

procedure WriteStringToFile(const FileName, TextString: String);
var
  tmpSL: TStringList;
begin
  tmpSL:=TStringList.Create;
  tmpSL.Add(TextString);
  tmpSL.SaveToFile(FileName);
  tmpSL.Free;
end;
function ReadStringFromFile(const FileName: String): String;
var
  tmpSL: TStringList;
begin
  tmpSL:=TStringList.Create;
  tmpSL.LoadFromFile(FileName);
  Result:=tmpSL.Strings[0];
  tmpSL.Free;
end;

end.
