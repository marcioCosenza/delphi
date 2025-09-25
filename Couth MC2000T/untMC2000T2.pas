unit untMC2000T2;


interface

uses Classes, SysUtils, Vcl.Dialogs, CPDrv, vcl.Forms, System.UITypes;


{
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CPDrv, Vcl.StdCtrls,
  untMC2000T2, Vcl.Tabs, Vcl.ComCtrls, Vcl.ExtCtrls;
 }

Type
  TMC2000T2 = class

  public

    constructor create(form: TForm);

    //controle da marcadora
    function Avancar()  : string;
    function Cancelar() : string;
    function Pausar()   : string;
    function Reset()   : string;

    //Define qual é a linha que será configurada na marcadora
    procedure addLinha();
    procedure iniciarLista();

    //formatação da marcação
    procedure setDados    (valor: string); // Os dados que serão marcados
    procedure setAltChar  (valor: integer); // Altura do caractere
    procedure setLargChar (valor: integer); // Largura do caractere
    procedure setDens     (valor: integer); // Densidade
    procedure setPosX     (valor: integer); // Posição X
    procedure setPosY     (valor: integer); // Posição Y
    procedure setAngulo   (valor: integer); // Angulo da marcação
    procedure setSpeed    (valor: integer); // Velocidade da marcação
    procedure setForca    (valor: integer); // Força da marcação


    function getItemFuncao(qual: integer): string;  // Descritivo
    function getItemMin   (qual: integer): integer; // Valor minimo aceito pelo equipamento
    function getItemMax   (qual: integer): integer; // Valor maximo aceito pelo equipamento

    function enviar(): boolean;
    function getStatus(): string;


    function conectar(): boolean;
    function desConectar(): boolean;


//    procedure setDatamatrix(dmc : string);
//    procedure setLogo(arq: string);

  private

  const totalFuncoes = 8;

    //estrutura destinada a armazenar as informações dos campos
    type itemFuncao = record
        funcao : string;  // Descritivo
        min    : integer; // Valor maximo aceito pelo equipamento
        max    : integer; // Valor maximo aceito pelo equipamento
        size   : integer; // Quantidade de bytes por campo
        val    : string;  // valor que será marcado
        command: string;  // string com a instrucao que será enviada a marcadora
        status : boolean; // validação
    end;

    var
      item         : itemFuncao;
      listFuncaoes : array[0..totalFuncoes] of itemFuncao;
      linha        : integer;
      destinatario : string;
      comPort      : TCommPortDriver;




    procedure setDestinatario(destino: string);
    function prepararFicheiro: string;
    function send(linha: string): boolean;

    function getDestinatario() : string;
    function getFimFicheiro()  : string;

    function converter(valorIn, tam: integer): string;
    function validar(qual, valor: integer): boolean;
    function CRC(data: string): string;

    function getInicioLinha()  : string;
    function getFimLinha()     : string;

end;


var
  MC2000T2 : TMC2000T2;

implementation


function TMC2000T2.send(linha: string): boolean;
begin
  Result := False;

//  if (comPort.Connected) then
//    if (comPort.SendString(linha)) then
      Result := true;
end;

{ TTMC2000T2 }


// ==================================
// ===== DEFINIÇÕES DA MARCAÇÃO =====
// ==================================

procedure TMC2000T2.setAltChar(valor: integer);
const pos = 0;
begin
  if (validar(pos, valor)) then
      listFuncaoes[pos].command := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(1) +  listFuncaoes[pos].val  + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setLargChar(valor: integer);
const pos = 1;
begin
  if (validar(pos, valor)) then
    listFuncaoes[pos].command := getInicioLinha() + chr(10) + chr(0) + chr(38) + chr(linha) + chr(2) + listFuncaoes[pos].val + getFimLinha();
end;


// ==================================
procedure TMC2000T2.setDens(valor: integer);
const pos = 2;
begin
  if (validar(pos, valor)) then
      listFuncaoes[pos].command := getInicioLinha() + chr(10) + chr(0) + chr(38) + chr(linha) + chr(5) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setPosX(valor: integer);
const pos = 3;
begin
    if (validar(pos, valor)) then
      listFuncaoes[pos].command := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(6) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setPosY(valor: integer);
const pos = 4;
begin
  if (validar(pos, valor)) then
    listFuncaoes[pos].command := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(7) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setAngulo(valor: integer);
const pos = 5;
begin
  if (validar(pos, valor)) then
      listFuncaoes[pos].command := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(9) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setSpeed(valor: integer);
const pos = 6;
begin
  if (validar(pos, valor)) then
    listFuncaoes[pos].command := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(14) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setForca(valor: integer);
const pos = 7;
begin
  if (validar(pos, valor)) then
      listFuncaoes[pos].command := getInicioLinha() + chr(11) + chr(0) + chr(38) + chr(linha) + chr(15) + listFuncaoes[pos].val + getFimLinha();
end;



// ==================================
procedure TMC2000T2.setDados(valor: string);
const pos = 8;

var
//  val: string;
  tam: integer;

begin
//  val  := converter(param, vc);
  tam    := Length(valor) + 8;
//  if (validar(pos, valor)) then
      listFuncaoes[pos].command := getInicioLinha() + chr(tam) + chr(0) + chr(37) + chr(linha) + valor + getFimLinha();
///  Result := getInicioLinha() + chr(tam) + chr(0) + chr(37) + chr(linha) + val + getFimLinha();
end;





// =================================
// ===== CONTROLE DA MARCADORA =====
// =================================

function TMC2000T2.Avancar: string;
var
  aux : string;
begin
  aux := chr(16) + getDestinatario + chr(7) + chr(0) + chr(49);//   '070031';
  aux := aux + CRC(aux);
  send(aux);
