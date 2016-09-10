unit uSimpleWebServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Sockets;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    memlog: TMemo;
    btnstart: TButton;
    btnstop: TButton;
    btnrestart: TButton;
    btnexit: TButton;
    Label1: TLabel;
    btnsettingssave: TButton;
    tcpserver: TTcpServer;
    Label2: TLabel;
    edtport: TEdit;
    redlicense: TRichEdit;
    procedure btnexitClick(Sender: TObject);
    procedure btnstartClick(Sender: TObject);
    procedure btnstopClick(Sender: TObject);
    procedure btnrestartClick(Sender: TObject);
    procedure btnsettingssaveClick(Sender: TObject);
    procedure tcpserverAccept(Sender: TObject; ClientSocket: TCustomIpClient);
  private
    { Private declarations }
  public
    { Public declarations }
    serverclosed : String;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnexitClick(Sender: TObject);
begin
  memlog.Lines.Add(DateTimeToStr(now)+': Stopping Server... (If Started)');
  tcpserver.Close;
  sleep(5000);
  Close;
end;

procedure TForm1.btnrestartClick(Sender: TObject);
begin
  btnstop.Enabled := False;
  memlog.Lines.Add(DateTimeToStr(now)+': Server Restarting...');
  tcpserver.Close;
  tcpserver.Open;
  sleep(5000);
  memlog.Lines.Add(DateTimeToStr(now)+': Server Restarted');
  btnstop.Enabled := True;
end;

procedure TForm1.btnsettingssaveClick(Sender: TObject);
begin
  tcpserver.LocalPort := edtport.Text;
end;

procedure TForm1.btnstartClick(Sender: TObject);
begin
  btnstart.Enabled := False;
  btnsettingssave.Enabled := False;
  btnstop.Enabled := True;
  btnrestart.Enabled := True;

  tcpserver.Open;
  memlog.Lines.Add(DateTimeToStr(now)+': Server Started');
end;

procedure TForm1.btnstopClick(Sender: TObject);
begin
  btnstop.Enabled := False;
  btnsettingssave.Enabled := True;
  btnstart.Enabled := True;
  btnrestart.Enabled := False;

  tcpserver.Close;
  memlog.Lines.Add(DateTimeToStr(now)+': Server Stopped');
end;

procedure TForm1.tcpserverAccept(Sender: TObject;
  ClientSocket: TCustomIpClient);
var
  Line, Path : String;
  HTTPPos : Integer;
begin
  Line := ' ';

  while ClientSocket.Connected and (Line <> '') do
  Begin
    Line := ClientSocket.Receiveln();

    memlog.Lines.Add(Line);

    if Copy(Line,1,3) = 'GET' then
      Begin
        HTTPPos := Pos('HTTP',Line);

        Path := Copy(Line,5,HTTPPos-6);

        memlog.Lines.Add('Path: '+Path);
      End;

  End;

  if Path = '/' then
    Path := 'index.html';

  if FileExists('htdocs/' + Path) then
    with TStringList.Create do
    begin
      LoadFromFile('htdocs/' + Path);
      ClientSocket.Sendln('HTTP/1.0 200 OK');
      ClientSocket.Sendln('');
      ClientSocket.Sendln(Text);
      ClientSocket.Close;

      Free;
      exit;
    end;

  ClientSocket.Sendln('HTTP/1.0 404 Not Found');
  ClientSocket.Sendln('');
  ClientSocket.Sendln('<h1>404 Not Found</h1><br><br>Path: '+Path);
  ClientSocket.Close;

end;

end.
