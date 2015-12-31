unit uMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Data.DB, Datasnap.DBClient, Vcl.DBCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  frxClass, frxDMPExport, System.Win.ComObj;

type
  TfrmMatch = class(TForm)
    Panel2: TPanel;
    pnBotoesVisualizacao: TPanel;
    btSair: TSpeedButton;
    btExport1: TSpeedButton;
    btExport2: TSpeedButton;
    pnFiltro: TPanel;
    btConsultar: TSpeedButton;
    gdMatch: TDBGrid;
    cbLoteImportacao: TComboBox;
    ds_Match: TDataSource;
    cds_Match: TClientDataSet;
    cds_MatchSKU: TStringField;
    cds_MatchMARCA: TStringField;
    cds_MatchCUSTOANTERIOR: TCurrencyField;
    cds_MatchCUSTOATUAL: TCurrencyField;
    cds_MatchPERCENTUALDIFERENCA: TCurrencyField;
    cds_MatchFORNCECEDORANTERIOR: TStringField;
    cds_MatchFORNECEDORATUAL: TStringField;
    cds_MatchSTATUS: TStringField;
    SaveDialog1: TSaveDialog;
    btRelatorio: TSpeedButton;
    edFiltroSKU: TLabeledEdit;
    edFiltroMarca: TLabeledEdit;
    cds_MatchLOTE: TIntegerField;
    cds_MatchDATAULTIMOLOTE: TDateField;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure btConsultarClick(Sender: TObject);
    procedure gdMatchTitleClick(Column: TColumn);
    procedure cds_MatchCalcFields(DataSet: TDataSet);
    procedure ExportClick(Sender: TObject);
  private
    Procedure CarregaLoteImportacao;
    Procedure ConsultaMatch;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMatch: TfrmMatch;

implementation

uses
  uConstantes,
  uFuncoes,
  uBeanLOTEIMPORTACAO,
  uFWConnection,
  uMensagem,
  uDMUtil;

{$R *.dfm}

{ TfrmMatch }

procedure TfrmMatch.btConsultarClick(Sender: TObject);
begin
  ConsultaMatch;
end;

procedure TfrmMatch.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMatch.CarregaLoteImportacao;
Var
  FWC : TFWConnection;
  L  : TLOTE;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  L   := TLOTE.Create(FWC);

  try
    try

      L.SelectList('','DATA_HORA DESC');
      cbLoteImportacao.Items.Clear;

      if L.Count > 0 then begin
        for I := 0 to L.Count - 1 do begin
          cbLoteImportacao.Items.Add(IntToStr(TLOTE(L.Itens[I]).ID.Value) + ' - ' + FormatDateTime('dd/mm/yyyy', TLOTE(L.Itens[I]).DATA_HORA.Value));
          if cbLoteImportacao.Items.Count >= 5 then
            Break;
        end;
      end;

      if cbLoteImportacao.Items.Count > 0 then
        cbLoteImportacao.ItemIndex := 0;

    except
      on E : Exception do Begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gerar lote de Importa��o', 'ClassName ' + E.ClassName + ' ' + E.Message);
      End;
    end;
  finally
    FreeAndNil(L);
    FreeAndNil(FWC);
  end;

end;

procedure TfrmMatch.cds_MatchCalcFields(DataSet: TDataSet);
begin
  with DataSet do begin
    FieldByName('PERCENTUALDIFERENCA').Value := 0.00;
    if FieldByName('CUSTOANTERIOR').Value > 0.00 then begin
      if FieldByName('CUSTOATUAL').Value > 0.00 then begin

        if FieldByName('CUSTOATUAL').Value > FieldByName('CUSTOANTERIOR').Value then
          FieldByName('PERCENTUALDIFERENCA').Value := Trunc((((FieldByName('CUSTOATUAL').Value * 100) / FieldByName('CUSTOANTERIOR').Value) - 100) * 100) / 100.00
        else begin
          if FieldByName('CUSTOATUAL').Value < FieldByName('CUSTOANTERIOR').Value then
            FieldByName('PERCENTUALDIFERENCA').Value := Trunc((100 - ((FieldByName('CUSTOATUAL').Value * 100) / FieldByName('CUSTOANTERIOR').Value)) * 100.00) / 100.00
        end;

      end;
    end;
  end;
end;

procedure TfrmMatch.ConsultaMatch;
Var
  FWC     : TFWConnection;
  SQL     : TFDQuery;
  SQLLOTE : TFDQuery;
