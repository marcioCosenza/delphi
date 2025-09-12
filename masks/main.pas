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
    GroupBox5: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    edtPlacaOld: TEdit;
    edtPlacaMS: TEdit;
    GroupBox6: TGroupBox;
    edtEmail: TEdit;
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
  CPFstr, CNPJstr, telFixstr, telCelstr, CEPstr, placaOldstr, placaMSstr: string;
  CPFBol, CNPJBol, telFixBol, telCelBol, CEPBol, placaOldBol, placaMSBol: Boolean;

  placaOldNum, placaMSNum: string;
  email: string;
  emailBol: Boolean;
begin

  // recupera apenas os numeros
  CPFNum      :=  StrToCurr(mask.limparTxt(edtCPF.Text));
  CNPJNum     :=  StrToCurr(mask.limparTxt(edtCNPJ.Text));
  telFixNum   :=  StrToCurr(mask.limparTxt(edtFoneFixo.Text));
  telCelNum   :=  StrToCurr(mask.limparTxt(edtFoneCel.Text));
  CEPNum      :=  StrToCurr(mask.limparTxt(edtCEP.Text));
  placaOldNum :=  mask.limparTxt(edtPlacaOld.Text);
  placaMSNum  :=  mask.limparTxt(edtPlacaMS.Text);
  email       := edtEmail.Text;

  //aplica a mascara de exibição
  CPFstr      := mask.formatarCPF(CPFNum);
  CNPJstr     := mask.formatarCNPJ(CNPJNum);
  telFixstr   := mask.formatarFone(telFixNum);
  telCelstr   := mask.formatarCel(telCelNum);
  CEPstr      := mask.formatarCEP(CEPNum);
  placaOldstr := mask.formatarPlacaOld(placaOldNum);
  placaMSstr  := mask.formatarPlacaMS(placaMSNum);

  //valida se esta correto
  CPFBol      := mask.isCPF(CPFstr);
  CNPJBol     := mask.isCNPJ(CNPJstr);
  telFixBol   := mask.isFone(telFixstr);
  telCelBol   := mask.isCel(telCelstr);
  CEPBol      := mask.isCEP(CEPstr);
  placaOldBol := mask.isPlacaOld(placaOldstr);
  placaMSBol  := mask.isPlacaMS(placaMSNum);
  emailBol    := mask.isEmail(email);

  //exibe os valores
  StringGrid1.Cells[0,0] := 'CPF';
  StringGrid1.Cells[0,1] := 'CNPJ';
  StringGrid1.Cells[0,2] := 'Telefone Fixo';
  StringGrid1.Cells[0,3] := 'Telefone Celular';
  StringGrid1.Cells[0,4] := 'CEP';
  StringGrid1.Cells[0,5] := 'Placa antiga';
  StringGrid1.Cells[0,6] := 'Placa MercoSul';
  StringGrid1.Cells[0,7] := 'Email';

  //somente os numeros
  StringGrid1.Cells[1,0] := CPFNum.ToString;
  StringGrid1.Cells[1,1] := CNPJNum.ToString;
  StringGrid1.Cells[1,2] := telFixNum.ToString;
  StringGrid1.Cells[1,3] := telCelNum.ToString;
  StringGrid1.Cells[1,4] := CEPNum.ToString;
  StringGrid1.Cells[1,5] := placaOldNum;
  StringGrid1.Cells[1,6] := placaMSNum;
  StringGrid1.Cells[1,7] := 'Não aplica';

  //formatado
  StringGrid1.Cells[2,0] := CPFstr;
  StringGrid1.Cells[2,1] := CNPJstr;
  StringGrid1.Cells[2,2] := telFixstr;
  StringGrid1.Cells[2,3] := telCelstr;
  StringGrid1.Cells[2,4] := CEPstr;
  StringGrid1.Cells[2,5] := placaOldstr;
  StringGrid1.Cells[2,6] := placaMSstr;
  StringGrid1.Cells[2,7] := email;

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

  if (placaOldBol) then StringGrid1.Cells[3,5] :='OK'
  else StringGrid1.Cells[3,5] := 'NOK';

  if (placaMSBol) then StringGrid1.Cells[3,6] :='OK'
  else StringGrid1.Cells[3,6] := 'NOK';

  if (emailBol) then StringGrid1.Cells[3,7] :='OK'
  else StringGrid1.Cells[3,7] := 'NOK';
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
  mask.defPlacaOld(edtPlacaOld);
  mask.defPlacaMS(edtPlacaMS);
  mask.defEmail(edtEmail);

  mask.start(Self);
end;

procedure TForm1.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  mask.validaAllEdtColor(Self);
end;

end.
