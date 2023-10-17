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
begin

  //
end;

procedure TfmContextEdit.initData;
begin

  //
end;


procedure TfmContextEdit.storeData;
begin

  //
end;


procedure TfmContextEdit.loadData;
begin

  //
end;


function TfmContextEdit.validateData : Boolean;
begin

  Result := True;
end;


procedure TfmContextEdit.viewRecord;
begin

  try

    initializeQuery(qrTask,'select * from tblcontexts where id = :pid');
    qrTask.ParamByName('pid').AsInteger := MainForm.getLastRecordID();
    qrTask.Open();
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

