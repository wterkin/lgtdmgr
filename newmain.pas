unit newmain;

{$mode ObjFPC}{$H+}

interface

uses
      Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics
      , Dialogs, ExtCtrls, ComCtrls, DBGrids, StdCtrls, Buttons, ActnList
      , DateUtils, Grids, Windows
      , task_edit, setup
      , tapp , tdb, tmsg, tlookup, tini, tstr
      ;

type

  { TfmNewMain }

  TfmNewMain = class(TForm)
    actChangeCompletedTask: TAction;
    actChangeInputTask: TAction;
    actChangeTrashTask: TAction;
    actChangeWorkTask: TAction;
    actDeleteCompletedTask: TAction;
    actDeleteInputTask: TAction;
    actDeleteTrashTask: TAction;
    actDeleteWorkTask: TAction;
    actSave: TAction;
    ActionList: TActionList;
    actNewTask: TAction;
    actQuit: TAction;
    actSetup: TAction;
    actToCompleted: TAction;
    actToInputBox: TAction;
    actToTrashBin: TAction;
    actToWork: TAction;
    bbtFilter: TBitBtn;
    bbtSave: TBitBtn;
    bbtToInput1: TBitBtn;
    bbtToInput2: TBitBtn;
    bbtToInput3: TBitBtn;
    bbtToTrash3: TBitBtn;
    bbtToTrash4: TBitBtn;
    bbtToTrash5: TBitBtn;
    bbtToTrash6: TBitBtn;
    bbtToTrash7: TBitBtn;
    bbtToTrash8: TBitBtn;
    bbtToWork1: TBitBtn;
    bbtToWork2: TBitBtn;
    bbtToWork3: TBitBtn;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    cbContexts: TComboBox;
    cbPeriod: TComboBox;
    dbgCompleted: TDBGrid;
    dbgInput: TDBGrid;
    dbgTrash: TDBGrid;
    dbgWork: TDBGrid;
    dsCompleted: TDataSource;
    dsInput: TDataSource;
    dsTrash: TDataSource;
    dsWork: TDataSource;
    edFilter: TEdit;
    edTaskName: TEdit;
    ImageList: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    PageControl: TPageControl;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    qrCompleted: TSQLQuery;
    qrContexts: TSQLQuery;
    qrInput: TSQLQuery;
    qrTaskEx: TSQLQuery;
    qrTrash: TSQLQuery;
    qrWork: TSQLQuery;
    sbChangeInputTask: TSpeedButton;
    sbChangeTrashTask: TSpeedButton;
    sbChangeTrashTask1: TSpeedButton;
    sbChangeWorkTask: TSpeedButton;
    sbDeleteInputTask: TSpeedButton;
    sbDeleteTrashTask: TSpeedButton;
    sbDeleteTrashTask1: TSpeedButton;
    sbDeleteWorkTask: TSpeedButton;
    sbNewTask: TSpeedButton;
    sbQuit: TSpeedButton;
    sbSetup: TSpeedButton;
    Splitter1: TSplitter;
    Splitter3: TSplitter;
    SQLite: TSQLite3Connection;
    StatusBar: TStatusBar;
    Transaction: TSQLTransaction;
    tsDone: TTabSheet;
    tsWork: TTabSheet;
    procedure actChangeCompletedTaskExecute(Sender: TObject);
    procedure actChangeInputTaskExecute(Sender: TObject);
    procedure actChangeTrashTaskExecute(Sender: TObject);
    procedure actChangeWorkTaskExecute(Sender: TObject);
    procedure actDeleteCompletedTaskExecute(Sender: TObject);
    procedure actDeleteInputTaskExecute(Sender: TObject);
    procedure actDeleteTrashTaskExecute(Sender: TObject);
    procedure actDeleteWorkTaskExecute(Sender: TObject);
    procedure actNewTaskExecute(Sender: TObject);
    procedure actQuitExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSetupExecute(Sender: TObject);
    procedure actToCompletedExecute(Sender: TObject);
    procedure actToInputBoxExecute(Sender: TObject);
    procedure actToTrashBinExecute(Sender: TObject);
    procedure actToWorkExecute(Sender: TObject);
    procedure bbtFilterClick(Sender: TObject);
    procedure cbContextsChange(Sender: TObject);
    procedure cbPeriodChange(Sender: TObject);
    procedure dbgCompletedCellClick(Column: TColumn);
    procedure dbgCompletedDblClick(Sender: TObject);
    procedure dbgInputCellClick(Column: TColumn);
    procedure dbgInputDblClick(Sender: TObject);
    procedure dbgInputPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure dbgTrashCellClick(Column: TColumn);
    procedure dbgTrashDblClick(Sender: TObject);
    procedure dbgTrashPrepareCanvas(sender: TObject; DataCol: Integer;
      Column: TColumn; AState: TGridDrawState);
    procedure dbgWorkCellClick(Column: TColumn);
    procedure dbgWorkDblClick(Sender: TObject);
    procedure edTaskNameChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
  private
    miLastRecordID  : Integer;
    moContextsCombo : TEasyLookupCombo;
    msDataBasePath  : String;
    miContext       : Integer;
    procedure createDatabaseIfNeeded();
    procedure reopenTables();
    procedure reopenTablesWithFilter();
    procedure enableMovingActions(pblEnabled : Boolean = True);
    function  getSelectedPeriodBegin() : TDate;
    function  deleteTask(piID : Integer; psName : String) : Boolean;
    procedure changeState(piState: Integer);
    procedure loadConfig();
    procedure saveConfig();

  public

    procedure processError(psDesc, psDetail : String);
    procedure processException(psDesc : String; poException : Exception);
    function getLastRecordID() : Integer;
  end;

