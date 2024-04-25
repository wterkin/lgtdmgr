unit task_edit;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
		StdCtrls, DateTimePicker, SQLDB, DateUtils
    ,tdb, tlookup
    ;

type

		{ TfmTaskEdit }

    TfmTaskEdit = class(TForm)
				bbtOk : TBitBtn;
				bbtCancel : TBitBtn;
				cbContexts : TComboBox;
				dtpDeadLine : TDateTimePicker;
				edTaskName : TEdit;
				Label1 : TLabel;
				Label2 : TLabel;
				Label3 : TLabel;
				Label4 : TLabel;
				lblCreated : TLabel;
				lblUpdated : TLabel;
				meContent : TMemo;
				Panel1 : TPanel;
				qrTask : TSQLQuery;
				qrTaskEx : TSQLQuery;
		  procedure bbtOkClick(Sender : TObject);
    private

        moMode : TDBMode;
        moContextsCombo : TEasyLookupCombo;
      procedure initData();
      procedure storeData();
      procedure loadData();
      function  validateData() : Boolean;
    public

      { public declarations }
      procedure viewRecord(piID : Integer);
      procedure appendRecord();
    end;

const csInsertTaskSQL =
        'insert into tbltasks ('#13+
		    '                      fcontext,'#13+
		    '                      fname,'#13+
		    '                      ftext,'#13+
		    '                      fdeadline,'#13+
		    '                      fstate,'#13+
		    '                      fstatus,'#13+
		    '                      fcreated,'#13+
        '                      fupdated'#13+
		    '                  )'#13+
		    '                  VALUES ('#13+
		    '                      :pcontext,'#13+
		    '                      :pname,'#13+
		    '                      :ptext,'#13+
		    '                      :pdeadline,'#13+
		    '                      1,'#13+
		    '                      1,'#13+
		    '                      :pcreated,'#13+
		    '                      :pupdated'#13+
		    '                  );'#13;

var
    fmTaskEdit : TfmTaskEdit;

implementation

uses main;

{$R *.lfm}

{ TfmTaskEdit }
procedure TfmTaskEdit.bbtOkClick(Sender : TObject);
const csUpdateSQL =
        'UPDATE tbltasks'#13+
        '  SET fcontext = :pcontext,'#13+
        '      fname = :pname,'#13+
        '      ftext = :ptext,'#13+
        '      fdeadline = :pdeadline,'#13+
        '      fupdated = :pupdated'#13+
        '  WHERE id = :pid'#13;
begin

  if validateData() then
  begin

    try
      if moMode = dmInsert then
      begin

        initializeQuery(qrTaskEx,csInsertTaskSQL);

      end else
      begin

        initializeQuery(qrTaskEx,csUpdateSQL);
  		end;
  		StoreData();
      qrTaskEx.ExecSQL;
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


procedure TfmTaskEdit.initData();
begin

  edTaskName.Text := '';
  meContent.Lines.Clear;
  dtpDeadLine.Date := NullDate;
  moContextsCombo := TEasyLookupCombo.Create();
  moContextsCombo.setComboBox(cbContexts);
  moContextsCombo.setQuery(MainForm.qrContexts);
  moContextsCombo.setSQL('select * from tblcontexts where fstatus>0');
  moContextsCombo.setKeyField('id');
  moContextsCombo.setListField('fname');
  lblCreated.Caption := DateToStr(Now);
  moContextsCombo.fill();
  cbContexts.ItemIndex := MainForm.cbContexts.ItemIndex;
end;


procedure TfmTaskEdit.storeData();
begin

  qrTaskEx.ParamByName('pname').Text := edTaskName.Text;
  qrTaskEx.ParamByName('ptext').Text := meContent.Text;
  if (dtpDeadLine.Date <> NullDate) then // and (dtpDeadLine.Date <> EncodeDate(1899, 12, 30)) then
  begin

    qrTaskEx.ParamByName('pdeadline').AsDate := dtpDeadLine.Date;
	end;
	qrTaskEx.ParamByName('pcontext').AsInteger := moContextsCombo.getIntKey();
  if moMode = dmUpdate then
  begin

    qrTaskEx.ParamByName('pid').AsInteger := MainForm.getLastRecordID();
    qrTaskEx.ParamByName('pupdated').AsDateTime := Now;
  end else
  begin

    qrTaskEx.ParamByName('pcreated').AsDateTime := Now;
    qrTaskEx.ParamByName('pupdated').AsDateTime := Now;
	end;
end;


procedure TfmTaskEdit.loadData();
var liContextKey : Integer;
    //s:string;
begin

  //s:=qrTask.FieldByName('fname').AsString;
  edTaskName.Text := qrTask.FieldByName('fname').AsString;
  meContent.Text := qrTask.FieldByName('ftext').AsString;
  if DateOf(qrTask.FieldByName('fdeadline').AsDateTime) = EncodeDate(1899, 12, 30) then
  begin

    dtpDeadLine.Date := NullDate;
  end else
  begin

    dtpDeadLine.Date := qrTask.FieldByName('fdeadline').AsDateTime;
	end;
	lblCreated.Caption := 'Задача создана ' + DateToStr(qrTask.FieldByName('fcreated').AsDateTime);
  if not qrTask.FieldByName('fcreated').IsNull then
  begin

    lblUpdated.Caption := 'Задача изменена ' + DateToStr(qrTask.FieldByName('fupdated').AsDateTime);
	end;
	liContextKey := qrTask.FieldByName('fcontext').AsInteger;
  moContextsCombo := TEasyLookupCombo.Create();
  moContextsCombo.setComboBox(cbContexts);
  moContextsCombo.setQuery(MainForm.qrContexts);
  moContextsCombo.setSQL('select * from tblcontexts where fstatus>0');
  moContextsCombo.setKeyField('id');
  moContextsCombo.setListField('fname');
  moContextsCombo.fill();
  moContextsCombo.setKey(liContextKey);
end;


function TfmTaskEdit.validateData() : Boolean;
begin

  Result := True;
end;


procedure TfmTaskEdit.viewRecord(piID : Integer);
begin

  try

    initializeQuery(qrTask,'select * from tbltasks where id = :pid');
    qrTask.ParamByName('pid').AsInteger := piID;
    qrTask.Open();
 	except on E: Exception do

    MainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
	end;
	moMode := dmUpdate;
	LoadData();
  ShowModal;
end;


procedure TfmTaskEdit.appendRecord();
begin

  moMode := dmInsert;
	InitData();
  ShowModal;
end;


end.