begin

  FWC     := TFWConnection.Create;
  SQL     := TFDQuery.Create(nil);
  SQLLOTE := TFDQuery.Create(nil);

  cds_Match.DisableControls;
  cds_Match.EmptyDataSet;
  try

    SQLLOTE.Close;
    SQLLOTE.SQL.Clear;
    SQLLOTE.SQL.Add('SELECT L.ID, CAST(L.DATA_HORA AS DATE) FROM LOTE L WHERE L.ID = (');
    SQLLOTE.SQL.Add('SELECT COALESCE(MAX(IMP.ID_LOTE),0) FROM IMPORTACAO IMP');
    SQLLOTE.SQL.Add('	INNER JOIN IMPORTACAO_ITENS IMPI ON (IMPI.ID_IMPORTACAO = IMP.ID)');
    SQLLOTE.SQL.Add('WHERE');
    SQLLOTE.SQL.Add('	IMPI.ID_PRODUTO = :ID_PRODUTO)');
    SQLLOTE.Params[0].DataType := ftInteger;
    SQLLOTE.Connection  := FWC.FDConnection;

    SQL.Close;
    SQL.SQL.Clear;
    SQL.SQL.Add('SELECT');
    SQL.SQL.Add('	P.ID,');
    SQL.SQL.Add('	P.SKU,');
    SQL.SQL.Add('	P.MARCA,');
    SQL.SQL.Add('	P.CUSTO AS CUSTOANTERIOR,');
    SQL.SQL.Add('	10 AS CUSTOATUAL,');
    SQL.SQL.Add('	CAST(P.SUB_GRUPO AS VARCHAR(100)) AS FORNANTERIOR,');
    SQL.SQL.Add('	CAST(''Fornec. Atual'' AS VARCHAR(100)) AS FORNATUAL,');
    SQL.SQL.Add('	CAST(''ATUALIZADO'' AS VARCHAR(100)) AS STATUS');
    SQL.SQL.Add('FROM PRODUTO P');
    SQL.Connection  := FWC.FDConnection;
    SQL.Open;

    if not SQL.IsEmpty then begin
      SQL.First;
      while not SQL.Eof do begin
        cds_Match.Append;
        cds_MatchSKU.Value                  := SQL.Fields[1].Value;
        cds_MatchMARCA.Value                := SQL.Fields[2].Value;
        cds_MatchCUSTOANTERIOR.Value        := SQL.Fields[3].Value;
        cds_MatchCUSTOATUAL.Value           := SQL.Fields[4].Value;
        cds_MatchFORNCECEDORANTERIOR.Value  := SQL.Fields[5].Value;
        cds_MatchFORNECEDORATUAL.Value      := SQL.Fields[6].Value;
        cds_MatchSTATUS.Value               := SQL.Fields[7].Value;

        //Carrega o �ltimo Lote
        SQLLOTE.Close;
        SQLLOTE.Prepare;
        SQLLOTE.Params[0].Value := SQL.Fields[0].Value; //Passa o ID
        SQLLOTE.Open;
        if not SQLLOTE.IsEmpty then begin
          cds_MatchLOTE.Value                 := SQLLOTE.Fields[0].Value;
          cds_MatchDATAULTIMOLOTE.Value       := SQLLOTE.Fields[1].Value;
        end;

        cds_Match.Post;
        SQL.Next
      end;
      cds_Match.First;
    end;

  finally
    cds_Match.EnableControls;
    FreeAndNil(SQLLOTE);
    FreeAndNil(SQL);
    FreeAndNil(FWC);
  end;

end;

procedure TfrmMatch.ExportClick(Sender: TObject);
Var
  Excel : Variant;
begin

  if not cds_Match.IsEmpty then begin


    cds_Match.DisableControls;
    Excel := CreateOleObject('Excel.Application');

    try

      Excel.WorkBooks.Add;
      Excel.WorkBooks[1].WorkSheets[1].Name := 'Estoque';
      Excel.Visible := False;

      if (Sender as TSpeedButton).Name = 'btExport1' then begin

        Excel.Caption := 'Atualiza��o de Estoque Virtual';
        Excel.Cells[1,1] := 'SKU';
        Excel.Cells[1,2] := 'MARCA';
        Excel.Cells[1,3] := 'STATUS';

        cds_Match.First;
        While not cds_Match.Eof do begin
          Excel.Cells[cds_Match.RecNo + 1,1]  := cds_MatchSKU.Value;
          Excel.Cells[cds_Match.RecNo + 1,2]  := cds_MatchMARCA.Value;
          Excel.Cells[cds_Match.RecNo + 1,3]  := cds_MatchSTATUS.Value;
          cds_Match.Next;
        end;

        Excel.Range['A1:C1'].Font.Bold       := True;
      end;

      if (Sender as TSpeedButton).Name = 'btExport2' then begin

      end;

      Excel.Columns.AutoFit;
      Excel.DisplayAlerts := False;

      if SaveDialog1.Execute then begin
        Excel.ActiveWorkbook.SaveAs(SaveDialog1.FileName);
        DisplayMsg(MSG_INF, 'Arquivo Gerado com Sucesso!');
      end;

    finally
      Excel.Workbooks.close;
      Excel.Quit;
      Excel := Unassigned;
      cds_Match.EnableControls;
    end;

  end else
    DisplayMsg(MSG_WAR, 'N�o h� Dados a serem Exportados, Verifique!');

end;

procedure TfrmMatch.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmMatch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : begin
        Close;
    end;
  end;
end;

procedure TfrmMatch.FormShow(Sender: TObject);
begin
  cds_Match.CreateDataSet;

  //AutoSizeDBGrid(gdPesquisa);

  CarregaLoteImportacao;
end;

procedure TfrmMatch.gdMatchTitleClick(Column: TColumn);
Var
  I : Integer;
begin

  if (Column.Field.FieldKind <> fkCalculated) then begin

    cds_Match.IndexFieldNames := Column.FieldName;

    for I := 0 to gdMatch.Columns.Count -1 do begin
      if gdMatch.Columns[I].Color <> clWhite then begin
        gdMatch.Columns[I].Color := clWhite;
      end;
    end;
    Column.Color := clLime;
  end;
end;

end.
