unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CPDrv, Vcl.StdCtrls,
  untMC2000T2, Vcl.Tabs, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TFormMain = class(TForm)
    Panel4: TPanel;
    Panel2: TPanel;
    GroupBox2: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
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
    Button5: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel1: TPanel;
    GroupBox3: TGroupBox;
    Button6: TButton;
    Button7: TButton;
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure edtPosXKeyPress(Sender: TObject; var Key: Char);
    procedure edtForcaKeyPress(Sender: TObject; var Key: Char);
    procedure edtAnguloKeyPress(Sender: TObject; var Key: Char);
    procedure edtAlturaKeyPress(Sender: TObject; var Key: Char);
    procedure edtPosYKeyPress(Sender: TObject; var Key: Char);
    procedure edtDensKeyPress(Sender: TObject; var Key: Char);
    procedure edtSpeedKeyPress(Sender: TObject; var Key: Char);
    procedure edtLargKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }

    procedure habilitar(param: boolean);
    procedure soNum(KeyChar: char);
    function  valRange(funcao: integer): boolean;

    type itemFuncao = record
        funcao: string;
        min: integer;
        max: integer;

    end;
    var
      item: itemFuncao;
      listFuncaoes: array[0..10] of itemFuncao;

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
  I: Integer;
  lbl: TLabel;
begin


for I := 0 to 10 do
  begin

    case I of

    0:begin
        item.funcao := 'Altura';
        item.min    := 0;
        item.max    := 400;
        lbl         := Label1;
      end;

    1:begin
        item.funcao := 'Largura';
        item.min    := 0;
        item.max    := 200;
        lbl         := Label6;
      end;
{
    2:begin
        item.funcao := 'Espaçamento';
        item.min    := 0;
        item.max    := 200;
        lbl         := Label1
      end;
 }
    3:begin
        item.funcao := 'Densidade';
        item.min    := 1;
        item.max    := 101;
        lbl         := Label5;
      end;

    4:begin
        item.funcao := 'Pos X';
        item.min    := 0;
        item.max    := 10000;
        lbl         := Label2;
      end;

    5:begin
        item.funcao := 'Pos Y';
        item.min    := 0;
        item.max    := 10000;
        lbl         := Label4;
      end;

    6:begin
        item.funcao := 'Angulo';
        item.min    := 0;
        item.max    := 3600;
        lbl         := Label8;
      end;

    7:begin
        item.funcao := 'Velocidade';
        item.min    := 1;
        item.max    := 10;
        lbl         := Label7;
      end;

    8:begin
        item.funcao := 'Força';
        item.min    := 1;
        item.max    := 10;
        lbl         := Label3;
      end;

    end;

    listFuncaoes[I] := item;
    lbl.Caption := item.funcao + ' (' + item.min.ToString() + '/' +item.max.ToString()  + ')'
  end;


  habilitar(False);
  MC2000T2 := TMC2000T2.create;
end;


procedure TFormMain.Button1Click(Sender: TObject);
begin
  MC2000T2.Avancar();
end;

procedure TFormMain.Button2Click(Sender: TObject);
begin
  MC2000T2.Pausar();
end;

procedure TFormMain.Button3Click(Sender: TObject);
begin
  MC2000T2.Cancelar();
end;

procedure TFormMain.Button5Click(Sender: TObject);
begin
  {}
//  MC2000T2.setLinha    (I);
//  MC2000T2.setDados    (); // Os dados que serão marcados
  MC2000T2.setAltChar  (StrToInt(edtAltura.Text)); // Altura do caractere
  MC2000T2.setLargChar (StrToInt(edtLarg.Text));   // Largura do caractere
  MC2000T2.setDens     (StrToInt(edtDens.Text));   // Densidade
  MC2000T2.setPosX     (StrToInt(edtPosX.Text));   // Posição X
  MC2000T2.setPosY     (StrToInt(edtPosY.Text));   // Posição Y
  MC2000T2.setAngulo   (StrToInt(edtAngulo.Text)); // Angulo da marcação
  MC2000T2.setSpeed    (StrToInt(edtSpeed.Text));  // Velocidade da marcação
  MC2000T2.setForca    (StrToInt(edtForca.Text));  // Força da marcação
  //    if (MC2000T2.enviar()) then
  {}
end;


procedure TFormMain.Button6Click(Sender: TObject);
begin
  habilitar(False);
end;

procedure TFormMain.Button7Click(Sender: TObject);
begin
  habilitar(True);
end;

procedure TFormMain.edtAlturaKeyPress(Sender: TObject; var Key: Char);
begin
  soNum(Key);
end;

procedure TFormMain.edtAnguloKeyPress(Sender: TObject; var Key: Char);
begin
  soNum(Key);
end;

procedure TFormMain.edtDensKeyPress(Sender: TObject; var Key: Char);
begin
  soNum(Key);
end;

procedure TFormMain.edtForcaKeyPress(Sender: TObject; var Key: Char);
begin
  soNum(Key);
end;

procedure TFormMain.edtLargKeyPress(Sender: TObject; var Key: Char);
begin
  soNum(Key);
end;

procedure TFormMain.edtPosXKeyPress(Sender: TObject; var Key: Char);
begin
  soNum(Key);
end;

procedure TFormMain.edtPosYKeyPress(Sender: TObject; var Key: Char);
begin
  soNum(Key);
end;

procedure TFormMain.edtSpeedKeyPress(Sender: TObject; var Key: Char);
begin
  soNum(Key);
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
      if (Components[i] is TButton )  then TButton   (Components[i]).Enabled := param;
      if (Components[i] is TLabel )   then TLabel    (Components[i]).Enabled := param;
      if (Components[i] is TEdit )    then TEdit     (Components[i]).Enabled := param;
      if (Components[i] is TTabSheet) then TTabSheet (Components[i]).Enabled := param;
    end;

    PageControl1.Enabled := param;

    if param then Button7.Enabled := false
    else Button7.Enabled := true;
end;

//===========================================
procedure TFormMain.soNum(KeyChar: char);
begin
  if (not (KeyChar in ['0'..'9'])) then KeyChar := #0;
end;

function TFormMain.valRange(funcao: integer): boolean;
begin
Result := false;
if li then

end;

end.
