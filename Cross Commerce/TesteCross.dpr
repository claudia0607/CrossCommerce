program TesteCross;

uses
  Forms,
  UPrinc in 'UPrinc.pas' {FPrinc};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFPrinc, FPrinc);
  Application.Run;
end.