const ciInputType        = 1;
      ciWorkType         = 2;
      ciTrashType        = 3;
      ciDoneType         = 4;

      ciTodayTasks       = 0;
      ciWeekTasks        = 1;
      ciMonthTasks       = 2;
      ciYearTasks        = 3;
      ciAllTasks         = 4;

      ciFilterOnIcon     = 11;
      ciFilterOffIcon    = 10;

      ciColumnWidthDiff  = 34;
      csDatabaseFileName = 'lgtdmgr.db';
      ciDateColumnWidth  = 84;

      ciExpiredColor     = $5200C1;
      ciLastDayColor     = $047299;
      ciThisWeekColor    = $2D7000;
      ciSomeDayColor     = $99310F;
      csIniFile          = 'lgtdmgr.ini';
      csVersion          = '1.5';


var
  fmNewMain: TfmNewMain;
  NewMainForm : TfmNewMain;

{TODO: при клике в статусе выводить содержание задачи}
{TODO: сделать резервирование базы }
implementation

{$R *.lfm}

{ TfmNewMain }
procedure TfmNewMain.createDatabaseIfNeeded();
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
    sqlite.DatabaseName := msDataBasePath;
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


procedure TfmNewMain.reopenTables;
const csMainSQL = 'select  id, cast(fname as varchar) as fname, ftext,'#13+
                  '        strftime(''%d-%m-%Y'', fcreated) as fdate,'#13+
                  '        strftime(''%h:%m'', fcreated) as ftime,'#13+
                  '        fdeadline, fcreated, fupdated'#13+
						      '  from tbltasks'#13+
                  ' where     (fstate = :pstate)'#13+
                  '       and (fstatus = 1)'#13+
                  '       and (fcontext = :pcontext)'#13+
                  '       and (fcreated > :pdatebegin)';

