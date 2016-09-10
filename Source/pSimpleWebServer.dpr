program pSimpleWebServer;

uses
  Forms,
  uSimpleWebServer in 'uSimpleWebServer.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Simple Web Server';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
