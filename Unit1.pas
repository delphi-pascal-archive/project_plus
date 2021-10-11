unit Unit1;

// Программа Project Plus (P+) предназначена для объединения
// проектов Delphi. При слиянии проектов их файлы и формы должны
// иметь стандартные имнена (unit, form и т.д.) !!!
// Настоятельно рекомендую делать копии основных проектов!!!

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, Buttons, ExtCtrls, Menus;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    XPManifest1: TXPManifest;
    SpeedButton1: TSpeedButton;
    Edit2: TEdit;
    Bevel1: TBevel;
    ListBox1: TListBox;
    Bevel2: TBevel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;

    function DefExc(str,sub:string; pos:integer):boolean;             //Проверка на исключение
    function ReplaceStr(Str,Sub1,Sub2:string):string;                 //Замена подстроки Sub1 на Sub2 строки Str (с проверкой на исключения)
    function FindSub(Str,Sub:string; index1, index2:integer):integer; //Поиск подстроки
    function ExtractNum(str:string; pos:integer):integer;             //Извлечение первого попавшегося числа из строки
    function LengthNum(int:integer):integer;                          //Хрень
    function GetFileName(FullName:string):string;                     //Тоже самое, что ExtractFileName - свое как-то лучше
    function ExtractNumFile(FileName:string):integer;                 //Извлечение первого попавшегося числа из имение файла (поиск с конца)
    function DefMaxFile(FileList:TStringList; Ext:string):integer;    //Определения файла с максимальным номером (по Unit)
    function FindFile(Dir,FileName:string):boolean;                   //Проверка папки на существование файла FileName
    function GetShortName(fullname:string):string;                    //Получение имени unit1.pas->unit1

    procedure RemakerFile(FileName:string);                           //Переделка файла
    procedure RemakerFiles(List:TStringList);                         //Переделка файлов из списка
    function  NewNameFile(FullName:string):string;                    //Почти как RenameFile
    procedure RenameFiles(List:TStringList);                          //Переименовывание файлов из списка
    procedure CopyFiles(Dir1,Dir2:string);                            //Копирование файлов Dir1 -> Dir2
    procedure LoadDelphiProject(filename:string);
    procedure ReMakeDelphiProject;
    procedure DeleteFiles(Dir:string);                         //Очищение папки

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Excepts,BasicFiles,AdditionFiles,ExcList:TStringList; //Исключения, доп. и осн. файлы
  max,chdr,indmax:integer;
  maxfile:string;
implementation

uses Unit2;

{$R *.dfm}

procedure TForm1.LoadDelphiProject(filename:string);
var
i,k,ind:integer;
str:string;
Text:TStringList;
begin
Text:=TStringList.Create;
Text.LoadFromFile(FileName);
     ListBox1.Items.Add('Загрузка файла - OK');
     ListBox1.Items.Add('');
     ind:=0;
for i:=0 to Text.Count-1 do begin
     ListBox1.Items[listbox1.Count-1]:='Анализ строки - '+Text.Strings[i];
     Listbox1.ItemIndex:=listbox1.Count-1;
Text.Strings[i]:=AnsiLowerCase(Trim(Text.Strings[i]));
 if Copy(Text.Strings[i],length(Text.Strings[i])-1,2)='};' then begin        //unitN in 'unitN.pas' {formN}; - последняя строчка
 Text.Strings[i]:=Copy(Text.Strings[i],1,length(Text.Strings[i])-2)+'},';    //unitN in 'unitN.pas' {formN}, - для дальнейшего добавления
   for k:=0 to AdditionFiles.Count-1 do begin
     if ExtractFileExt(AdditionFiles.Strings[k])='.pas' then begin
       ind:=ind+1;
       Text.Insert(i+ind,GetShortName(AdditionFiles.Strings[k])+' in '+chr(39)+GetFileName(AdditionFiles.Strings[k])+chr(39)+' {form'+ inttostr(ExtractNumFile(AdditionFiles.Strings[k]))+'},');
     end;
   end;
 str:=Text.Strings[i+ind];
 Delete(str,length(str),1);
 Text.Strings[i+ind]:=str+';';
 break;
 end;
end;
for i:=0 to Text.Count-1 do begin
 if Copy(Text.Strings[i],length(Text.Strings[i])-1,2)=');' then begin       //application.createform(tformN, formN); - последняя строчка
   for k:=0 to AdditionFiles.Count-1 do begin
     if ExtractFileExt(AdditionFiles.Strings[k])='.pas' then begin
       Text.Insert(i+1,'Application.CreateForm(TForm'+inttostr(ExtractNumFile(AdditionFiles.Strings[k]))+', Form'+inttostr(ExtractNumFile(AdditionFiles.Strings[k]))+');');
     end;
   end;
  break;
 end;
end;
   ListBox1.Items[listbox1.Count-1]:='Анализ текста - OK';
Text.SaveToFile(filename);
   ListBox1.Items.Add('Сохранение файла - OK');
Text.Free;
end;