var ldtDateBegin : TDate;
begin

  ldtDateBegin := getSelectedPeriodBegin();
  try

    restartTransaction(Transaction);
    initializeQuery(qrInput, csMainSQL, False);
    qrInput.ParamByName('pstate').AsInteger := ciInputType;
    qrInput.ParamByName('pcontext').AsInteger := moContextsCombo.getIntKey();
    qrInput.ParamByName('pdatebegin').AsDate := ldtDateBegin;
    qrInput.Open();
    actChangeInputTask.Enabled := qrInput.RecordCount > 0;
    actDeleteInputTask.Enabled := qrInput.RecordCount > 0;

    initializeQuery(qrWork, csMainSQL, False);
    qrWork.ParamByName('pstate').AsInteger := ciWorkType;
    qrWork.ParamByName('pcontext').AsInteger := moContextsCombo.getIntKey();
    qrWork.ParamByName('pdatebegin').AsDate := ldtDateBegin;
    qrWork.Open();
    actChangeWorkTask.Enabled := qrWork.RecordCount > 0;
    actDeleteWorkTask.Enabled := qrWork.RecordCount > 0;

    initializeQuery(qrTrash, csMainSQL, False);
    qrTrash.ParamByName('pstate').AsInteger := ciTrashType;
    qrTrash.ParamByName('pcontext').AsInteger := moContextsCombo.getIntKey();
    qrTrash.ParamByName('pdatebegin').AsDate := ldtDateBegin;
    qrTrash.Open();
    actChangeTrashTask.Enabled := qrTrash.RecordCount > 0;
    actDeleteTrashTask.Enabled := qrTrash.RecordCount > 0;

    initializeQuery(qrCompleted, csMainSQL, False);
    qrCompleted.ParamByName('pstate').AsInteger := ciDoneType;
    qrCompleted.ParamByName('pcontext').AsInteger := moContextsCombo.getIntKey();
    qrCompleted.ParamByName('pdatebegin').AsDate := ldtDateBegin;
    qrCompleted.Open();
    actChangeCompletedTask.Enabled := qrCompleted.RecordCount > 0;
    actDeleteCompletedTask.Enabled := qrCompleted.RecordCount > 0;
    EnableMovingActions(False);
	except on E : Exception do

    processException('В процессе работы программы возникла исключительная ситуация!', E);
	end;
end;


procedure TfmNewMain.reopenTablesWithFilter;
const csFilterSQL = 'select  id, cast(fname as varchar) as fname, ftext,'#13+
                    '        strftime(''%d-%m-%Y'', fcreated) as fdate,'#13+
                    '        strftime(''%h:%m'', fcreated) as ftime,'#13+
                    '        fdeadline, fcreated, fupdated'#13+
						        '  from tbltasks'#13+
                    ' where     (fstate = :pstate)'#13+
                    '       and (fstatus = 1)'#13+
                    '       and ((fname like :ptext)'#13+
                    '         or (ftext like :ptext))';

var lsFilter : String;
begin

  lsFilter := '%' + edFilter.Text + '%';
  try

    restartTransaction(Transaction);
    initializeQuery(qrInput, csFilterSQL, False);
    qrInput.ParamByName('pstate').AsInteger := ciInputType;
    qrInput.ParamByName('ptext').AsString := lsFilter;
    qrInput.Open();
    actChangeInputTask.Enabled := qrInput.RecordCount > 0;
    actDeleteInputTask.Enabled := qrInput.RecordCount > 0;

    initializeQuery(qrWork, csFilterSQL, False);
    qrWork.ParamByName('pstate').AsInteger := ciWorkType;
    qrWork.ParamByName('ptext').AsString := lsFilter;
    qrWork.Open();
    actChangeWorkTask.Enabled := qrWork.RecordCount > 0;
    actDeleteWorkTask.Enabled := qrWork.RecordCount > 0;

    initializeQuery(qrTrash, csFilterSQL, False);
    qrTrash.ParamByName('pstate').AsInteger := ciTrashType;
    qrTrash.ParamByName('ptext').AsString := lsFilter;
    qrTrash.Open();
    actChangeTrashTask.Enabled := qrTrash.RecordCount > 0;
    actDeleteTrashTask.Enabled := qrTrash.RecordCount > 0;

    initializeQuery(qrCompleted, csFilterSQL, False);
    qrCompleted.ParamByName('pstate').AsInteger := ciDoneType;
    qrCompleted.ParamByName('ptext').AsString := lsFilter;
    qrCompleted.Open();
    actChangeCompletedTask.Enabled := qrCompleted.RecordCount > 0;
    actDeleteCompletedTask.Enabled := qrCompleted.RecordCount > 0;
    EnableMovingActions(False);
	except on E : Exception do

    processException('В процессе работы программы возникла исключительная ситуация!', E);
	end;
end;


procedure TfmNewMain.EnableMovingActions(pblEnabled : Boolean);
begin

  actToCompleted.Enabled := pblEnabled;
  actToInputBox.Enabled := pblEnabled;
  actToTrashBin.Enabled := pblEnabled;
  actToWork.Enabled := pblEnabled;
end;


function TfmNewMain.getSelectedPeriodBegin : TDate;
var liDays : Integer;
    ldtDateBegin : TDate;
