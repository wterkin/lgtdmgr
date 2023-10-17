program lgtdmgr;

{$mode objfpc}{$H+}

uses
      {$IFDEF UNIX}
      cthreads,
      {$ENDIF}
      {$IFDEF HASAMIGA}
      athreads,
      {$ENDIF}
      Interfaces, // this includes the LCL widgetset
      Forms, datetimectrls, main, task_edit, setup, context_edit
      { you can add units after this };

{$R *.res}

begin
      RequireDerivedFormResource:=True;
		Application.Scaled:=True;
      Application.Initialize;
		Application.CreateForm(TfmMain, fmMain);
		Application.CreateForm(TfmTaskEdit, fmTaskEdit);
		Application.CreateForm(TfmSetup, fmSetup);
		Application.CreateForm(TfmContextEdit, fmContextEdit);
      Application.Run;
end.

