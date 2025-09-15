unit frmMaim;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.StrUtils,
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
    btValidar: TButton;
    StringGrid1: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    GroupBox5: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    edtPlOld: TEdit;
    edtPlMS: TEdit;
    GroupBox6: TGroupBox;
    edtEmail: TEdit;
    chkbxShowAlerta: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure btValidarClick(Sender: TObject);
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  mask := TMask.Create(self);

  mask.defCEP   (edtCEP, edtEnde, edtComple, edtBairro, edtCidade, CmbBxUF);
  mask.defCPF   (edtCPF);
  mask.defCNPJ  (edtCNPJ);
  mask.defFFixo (edtFoneFixo);
  mask.defCel   (edtFoneCel);
  mask.defPlOld (edtPlOld);
  mask.defPlMS  (edtPlMS);
  mask.defEmail (edtEmail);

  mask.start(Self);
end;

procedure TForm1.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  mask.validaAllEdtColor(Self);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  mask.Destroy;
end;


procedure TForm1.btValidarClick(Sender: TObject);
var
  CPFNum, CNPJNum, telFixNum, telCelNum, CEPNum: Double;
  CPFstr, CNPJstr, telFixstr, telCelstr, CEPstr, PlOldstr, PlMSstr: string;
  CPFBol, CNPJBol, telFixBol, telCelBol, CEPBol, PlOldBol, PlMSBol: Boolean;

  PlOldNum, PlMSNum: string;
  email   : string;
  emailBol: Boolean;
begin

  //define se será exibido uma mensagem de alerta
  mask.setExibirMSG(chkbxShowAlerta.IsChecked);

  // recupera apenas os numeros
  CPFNum     := StrToCurr (mask.limparTxt (edtCPF.Text));
  CNPJNum    := StrToCurr (mask.limparTxt (edtCNPJ.Text));
  telFixNum  := StrToCurr (mask.limparTxt (edtFoneFixo.Text));
  telCelNum  := StrToCurr (mask.limparTxt (edtFoneCel.Text));
  CEPNum     := StrToCurr (mask.limparTxt (edtCEP.Text));
  PlOldNum   := mask.limparTxt (edtPlOld.Text);
  PlMSNum    := mask.limparTxt (edtPlMS.Text);
  email      := edtEmail.Text;

  //aplica a mascara de exibição
  CPFstr    := mask.formatCPF(CPFNum);
  CNPJstr   := mask.formatCNPJ(CNPJNum);
  telFixstr := mask.formatFone(telFixNum);
  telCelstr := mask.formatCel(telCelNum);
  CEPstr    := mask.formatCEP(CEPNum);
  PlOldstr  := mask.formatPlOld(PlOldNum);
  PlMSstr   := mask.formatPlMS(PlMSNum);

  //valida se esta correto
  CPFBol    := mask.isCPF(CPFstr);
  CNPJBol   := mask.isCNPJ(CNPJstr);
  telFixBol := mask.isFone(telFixstr);
  telCelBol := mask.isCel(telCelstr);
  CEPBol    := mask.isCEP(CEPstr);
  PlOldBol  := mask.isPlOld(PlOldstr);
  PlMSBol   := mask.isPlMS(PlMSstr);
  emailBol  := mask.isEmail(email);

  //exibe os valores
  StringGrid1.Cells[0,0] := 'CPF';
  StringGrid1.Cells[0,1] := 'CNPJ';
  StringGrid1.Cells[0,2] := 'Telefone Fixo';
  StringGrid1.Cells[0,3] := 'Telefone Celular';
  StringGrid1.Cells[0,4] := 'CEP';
  StringGrid1.Cells[0,5] := 'Pl antiga';
  StringGrid1.Cells[0,6] := 'Pl MercoSul';
  StringGrid1.Cells[0,7] := 'Email';

  //somente os numeros
  StringGrid1.Cells[1,0] := CPFNum.ToString;
  StringGrid1.Cells[1,1] := CNPJNum.ToString;
  StringGrid1.Cells[1,2] := telFixNum.ToString;
  StringGrid1.Cells[1,3] := telCelNum.ToString;
  StringGrid1.Cells[1,4] := CEPNum.ToString;
  StringGrid1.Cells[1,5] := PlOldNum;
  StringGrid1.Cells[1,6] := PlMSNum;
  StringGrid1.Cells[1,7] := 'Não aplica';

  //formatado
  StringGrid1.Cells[2,0] := CPFstr;
  StringGrid1.Cells[2,1] := CNPJstr;
  StringGrid1.Cells[2,2] := telFixstr;
  StringGrid1.Cells[2,3] := telCelstr;
  StringGrid1.Cells[2,4] := CEPstr;
  StringGrid1.Cells[2,5] := PlOldstr;
  StringGrid1.Cells[2,6] := PlMSstr;
  StringGrid1.Cells[2,7] := email;

  //validacao
  StringGrid1.Cells[3,0] := ifThen (CPFBol,    'OK','NOK');
  StringGrid1.Cells[3,1] := ifThen (CNPJBol,   'OK','NOK');
  StringGrid1.Cells[3,2] := ifThen (telFixBol, 'OK','NOK');
  StringGrid1.Cells[3,3] := ifThen (telCelBol, 'OK','NOK');
  StringGrid1.Cells[3,4] := ifThen (CEPBol,    'OK','NOK');
  StringGrid1.Cells[3,5] := ifThen (PlOldBol,  'OK','NOK');
  StringGrid1.Cells[3,6] := ifThen (PlMSBol,   'OK','NOK');
  StringGrid1.Cells[3,7] := ifThen (emailBol,  'OK','NOK');
end;


end.