begin

  case cbPeriod.ItemIndex of

    ciTodayTasks: begin

      liDays := 0;
    end;
	  ciWeekTasks: begin

      liDays := -7;
		end;
    ciMonthTasks: begin

      liDays := -30;
		end;
    ciYearTasks: begin

      liDays := -365;
		end;
    ciAllTasks: begin

      liDays := -36500;
		end;
  end;
  ldtDateBegin := IncDay(DateOf(Now), liDays);
  Result := ldtDateBegin;
end;


function TfmNewMain.deleteTask(piID : Integer; psName : String) : Boolean;
begin

  Result := False;
  try


    if askYesOrNo('Вы действительно хотите удалить задачу "' + psName + '" ?') then
    begin

      initializeQuery(qrTaskEx,'update tbltasks set fstatus = 0 where id = :pid');
      qrTaskEx.ParamByName('pid').AsInteger := piID;
      qrTaskEx.ExecSQL;
      Transaction.Commit;
      if bbtFilter.ImageIndex = ciFilterOffIcon then
      begin

        reopenTablesWithFilter();
      end else
      begin

      	reopenTables();
    	end;
      Result := True;
		end;
	except on E: Exception do
    begin

      NewMainForm.Transaction.Rollback;
      NewMainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
    end;
  end;
end;


procedure TfmNewMain.processError(psDesc, psDetail: String);
begin

  FatalError(psDesc, psDetail);
end;


procedure TfmNewMain.processException(psDesc: String; poException: Exception);
begin

  FatalError(poException.Message, psDesc);
end;


procedure TfmNewMain.changeState(piState : Integer);
begin

  try

    initializeQuery(qrTaskEx, 'update tbltasks set fstate=:pstate where id=:pid');
    qrTaskEx.ParamByName('pstate').AsInteger := piState;
    qrTaskEx.ParamByName('pid').AsInteger := miLastRecordID;
    qrTaskEx.ExecSQL;
    Transaction.Commit;
    reopenTables();
	except on E: Exception do
    begin

      NewMainForm.Transaction.Rollback;
      NewMainForm.processException('В процессе работы возникла исключительная ситуация: ', E);
		end;
	end;
end;


function TfmNewMain.getLastRecordID : Integer;
begin

  Result := miLastRecordID;
end;


procedure TfmNewMain.loadConfig;
var loIniMgr : TEasyIniManager;
begin

  msDataBasePath := getAppFolder + csDatabaseFileName;
  if not FileExists(getAppFolder + csIniFile) then
  begin

    loIniMgr := TEasyIniManager.Create(getAppFolder + csIniFile);
    loIniMgr.write('main', 'database', msDataBasePath);
    FreeAndNil(loIniMgr);
  end else
  begin

    loIniMgr := TEasyIniManager.Create(getAppFolder + csIniFile);
    msDataBasePath := loIniMgr.read('main', 'database', msDataBasePath);
    miContext := loIniMgr.read('main', 'context', cbContexts.ItemIndex);
    cbPeriod.ItemIndex := loIniMgr.read('main', 'period', cbPeriod.ItemIndex);
    FreeAndNil(loIniMgr);
  end;
end;


procedure TfmNewMain.saveConfig;
var loIniMgr : TEasyIniManager;
begin

  loIniMgr := TEasyIniManager.Create(getAppFolder + csIniFile);
  loIniMgr.write('main', 'context', cbContexts.ItemIndex);
  loIniMgr.write('main', 'period', cbPeriod.ItemIndex);
  FreeAndNil(loIniMgr);
end;


procedure TfmNewMain.actToInputBoxExecute(Sender : TObject);
begin

  changeState(ciInputType);
end;


procedure TfmNewMain.actToCompletedExecute(Sender : TObject);
begin

  changeState(ciDoneType);
end;


procedure TfmNewMain.actQuitExecute(Sender : TObject);
begin

  Close();
end;


procedure TfmNewMain.actSetupExecute(Sender : TObject);
begin

  fmSetup.ShowModal();
  reopenTables();
end;


procedure TfmNewMain.actNewTaskExecute(Sender : TObject);
begin

  fmTaskEdit.appendRecord();
  reopenTables();
end;


procedure TfmNewMain.actChangeInputTaskExecute(Sender : TObject);
begin

  fmTaskEdit.viewRecord(qrInput.FieldByName('id').AsInteger);
  if bbtFilter.ImageIndex = ciFilterOffIcon then
  begin

    reopenTablesWithFilter();
  end else
  begin

    reopenTables();
  end;
end;


