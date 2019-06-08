// ------------------------------------ //
// clibtool by Yoti, Copyright (c) 2019 //
// ------------------------------------ //

program clibtool;

{$APPTYPE CONSOLE}

uses
  Classes,
  ClassesMy,
  SysUtils,
  SysUtilsMy,
  Windows;

const
  TitleStr: String = 'CLIB tool by Yoti';
  FileSign: AnsiString = 'CLIB' + #$1A + #$1E + #$00 + #$00 + #$00 + #$00 + #$00
                       + #$01 + #$00 + #$00 + #$00; // далее идёт имя файла и $00

type
  Entry = Packed Record
    Offset: Int64;
    Size: Int64;
  end;

var
  ConsoleTitle: String;

procedure UnPack(inFileName, outDirName: String);
var
  inMS: TMemoryStream;
  Head: Array of AnsiChar;
  Sign: AnsiString;
  Count: Integer;
  i: Integer;
  Name: AnsiString;
  aChr: AnsiChar;
  MyEntry: Entry;
begin
  inMS:=TMemoryStream.Create;
  inMS.LoadFromFile(inFileName);

  SetLength(Head, Length(FileSign));
  FillChar(Head[0], Length(Head), $00);
  inMS.Read(&Head[1], Length(Head));
  Sign:='';
  SetString(Sign, PAnsiChar(@Head[1]), Length(Head));
  if (Sign <> FileSign) then begin
    WriteLn('Wrong file header!');
    Exit;
  end;

  if (DirectoryExists(outDirName) = True) then begin
    WriteLn('Output dir exist!');
    Exit;
  end else begin
    MkDir(outDirName);
  end;

  repeat // пропускаем имя файла неизвестной длины
    inMS.Read(aChr, SizeOf(aChr));
  until (aChr = #$00);

  inMS.Read(Count, SizeOf(Count));
  WriteLn('Count: ' + IntToStr(Count));
  for i:=1 to Count do begin
    Name:='';
    repeat
      inMS.Read(aChr, SizeOf(aChr));
      Name:=Name + aChr;
    until (aChr = #$00);
    Name:=Copy(Name, 1, Length(Name) - 1);

    inMS.Seek(1, soFromCurrent);
    inMS.Read(MyEntry, SizeOf(MyEntry));

    WriteLn(String(Name) + ' (' + IntToStr(MyEntry.Size) + ')');
    SaveStreamToFileSafe(inMS, outDirName + '\' + String(Name), MyEntry.Offset, MyEntry.Size);
  end;

  inMS.Free;
  WriteLn('The job was done.');
end;

function FillList(const DirName: String; const Files, Dirs, SubDirs: Boolean; List: TStringList): Cardinal;
var
  IsFound: Boolean;
  MySearchRec: TSearchRec;
begin
  Result:=0;
  IsFound:=SysUtils.FindFirst(DirName + '\*.*', faAnyFile, MySearchRec) = 0;

  while (IsFound = True) do begin
    if ((MySearchRec.Name <> '.') and (MySearchRec.Name <> '..')) then begin
      if ((DirectoryExists(DirName + '\' + MySearchRec.Name) = True) and (Dirs = True)) then begin
        List.Add(MySearchRec.Name);
        Inc(Result);

        if (SubDirs = True)
        then FillList(DirName + '\' + MySearchRec.Name, Files, Dirs, SubDirs, List);
      end;

      if ((FileExists(DirName + '\' + MySearchRec.Name) = True) and (Files = True)) then begin
        List.Add(MySearchRec.Name);
        Inc(Result);
      end;
    end;

    IsFound:=SysUtils.FindNext(MySearchRec) = 0;
  end;

  SysUtils.FindClose(MySearchRec);
end;

procedure RePack(inDirName, outFileName: String);
var
  outFS: TFileStream;
  tmpSL: TStringList;
  Count: Cardinal;
  Offset: Int64;
  i: Cardinal;
  s: AnsiString;
  b: Array[0..1] of Byte;
  MyEntry: Entry;
begin
  if (FileExists(outFileName) = True) then begin
    WriteLn('Output file exist!');
    Exit;
  end;

  outFS:=TFileStream.Create(outFileName, fmCreate or fmOpenWrite or fmShareExclusive);
  tmpSL:=TStringList.Create;
  outFS.Write(&FileSign[1], Length(FileSign));
  s:=AnsiString(ExtractFileName(outFileName));
  outFS.Write(&s[1], Length(s));
  FillChar(b, SizeOf(b), $00);
  outFS.Write(b, 1);
  Count:=FillList(inDirName, True, False, False, tmpSL);
  WriteLn('Count: ' + IntToStr(Count));
  outFS.Write(Count, SizeOf(Count));
  FillChar(MyEntry, SizeOf(MyEntry), $00);

  Offset:=Length(FileSign);
  Offset:=Offset + Length(AnsiString(ExtractFileName(outFileName)));
  Offset:=Offset + 1;
  Offset:=Offset + SizeOf(Count);
  for i:=0 to Count-1 do begin
    Offset:=Offset + Length(AnsiString(tmpSL.Strings[i]));
    Offset:=Offset + SizeOf(b);
    Offset:=Offset + SizeOf(MyEntry);
  end;

  for i:=0 to Count-1 do begin
    Write(tmpSL.Strings[i]);
    s:=AnsiString(tmpSL.Strings[i]);
    outFS.Write(&s[1], Length(s));
    outFS.Write(b, SizeOf(b));
    FillChar(MyEntry, SizeOf(MyEntry), $00);
    MyEntry.Size:=ClassesMy.GetFileSize(inDirName + '\' + tmpSL.Strings[i]);
    MyEntry.Offset:=Offset;
    Offset:=Offset + MyEntry.Size;
    outFS.Write(MyEntry, SizeOf(MyEntry));
    WriteLn(' (' + IntToStr(MyEntry.Size) + ')');
  end;

  for i:=0 to Count-1 do begin
    AddFileToStreamSafe(inDirName + '\' + tmpSL.Strings[i], outFS);
  end;

  tmpSL.Free;
  outFS.Free;
  WriteLn('The job was done.');
end;

begin
  GetConsoleTitle(PChar(ConsoleTitle), MAX_PATH);
  SetConsoleTitle(PChar(ChangeFileExt(ExtractFileName(ParamStr(0)), '')));
  WriteLn(TitleStr);

  if (ParamCount < 1) then begin
    WriteLn('usage: ' + ExtractFileName(ParamStr(0)) + ' <input> [output]');
    Exit;
  end;
  if ((FileExists(ParamStr(1)) = False)
  and (DirectoryExists(ParamStr(1)) = False)) then begin
    WriteLn('usage: ' + ExtractFileName(ParamStr(0)) + ' <input> [output]');
    Exit;
  end;

  if (FileExists(ParamStr(1)) = True) then begin
    WriteLn('Unpacking ' + ExtractFileName(ParamStr(1)) + '...');
    if (ParamStr(2) <> '')
    then UnPack(ParamStr(1), ParamStr(2))
    else UnPack(ParamStr(1), ChangeFileExt(ExtractFileName(ParamStr(1)), ''));
  end else if (DirectoryExists(ParamStr(1)) = True) then begin
    WriteLn('Repacking ' + ExtractDirName(ParamStr(1)) + '...');
    if (ParamStr(2) <> '')
    then RePack(ParamStr(1), ParamStr(2))
    else RePack(ParamStr(1), ExtractDirName(ParamStr(1)) + '.CLIB');
  end;

  SetConsoleTitle(PChar(ConsoleTitle));
  Exit;
end.
