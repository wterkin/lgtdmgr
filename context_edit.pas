unit context_edit;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
		Buttons, SQLDB
    , tdb, tstr
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
        miID : Integer;
        procedure initData();
        procedure storeData();
        procedure loadData();
        function  validateData() : Boolean;
    public

        procedure viewRecord(piID: Integer);
        procedure appendRecord();
    end;

var
    fmContextEdit : TfmContextEdit;

implementation

uses main;

{$R *.lfm}

{ TfmContextEdit }

procedure TfmContextEdit.bbtOkClick(Sender : TObject);
const csInsertSQL =
        'insert into tblcontexts ('#13+
		    '                      fname,'#13+
		    '                      fcreated'#13+
		    '                  )'#13+
		    '                  VALUES ('#13+
		    '                      :pname,'#13+
		    '                      :pcreated'#13+
		    '                  );'#13;
      csUpdateSQL =
        'UPDATE tblcontexts'#13+
        '  SET fname = :pname,'#13+
        '      fupdated = :pupdated'#13+
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

  qrContextsEx.ParamByName('pname').Text := edName.Text;
  if moMode = dmUpdate then
  begin

    qrContextsEx.ParamByName('pid').AsInteger := miID;
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

  Result := not isEmpty(edName.Text);
end;


procedure TfmContextEdit.viewRecord(piID : Integer);
begin

  try
    miID := piID;
    initializeQuery(qrContexts,'select * from tblcontexts where id = :pid');
    qrContexts.ParamByName('pid').AsInteger := miID;
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