end;

//=================================
function TMC2000T2.Cancelar: string;
var
  aux : string;
begin
  aux := chr(16) + getDestinatario + chr(7) + chr(0) + chr(52);//   '070031';
  aux := aux + CRC(aux);
  send(aux);
end;

//=================================
function TMC2000T2.Pausar: string;
var
  aux : string;
begin
  aux := chr(16) + getDestinatario + chr(7) + chr(0) + chr(51);//   '070031';
  aux := aux + CRC(aux);
  send(aux);
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

procedure TMC2000T2.iniciarLista();
var
  I: Integer;

begin


linha := 0;

for I := 0 to totalFuncoes do
  begin

    case I of

      0:begin
          item.funcao := 'Altura';
          item.min    := 0;
          item.max    := 400;
          item.size   := 2;
        end;


      1:begin
          item.funcao := 'Largura';
          item.min    := 0;
          item.max    := 200;
          item.size   := 1;
        end;

      2:begin
          item.funcao := 'Densidade';
          item.min    := 1;
          item.max    := 101;
          item.size   := 1;
        end;

      3:begin
          item.funcao := 'Pos X';
          item.min    := 0;
          item.max    := 10000;
          item.size   := 2;
        end;

      4:begin
          item.funcao := 'Pos Y';
          item.min    := 0;
          item.max    := 10000;
          item.size   := 2;
        end;

      5:begin
          item.funcao := 'Angulo';
          item.min    := 0;
          item.max    := 3600;
          item.size   := 2;
        end;

      6:begin
          item.funcao := 'Velocidade';
          item.min    := 1;
          item.max    := 10;
          item.size   := 1;
        end;

      7:begin
          item.funcao := 'Força';
          item.min    := 1;
          item.max    := 10;
          item.size   := 1;
        end;
       {
      8:begin
          item.funcao := 'Espaçamento';
          item.min    := 0;
          item.max    := 200;
          item.size   := 1;
        end;
        }

    end;

    item.status     := False;
    item.command    := '';

    listFuncaoes[I] := item;
  end;

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
  Result := chr(16) +chr(2) + chr(7) + chr(0) + chr(33) + chr(3) +chr(3);
end;


function TMC2000T2.Reset: string;
begin
  send(prepararFicheiro);
  iniciarLista();
end;

procedure TMC2000T2.setDestinatario(destino: string);
begin
  destinatario := destino;
end;


function TMC2000T2.CRC(data: string): string;
begin
  result := Chr(3) + Chr(3);
end;




constructor TMC2000T2.create(form: TForm);
begin
  comPort := TCommPortDriver.Create(form);

  comPort.PortName := 'COM1';
  comPort.BaudRate := TBaudRate.br9600;// := 9600;
  comPort.StopBits := TStopBits.sb1BITS;
  comPort.SwFlow   := sfNONE;
  comPort.DataBits := db8BITS;
  comPort.Parity   := ptNONE;

  iniciarLista();
end;

function TMC2000T2.desConectar: boolean;
begin
  comPort.Disconnect();
end;

////////////////



function TMC2000T2.validar(qual, valor: integer): boolean;
var
  min, max : integer;
  funcao   : string;
  saidaTxt : string;
begin

  Result := False;
  min    := listFuncaoes[qual].min;
  max    := listFuncaoes[qual].max;

  if ((valor >= min)  and (valor <= max )) then
    begin
      Result := True;
      listFuncaoes[qual].val := converter(valor, listFuncaoes[qual].size);
    end
  else
    begin
      funcao   :=  listFuncaoes[qual].funcao;
      saidaTxt := 'O valor para ' + funcao + ' deve ser' + #13  + #13;
      saidaTxt :=  saidaTxt +' Maior que: ' + min.ToString  + #13;
      saidaTxt :=  saidaTxt +' Menor que: ' + max.ToString  + #13;
      saidaTxt :=  saidaTxt +' valor informado:  ' + valor.ToString;
      ShowMessage(saidaTxt);
    end;

    listFuncaoes[qual].status := Result;
end;


function TMC2000T2.getInicioLinha(): string;
begin
 Result := chr(16) + chr(2);
end;

function TMC2000T2.getItemFuncao(qual: integer): string;
begin
  Result := listFuncaoes[qual].funcao;
end;

function TMC2000T2.getItemMax(qual: integer): integer;
begin
  Result := listFuncaoes[qual].max;
end;

function TMC2000T2.getItemMin(qual: integer): integer;
begin
  Result := listFuncaoes[qual].min;
end;

function TMC2000T2.getFimLinha(): string;
begin
  Result :=  chr(3) +chr(3);
end;


function TMC2000T2.conectar: boolean;
begin
  Result := true;
  if (not (comPort.Connect())) then
    begin
      Result := false;
      MessageDlg('Falha ao efetuar a conexao com a marcadora Couth MC2000!', mtInformation, [mbok], 0);
    end;
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


procedure TMC2000T2.addLinha();
begin
  linha := linha + 1;
end;



function TMC2000T2.enviar: boolean;
var
  I: Integer;
  isOK: boolean;
begin

  //verifica se todas as funçoes foram carregadas corretamente
  isOK := true;
  for I := 0 to totalFuncoes do
      if ((isOK) and (not (listFuncaoes[I].status))) then
          isOK := false;



  if (isOK) then
    begin

      //enviad o ficheiro,
      isOK :=  send(prepararFicheiro());
      if (isOK) then
        //envia as linhas
        for I := 0 to totalFuncoes do
          if (isOK) then
            isOK :=  send(listFuncaoes[I].command);

      //reseta as variaveis
      if (isOK) then iniciarLista();
    end;

 Result := isOK;
end;


end.





