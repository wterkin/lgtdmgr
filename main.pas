unit main;

{$mode objfpc}{$H+}

interface

uses
      Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics,
			Dialogs, ExtCtrls, ComCtrls, DBGrids, StdCtrls, Buttons, ActnList, Windows
      , task_edit, setup
      , tapp , tdb, tmsg, tlookup
      ;

type

			{ TfmMain }

      TfmMain = class(TForm)
						actChangeTask : TAction;
						actDeleteTask : TAction;
						actSetup : TAction;
						actQuit : TAction;
						actNewTask : TAction;
					  actToCompleted : TAction;
					  actToTrashBin : TAction;
					  actToInputBox : TAction;
					  actToWork : TAction;
					  ActionList : TActionList;
						bbtToInput : TBitBtn;
					  bbtToDone : TBitBtn;
					  bbtToTrash : TBitBtn;
						bbtToWork : TBitBtn;
					  cbContexts : TComboBox;
					  cbPeriod : TComboBox;
						dbgInput : TDBGrid;
						dbgWork : TDBGrid;
					  dsInput : TDataSource;
					  dbgTrash : TDBGrid;
					  dbgDone : TDBGrid;
					  dsWork : TDataSource;
					  dsTrash : TDataSource;
					  dsDone : TDataSource;
					  ImageList : TImageList;
					  Panel1 : TPanel;
						Panel2 : TPanel;
						Panel3 : TPanel;
						Panel4 : TPanel;
					  qrWork : TSQLQuery;
					  qrTrash : TSQLQuery;
					  qrDone : TSQLQuery;
						SpeedButton1 : TSpeedButton;
						SpeedButton2 : TSpeedButton;
						SpeedButton3 : TSpeedButton;
						SpeedButton4 : TSpeedButton;
						SpeedButton5 : TSpeedButton;
						Splitter1 : TSplitter;
					  Splitter2 : TSplitter;
					  Splitter3 : TSplitter;
					  SQLite : TSQLite3Connection;
					  qrInput : TSQLQuery;
						qrContexts : TSQLQuery;
						qrTaskExt : TSQLQuery;
					  Transaction : TSQLTransaction;
					  StatusBar : TStatusBar;
				procedure actChangeTaskExecute(Sender : TObject);
				procedure actDeleteTaskExecute(Sender : TObject);
        procedure actNewTaskExecute(Sender : TObject);
        procedure actQuitExecute(Sender : TObject);
				procedure actSetupExecute(Sender : TObject);
        procedure actToCompletedExecute(Sender : TObject);
		    procedure actToInputBoxExecute(Sender : TObject);
				procedure actToTrashBinExecute(Sender : TObject);
				procedure actToWorkExecute(Sender : TObject);
				procedure dbgDoneCellClick({%H-}Column : TColumn);
				procedure dbgInputCellClick({%H-}Column : TColumn);
				procedure dbgWorkCellClick({%H-}Column : TColumn);
				procedure dbgTrashCellClick({%H-}Column : TColumn);
		    procedure FormCreate(Sender : TObject);
				procedure FormKeyDown(Sender : TObject; var Key : Word;
								Shift : TShiftState);
      private

            miLastRecordID : Integer;
            moContextsCombo : TEasyLookupCombo;

        procedure createDatabaseIfNeeded();
        procedure reopenTable();
        procedure EnableMovingActions(pblEnabled : Boolean = True);
      public

        function getLastRecordID() : Integer;
        procedure processError(psDesc, psDetail : String);
        procedure processException(psDesc : String; poException : Exception);
        procedure changeState(piState: Integer);
      end;


const ciInputType = 1;
      ciWorkType = 2;
      ciTrashType = 3;
      ciDoneType = 4;
      ciColumnWidthDiff = 34;
      csDatabaseFileName = 'lgtdmgr.db';

var fmMain : TfmMain;
    MainForm : TfmMain;


{ToDo: Хорошо бы добавить поле дедлайна и помечать красным просроченные задания}
{      А оранжевым - за неделю до дедлайна}


implementation

{$R *.lfm}

{ TfmMain }