procedure TfmNewMain.actChangeTrashTaskExecute(Sender : TObject);
begin

  fmTaskEdit.viewRecord(qrTrash.FieldByName('id').AsInteger);
  if bbtFilter.ImageIndex = ciFilterOffIcon then
  begin

    reopenTablesWithFilter();
  end else
  begin

  	reopenTables();
	end;
end;


procedure TfmNewMain.actChangeCompletedTaskExecute(Sender : TObject);
begin

  fmTaskEdit.viewRecord(qrCompleted.FieldByName('id').AsInteger);
  if bbtFilter.ImageIndex = ciFilterOffIcon then
  begin

    reopenTablesWithFilter();
  end else
  begin

  	reopenTables();
	end;
end;


procedure TfmNewMain.actChangeWorkTaskExecute(Sender : TObject);
begin

  fmTaskEdit.viewRecord(qrWork.FieldByName('id').AsInteger);
  if bbtFilter.ImageIndex = ciFilterOffIcon then
  begin

    reopenTablesWithFilter();
  end else
  begin

  	reopenTables();
	end;
end;


procedure TfmNewMain.actDeleteCompletedTaskExecute(Sender : TObject);
begin

  if not deleteTask(qrCompleted.FieldByName('id').AsInteger,
                    qrCompleted.FieldByName('fname').AsString) then
  begin

    notify('Внимание!', 'Удаление задачи не удалось из-за ошибки.');
	end;
end;


procedure TfmNewMain.actDeleteInputTaskExecute(Sender : TObject);
begin

  if not deleteTask(qrInput.FieldByName('id').AsInteger,
                    qrInput.FieldByName('fname').AsString) then
  begin

    notify('Внимание!', 'Удаление задачи не удалось из-за ошибки.');
	end;
end;


procedure TfmNewMain.actDeleteTrashTaskExecute(Sender : TObject);
begin

  if not deleteTask(qrTrash.FieldByName('id').AsInteger,
                    qrTrash.FieldByName('fname').AsString) then
  begin

    notify('Внимание!', 'Удаление задачи не удалось из-за ошибки.');
	end;
end;


procedure TfmNewMain.actDeleteWorkTaskExecute(Sender : TObject);
begin

  if not deleteTask(qrWork.FieldByName('id').AsInteger,
                    qrWork.FieldByName('fname').AsString) then
  begin

    notify('Внимание!', 'Удаление задачи не удалось из-за ошибки.');
	end;
end;


procedure TfmNewMain.actSaveExecute(Sender: TObject);
begin

  try

    initializeQuery(qrTaskEx,csInsertTaskSQL);
    qrTaskEx.ParamByName('pname').Text := edTaskName.Text;
    qrTaskEx.ParamByName('ptext').Text := '';
    qrTaskEx.ParamByName('pcontext').AsInteger := moContextsCombo.getIntKey();
    qrTaskEx.ParamByName('pcreated').AsDateTime := Now;
    qrTaskEx.ExecSQL;
    Transaction.Commit;
    reopenTables();
  except on E: Exception do
  begin
      Transaction.Rollback;
      processException('В процессе работы возникла исключительная ситуация: ', E);
  end;
  end;
  edTaskName.Clear;
end;


procedure TfmNewMain.actToTrashBinExecute(Sender : TObject);
begin

  changeState(ciTrashType);
end;


procedure TfmNewMain.actToWorkExecute(Sender : TObject);
begin

  changeState(ciWorkType);
end;


procedure TfmNewMain.bbtFilterClick(Sender: TObject);
begin

  if bbtFilter.ImageIndex = ciFilterOnIcon then
  begin

    // *** Фильтр выключен. Включаем.
    bbtFilter.ImageIndex := ciFilterOffIcon;
    edFilter.Enabled := False;
    cbContexts.Enabled := False;
    cbPeriod.Enabled := False;
    reopenTablesWithFilter();

  end else
  begin

    if bbtFilter.ImageIndex = ciFilterOffIcon then
    begin

      // *** Фильтр включен. Выключаем.
      bbtFilter.ImageIndex := ciFilterOnIcon;
      edFilter.Enabled := True;
      cbContexts.Enabled := True;
      cbPeriod.Enabled := True;
      reopenTables();
    end;
  end;
end;


procedure TfmNewMain.cbContextsChange(Sender: TObject);
begin

  reopenTables();
end;


