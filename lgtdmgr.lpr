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
      Forms, datetimectrls, main, task_edit
      { you can add units after this };

{$R *.res}

begin
      RequireDerivedFormResource:=True;
			Application.Scaled:=True;
      Application.Initialize;
		Application.CreateForm(TfmMain, fmMain);
		Application.CreateForm(TfrmTaskEdit, frmTaskEdit);
      Application.Run;
end.

