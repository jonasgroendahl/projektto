unit Unit1;
// DEBUGGING : http://console.realtime.co/   -- CHECK IF MESSAGES ARRIVE
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdHTTP,IdSSLOpenSSL;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Gserver : string;
  Gappkey : string;


implementation

{$R *.dfm}

function RandomizeString(strlen : Integer): string;
var
  str : string;
begin
  Randomize;
  str :='abcdefgijklmnopqerstuvwxyzABCDEFGIJKLMOPQERSTUVWXYZ1234567890';
  Result := '';
  while Result.Length < strlen do
    Result := Result + str[Random(Length(str))+1];


end;

// CONNECT, find best available server, sets global variable Gserver used in other calls
procedure TForm1.Button1Click(Sender: TObject);
var
  appkey : string;
  client : TIdHTTP;
  server : string;
  result : string;
  error : string;

begin
    client := TIdHTTP.Create;
    server := 'http://ortc-developers.realtime.co/server/2.1?appkey=';
    appkey := inputbox('Identify server', 'Please type your app key', 'FcRKO8');
    ShowMessage(appkey);
    server := Concat(server,appkey);
    try
      try
         result := client.Get(server);
         // For addresses with https, check http://stackoverflow.com/questions/11554003/tidhttp-get-eidiohandlerpropinvalid-error
         ShowMessage(result);
     except
        on e: Exception do begin
         error := 'An error occured';
       end;
    end;
    finally
      client.Free;
    end;
     Delete(result,1,Pos('"',result));
     result := Copy(result,1,Pos('"',result)-1);
     Gserver := result;
end;

// AUTHENTICATE TO ORTC API server, create channels and set permissions
procedure TForm1.Button2Click(Sender: TObject);
var
  token : string;
  pvt : string;
  appkey : string;
  ttl : string;
  pkey : string;
  tp : string;
  chan : string;
  perm : string;
  chanlist : TStringList;
  morechannel : boolean;
  msg : TStringList;
  nyStreng : string;
  result : string;
  client : TIdHTTP;
  server : string;
  i: Integer;

begin
client := TIdHTTP.Create;
if Gserver = '' then
    ShowMessage('You must find the server first, click the server/version button!')
    else begin
              token := inputbox('Token', 'Please type your AUTH token', 'UserToken');
              pvt := inputbox('PVT', 'Private yes/no  (1 OR 0)', '1');
              while ((pvt <> '1') AND (pvt <> '0')) do
              begin
                pvt := inputbox('PVT', 'Private yes/no  (1 OR 0)', '1');
              end;
              appkey := inputbox('App key', 'Please type your APP key', 'FcRKO8');
              ttl := inputbox('TTL', 'Time to live', '61');
              while (ttl.toInteger < 61) do
              begin
                ttl := inputbox('TTL', 'Time to live', '61');
              end;
              pkey := inputbox('Private key', 'Please type your private key', 'CU4VcHtGQsXZ');
              tp := inputbox('Total Permissons', 'Assign permissions', '2');
              chan := inputbox('Channels', 'Type a channel name', 'blue');
              perm := inputbox('Permission', 'write or read', 'r');
              while (perm<>'r') AND (perm<>'w') do
              begin
                      perm := inputbox('Permission', 'write or read', 'r');
              end;
              morechannel := true;
              chanlist := TStringList.Create;
              chanlist.Add(chan+'='+perm);
              while morechannel = true do
              begin
                   chan := inputbox('Add more channels', 'Type a channel name, "stop" to stop', 'stop');
                   if chan = 'stop' then
                    morechannel := false
                    else begin perm := inputbox('Permission', 'write or read', 'r');
                    chanlist.Add(chan+'='+perm);


                    end;
              end;

              //for i := 0 to chanlist.Count-1 do
               // nyStreng := nyStreng + chanlist[i] + '&';
             // SetLength(nyStreng, nyStreng.Length-1);
              // Another way of adding channel string
              //chanlist.Delimiter := '&';
              //nyStreng := chanlist.DelimitedText;

              ShowMessage(nyStreng);
              msg := TStringList.Create;
              msg.Add('AT='+token);
              msg.Add('PVT='+pvt);
              msg.Add('AK='+appkey);
              msg.Add('TTL='+ttl);
              msg.Add('PK='+pkey);
              msg.Add('TP='+tp);
              for i := 0 to chanlist.Count-1 do
                  msg.Add(chanlist[i]);


              OutputDebugString(PChar(nyStreng));

              server := Gserver;
              //Delete(server,1,Pos('"',server));
              OutputDebugString(PChar(server));
              //server := Copy(server,1,Pos('"',server)-1);
              server := Concat(server,'/authenticate');
              //OutputDebugString(PChar(server));
              //OutputDebugString(PChar(msg[0]));
              //OutputDebugString(PChar(msg[1]));
              result := client.Post(server,msg);
              ShowMessage(result);
              Gappkey := appkey;
    end;