procedure TfmNewMain.cbPeriodChange(Sender: TObject);
begin

  reopenTables();
end;

procedure TfmNewMain.dbgCompletedCellClick(Column: TColumn);
begin

  miLastRecordID := qrCompleted.FieldByName('id').AsInteger;
  EnableMovingActions(qrCompleted.RecordCount > 0);
  actToCompleted.Enabled := False;
end;


procedure TfmNewMain.dbgCompletedDblClick(Sender: TObject);
begin

  //
end;

procedure TfmNewMain.dbgInputCellClick(Column: TColumn);
begin

  miLastRecordID := qrInput.FieldByName('id').AsInteger;
  EnableMovingActions(qrInput.RecordCount > 0);
  actToInputBox.Enabled := False;
end;


procedure TfmNewMain.dbgInputDblClick(Sender: TObject);
begin

  //
end;


procedure TfmNewMain.dbgInputPrepareCanvas(sender: TObject; DataCol: Integer;
  Column: TColumn; AState: TGridDrawState);
var ldtDeadLine : TDate;
    ldtDateEnd : TDate;
    loGrid : TDBGrid;
    liDays : Integer;
begin

  loGrid := sender as TDBGrid;
  if not loGrid.DataSource.DataSet.FieldByName('fdeadline').IsNull then
  begin

    ldtDeadLine := loGrid.DataSource.DataSet.FieldByName('fdeadline').AsDateTime;
    if (loGrid.Name = 'dbgTrash') or (loGrid.Name = 'dbgDone') then
    begin

      if not loGrid.DataSource.DataSet.FieldByName('fupdated').IsNull then
      begin

        ldtDateEnd := loGrid.DataSource.DataSet.FieldByName('fupdated').AsDateTime;
      end else
      begin

        ldtDateEnd := loGrid.DataSource.DataSet.FieldByName('fcreated').AsDateTime;
      end;
    end else
    begin

      ldtDateEnd := Now;
    end;

    liDays := DaysBetween(ldtDateEnd, ldtDeadLine);
    if (ldtDeadLine < ldtDateEnd) and (liDays > 0) then
    begin

      // *** Просроченные задания
      loGrid.Canvas.Font.Color := ciExpiredColor;
    end else
    begin

      if liDays = 0 then
      begin

        // *** Срок выполнения истекает сегодня
        loGrid.Canvas.Font.Color := ciLastDayColor;
      end else
      begin

        if liDays <= 7 then
        begin

          // *** Срок исполнения на этой неделе
          loGrid.Canvas.Font.Color := ciThisWeekColor;
        end else
        begin

          // *** Не срочное дело
          loGrid.Canvas.Font.Color := ciSomeDayColor;
      	end;
      end;
    end;
  end else
  begin

    loGrid.Canvas.Font.Color := ciSomeDayColor;
  end;
end;

procedure TfmNewMain.dbgTrashCellClick(Column: TColumn);
begin

  miLastRecordID := qrTrash.FieldByName('id').AsInteger;
  EnableMovingActions(qrTrash.RecordCount > 0);
  actToTrashBin.Enabled := False;
end;


procedure TfmNewMain.dbgTrashDblClick(Sender: TObject);
begin

  //
end;


procedure TfmNewMain.dbgTrashPrepareCanvas(sender: TObject; DataCol: Integer;
  Column: TColumn; AState: TGridDrawState);
begin

  dbgTrash.Canvas.Font.Color := ciSomeDayColor;
  dbgCompleted.Canvas.Font.Color := ciSomeDayColor;
end;

procedure TfmNewMain.dbgWorkCellClick(Column: TColumn);
begin

  miLastRecordID := qrWork.FieldByName('id').AsInteger;
  EnableMovingActions(qrWork.RecordCount > 0);
  actToWork.Enabled := False;
end;

procedure TfmNewMain.dbgWorkDblClick(Sender: TObject);
begin

  //
end;

procedure TfmNewMain.edTaskNameChange(Sender: TObject);
begin

  bbtSave.Enabled := Length(Trim(edTaskName.Text)) > 0;
end;


procedure TfmNewMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

  saveConfig();
end;


