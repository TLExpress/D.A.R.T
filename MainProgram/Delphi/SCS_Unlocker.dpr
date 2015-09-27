{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
program SCS_Unlocker;

uses
  FastMM4,
  Forms,

  Repairer      in '..\Repairer.pas',
  FilesManager  in '..\FilesManager.pas',

  MainForm          in '..\MainForm.pas' {fMainForm},
  PrcsSettingsForm  in '..\PrcsSettingsForm.pas' {fPrcsSettingsForm},
  ErrorForm         in '..\ErrorForm.pas' {fErrorForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SCS Unlocker';
  Application.CreateForm(TfMainForm, fMainForm);
  Application.CreateForm(TfErrorForm, fErrorForm);
  Application.CreateForm(TfPrcsSettingsForm, fPrcsSettingsForm);
  Application.Run;
end.