procedure TForm1.ReMakeDelphiProject;
var
i:integer;
begin
for i:=0 to BasicFiles.Count-1 do begin
 if ExtractFileExt(BasicFiles.Strings[i])='.dpr' then begin
 Listbox1.Items.Add('-----Переделка файла '+GetFileName(BasicFiles.Strings[i]+'-----'));
  LoadDelphiProject(BasicFiles.Strings[i]);
  exit;
 end;
end;
showmessage('.dpr файл не найден.');
end;

function TForm1.GetShortName(fullname:string):string;
begin
fullname:=GetFileName(FullName);
Result:=Copy(FullName,1,pos('.',FullName)-1);
end;

function TForm1.FindFile(Dir,FileName:string):boolean;
var
DirInfo: TSearchRec;
r : Integer;
begin
r := FindFirst(dir+'*.*', FaAnyfile, DirInfo);
while r = 0 do begin
if ((DirInfo.Attr and FaDirectory<>FaDirectory) and (DirInfo.Attr and FaVolumeId<>FaVolumeID)) then
 if FileName=Dir+DirInfo.Name then begin
 Result:=true;
 exit;
 end;
 r := FindNext(DirInfo);
end;
SysUtils.FindClose(DirInfo);
Result:=false;
end;

procedure TForm1.CopyFiles(Dir1,Dir2:string);
var
DirInfo: TSearchRec;
r : Integer;
begin
r := FindFirst(dir1+'*.*', FaAnyfile, DirInfo);
while r = 0 do begin
if ((DirInfo.Attr and FaDirectory<>FaDirectory) and (DirInfo.Attr and FaVolumeId<>FaVolumeID)) then
 CopyFile(PAnsiChar(Dir1+DirInfo.Name),PAnsiChar(Dir2+DirInfo.Name),LongBool(0));
 r := FindNext(DirInfo);
 application.ProcessMessages;
end;
SysUtils.FindClose(DirInfo);
end;

procedure TForm1.DeleteFiles(Dir:string);
var
DirInfo: TSearchRec;
r : Integer;
begin
r := FindFirst(dir+'*.*', FaAnyfile, DirInfo);
while r = 0 do begin
if ((DirInfo.Attr and FaDirectory<>FaDirectory) and (DirInfo.Attr and FaVolumeId<>FaVolumeID)) then
 DeleteFile(PAnsiChar(Dir+DirInfo.Name));
 r := FindNext(DirInfo);
 application.ProcessMessages;
end;
SysUtils.FindClose(DirInfo);
end;


procedure TForm1.RemakerFiles(List:TStringList);
var
ext:string;
i:integer;
begin
for i:=List.count-1 downto 0  do begin
ext:=ExtractFileExt(List.Strings[i]);
 if (ext='.pas') or (ext='.dfm') then begin
  RemakerFile(List.Strings[i]);
 end;
end;
end;

procedure TForm1.RemakerFile(FileName:string);
var
i:integer;
TextFile:TStringList;
begin
  Listbox1.Items.Add('-----Переделка файла '+GetFileName(FileName)+'-----');
TextFile:=TStringList.Create;
Textfile.LoadFromFile(filename);
  Listbox1.Items.Add('Загрузка файла - OK');
  ListBox1.Items.Add('');
  application.ProcessMessages;
for i:=0 to TextFile.Count-1 do begin
  Listbox1.Items[listbox1.Count-1]:='Анализ строки - '+TextFile.Strings[i];
  listbox1.ItemIndex:=listbox1.Count-1;
 TextFile.Strings[i]:=ReplaceStr(AnsiLowerCase(TextFile.Strings[i]),'form','form');
 TextFile.Strings[i]:=ReplaceStr(AnsiLowerCase(TextFile.Strings[i]),'unit','unit');
  sleep(1); application.ProcessMessages;
end;
  Listbox1.Items[listbox1.Count-1]:='Анализ текста - OK';
  TextFile.SaveToFile(filename);
  listbox1.Items.Add('Сохранение файла - OK');
TextFile.Free;
end;

procedure TForm1.RenameFiles(List:TStringList);
var
i:integer;
begin
Listbox1.Items.Add('-----Переименование файлов-----');
for i:=List.count-1 downto 0 do begin
 Listbox1.Items.Add(GetFileName(List.Strings[i])+' -> ');
 List.Strings[i]:=NewNameFile(List.Strings[i]);
 Listbox1.Items[listbox1.Count-1]:=Listbox1.Items[listbox1.Count-1]+GetFileName(List.Strings[i])+' - OK';
 listbox1.ItemIndex:=listbox1.Count-1;
end;
end;

function TForm1.NewNameFile(FullName:string):string;
var
num:integer;
path,filename:string;
begin
FileName:=GetFileName(FullName);
Path:=ExtractFilePath(FullName);
num:=ExtractNumFile(FileName);
if num<>0 then begin
 Delete(filename,pos(inttostr(num),filename),lengthNum(num));
 Insert(inttostr(num+max),FileName,pos('.',filename));
