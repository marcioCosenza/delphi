unit frmMain;

interface

uses
  System.SysUtils, System.Classes, System.UITypes,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.Controls,
  untMC2000T2, CPDrv;

type
  TFormMain = class(TForm)
    Panel4: TPanel;
    Panel3: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    edtPosX: TEdit;
    edtForca: TEdit;
    edtAngulo: TEdit;
    edtLarg: TEdit;
    edtAltura: TEdit;
    edtSpeed: TEdit;
    edtPosY: TEdit;
    edtDens: TEdit;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel1: TPanel;
    GroupBox3: TGroupBox;
    StringGrid1: TStringGrid;
    Panel2: TPanel;
    GroupBox2: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    GroupBox4: TGroupBox;
    RdBttnTxt: TRadioButton;
    RdBttnFile: TRadioButton;
    RdBttnDtmtrx: TRadioButton;
    edtDados: TEdit;
    Label9: TLabel;
    Button5: TButton;
    Panel7: TPanel;
    Panel8: TPanel;
    BttnAdd: TButton;
    BttnLimpar: TButton;
    BttnEnviar: TButton;
    Panel9: TPanel;
    Panel10: TPanel;
    CheckBox1: TCheckBox;
    Timer1: TTimer;
    procedure BttnEnviarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure edtPosXKeyPress(Sender: TObject; var Key: Char);
    procedure edtForcaKeyPress(Sender: TObject; var Key: Char);
    procedure edtAnguloKeyPress(Sender: TObject; var Key: Char);
    procedure edtAlturaKeyPress(Sender: TObject; var Key: Char);
    procedure edtPosYKeyPress(Sender: TObject; var Key: Char);
    procedure edtDensKeyPress(Sender: TObject; var Key: Char);
    procedure edtSpeedKeyPress(Sender: TObject; var Key: Char);
    procedure edtLargKeyPress(Sender: TObject; var Key: Char);
    procedure BttnAddClick(Sender: TObject);
    procedure BttnLimparClick(Sender: TObject);
    procedure Panel7Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure tratarTela();
  private
    { Private declarations }

    procedure habilitar(param: boolean);
    procedure habilitarBTsIsConected(param: boolean);
    function soNum(KeyChar: char): char;

  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;
  MC2000T2: TMC2000T2;

implementation

{$R *.dfm}


procedure TFormMain.FormCreate(Sender: TObject);
var
  I     : Integer;
  titulo: string;



begin

//  habilitar(False);
  habilitar(True);
  MC2000T2 := TMC2000T2.create(Self);

  //a confguração é opcional, pode ser feita diretamente no 'oCreate' da classe TMC2000T2
  MC2000T2.setCPortPortName('COM1');
  MC2000T2.setCPortBaudRate(br9600);
  MC2000T2.setCPortStopBits(sb1BITS);
  MC2000T2.setCPortSwFlow(sfNONE);
  MC2000T2.setCPortDataBits(db8BITS);
  MC2000T2.setCPortParity(TParity.ptNONE);

  for I := 0 to 7 do
    begin
    titulo := MC2000T2.getItemFuncao(I)  + ' (' + MC2000T2.getItemMin(I).ToString() + '/' + MC2000T2.getItemMax(I).ToString() + ')';
    case I of
      0:Label1.Caption := titulo;
      1:Label6.Caption := titulo;
      2:Label5.Caption := titulo;
      3:Label2.Caption := titulo;
      4:Label4.Caption := titulo;
      5:Label8.Caption := titulo;
      6:Label7.Caption := titulo;
      7:Label3.Caption := titulo;
  //    8:LabelXX.Caption := titulo;
    end;



  end;



//for I := 0 to 8 do
  StringGrid1.DefaultColWidth := 60;
  StringGrid1.Font.Size := 14;

StringGrid1.Cells[0,0] := 'Pos X';
StringGrid1.Cells[1,0] := 'Pos Y';
StringGrid1.Cells[2,0] := 'Força';
StringGrid1.Cells[3,0] := 'Dens.';
StringGrid1.Cells[4,0] := 'Ang.';
StringGrid1.Cells[5,0] := 'Vel.';
StringGrid1.Cells[6,0] := 'Alt';
StringGrid1.Cells[7,0] := 'Larg';

end;


procedure TFormMain.Button1Click(Sender: TObject);
begin
  tratarTela();
  MC2000T2.Avancar();
end;

procedure TFormMain.Button2Click(Sender: TObject);
begin
  tratarTela();
  MC2000T2.Pausar();
end;

procedure TFormMain.Button3Click(Sender: TObject);
begin
  tratarTela();
  MC2000T2.Cancelar();
end;

procedure TFormMain.Button4Click(Sender: TObject);
begin
  tratarTela();
  if (MC2000T2.solStatus()) then
  MessageDlg('sucesso!', mtInformation, [mbok], 0)
  else MessageDlg('Falha!', mtError, [mbok], 0);
end;

procedure TFormMain.BttnEnviarClick(Sender: TObject);
begin
  //MC2000T2.setDestinatario(2); // o valor do parametro é o valor em decimal da tabela ASCii

  tratarTela();

  if (MC2000T2.enviar()) then MessageDlg('Dados enviados com sucesso!', mtInformation, [mbok], 0)
  else MessageDlg('Falha ao enviar os dados a marcadora Couth!', mtError, [mbok], 0);
end;


