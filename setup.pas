unit setup;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
		ComCtrls, Buttons, DBGrids,
    tdb;

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
				SpeedButton1 : TSpeedButton;
				SpeedButton2 : TSpeedButton;
				SpeedButton3 : TSpeedButton;
				procedure FormShow(Sender : TObject);
    procedure SpeedButton1Click(Sender : TObject);
				procedure SpeedButton2Click(Sender : TObject);
				procedure SpeedButton3Click(Sender : TObject);
    private

    public

    end;

var
    fmSetup : TfmSetup;

implementation


uses main;
{$R *.lfm}

{ TfmSetup }

procedure TfmSetup.SpeedButton1Click(Sender : TObject);
begin

  //
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

procedure TfmSetup.SpeedButton2Click(Sender : TObject);
begin

  //
end;

procedure TfmSetup.SpeedButton3Click(Sender : TObject);
begin

  //
end;

end.

