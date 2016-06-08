unit uBeanPrecificacao_itens;

interface
uses
  uDomains,
  uFWPersistence;
type
  TPRECIFICACAO_ITENS = class(TFWPersistence)
  private
    FPRECIFICACAO_ID: TFieldInteger;
    FTIPOCALCULO: TFieldInteger;
    FPRECOCADASTRO: TFieldCurrency;
    FPRECODE: TFieldCurrency;
    FMARGEMSUGERIDA: TFieldCurrency;
    FCUSTO_ATUAL: TFieldCurrency;
    FMARGEMPRATICAR: TFieldCurrency;
    FMEDIA: TFieldCurrency;
    FID: TFieldInteger;
    FPRECOESPECIAL: TFieldCurrency;
    FCUSTO_ANT: TFieldCurrency;
    FPRECOPOR: TFieldCurrency;
    procedure SetCUSTO_ANT(const Value: TFieldCurrency);
    procedure SetCUSTO_ATUAL(const Value: TFieldCurrency);
    procedure SetID(const Value: TFieldInteger);
    procedure SetMARGEMPRATICAR(const Value: TFieldCurrency);
    procedure SetMARGEMSUGERIDA(const Value: TFieldCurrency);
    procedure SetMEDIA(const Value: TFieldCurrency);
    procedure SetPRECIFICACAO_ID(const Value: TFieldInteger);
    procedure SetPRECOCADASTRO(const Value: TFieldCurrency);
    procedure SetPRECODE(const Value: TFieldCurrency);
    procedure SetPRECOESPECIAL(const Value: TFieldCurrency);
    procedure SetPRECOPOR(const Value: TFieldCurrency);
    procedure SetTIPOCALCULO(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property CUSTO_ANT : TFieldCurrency read FCUSTO_ANT write SetCUSTO_ANT;
    property CUSTO_ATUAL : TFieldCurrency read FCUSTO_ATUAL write SetCUSTO_ATUAL;
    property PRECOESPECIAL : TFieldCurrency read FPRECOESPECIAL write SetPRECOESPECIAL;
    property PRECOCADASTRO : TFieldCurrency read FPRECOCADASTRO write SetPRECOCADASTRO;
    property MARGEMSUGERIDA : TFieldCurrency read FMARGEMSUGERIDA write SetMARGEMSUGERIDA;
    property PRECODE : TFieldCurrency read FPRECODE write SetPRECODE;
    property PRECOPOR : TFieldCurrency read FPRECOPOR write SetPRECOPOR;
    property MARGEMPRATICAR : TFieldCurrency read FMARGEMPRATICAR write SetMARGEMPRATICAR;
    property MEDIA : TFieldCurrency read FMEDIA write SetMEDIA;
    property PRECIFICACAO_ID : TFieldInteger read FPRECIFICACAO_ID write SetPRECIFICACAO_ID;
    property TIPOCALCULO : TFieldInteger read FTIPOCALCULO write SetTIPOCALCULO;
  end;
implementation

{ TPRECIFICACAO_ITENS }

procedure TPRECIFICACAO_ITENS.InitInstance;
begin
  inherited;
  ID.isPK   := True;
end;

procedure TPRECIFICACAO_ITENS.SetCUSTO_ANT(const Value: TFieldCurrency);
begin
  FCUSTO_ANT := Value;
end;

procedure TPRECIFICACAO_ITENS.SetCUSTO_ATUAL(const Value: TFieldCurrency);
begin
  FCUSTO_ATUAL := Value;
end;

procedure TPRECIFICACAO_ITENS.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPRECIFICACAO_ITENS.SetMARGEMPRATICAR(const Value: TFieldCurrency);
begin
  FMARGEMPRATICAR := Value;
end;

procedure TPRECIFICACAO_ITENS.SetMARGEMSUGERIDA(const Value: TFieldCurrency);
begin
  FMARGEMSUGERIDA := Value;
end;

procedure TPRECIFICACAO_ITENS.SetMEDIA(const Value: TFieldCurrency);
begin
  FMEDIA := Value;
end;

procedure TPRECIFICACAO_ITENS.SetPRECIFICACAO_ID(const Value: TFieldInteger);
begin
  FPRECIFICACAO_ID := Value;
end;

procedure TPRECIFICACAO_ITENS.SetPRECOCADASTRO(const Value: TFieldCurrency);
begin
  FPRECOCADASTRO := Value;
end;

procedure TPRECIFICACAO_ITENS.SetPRECODE(const Value: TFieldCurrency);
begin
  FPRECODE := Value;
end;

procedure TPRECIFICACAO_ITENS.SetPRECOESPECIAL(const Value: TFieldCurrency);
begin
  FPRECOESPECIAL := Value;
end;

procedure TPRECIFICACAO_ITENS.SetPRECOPOR(const Value: TFieldCurrency);
begin
  FPRECOPOR := Value;
end;

procedure TPRECIFICACAO_ITENS.SetTIPOCALCULO(const Value: TFieldInteger);
begin
  FTIPOCALCULO := Value;
end;

end.