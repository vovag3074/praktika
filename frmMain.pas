unit frmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, UniProvider,
  InterBaseUniProvider, DBAccess, Uni, Data.DB, FMX.Controls.Presentation,
  FMX.StdCtrls, TgBotApi, MemDS, System.JSON, UniDacFmx, System.IOUtils;

type
  TfmMain = class(TForm)
    StyleBook1: TStyleBook;
    IBC: TUniConnection;
    IBT: TUniTransaction;
    IBP: TInterBaseUniProvider;
    Button1: TButton;
    t1: TTimer;
    l1: TLabel;
    qKat: TUniQuery;
    lbStatus: TLabel;
    qObInv: TUniQuery;
    qObj: TUniQuery;
    UniConnectDialogFmx1: TUniConnectDialogFmx;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure t1Timer(Sender: TObject);
  private
    { Private declarations }
    UserList:TStringList;
  public
    { Public declarations }
    SumInv:Double;
     procedure SendHello;
     procedure ProcMenuS(u: TtgUpdate);
     procedure ProcMenu1(PK:string;  ChatID:Int64);
     procedure ProcMenu2(PK:string;  ChatID:Int64);
  end;

TmyMenu= class(TtgInlineKeyboardMarkup)
  private
    FJSON: TJSONObject;
    KB:TJSONArray;
  public
   constructor Create;
   procedure AddKey(myText,myData: String);
   function ToString:string; virtual;
end;

var
  fmMain: TfmMain;
   Client:TtgClient;


implementation

{$R *.fmx}
procedure ProcCallbackQuery(u: TtgUpdate);
begin
  if Assigned(u.CallbackQuery) and
    Assigned(u.CallbackQuery.Message) and
    Assigned(u.CallbackQuery.Message.Chat)
    then
  begin
   // Client.SendMessageToChat(u.CallbackQuery.Message.Chat.Id, 'Вы выбрали ' + u.CallbackQuery.Data);
    fmMain.ProcMenuS(u);
  end;
end;

procedure ProcMenu(u: TtgUpdate);
var KeyBoard:TMyMenu;
    L:TStringList;
begin
  L:=TStringList.Create;
  L.Clear;
  fmMain.qKat.Active:=True;
  if fmMain.qKat.RecordCount>0 then
  begin  
   KeyBoard := TmyMenu.Create();
   fmMain.qKat.First;
   repeat
    KeyBoard.AddKey('🚩 '+fmMain.qKat.FieldByName('NAME_KAT').AsString,
    '1#'+fmMain.qKat.FieldByName('SOKR_KAT').AsString);
    fmMain.qKat.Next;
   until fmMain.qKat.Eof;
   try
    Client.SendMessageToChat(u.Message.Chat.Id, 'Меню', KeyBoard.ToString);
   finally
    KeyBoard.Free;
   end;
  end;
end;
procedure ProcStart(u: TtgUpdate);
begin
  var KeyBoard := TtgReplyKeyboardMarkup.Create([
    ['/start', '/menu', '/info']
    ]);
  try
    fmMain.SumInv:=0;
    var S:string;
    S := 'Добро пожаловать '+u.Message.From.FirstName+sLineBreak;
    S:= S+ 'Инвестиционная игра'+ sLineBreak+'Доступны следующие комманды: '+
    sLineBreak+' /start - показывает это сообщение'+sLineBreak+
    ' /menu - начало игры'+sLineBreak+' /info - сумма инвестиций';
    Client.SendMessageToChat(u.Message.Chat.Id, S , KeyBoard.ToString);
    fmMain.UserList.Add(u.Message.From.FirstName+';'+intToStr(u.Message.Chat.Id)+
    ';0');
  finally
    KeyBoard.Free;
  end;
end;
procedure ProcInfo(u: TtgUpdate);
begin
 if fmMain.SumInv<=0 then
  Client.SendMessageToChat(u.Message.Chat.Id, 'Нет информации')
  else
   Client.SendMessageToChat(u.Message.Chat.Id, 'Общая сумма инвестиций ='+FloatToStr(fmMain.SumInv));

end;
procedure ProcA(u: TtgUpdate);
begin
  Client.SendMessageToChat(u.Message.Chat.Id, 'Не Ааа!');
end;

procedure TfmMain.Button1Click(Sender: TObject);
begin
  // подключаемся к БД
 IBC.Connect;
 //Запускаем Telegram Bot
  Client := TtgClient.Create('5046045551:AAHMzFJ0IRdnLVr4xBpEl--DkR01aZkCbr8');
 Application.ProcessMessages;
  SendHello;
 //LongPoll
  t1.Enabled:=True;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
{$IFDEF WIN32}
 IBC.Database:=ExtractFilePath(ParamStr(0))+'Data\SCHOOL.FDB';
{$ENDIF} 
{$IFDEF WIN64}
 IBC.Database:=ExtractFilePath(ParamStr(0))+'Data\SCHOOL.FDB';
{$ENDIF} 
{$IFDEF MACOS}
  ibc.SpecificOptions.Values['clientLibrary']:= 'libfbclient.dylib';
  IBC.Database:=TPath.Combine(TPath.GetSharedDocumentsPath,'SCHOOL.FDB');// +'Data\SCHOOL.FDB';
{$ENDIF}
UserList:=TStringList.Create;
UserList.Clear;
end;