procedure TfmNewMain.FormCreate(Sender: TObject);
begin

  inherited;
  NewMainForm := fmNewMain;
  try

    Caption := Caption + ' ver. ' + csVersion;
    loadConfig();
    createDatabaseIfNeeded();

    miLastRecordID := -1;
    qrInput.Active := False;
    qrWork.Active := False;
    qrTrash.Active := False;
    qrCompleted.Active := False;

    SQLite.Connected := True;

    EnableMovingActions(False);

    moContextsCombo := TEasyLookupCombo.Create();
    moContextsCombo.setComboBox(cbContexts);
    moContextsCombo.setQuery(qrContexts);
    moContextsCombo.setSQL('select * from tblcontexts where fstatus>0');
    moContextsCombo.setKeyField('id');
    moContextsCombo.setListField('fname');
    moContextsCombo.fill();
    cbContexts.ItemIndex := miContext;
    reopenTables();

    dbgInput.SelectedColor := $DDDDDD;
    dbgInput.FocusColor := clNavy;
    dbgWork.SelectedColor := $DDDDDD;
    dbgWork.FocusColor := clNavy;
    dbgTrash.SelectedColor := $DDDDDD;
    dbgTrash.FocusColor := clNavy;
    dbgCompleted.SelectedColor := $DDDDDD;
    dbgCompleted.FocusColor := clNavy;
    dbgTrash.Canvas.Font.Color := ciSomeDayColor;
    dbgCompleted.Canvas.Font.Color := ciSomeDayColor;

    FormResize(Self);
  except on E: Exception do
    begin

      processException('В процессе запуска программы возникла исключительная ситуация: ', E);
      Application.Terminate;
    end;
  end;
end;

procedure TfmNewMain.FormDblClick(Sender: TObject);
begin


end;


procedure TfmNewMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var liIndex : Integer;
begin

  liIndex := cbContexts.ItemIndex;
  if (ssCtrl in Shift) and (Key = VK_Q) then
  begin

    actQuitExecute(Nil);
  end else
  begin

    case Key of

      VK_F1 : begin

        if actToInputBox.Enabled then
        begin

          actToInputBoxExecute(Nil);
        end;
      end;
      VK_F2: begin

        if actToWork.Enabled then
        begin

          actToWorkExecute(Nil);
        end;
      end;
      VK_F3: begin

        if actToTrashBin.Enabled then
        begin

          actToTrashBinExecute(Nil);
        end;
      end;
      VK_F4: begin

        if actToCompleted.Enabled then
        begin

          actToCompletedExecute(Nil);
        end;
      end;
      VK_F12: begin

        if bbtFilter.IsEnabled then
        begin

          bbtFilterClick(Self);
	end;
      end;
      VK_PRIOR: begin

        if liIndex > 0 then
        begin

          dec(liIndex);
          cbContexts.ItemIndex := liIndex;
          cbContexts.OnChange(Nil);
	end;
      end;
      VK_NEXT: begin

        if liIndex + 1 < cbContexts.Items.Count then
        begin

          inc(liIndex);
          cbContexts.ItemIndex := liIndex;
          cbContexts.OnChange(Nil);
	end;
      end;
      VK_ADD: begin

        if cbPeriod.ItemIndex < cbPeriod.Items.Count -1 then
        begin

          cbPeriod.ItemIndex := cbPeriod.ItemIndex + 1;
          cbPeriodChange(Nil);
	end;
      end;
      VK_SUBTRACT: begin

        if cbPeriod.ItemIndex > 0 then
        begin

          cbPeriod.ItemIndex := cbPeriod.ItemIndex - 1;
          cbPeriodChange(Nil);
	end;
      end;
    end;
  end;
end;


procedure TfmNewMain.FormResize(Sender: TObject);
begin

  dbgInput.Columns[0].Width := ciDateColumnWidth;
  dbgInput.Columns[1].Width := dbgInput.Width - (ciColumnWidthDiff + ciDateColumnWidth);
  dbgWork.Columns[0].Width := ciDateColumnWidth;
  dbgWork.Columns[1].Width := dbgWork.Width - (ciColumnWidthDiff + ciDateColumnWidth);
  dbgTrash.Columns[0].Width := ciDateColumnWidth;
  dbgTrash.Columns[1].Width := dbgTrash.Width - (ciColumnWidthDiff + ciDateColumnWidth);
  dbgCompleted.Columns[0].Width := ciDateColumnWidth;
  dbgCompleted.Columns[1].Width := dbgCompleted.Width - (ciColumnWidthDiff + ciDateColumnWidth);
end;


end.