procedure TFormMain.CheckBox1Click(Sender: TObject);
begin
  MC2000T2.setKeepCon(CheckBox1.Checked);
end;

procedure TFormMain.BttnAddClick(Sender: TObject);
var
  op: integer;
begin

  op := 0;
  if (RdBttnDtmtrx.Checked) then op := 1
  else if (RdBttnFile.Checked) then op := 2;

  MC2000T2.addLinha    ();
  MC2000T2.setAltChar  (StrToInt(edtAltura.Text)); // Altura do caractere
  MC2000T2.setLargChar (StrToInt(edtLarg.Text));   // Largura do caractere
  MC2000T2.setDens     (StrToInt(edtDens.Text));   // Densidade
  MC2000T2.setPosX     (StrToInt(edtPosX.Text));   // Posição X
  MC2000T2.setPosY     (StrToInt(edtPosY.Text));   // Posição Y
  MC2000T2.setAngulo   (StrToInt(edtAngulo.Text)); // Angulo da marcação
  MC2000T2.setSpeed    (StrToInt(edtSpeed.Text));  // Velocidade da marcação
  MC2000T2.setForca    (StrToInt(edtForca.Text));  // Força da marcação
  MC2000T2.setDados    (edtDados.Text, op);        // Os dados que serão marcados, op (0:txt; 1: datamatrix; 2: arquivo)

  habilitarBTsIsConected(True);

  StringGrid1.RowCount := StringGrid1.RowCount + 1;
  StringGrid1.Cells[0, StringGrid1.RowCount -1] := edtPosX.Text;
  StringGrid1.Cells[1, StringGrid1.RowCount -1] := edtPosY.Text;
  StringGrid1.Cells[2, StringGrid1.RowCount -1] := edtForca.Text;
  StringGrid1.Cells[3, StringGrid1.RowCount -1] := edtDens.Text;
  StringGrid1.Cells[4, StringGrid1.RowCount -1] := edtAngulo.Text;
  StringGrid1.Cells[5, StringGrid1.RowCount -1] := edtSpeed.Text;
  StringGrid1.Cells[6, StringGrid1.RowCount -1] := edtAltura.Text;
  StringGrid1.Cells[7, StringGrid1.RowCount -1] := edtLarg.Text;
end;

procedure TFormMain.BttnLimparClick(Sender: TObject);
begin
  MC2000T2.iniciarLista();

  edtAltura.Text := '0';
  edtLarg.Text   := '0';
  edtDens.Text   := '1';
  edtPosX.Text   := '0';
  edtPosY.Text   := '0';
  edtAngulo.Text := '0';
  edtSpeed.Text  := '1';
  edtForca.Text  := '1';
//  MC2000T2.setDados    (); // Os dados que serão marcados

  habilitarBTsIsConected(False);

  StringGrid1.RowCount := 1;
end;

procedure TFormMain.edtAlturaKeyPress(Sender: TObject; var Key: Char);
begin
 key := soNum(Key);
end;

procedure TFormMain.edtAnguloKeyPress(Sender: TObject; var Key: Char);
begin
 key := soNum(Key);
end;

procedure TFormMain.edtDensKeyPress(Sender: TObject; var Key: Char);
begin
 key := soNum(Key);
end;

procedure TFormMain.edtForcaKeyPress(Sender: TObject; var Key: Char);
begin
 key := soNum(Key);
end;

procedure TFormMain.edtLargKeyPress(Sender: TObject; var Key: Char);
begin
 key := soNum(Key);
end;

procedure TFormMain.edtPosXKeyPress(Sender: TObject; var Key: Char);
begin
 key := soNum(Key);
end;

procedure TFormMain.edtPosYKeyPress(Sender: TObject; var Key: Char);
begin
 key := soNum(Key);
end;

procedure TFormMain.edtSpeedKeyPress(Sender: TObject; var Key: Char);
begin
 key := soNum(Key);
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(MC2000T2);
end;




//===========================================
procedure TFormMain.habilitar(param: boolean);
var
  i: integer;
begin
  for i := 0  to ComponentCount -1 do
    begin
      if (Components[i] is TButton )     then TButton      (Components[i]).Enabled := param;
      if (Components[i] is TLabel )      then TLabel       (Components[i]).Enabled := param;
      if (Components[i] is TEdit )       then TEdit        (Components[i]).Enabled := param;
      if (Components[i] is TTabSheet)    then TTabSheet    (Components[i]).Enabled := param;
      if (Components[i] is TCheckBox)    then TCheckBox    (Components[i]).Enabled := param;
      if (Components[i] is TRadioButton) then TRadioButton (Components[i]).Enabled := param;
    end;


//    if param then BttnConectar.Enabled := false
//    else BttnConectar.Enabled := true;
end;

procedure TFormMain.habilitarBTsIsConected(param: boolean);
begin
  BttnEnviar.Enabled := param;
  BttnLimpar.Enabled := param;
end;

procedure TFormMain.Panel7Click(Sender: TObject);
begin

end;

//===========================================
function TFormMain.soNum(KeyChar: char): char;
begin
  if (not (CharInSet(KeyChar, ['0'..'9', #8]))) then KeyChar := #0;
  Result := KeyChar;
end;


procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  if (not (MC2000T2.getEnviando)) then
    begin
      Timer1.Enabled := False;
      habilitar(True);
    end;
end;

procedure TFormMain.tratarTela;
begin
  habilitar(false);
  Timer1.Enabled := True;
end;

end.
