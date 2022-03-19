program Praktika;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmMain in 'frmMain.pas' {fmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
