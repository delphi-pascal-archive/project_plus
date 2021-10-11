unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, FileCtrl, StdCtrls;

type
  TForm2 = class(TForm)
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    Label1: TLabel;
    FileListBox1: TFileListBox;
    Label2: TLabel;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure CopyList(List:TStringList; dir:string);
    procedure ReverseList(List:TStringList);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm2.ReverseList(List:TStringList);
var
i:integer;
temp:string;
begin
for i:=(List.Count-1) downto (List.Count-1) div 2 do begin
temp:=List.Strings[i];
List.Strings[i]:=List.Strings[list.count-1-i];
List.Strings[list.count-1-i]:=temp;
end;
end;

procedure TForm2.CopyList(List:TStringList; dir:string);
var
i:integer;
begin
for i:=0 to FileListBox1.count-1 do begin
if (Copy(ExtractFileExt(FileListBox1.Items[i]),1,1)<>'~') and
   (ExtractFileExt(FileListBox1.Items[i])<>'.exe') then begin
if (ExtractFileExt(FileListBox1.Items[i])<>'.res')  then List.Add(dir+'\'+FileListBox1.Items[i]);
end else begin
 DeleteFile(dir+'\'+FileListBox1.Items[i]);
end;
end;
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
begin
//создаем списки файлов основного проекта и дополнительного.
//Копируем файлы дополнительного проекта в папку Project и там их изменяем
form2.Close;
if chdr=0 then begin    //Основной
 BasicFiles.Free;
 BasicFiles:=TStringList.Create;
 BasicFiles.Sort;
CopyList(BasicFiles,DirectoryListBox1.Directory);
form1.Edit1.Text:=DirectoryListbox1.Directory+'\';
end;
if chdr=1 then begin   //Дополнительный
 AdditionFiles.Free;
 AdditionFiles:=TStringList.Create;
 AdditionFiles.Sort;
Form1.CopyFiles(directorylistbox1.Directory+'\', ExtractFilePath(ParamStr(0))+'Project\');   //Копируем файлы в папку Project
CopyList(AdditionFiles,ExtractFilePath(ParamStr(0))+'Project');                              //Добавляем в список файлы с новым путем
form1.Edit2.Text:=ExtractFilePath(ParamStr(0))+'Project\';
end;
if (form1.Edit1.Text<>'') and (Form1.Edit2.Text<>'') then form1.SpeedButton2.Enabled:=true else form1.SpeedButton2.Enabled:=false;
end;

end.
