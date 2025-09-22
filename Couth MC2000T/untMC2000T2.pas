unit untMC2000T2;

interface

uses Classes, SysUtils;

Type
  TMC2000T2 = class

  public

    //controle da marcadora
    function Avancar: string;
    function Cancelar: string;
    function Pausar: string;
    function getStatus(): string;

    procedure setLinha(param: integer);

    //formatação da marcação
    procedure setDados    (param: integer); // Os dados que serão marcados
    procedure setAltChar  (param: integer); // Altura do caractere
    procedure setLargChar (param: integer); // Largura do caractere
    procedure setDens     (param: integer); // Densidade
    procedure setPosX     (param: integer); // Posição X
    procedure setPosY     (param: integer); // Posição Y
    procedure setAngulo   (param: integer); // Angulo da marcação
    procedure setSpeed    (param: integer); // Velocidade da marcação
    procedure setForca    (param: integer); // Força da marcação

    function enviar(): boolean;

//    procedure setDatamatrix(dmc : string);
//    procedure setLogo(arq: string);

  private

    //quantidade de bytes por campo
    const vcAltura = 2;
    const vcLarg   = 1;
    const vcPosX   = 2;
    const vcPosY   = 2;
    const vcDens   = 1;
    const vcForca  = 1;
    const vcSpeed  = 1;
    const vcAngulo = 2;

    var
      linha        : integer;
      destinatario : string;

      vDados   :string;

      vAltChar : string; // Altura do caractere
      vLargChar: string; // Largura do caractere
      vDens    : string; // Densidade
      vPosX    : string; // Posição X
      vPosY    : string; // Posição Y
      vAngulo  : string; // Angulo da marcação
      vSpeed   : string; // Velocidade da marcação
      vForca   : string; // Força da marcação

    function prepararFicheiro: string;
    procedure setDestinatario(destino: string);

    function CRC(data: string): string;

    function getDestinatario : string;
    function getFimFicheiro  : string;

    function getInicioLinha  : string;
    function getFimLinha     : string;
    function converter(valorIn, tam: integer): string;
    procedure iniciarVariaveis();


end;


var
  MC2000T2 : TMC2000T2;

implementation


{ TTMC2000T2 }


// ==================================
// ===== DEFINIÇÕES DA MARCAÇÃO =====
// ==================================

procedure TMC2000T2.setAltChar(param: integer);
var
  val: string;
begin
  val  := converter(param, vcAltura);
  vAltChar := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(1) +  val  + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setAngulo(param: integer);
var
  val: string;
begin
  val  := converter(param, vcAngulo);
  vAngulo := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(9) + val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setDados(param: integer);
var
  val: string;
  tam: integer;
begin
//  val  := converter(param, vc);
//  tam    := Length(val) + 8;

//  Result := getInicioLinha() + chr(tam) + chr(0) + chr(37) + chr(linha) + val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setDens(param: integer);
var
  val: string;
begin
  val  := converter(param, vcDens);
  vDens := getInicioLinha() + chr(10) + chr(0) + chr(38) + chr(linha) + chr(5) + val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setForca(param: integer);
var
  val: string;
begin
  val  := converter(param, vcForca);
  vForca := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(15) + val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setLargChar(param: integer);
var
  val: string;
begin
  val  := converter(param, vcLarg);
  vLargChar := getInicioLinha() + chr(10) + chr(0) + chr(38) + chr(linha) + chr(2) + val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setPosX(param: integer);
var
  val: string;
begin
  val  := converter(param, vcPosX);
  vPosX := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(6) + val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setPosY(param: integer);
var
  val: string;
begin
  val  := converter(param, vcPosY);
  vPosY := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(7) + val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setSpeed(param: integer);
var
  val: string;
begin
  val  := converter(param, vcSpeed);
  vSpeed := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(14) + val + getFimLinha();
end;




// =================================
// ===== CONTROLE DA MARCADORA =====
// =================================

function TMC2000T2.Avancar: string;
var
  aux : string;
begin
  aux := chr(16) + getDestinatario + chr(7) + chr(0) + chr(49);//   '070031';
  Result := aux+CRC(aux);
end;

//=================================
function TMC2000T2.Cancelar: string;
var
  aux : string;
begin
  aux := chr(16) + getDestinatario + chr(7) + chr(0) + chr(52);//   '070031';
  Result := aux + CRC(aux);
end;

//=================================
function TMC2000T2.Pausar: string;
var
  aux : string;
begin
  aux := chr(16) + getDestinatario + chr(7) + chr(0) + chr(51);//   '070031';
  Result := aux+CRC(aux);
end;


// =================================
// ==== FORMATAÇÃO DA MARCAÇÃO =====
// =================================


{
function TMC2000T2.getDados: string;
begin
  Result := dados;
end;

}
{
procedure TMC2000T2.setDatamatrix(dmc: string);
begin
  dmc := 'DMS(' + dmc + ')';
  setDados(Chr(30) + dmc + Chr(31));
end;

}
function TMC2000T2.getDestinatario: string;
begin
  Result := destinatario;
end;

function TMC2000T2.getFimFicheiro: string;
begin
  Result := chr(11);
end;


function TMC2000T2.getStatus: string;
var
  aux : string;

begin
  aux := chr(16) + getDestinatario + chr(7) + chr(0) + chr(2);//   '070002';
  Result := aux+CRC(aux);
end;

procedure TMC2000T2.iniciarVariaveis;
begin
  vDados    := '';
  vAltChar  := '';
  vLargChar := '';
  vDens     := '';
  vPosX     := '';
  vPosY     := '';
  vAngulo   := '';
  vSpeed    := '';
  vForca    := '';
end;

{

procedure TMC2000T2.setLogo(arq: string);
begin
  arq := 'L(' + arq + '.LOG)';
  setDados(Chr(30)  + arq + Chr(31));
end;

}

Function TMC2000T2.prepararFicheiro: string;
begin
  iniciarVariaveis();
  Result := chr(16) +chr(2) + chr(7) + chr(0) + chr(33) + chr(3) +chr(3);
end;


procedure TMC2000T2.setDestinatario(destino: string);
begin
  destinatario := destino;
end;


function TMC2000T2.CRC(data: string): string;
begin
  result := Chr(3) + Chr(3);
end;




////////////////
function TMC2000T2.getInicioLinha(): string;
begin
 Result := chr(16) + chr(2);
end;

function TMC2000T2.getFimLinha(): string;
begin
  Result :=  chr(3) +chr(3);
end;


function TMC2000T2.converter(valorIn, tam: integer): string;
var
  hex, hexAux, hexSaida, hexAuxCHR : string;
  fim, i : integer;
begin

  hex := IntToHex(valorIn, (tam * 2));

  //inverter o byte mais significativo
  hexAux := '';
  hexSaida := '';
  fim := Length(hex);
  i := fim;
  repeat
    hexAux :=  hex[i - 1] + hex[i];
    hexAuxCHR := Chr (StrToInt('$'+hexAux));
    hexSaida := hexSaida + hexAuxCHR;
    i := i - 2;
  until i <= 0;

  Result := hexSaida;
end;


procedure TMC2000T2.setLinha(param: integer);
begin
  linha := param;
end;



function TMC2000T2.enviar: boolean;
begin
  prepararFicheiro();

  iniciarVariaveis();
end;


end.