end;
// SEND
// LEAVE PRIVATE KEY FIELD EMPTY if private key is not known == can not send messages to channels not defined in the AUTH
procedure TForm1.Button3Click(Sender: TObject);
var
  token, appkey, pkey, chan, server, msg, rstring, newstr, result : string;
  msgs,  msgToSend : tStringList;
  client : TIdHTTP;
  stringparts, index : Integer;
  i, j: Integer;

begin
     client := TIdHTTP.Create;
     msgs := TStringList.Create;
     token := inputbox('Token', 'Please type your AUTH token', 'UserToken');
     appkey := inputbox('App key', 'Please type your APP key', 'FcRKO8');
     pkey := inputbox('Private key', 'Please type your private key', 'CU4VcHtGQsXZ');
     chan := inputbox('Channels', 'Type a channel name', 'blue');
     msg := inputBox('Message', 'Type a message', 'Hello World');
     rstring := RandomizeString(8);
     OutputDebugString(PChar(rstring));
     // For long messages , might be bugged (havent tested if it works with long messages)
     if (msg.Length > 800) then
          begin
          j := 0;
          stringparts := msg.Length Div 800;
          for i := 0 to stringparts-1 do
            index := i+1;
            newstr := rstring + '_' + inttostr(i) + '-'+inttostr(stringparts)+ '_' + Copy(msg,j,j+800);
            // + (i+1) + '-' + stringparts + '_' + Copy(msg,j,j+800);
            msgs.Add(newstr);
            j := j + 800;
          for i := 0 to stringparts-1 do
               msgToSend := TStringList.Create;
               msgToSend.Add('AT='+token);
               msgToSend.Add('AK='+appkey);
               msgToSend.Add('PK='+pkey);
               msgToSend.Add('C='+chan);
               msgToSend.Add('M='+msgs[i]);

          end
     // IF SHORT MSG
    else begin
      newstr := rstring + '_1-1_' + msg;
      OutputDebugString(PChar(newstr));
      msgToSend := TStringList.Create;
      msgToSend.Add('AT='+token);
      msgToSend.Add('AK='+appkey);
      msgToSend.Add('PK='+pkey);
      msgToSend.Add('C='+chan);
      msgToSend.Add('M='+newstr);
      server := Gserver;
      server := Concat(server,'/send');
      result := client.Post(server, msgToSend);
      ShowMessage(result);
    end;
end;


// ENABLE PRESENCE ON CHANNEL
procedure TForm1.Button4Click(Sender: TObject);
var
  server, pkey, meta, chan, appkey, result : string;
  liste : TStringList;
  client : TIdHTTP;
begin
  client := TIdHTTP.Create;
  liste := TStringList.Create;
  appkey := inputbox('Application key', 'Insert app key', 'FcRKO8');
  chan := inputbox('Channel', 'Channel name', 'blue');
  pkey := inputbox('Private key', 'Insert private key', 'CU4VcHtGQsXZ');
  meta := inputbox('Meta data', 'True or false', 'false');
  while (meta<>'false') AND (meta<>'true') do
    meta :=inputbox('Wrong parameter for meta data', 'True or false', 'false');
  server := Gserver + '/presence/enable/' + appkey + '/' + chan;
  OutputDebugString(PChar(server));
  liste.Values['privatekey'] := pkey;
  liste.Values['metadata'] := meta;
  result := client.Post(server,liste);
  ShowMessage(result);
end;

// GET PRESENCE OF CHANNEL
procedure TForm1.Button5Click(Sender: TObject);
var
  server, result, chan : string;
  client : TIdHTTP;
begin
  client := TIdHTTP.Create;
  chan := inputbox('Channel', 'Get info on channel', 'blue');
  server := Gserver + '/presence/'+Gappkey+'/myToken/'+chan;
  result  := client.Get(server);
  ShowMessage(result);

end;

// DISABLE CHANNEL PRESENCE
procedure TForm1.Button6Click(Sender: TObject);
var
  server, result, chan, pkey : string;
  client : TIdHTTP;
  liste : TStringList;
begin
  client := TIdHTTP.Create;
  chan := inputbox('Channel', 'Name the channel to disable', 'blue');
  server := Gserver +'/presence/disable/FcRKO8/'+chan;
  pkey := inputbox('Private key', 'Insert private key for channel','CU4VcHtGQsXZ');
  liste := TStringList.Create;
  liste.Values['privatekey'] := pkey;
  result := client.Post(server,liste);
  ShowMessage(result);

end;

end.


// Enable persistent connection, SOCKET, RECEIVE MESSAGES
// http://stackoverflow.com/questions/25181302/websocket-client-implementations-for-delphi
