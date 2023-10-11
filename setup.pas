unit setup;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
		ComCtrls, Buttons, DBGrids;

type

		{ TfmSetup }

    TfmSetup = class(TForm)
				bbtQuit : TBitBtn;
				ControlBar1 : TControlBar;
				dsContexts : TDataSource;
				DBGrid1 : TDBGrid;
				Panel1 : TPanel;
				sbCreate : TSpeedButton;
				sbChange : TSpeedButton;
				sbDelete : TSpeedButton;
				qrContexts : TSQLQuery;
				qrContextEx : TSQLQuery;
    private

    public

    end;

var
    fmSetup : TfmSetup;

implementation


uses main;
{$R *.lfm}

end.

