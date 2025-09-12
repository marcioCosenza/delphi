program masks;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmMaim in 'frmMaim.pas' {Form1},
  untBuscaCEP in 'untBuscaCEP.pas',
  untMask in 'untMask.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