end else Insert('1',FileName,pos('.',filename));
FileName:=Path+FileName;
RenameFile(FullName,FileName);
Result:=FileName;
end;

function TForm1.DefMaxFile(FileList:TStringList; Ext:string):integer;
var
i,best:integer;
FileName:string;
Num:integer;
begin
best:=0;
for i:=0 to FileList.Count-1 do begin
 if ExtractFileExt(AnsilowerCase(FileList.Strings[i]))=ext then begin
  FileName:=GetFileName(FileList.Strings[i]);
  Num:=ExtractNumFile(FileName);
  if Best<Num then begin
   best:=Num;
   maxfile:=FileList.Strings[i];
   indmax:=i;
  end;
 end;
end;
Result:=best;
end;


function TForm1.GetFileName(FullName:string):string;
var
i:integer;
begin
for i:=length(FullName) downto 1 do begin
 if FullName[i]='\' then begin
  Result:=Copy(FullName,i+1,length(FullName)-i);
  exit;
 end;
end;
Result:=FullName;
end;

function TForm1.ExtractNumFile(FileName:string):integer;
var
num:string;
p,i,v:integer;
begin
p:=pos('.',filename);
for i:=p-1 downto 1 do begin
 if TryStrtoInt(FileName[i],v)=true then begin
  num:=filename[i]+num;
 end else break;
end;
if num='' then num:='0';
Result:=strtoint(num);
end;

function TForm1.FindSub(Str,Sub:string; index1, index2:integer):integer;
var
i:integer;
begin
for i:=index1 to index2 do begin
 if Copy(Str,i,Length(Sub))=sub then begin
 Result:=i;
 exit;
 end;
end;
Result:=0;
end;

function TForm1.ReplaceStr(Str,Sub1,Sub2:string):string;
var
pos,num:integer;
i1,i2:integer;
before,after,s1,s2:string;
begin
pos:=0;
i1:=1;
i2:=length(str);
pos:=FindSub(str,sub1,i1,i2);
while pos<>0 do begin
s1:=sub1;
s2:=sub2;
if DefExc(str,sub1,pos)=false then begin
num:=ExtractNum(str,pos+length(s1));
  s1:=s1+inttostr(num);
  s2:=s2+inttostr(num+max);
Before:=Copy(str,1,pos-1);
After:=copy(str,pos+length(s1),length(str)-length(Before+s1));
  str:=Before+s2+After;
  i1:=pos+length(s2);
end else begin
  i1:=pos+length(s1);
end;
  i2:=length(str);
  pos:=FindSub(str,sub1,i1,i2);
end;
result:=str;
end;

function TForm1.LengthNum(int:integer):integer;
begin
result:=Length(InttoStr(int));
end;

Function TForm1.DefExc(str,sub:string; pos:integer):boolean;
var
i:integer;
begin
for i:=0 to Excepts.Count-1 do begin
 if copy(str,pos,length(sub)+1)=Excepts.Strings[i] then begin
 result:=true;
 exit;
 end;
end;
result:=false;
end;

function TForm1.ExtractNum(str:string; pos:integer):integer;
var
i,v:integer;
num:string;
begin
num:='';
for i:=pos to Length(str) do begin
 if TryStrtoInt(Str[i],v)=true then begin
 num:=num+str[i];
 end else break;
end;
if num='' then num:='0';
Result:=strtoint(num);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
Excepts.Free;
BasicFiles.free;
AdditionFiles.Free;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
Listbox1.Clear;
//-----Создание списка исключений---
Excepts.Free;
Excepts:=TStringList.Create;
//----Исключения--------------------
Excepts.Add('form.');
Excepts.Add('form)');
Excepts.Add('forms');
Excepts.Add('forma');
Excepts.Add('form(');
Excepts.Add('unit ');
//------Определение макс. unit------
max:=DefMaxfile(BasicFiles,'.pas');
//-----Переделка файлов-------------
RemakerFiles(AdditionFiles);
application.ProcessMessages;
//----------------------------------
RenameFiles(AdditionFiles);
RemakeDelphiProject;
Listbox1.Items.Add('-----Завершение слияния-----');
ListBox1.Items.Add('Копирование файлов...');
CopyFiles(ExtractFilePath(ParamStr(0))+'Project\',edit1.Text);
ListBox1.Items[listbox1.Count-1]:='Копирование файлов - OK';
 application.ProcessMessages;
ListBox1.Items.Add('Очищение каталога Project...');
DeleteFiles(ExtractFilePath(ParamStr(0))+'Project\');
ListBox1.Items[listbox1.Count-1]:='Очищение каталога Project - OK';

edit1.Text:=''; edit2.Text:='';
speedbutton2.Enabled:=false;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
chdr:=0;
form2.show;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
chdr:=0;
form2.show;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
chdr:=1;
form2.Show;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
form1.Close;
end;

procedure TForm1.N5Click(Sender: TObject);
begin
showmessage('Автор программы Бышин Артем'+#13#10+
            'Версия программы 1.0');
end;

end.

