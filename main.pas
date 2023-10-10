unit main;

{$mode objfpc}{$H+}

interface

uses
      Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics,
			Dialogs, ExtCtrls, ComCtrls, DBGrids, StdCtrls, Buttons, ActnList, Windows
      , task_edit
      , tapp , tdb, tmsg, tlookup
      ;

type

			{ TfmMain }

      TfmMain = class(TForm)
						actChangeTask : TAction;
						actDeleteTask : TAction;
						actQuit : TAction;
						actNewTask : TAction;
					  actToCompleted : TAction;
					  actToTrashBin : TAction;
					  actToInputBox : TAction;
					  actToWork : TAction;
					  ActionList : TActionList;
					  bbtToInput : TBitBtn;
					  bbtToWork : TBitBtn;
					  bbtToDone : TBitBtn;
					  bbtDelayed : TBitBtn;
					  cbContexts : TComboBox;
					  cbPeriod : TComboBox;
					  dsInput : TDataSource;
					  dbgInput : TDBGrid;
					  dbgToWork : TDBGrid;
					  dbgTrash : TDBGrid;
					  dbgDone : TDBGrid;
					  dsToWork : TDataSource;
					  dsTrash : TDataSource;
					  dsDone : TDataSource;
					  ImageList : TImageList;
					  Panel1 : TPanel;
					  qrToWork : TSQLQuery;
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
					  Transaction : TSQLTransaction;
					  StatusBar : TStatusBar;
						procedure actNewTaskExecute(Sender : TObject);
            procedure actQuitExecute(Sender : TObject);
            procedure actToCompletedExecute(Sender : TObject);
		        procedure actToInputBoxExecute(Sender : TObject);
					  procedure actToTrashBinExecute(Sender : TObject);
					  procedure actToWorkExecute(Sender : TObject);
						procedure dbgDoneCellClick({%H-}Column : TColumn);
						procedure dbgInputCellClick({%H-}Column : TColumn);
						procedure dbgToWorkCellClick({%H-}Column : TColumn);
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

      end;

const ciInputType = 1;
      ciToDoType = 2;
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
        '    "fname" nchar(32) not null on conflict abort,'#13+
        '    "fstatus" integer not null on conflict abort default(1)'#13+
        ');';

      csSQLCreateTasksTable =
        'create table "tbltasks" ('#13+
        '    "id" integer primary key asc on conflict abort'+
        '         autoincrement not null on conflict abort '+
        '         unique on conflict abort,'#13+
        '    "fcontext" integer not null on conflict abort,'#13+
        '    "fname" nchar(32) not null on conflict abort,'#13+
        '    "ftext" text,'#13+
        '    "fstate" integer not null on conflict abort default(1),'#13+
        '    "fstatus" integer not null on conflict abort default(1),'#13+
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
    qrToWork.Active := False;
    qrTrash.Active := False;
    qrDone.Active := False;
    SQLite.Connected := True;
    reopenTable();
    EnableMovingActions(False);
    dbgInput.Columns[0].Width := dbgInput.Width - ciColumnWidthDiff;
    dbgToWork.Columns[0].Width := dbgToWork.Width - ciColumnWidthDiff;
    dbgTrash.Columns[0].Width := dbgTrash.Width - ciColumnWidthDiff;
    dbgDone.Columns[0].Width := dbgDone.Width - ciColumnWidthDiff;

    moContextsCombo := TEasyLookupCombo.Create();
    moContextsCombo.setComboBox(cbContexts);
    moContextsCombo.setQuery(qrContexts);
    moContextsCombo.setSQL('select * from tblcontexts where fstatus>0');
    moContextsCombo.setKeyField('id');
    moContextsCombo.setListField('fname');
    moContextsCombo.fill();

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

  if not qrDone.RecordCount > 0 then
  begin

    EnableMovingActions();
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
    actToInputBox.Enabled := False;
    miLastRecordID := qrInput.FieldByName('id').AsInteger;
  end else
  begin

    EnableMovingActions(False);
	end;
end;


procedure TfmMain.dbgToWorkCellClick(Column : TColumn);
begin

  if qrToWork.RecordCount > 0 then
  begin

    EnableMovingActions();
    actToWork.Enabled := False;
    miLastRecordID := qrToWork.FieldByName('id').AsInteger;
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
    actToTrashBin.Enabled := False;
    miLastRecordID := qrTrash.FieldByName('id').AsInteger;
  end else
  begin

    EnableMovingActions(False);
	end;
end;


procedure TfmMain.actToInputBoxExecute(Sender : TObject);
begin

  //
end;


procedure TfmMain.actToCompletedExecute(Sender : TObject);
begin

  //
end;


procedure TfmMain.actQuitExecute(Sender : TObject);
begin

  Close();
end;

procedure TfmMain.actNewTaskExecute(Sender : TObject);
begin

  //fmTaskEdit.;
end;


procedure TfmMain.actToTrashBinExecute(Sender : TObject);
begin

  //
end;


procedure TfmMain.actToWorkExecute(Sender : TObject);
begin

  //
end;


procedure TfmMain.reopenTable;
const csMainSQL = 'select  id, fname, ftext'#13+
						      '  from tbltasks'#13+
                  ' where fstate = :ptype';
//var i:integer;
begin

  try

    Transaction.Active := True;
    initializeQuery(qrInput, csMainSQL, False);
    qrInput.ParamByName('ptype').AsInteger := ciInputType;
    qrInput.Open();

    initializeQuery(qrToWork, csMainSQL, False);
    qrToWork.ParamByName('ptype').AsInteger := ciToDoType;
    qrToWork.Open();

    initializeQuery(qrTrash, csMainSQL, False);
    qrTrash.ParamByName('ptype').AsInteger := ciTrashType;
    qrTrash.Open();

    initializeQuery(qrDone, csMainSQL, False);
    qrDone.ParamByName('ptype').AsInteger := ciDoneType;
    qrDone.Open();
    //i:=qrDone.RecordCount;
	finally


	end;

end;


procedure TfmMain.EnableMovingActions(pblEnabled : Boolean);
begin

  actToCompleted.Enabled := pblEnabled;
  actToInputBox.Enabled := pblEnabled;
  actToTrashBin.Enabled := pblEnabled;
  actToWork.Enabled := pblEnabled;
end;


end.