procedure TfmMain.ProcMenu1(PK: string; ChatID:Int64);
var KeyBoard2:TMyMenu;
begin
 qObInv.Close;
 qObInv.ParamByName('SN').AsString:=PK;
 qObInv.Active:=True;
 if qObInv.RecordCount>0 then
 begin
  KeyBoard2 := TmyMenu.Create();
   qObInv.First;
   repeat
      KeyBoard2.AddKey('🚒 '+fmMain.qObInv.FieldByName('NAME_OBJ').AsString,
    '2#'+fmMain.qObInv.FieldByName('SOKR_NAME').AsString);
     qObInv.Next;
   until qObInv.Eof;
   try
    Client.SendMessageToChat(ChatId, 'Виды инвестиций', KeyBoard2.ToString);
   finally
    KeyBoard2.Free;
   end;
 end;
end;

procedure TfmMain.ProcMenu2(PK: string; ChatID: Int64);
var KeyBoard2:TMyMenu;
begin
 qObj.Close;
 qObj.ParamByName('SN').AsString:=PK;
 qObj.Active:=True;
 if qObj.RecordCount>0 then
 begin
  KeyBoard2 := TmyMenu.Create();
   qObj.First;
   repeat
      KeyBoard2.AddKey('📍 '+fmMain.qObj.FieldByName('NAME_OBJ').AsString,
     '3#'+IntToStr(fmMain.qObj.FieldByName('SPROS1').AsInteger));
     qObj.Next;
   until qObj.Eof;
   try
    Client.SendMessageToChat(ChatId, 'Объекты инвестиций', KeyBoard2.ToString);
   finally
    KeyBoard2.Free;
   end;
 end;
end;

procedure TfmMain.ProcMenuS(u: TtgUpdate);
var
 i,t:Integer;
 S,p:string;
 ID:Int64;
 var Exp:Double;
begin
 ID:= u.CallbackQuery.Message.Chat.Id;
 S:= u.CallbackQuery.Data;
 i:=Pos('#',S); // до знака = № операции, после - ключ для выборки
 p:=Copy(S,0,i-1);
 t:=StrToInt(p);
 p:=Copy(S,i+1,Length(s)-i);
 if t=1 then
  begin
    ProcMenu1(p,ID);
  end;
 if t=2 then
  begin
    ProcMenu2(p,ID);
  end;
  if t=3 then
  begin
    if TryStrToFloat(p, Exp) then
    SumInv := SumInv+Exp;
    Client.SendMessageToChat(Id,'💰 Цена объекта = '+p);
    Client.SendMessageToChat(Id,'💵 Общая сумма инвестиций = '+FloatToStr(SumInv));
  end;
end;

procedure TfmMain.SendHello;
begin
   var Me: TtgUserResponse;
  if Client.GetMe(Me) then
    with Me do
    try
      if Ok and Assigned(Me.Result) then
      begin
       fmMain.BeginUpdate;
       fmMain.lbStatus.Text:='Подключен к боту: '+ Me.Result.Username;
       Application.ProcessMessages;
      end;
    finally
      fmMain.EndUpdate;
      Free;
    end;
end;

procedure TfmMain.t1Timer(Sender: TObject);
begin
 t1.Enabled:=False;
 Application.ProcessMessages;
  try
    Client.Polling(
      procedure(u: TtgUpdate)
      begin
        ProcCallbackQuery(u);
        if Assigned(u.Message) and Assigned(u.Message.Chat) then
        begin
          if u.Message.Text = '/menu' then
            ProcMenu(u)
          else if u.Message.Text = '/start' then
            ProcStart(u)
          else if u.Message.Text = '/info' then
            ProcInfo(u)
          else if u.Message.Text = 'А?' then
            ProcA(u);
        end;
      end
      );
     Application.ProcessMessages; 
  except
    on E: Exception do
    begin
     l1.Text:='Error: ' + E.Message;
     Application.ProcessMessages;
    end;
  end;
  t1.Enabled:=True;
end;

{ TmyMenu }

procedure TmyMenu.AddKey(myText, myData: String);
begin
 var JSRow := TJSONArray.Create;
    KB.Add(JSRow);
    var JSButton := TJSONObject.Create;
    JSButton.AddPair('text', myText);
    JSButton.AddPair('callback_data', myData);
    JSRow.Add(JSButton);
end;

constructor TmyMenu.Create;
begin
  inherited;
  FJSON := TJSONObject.Create;
  KB := TJSONArray.Create;
end;

function TmyMenu.ToString: string;
begin
  FJSON.AddPair('inline_keyboard', KB);
  Result := FJSON.ToJSON;
end;

end.