procedure TfmMain.createDatabaseIfNeeded();
{$region 'SQL'}
const csSQLCreateContextsTable =
        'create table "tblcontexts" ('#13+
        '    "id" integer primary key asc on conflict abort'+
        '         autoincrement not null on conflict abort '+
        '         unique on conflict abort,'#13+
        '    "fname" text not null on conflict abort,'#13+
        '    "fstatus" integer not null on conflict abort default(1),'#13+
        '    "fcreated" datetime, '#13+
        '    "fupdated" datetime '#13+
        ');';

      csSQLCreateTasksTable =
        'create table "tbltasks" ('#13+
        '    "id" integer primary key asc on conflict abort'+
        '         autoincrement not null on conflict abort '+
        '         unique on conflict abort,'#13+
        '    "fcontext" integer not null on conflict abort,'#13+
        '    "fname" text not null on conflict abort,'#13+
        '    "ftext" text,'#13+
        '    "fdeadline" datetime, '#13+
        '    "fstate" integer not null on conflict abort default(1),'#13+
        '    "fstatus" integer not null on conflict abort default(1),'#13+
        '    "fcreated" datetime, '#13+
        '    "fupdated" datetime, '#13+
        '    foreign key(fcontext) references tblcontexts(id)'#13+
        ');';

      csSQLAddHomeContext =
        'insert into "tblcontexts" ('#13+
        '  "fname", "fstatus"'#13+
        '  ) values ('#13+
        '  "Дом", 1'#13+
        '  )';
      csSQLAddJobContext =
        'insert into "tblcontexts" ('#13+
        '  "fname", "fstatus"'#13+
        '  ) values ('#13+
        '  "Работа", 1'#13+
        '  )';


{$endregion}
var lblDatabaseExists : Boolean;
begin

  try

    // *** Открываем соединение с БД
    sqlite.DatabaseName := getAppFolder()+csDatabaseFileName;
    lblDatabaseExists := FileExists(sqlite.DatabaseName);
    sqlite.Open;
    sqlite.Connected := True;
    // *** Если БД не создана...
    if not lblDatabaseExists then
    begin

      // *** Создаем БД
      Transaction.StartTransaction;
      sqlite.ExecuteDirect(csSQLCreateContextsTable);
      sqlite.ExecuteDirect(csSQLCreateTasksTable);
      sqlite.ExecuteDirect(csSQLAddHomeContext);
      sqlite.ExecuteDirect(csSQLAddJobContext);

      Transaction.Commit;
    end;
  except

    on E : Exception do
    begin

      fatalError('Ошибка!',E.Message);
    end;
  end;
end;


procedure TfmMain.FormCreate(Sender : TObject);
begin

  inherited;
  try

    MainForm := fmMain;
    createDatabaseIfNeeded();

    qrInput.Active := False;
    qrWork.Active := False;
    qrTrash.Active := False;
    qrDone.Active := False;

    SQLite.Connected := True;

    EnableMovingActions(False);
    //dbgInput.Columns[0].Width := dbgInput.Width - ciColumnWidthDiff;
    //dbgWork.Columns[0].Width := dbgWork.Width - ciColumnWidthDiff;
    //dbgTrash.Columns[0].Width := dbgTrash.Width - ciColumnWidthDiff;
    //dbgDone.Columns[0].Width := dbgDone.Width - ciColumnWidthDiff;

    moContextsCombo := TEasyLookupCombo.Create();
    moContextsCombo.setComboBox(cbContexts);
    moContextsCombo.setQuery(qrContexts);
    moContextsCombo.setSQL('select * from tblcontexts where fstatus>0');
    moContextsCombo.setKeyField('id');
    moContextsCombo.setListField('fname');
    moContextsCombo.fill();

    reopenTable();
    actChangeTask.Enabled := False;

	finally

	end;
end;


procedure TfmMain.FormKeyDown(Sender : TObject; var Key : Word;
		Shift : TShiftState);
begin

  if (ssCtrl in Shift) and (Key = VK_Q) then
  begin

    actQuitExecute(Nil);
  end else
  begin

    case Key of

      VK_F1 : begin

        actToInputBoxExecute(Nil);
			end;
      VK_F2: begin

        actToWorkExecute(Nil);
			end;
      VK_F3: begin

        actToTrashBinExecute(Nil);
			end;
      VK_F4: begin

        actToCompletedExecute(Nil);
			end;
		end;
  end;
end;


procedure TfmMain.dbgDoneCellClick(Column : TColumn);
begin

  if qrDone.RecordCount > 0 then
  begin

    EnableMovingActions();
    actChangeTask.Enabled := qrDone.RecordCount > 0;
    actToCompleted.Enabled := False;
    miLastRecordID := qrDone.FieldByName('id').AsInteger;
  end else
  begin

    EnableMovingActions(False);
  end
end;


procedure TfmMain.dbgInputCellClick(Column : TColumn);
begin

  if qrInput.RecordCount > 0 then
  begin

    EnableMovingActions();
    actChangeTask.Enabled := qrInput.RecordCount > 0;
    actToInputBox.Enabled := False;
    miLastRecordID := qrInput.FieldByName('id').AsInteger;
  end else
  begin

    EnableMovingActions(False);
	end;
end;


procedure TfmMain.dbgWorkCellClick(Column : TColumn);
begin

  if qrWork.RecordCount > 0 then
  begin

    EnableMovingActions();
    actChangeTask.Enabled := qrWork.RecordCount > 0;
    actToWork.Enabled := False;
    miLastRecordID := qrWork.FieldByName('id').AsInteger;
  end else
  begin

    EnableMovingActions(False);
	end;
end;


