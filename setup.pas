unit setup;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
		ComCtrls, Buttons, DBGrids
    , context_edit
    , tdb

    ;

type

		{ TfmSetup }

    TfmSetup = class(TForm)
				bbtQuit : TBitBtn;
				dsContexts : TDataSource;
				dbgContexts : TDBGrid;
				Panel1 : TPanel;
				Panel2 : TPanel;
				qrContexts : TSQLQuery;
				qrContextEx : TSQLQuery;
				sbCreateContext : TSpeedButton;
				sbChangeContext : TSpeedButton;
				sbDeleteContext : TSpeedButton;
				procedure FormShow(Sender : TObject);
    procedure sbCreateContextClick(Sender : TObject);
				procedure sbChangeContextClick(Sender : TObject);
				procedure sbDeleteContextClick(Sender : TObject);
    private

    public

    end;

var
    fmSetup : TfmSetup;

implementation


uses main;
{$R *.lfm}

{ TfmSetup }

procedure TfmSetup.sbCreateContextClick(Sender : TObject);
begin

  fmContextEdit.appendRecord();
end;


procedure TfmSetup.FormShow(Sender : TObject);
const csSelectContexts =
        'select id, cast(fname as varchar) as fname, fstatus'#13+
        '  from tblcontexts'#13+
        '  where fstatus > 0';
begin

  try

    initializeQuery(qrContexts, csSelectContexts,False);
    qrContexts.Open;
	except on E: Exception do
    begin

      MainForm.Transaction.Rollback;
      MainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
    end;
  end;
end;


procedure TfmSetup.sbChangeContextClick(Sender : TObject);
begin

  fmContextEdit.viewRecord();
end;

procedure TfmSetup.sbDeleteContextClick(Sender : TObject);
begin

  //
end;

end.

