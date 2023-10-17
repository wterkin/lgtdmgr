unit context_edit;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
		Buttons
    , tdb, SQLDB
    ;

type

		{ TfmContextEdit }

    TfmContextEdit = class(TForm)
				bbtOk : TBitBtn;
				bbtCancel : TBitBtn;
				edName : TEdit;
				Label1 : TLabel;
				Panel1 : TPanel;
				qrContexts : TSQLQuery;
				qrContextsEx : TSQLQuery;
				procedure bbtOkClick(Sender : TObject);
    private
        moMode : TDBMode;

        procedure initData();
        procedure storeData();
        procedure loadData();
        function  validateData() : Boolean;
    public

        procedure viewRecord();
        procedure appendRecord();
    end;

var
    fmContextEdit : TfmContextEdit;

implementation

uses setup;

{$R *.lfm}

{ TfmContextEdit }

procedure TfmContextEdit.bbtOkClick(Sender : TObject);
const csInsertSQL =
        'insert into tblcontexts ('#13+
		    '                      fname,'#13+
		    '                  )'#13+
		    '                  VALUES ('#13+
		    '                      :pname,'#13+
		    '                  );'#13;
      csUpdateSQL =
        'UPDATE tbltasks'#13+
        '  SET fname = :pname'#13+
        '  WHERE id = :pid'#13;
begin

  if validateData() then
  begin

    try
      if moMode = dmInsert then
      begin

        initializeQuery(qrContextsEx,csInsertSQL);

      end else
      begin

        initializeQuery(qrContextsEx,csUpdateSQL);
  		end;
  		StoreData();
      qrContextsEx.ExecSQL;
      MainForm.Transaction.Commit;
      ModalResult := mrOk;
  	except on E: Exception do
      begin

        MainForm.Transaction.Rollback;
        MainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
			end;
		end;
	end;
end;

procedure TfmContextEdit.initData;
begin

  edName.Text := '';
end;


procedure TfmContextEdit.storeData;
begin

  if moMode = dmUpdate then
  begin

    qrContextsEx.ParamByName('pid').AsInteger := fmSetup.qrContexts.FieldByName('id').AsInteger;
    qrContextsEx.ParamByName('pupdated').AsDateTime := Now;
  end else
  begin

    qrContextsEx.ParamByName('pcreated').AsDateTime := Now;
	end;
end;


procedure TfmContextEdit.loadData;
begin

  edName.Text := qrContexts.FieldByName('fname').AsString;
end;


function TfmContextEdit.validateData : Boolean;
begin

  Result := True;
end;


procedure TfmContextEdit.viewRecord;
begin

  try

    initializeQuery(qrContexts,'select * from tblcontexts where id = :pid');
    qrContexts.ParamByName('pid').AsInteger := fmSetup.qrContexts.FieldByName('id').AsInteger;
    qrContexts.Open();
 	except on E: Exception do

    MainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
	end;
	moMode := dmUpdate;
	LoadData();
  ShowModal;
end;


procedure TfmContextEdit.appendRecord;
begin

  moMode := dmInsert;
	InitData();
  ShowModal;
end;


end.

