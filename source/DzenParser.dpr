program DzenParser;

uses
  Vcl.Forms,
  unitMain in 'unitMain.pas' {frmMain},
  unitImage in 'unitImage.pas' {frmImage},
  unitLink in 'unitLink.pas' {frmLink};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
