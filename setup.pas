unit setup;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
		ComCtrls, Buttons, DBGrids
    , context_edit
    , tdb, tmsg
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

        procedure reOpenTable();
    public

        function isContextUsing : Boolean;
    end;

var
    fmSetup : TfmSetup;

implementation


uses newmain;
{$R *.lfm}

{ TfmSetup }

procedure TfmSetup.sbCreateContextClick(Sender : TObject);
begin

  fmContextEdit.appendRecord();
  reOpenTable();
end;


procedure TfmSetup.FormShow(Sender : TObject);
begin

  reOpenTable();
end;


procedure TfmSetup.sbChangeContextClick(Sender : TObject);
var liID : Integer;
begin

  liID := qrContexts.FieldByName('id').AsInteger;
  if not isContextUsing() then
  begin

    fmContextEdit.viewRecord(liID);
    reOpenTable();
  end else
  begin

    Notify('Внимание!', 'Невозможно изменить этот контекст, так как он уже используется!');
	end;
end;


procedure TfmSetup.sbDeleteContextClick(Sender : TObject);
var liID : Integer;
    lsName : String;
begin

  liID := qrContexts.FieldByName('id').AsInteger;
  lsName := qrContexts.FieldByName('fname').AsString;
  if not isContextUsing() then
  begin

    if askYesOrNo('Вы действительно хотите удалить контекст "' + lsName + '" ?') then
    begin

      try

        initializeQuery(qrContextEx, 'update tblcontexts set fstatus = 0 where id = :pid');
        qrContextEx.ParamByName('pid').AsInteger := liID;
        qrContextEx.ExecSQL();
        NewMainForm.Transaction.Commit;
        reOpenTable();
    	except on E: Exception do
        begin

          NewMainForm.Transaction.Rollback;
          NewMainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
    	  end;
    	end;

  	end;
  end else
  begin

    Notify('Внимание!', 'Невозможно удалить этот контекст, так как он уже используется!');
  end;
end;


procedure TfmSetup.reOpenTable;
const csSelectContexts =
          'select id, cast(fname as varchar) as fname, fstatus'#13+
          '  from tblcontexts'#13+
          '  where fstatus > 0';
begin

  try

    initializeQuery(qrContexts, csSelectContexts,False);
    qrContexts.Open;
    if qrContexts.RecordCount = 0 then
    begin

      sbChangeContext.Enabled := False;
      sbDeleteContext.Enabled := False;
    end;
	except on E: Exception do
    begin

      NewMainForm.Transaction.Rollback;
      NewMainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
    end;
  end;
end;


function TfmSetup.isContextUsing : Boolean;
var liID : Integer;
begin

  Result := False;
  liID := qrContexts.FieldByName('id').AsInteger;
  try

    initializeQuery(qrContextEx, 'select count(id) as acount from tbltasks where fcontext = :pid', False);
    qrContextEx.ParamByName('pid').AsInteger := liID;
    qrContextEx.Open();
    Result := qrContextEx.FieldByName('acount').AsInteger > 0;
    qrContextEx.Close();
    reOpenTable();
	except on E: Exception do
    begin

      NewMainForm.Transaction.Rollback;
      NewMainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
	  end;
	end;
end;


end.