procedure TfmMain.dbgTrashCellClick(Column : TColumn);
begin

  if qrTrash.RecordCount > 0 then
  begin

    EnableMovingActions();
    actChangeTask.Enabled := qrTrash.RecordCount > 0;
    actToTrashBin.Enabled := False;
    miLastRecordID := qrTrash.FieldByName('id').AsInteger;
  end else
  begin

    EnableMovingActions(False);
	end;
end;


procedure TfmMain.actToInputBoxExecute(Sender : TObject);
begin

  changeState(ciInputType);
end;


procedure TfmMain.actToCompletedExecute(Sender : TObject);
begin

  changeState(ciDoneType);
end;


procedure TfmMain.actQuitExecute(Sender : TObject);
begin

  Close();
end;


procedure TfmMain.actSetupExecute(Sender : TObject);
begin

  fmSetup.ShowModal();
  reopenTable();
end;


procedure TfmMain.actNewTaskExecute(Sender : TObject);
begin

  fmTaskEdit.appendRecord();
  reopenTable();
end;


procedure TfmMain.actChangeTaskExecute(Sender : TObject);
begin

  fmTaskEdit.viewRecord();
  reopenTable();
end;


procedure TfmMain.actDeleteTaskExecute(Sender : TObject);
begin

  try

    if askYesOrNo('Вы действительно хотите удалить эту задачу?') then
    begin

      initializeQuery(qrTaskExt,'delete from tbltasks where id = :pid');
      qrTaskExt.ParamByName('pid').AsInteger := miLastRecordID;
      qrTaskExt.ExecSQL;
      Transaction.Commit;
      reopenTable();
		end;
	except on E: Exception do
    begin

      MainForm.Transaction.Rollback;
      MainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
		end;
	end;
end;


procedure TfmMain.actToTrashBinExecute(Sender : TObject);
begin

  changeState(ciTrashType);
end;


procedure TfmMain.actToWorkExecute(Sender : TObject);
begin

  changeState(ciWorkType);
end;


procedure TfmMain.reopenTable;
const csMainSQL = 'select  id, cast(fname as varchar) as fname, ftext'#13+
						      '  from tbltasks'#13+
                  ' where fstate = :pstate';
//var      i:integer;
begin

  try

    restartTransaction(Transaction);
    initializeQuery(qrInput, csMainSQL, False);
    qrInput.ParamByName('pstate').AsInteger := ciInputType;
    qrInput.Open();

    initializeQuery(qrWork, csMainSQL, False);
    qrWork.ParamByName('pstate').AsInteger := ciWorkType;
    qrWork.Open();

    initializeQuery(qrTrash, csMainSQL, False);
    qrTrash.ParamByName('pstate').AsInteger := ciTrashType;
    qrTrash.Open();

    initializeQuery(qrDone, csMainSQL, False);
    qrDone.ParamByName('pstate').AsInteger := ciDoneType;
    qrDone.Open();
    (*
    if qrInput.RecordCount > 0 then
    begin

      miLastRecordID := qrInput.FieldByName('id').AsInteger;
    end else
    begin

      if qrWork.RecordCount > 0 then
      begin

        miLastRecordID := qrWork.FieldByName('id').AsInteger;
			end else
      begin

        if qrTrash.RecordCount >0 then
        begin

          miLastRecordID := qrTrash.FieldByName('id').AsInteger;
        end else
        begin

          if qrDone.RecordCount >0 then
          begin

            miLastRecordID := qrDone.FieldByName('id').AsInteger;
          end else
          begin

            actChangeTask.Enabled := False;
					end;

        end;
			end;
		end;
    *)
		//i:=qrDone.RecordCount;
	except on E : Exception do

    fatalError('Ошибка!', E.Message);
	end;
end;


procedure TfmMain.EnableMovingActions(pblEnabled : Boolean);
begin

  actToCompleted.Enabled := pblEnabled;
  actToInputBox.Enabled := pblEnabled;
  actToTrashBin.Enabled := pblEnabled;
  actToWork.Enabled := pblEnabled;
end;


function TfmMain.getLastRecordID() : Integer;
begin

  Result := miLastRecordID
end;


procedure TfmMain.processError(psDesc, psDetail: String);
begin

  FatalError(psDesc, psDetail);
end;


procedure TfmMain.processException(psDesc: String; poException: Exception);
begin

  FatalError(poException.Message, psDesc);
end;


procedure TfmMain.changeState(piState : Integer);
begin

  try

    initializeQuery(qrTaskExt, 'update tbltasks set fstate=:pstate where id=:pid');
    qrTaskExt.ParamByName('pstate').AsInteger := piState;
    qrTaskExt.ParamByName('pid').AsInteger := miLastRecordID;
    qrTaskExt.ExecSQL;
    Transaction.Commit;
    reopenTable();
	except on E: Exception do
    begin

      MainForm.Transaction.Rollback;
      MainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
		end;
	end;
end;


end.

