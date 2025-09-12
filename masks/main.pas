unit frmMaim;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, untMask, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, System.Rtti, FMX.Grid.Style, FMX.Grid;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    edtCEP: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    edtEnde: TEdit;
    edtComple: TEdit;
    edtBairro: TEdit;
    edtCidade: TEdit;
    CmbBxUF: TComboBox;
    GroupBox2: TGroupBox;
    edtCPF: TEdit;
    edtCNPJ: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox3: TGroupBox;
    Label3: TLabel;
    edtFoneFixo: TEdit;
    Label4: TLabel;
    edtFoneCel: TEdit;
    GroupBox4: TGroupBox;
    Converter: TButton;
    StringGrid1: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure ConverterClick(Sender: TObject);
  private
    { Private declarations }
    var mask: TMask;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}


procedure TForm1.ConverterClick(Sender: TObject);
var
  CPFNum, CNPJNum, telFixNum, telCelNum, CEPNum: Double;
  CPFstr, CNPJstr, telFixstr, telCelstr, CEPstr: string;
  CPFBol, CNPJBol, telFixBol, telCelBol, CEPBol: Boolean;
begin

  // recupera apenas os numeros
  CPFNum    :=  StrToCurr(mask.limparTxt(edtCPF.Text));
  CNPJNum   :=  StrToCurr(mask.limparTxt(edtCNPJ.Text));
  telFixNum :=  StrToCurr(mask.limparTxt(edtFoneFixo.Text));
  telCelNum :=  StrToCurr(mask.limparTxt(edtFoneCel.Text));
  CEPNum    :=  StrToCurr(mask.limparTxt(edtCEP.Text));


  //aplica a mascara de exibição
  CPFstr    := mask.formatarCPF(CPFNum);
  CNPJstr   := mask.formatarCNPJ(CNPJNum);
  telFixstr := mask.formatarFone(telFixNum);
  telCelstr := mask.formatarCel(telCelNum);
  CEPstr    := mask.formatarCEP(CEPNum);


  //valida se esta correto
  CPFBol    := mask.isCPF(CPFstr);
  CNPJBol   := mask.isCNPJ(CNPJstr);
  telFixBol := mask.isFone(telFixstr);
  telCelBol := mask.isCel(telCelstr);
  CEPBol    := mask.isCEP(CEPstr);


  //exibe os valores
  StringGrid1.Cells[0,0] := 'CPF';
  StringGrid1.Cells[0,1] := 'CNPJ';
  StringGrid1.Cells[0,2] := 'Telefone Fixo';
  StringGrid1.Cells[0,3] := 'Telefone Celular';
  StringGrid1.Cells[0,4] := 'CEP';

  //somente os numeros
  StringGrid1.Cells[1,0] := CPFNum.ToString;
  StringGrid1.Cells[1,1] := CNPJNum.ToString;
  StringGrid1.Cells[1,2] := telFixNum.ToString;
  StringGrid1.Cells[1,3] := telCelNum.ToString;
  StringGrid1.Cells[1,4] := CEPNum.ToString;

  //formatado
  StringGrid1.Cells[2,0] := CPFstr;
  StringGrid1.Cells[2,1] := CNPJstr;
  StringGrid1.Cells[2,2] := telFixstr;
  StringGrid1.Cells[2,3] := telCelstr;
  StringGrid1.Cells[2,4] := CEPstr;

  //validacao
  if (CPFBol) then StringGrid1.Cells[3,0] :='OK'
  else StringGrid1.Cells[3,0] := 'NOK';

  if (CNPJBol) then StringGrid1.Cells[3,1] :='OK'
  else StringGrid1.Cells[3,1] := 'NOK';

  if (telFixBol) then StringGrid1.Cells[3,2] :='OK'
  else StringGrid1.Cells[3,2] := 'NOK';

  if (telCelBol) then StringGrid1.Cells[3,3] :='OK'
  else StringGrid1.Cells[3,3] := 'NOK';

  if (CEPBol) then StringGrid1.Cells[3,4] :='OK'
  else StringGrid1.Cells[3,4] := 'NOK';

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  mask.Destroy;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  mask := TMask.Create  (self);

  mask.defCEP(edtCEP, edtEnde, edtComple, edtBairro, edtCidade, CmbBxUF);
  mask.defCPF(edtCPF);
  mask.defCNPJ(edtCNPJ);
  mask.defFoneFixo(edtFoneFixo);
  mask.defFoneCel(edtFoneCel);

  mask.start(Self);
end;

procedure TForm1.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  mask.validaAllEdtColor(Self);
end;

end.
