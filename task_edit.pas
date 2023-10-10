unit task_edit;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
		StdCtrls, DateTimePicker
    ,tdb, tdbguard, SQLDB
    ;

type

		{ TfmTaskEdit }

    TfmTaskEdit = class(TForm)
				bbtOk : TBitBtn;
				bbtCancel : TBitBtn;
				cbContentFilter : TComboBox;
				DateTimePicker1 : TDateTimePicker;
				edTaskName : TEdit;
				Label1 : TLabel;
				Label2 : TLabel;
				Label3 : TLabel;
				Label4 : TLabel;
				meContent : TMemo;
				Panel1 : TPanel;
				qrTaskEdit : TSQLQuery;
				procedure bbtOkClick(Sender : TObject);
    private

      procedure initData();
      procedure storeData();
      procedure loadData();
      function  validateData() : Boolean;
    public
      { public declarations }
      procedure viewRecord();
      procedure appendRecord();

    end;

var
    fmTaskEdit : TfmTaskEdit;

implementation

uses main;

{$R *.lfm}

{ TfmTaskEdit }
procedure TfmTaskEdit.bbtOkClick(Sender : TObject);
begin

  //
end;


procedure TfmTaskEdit.initData();
begin

  //
end;


procedure TfmTaskEdit.storeData();
begin

  //
end;


procedure TfmTaskEdit.loadData();
begin

  //
end;


function TfmTaskEdit.validateData() : Boolean;
begin

  //
end;


procedure TfmTaskEdit.viewRecord();
begin

  //
end;


procedure TfmTaskEdit.appendRecord();
begin

  //
end;


end.

