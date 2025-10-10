unit untMC2000T2;

interface

uses
  Classes, SysUtils, Vcl.Dialogs, Vcl.Forms, CPDrv, Winapi.Windows, System.UITypes;

Type
  TMC2000T2 = class

  public

    constructor create(form: TForm);
    destructor destroy();

    // configuração da conexao
    procedure setCPortPortName (param: string);
    procedure setCPortBaudRate (param: TBaudRate);
    procedure setCPortStopBits (param: TStopBits);
    procedure setCPortSwFlow   (param: TSwFlowControl);
    procedure setCPortDataBits (param: TDataBits);
    procedure setCPortParity   (param: TParity);

    //se deve desconectar da marcadora apos enviar a instrução
    procedure setKeepCon(param: boolean);

    //define qual marcadora receberá as instruções
    procedure setDestinatario(destino: integer);   // decimal da tabela Ascii - valor default: 2;

    // controle da marcadora
    function Avancar  (): string;
    function Cancelar (): string;
    function Pausar   (): string;
    function Reset    (): string;
    function solStatus(): boolean;

    // Configurada das linhas que serão marcadoras
    procedure iniciarLista();
    procedure addLinha();

    // formatação da marcação
    procedure setDados    (valor: string; op: integer); // Os dados que serão marcados; op(: )0: txt simples; 1: datamatrix; 2: imagens em arquivo)
    procedure setAltChar  (valor: integer); // Altura do caractere
    procedure setLargChar (valor: integer); // Largura do caractere
    procedure setDens     (valor: integer); // Densidade
    procedure setPosX     (valor: integer); // Posição X
    procedure setPosY     (valor: integer); // Posição Y
    procedure setAngulo   (valor: integer); // Angulo da marcação
    procedure setSpeed    (valor: integer); // Velocidade da marcação
    procedure setForca    (valor: integer); // Força da marcação

    //envia uma linha completa para a marcadora
    function enviar(): boolean;
    function getEnviando (): Boolean; // resgata se está sendo enviado dados a marcadora

    //retorno de parametros de configuração
    function getItemFuncao(qual: integer): string;  // Descritivo
    function getItemMin   (qual: integer): integer; // Valor minimo aceito pelo equipamento
    function getItemMax   (qual: integer): integer; // Valor maximo aceito pelo equipamento

  private

    const totalFuncoes = 8;

    // estrutura destinada a armazenar as informações dos campos
    type
      itemFuncao = record
        funcao  : string;  // Descritivo
        min     : integer; // Valor maximo aceito pelo equipamento
        max     : integer; // Valor maximo aceito pelo equipamento
        size    : integer; // Quantidade de bytes por campo
        val     : string;  // valor que será marcado
        command : string;  // string com a instrucao que será enviada a marcadora
        status  : boolean; // validação
      end;

    var
      item         : itemFuncao;
      listFuncaoes : array of itemFuncao;
      linha        : integer;
      destinatario : string;
      comPort      : TCommPortDriver;
      enviando     : boolean;
      keepCon      : boolean;

      //
      function getDestinatario(): string;

      //
      function getInicioLinha(): string;
      function getFimLinha(): string;

      //limpa os dados na marcadora
      function prepararFicheiro: string;

      //manipulação da strean de dados
      function converter(valorIn, tam: integer): string;
      function validar(qual, valor: integer): boolean;
      function CRC(data: string): string;

      //conexao
      function conectar(): boolean;
      function desconectar(): boolean;
      function send(linha: string): boolean;
      procedure sendCmd(param: char);
      procedure receberDados(Sender: TObject; DataPtr: Pointer; DataSize: DWORD);
      procedure finalizarEnvio(Sender: TObject);
      procedure finalizarEnvioCmd(Sender: TObject);

      //controle da lista
      procedure setItemDefaultValues();
      function getPosNaLista(pos: integer): integer;
end;

var
  MC2000T2: TMC2000T2;

implementation



{ TTMC2000T2 }



// =================================
constructor TMC2000T2.create(form: TForm);
begin
  setDestinatario(2); //valor default
  setKeepCon(false);

  comPort := TCommPortDriver.create(form);
  comPort.PortName := 'COM1';
  comPort.BaudRate := br9600;
  comPort.StopBits := sb1BITS;
  comPort.SwFlow   := sfNONE;
  comPort.DataBits := db8BITS;
  comPort.Parity   := TParity.ptNONE;
  comPort.OnReceiveData := receberDados;

  iniciarLista();
end;

// =================================
destructor TMC2000T2.destroy;
begin
  if (comPort.Connected) then desconectar();
end;



// =================================
// ===== CONTROLE DA MARCADORA =====
// =================================

function TMC2000T2.Avancar: string;
begin
  sendCmd(chr(49));
end;

// =================================
function TMC2000T2.Cancelar: string;
begin
  sendCmd(chr(52));
end;

// =================================
function TMC2000T2.Pausar: string;
begin
  sendCmd(chr(51));
end;


// =================================
function TMC2000T2.Reset: string;
begin
  {
    TamDados := TamDados + 8;//Cabecalho + CRC

    saida := chr(16) + getDestinatario + chr(TamDados) + chr(0) + chr(59) + dados + getFimFicheiro + CRC(dados);
    saida := chr(16) + getDestinatario + chr(7) + chr(0) + chr(1) + CRC(dados);
    Result := saida;

  }
end;


// =================================
function TMC2000T2.solStatus: boolean;
var
  aux: string;
begin
  Result := false;
  aux    := chr(16) + getDestinatario + chr(7) + chr(0) + chr(2);
  aux := aux + CRC(aux);
  Result := send(aux);
end;

// ==================================
Function TMC2000T2.prepararFicheiro: string;
begin
  Result := chr(16) + chr(2) + chr(7) + chr(0) + chr(33) + chr(3) + chr(3);
end;


// ==================================
// ===== DEFINIÇÕES DA MARCAÇÃO =====
// ==================================

procedure TMC2000T2.addLinha();
var
  tam: integer;
begin
  linha := linha + 1;
  tam := (linha * totalFuncoes) + linha;
  SetLength(listFuncaoes, tam);
  setItemDefaultValues();
end;


// ==================================
procedure TMC2000T2.setDestinatario(destino: integer);
begin
  destinatario := chr(destino);
end;

// ==================================
function TMC2000T2.getDestinatario: string;
begin
  Result := destinatario;
end;

// ==================================
procedure TMC2000T2.setAltChar(valor: integer);
const
  pos = 0;
var
  posicao: integer;
begin
  posicao := getPosNaLista(pos);
  if (validar(posicao, valor)) then
    listFuncaoes[posicao].command := getInicioLinha() + chr(11) + chr(0) +
      chr(38) + chr(linha) + chr(1) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setLargChar(valor: integer);
const
  pos = 1;
var
  posicao: integer;
begin
  posicao := getPosNaLista(pos);
  if (validar(posicao, valor)) then
    listFuncaoes[posicao].command := getInicioLinha() + chr(10) + chr(0) +
      chr(38) + chr(linha) + chr(2) + listFuncaoes[pos].val + getFimLinha();
end;


// ==================================
procedure TMC2000T2.setDens(valor: integer);
const
  pos = 2;
var
  posicao: integer;
begin
  posicao := getPosNaLista(pos);
  if (validar(posicao, valor)) then
    listFuncaoes[posicao].command := getInicioLinha() + chr(10) + chr(0) +
      chr(38) + chr(linha) + chr(5) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setPosX(valor: integer);
const
  pos = 3;
var
  posicao: integer;
begin
  posicao := getPosNaLista(pos);
  if (validar(posicao, valor)) then
    listFuncaoes[posicao].command := getInicioLinha() + chr(11) + chr(0) +
      chr(38) + chr(linha) + chr(6) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setPosY(valor: integer);
const
  pos = 4;
var
  posicao: integer;
begin
  posicao := getPosNaLista(pos);
  if (validar(posicao, valor)) then
    listFuncaoes[posicao].command := getInicioLinha() + chr(11) + chr(0) +
      chr(38) + chr(linha) + chr(7) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setAngulo(valor: integer);
const
  pos = 5;
var
  posicao: integer;
begin
  posicao := getPosNaLista(pos);
  if (validar(posicao, valor)) then
    listFuncaoes[posicao].command := getInicioLinha() + chr(11) + chr(0) +
      chr(38) + chr(linha) + chr(9) + listFuncaoes[pos].val + getFimLinha();
end;


// ==================================
procedure TMC2000T2.setSpeed(valor: integer);
const
  pos = 6;
begin
  if (validar(pos, valor)) then
    listFuncaoes[pos].command := getInicioLinha() + chr(11) + chr(0) + chr(38) +
      chr(linha) + chr(14) + listFuncaoes[pos].val + getFimLinha();
end;

// ==================================
procedure TMC2000T2.setForca(valor: integer);
const
  pos = 7;
begin
  if (validar(pos, valor)) then
    listFuncaoes[pos].command := getInicioLinha() + chr(11) + chr(0) + chr(38) +
      chr(linha) + chr(15) + listFuncaoes[pos].val + getFimLinha();
end;



// ==================================
procedure TMC2000T2.setDados(valor: string; op: integer);
const
  pos = 8;

var
  // val: string;
  tam: integer;
  posicao: integer;
  saida: string;
begin
  posicao := getPosNaLista(pos);
  tam     := Length(valor) + 8;
  listFuncaoes[posicao].status := true;

  // if (validar(pos, valor)) then

  case (op) of
    //texto simples
    0: saida := valor;

    //datamatrix
    1: saida := Chr(30) + 'DMS(' + valor + ')' + Chr(31);

    //nome doo arquivo (deve ser previamente carregado na marcadora)
    2: saida := Chr(30) + 'L(fileName.log)' + Chr(31);
  end;

  saida := chr(tam) + chr(0) + chr(37) + chr(linha) + saida;
  listFuncaoes[posicao].command := getInicioLinha() + saida + getFimLinha();
end;






//============================================
//========== CONEXAO E ENVIAR DADOS ==========
//============================================


procedure TMC2000T2.setKeepCon(param: boolean);
begin
  keepCon := param;
end;


//===========================================
procedure TMC2000T2.setCPortBaudRate(param: TBaudRate);
begin
  comPort.BaudRate := param;
end;

//===========================================
procedure TMC2000T2.setCPortDataBits(param: TDataBits);
begin
  comPort.DataBits := param;
end;

//===========================================
procedure TMC2000T2.setCPortParity(param: TParity);
begin
  comPort.Parity := param;
end;

//===========================================
procedure TMC2000T2.setCPortPortName(param: string);
begin
  comPort.PortName := param;
end;

//===========================================
procedure TMC2000T2.setCPortStopBits(param: TStopBits);
begin
  comPort.StopBits := param;
end;

//===========================================
procedure TMC2000T2.setCPortSwFlow(param: TSwFlowControl);
begin
  comPort.SwFlow := param;
end;

//===========================================
function TMC2000T2.conectar: boolean;
begin

  Result := true;
  comPort.Connect();
  if (not(comPort.Connected)) then
  begin
    Result := False;
    MessageDlg('Falha ao efetuar a conexao com a marcadora Couth MC2000!',
      mtInformation, [mbok], 0);
  end;
end;


//===========================================
function TMC2000T2.desconectar: boolean;
begin
  comPort.Disconnect();
  if (comPort.Connected) then Result := false
  else
    begin
      Result := true;
      enviando  := False;
    end;
end;



//===========================================
function TMC2000T2.enviar: boolean;
var
  I: integer;
  isOK: boolean;
begin

  // verifica se todas as funçoes foram carregadas corretamente
  isOK := true;
  for I := 0 to totalFuncoes do
    if ((isOK) and (not(listFuncaoes[I].status))) then
      isOK := False;

  if (isOK) then
  begin

    TThread.CreateAnonymousThread(
      procedure
      begin
        TThread.CurrentThread.OnTerminate := finalizarEnvio;
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          var
            I   : integer;
            kpC : boolean;
          begin
               kpC := keepCon;
             try

               setKeepCon(true);
               if (conectar()) then
                begin

                  isOK := send(prepararFicheiro());
                  if (isOK) then
                    for I := 0 to (Length(listFuncaoes) ) do
                      if (isOK) then isOK := send(listFuncaoes[I].command); // envia as linhas
                end;
             finally
              setKeepCon(kpC);
              if (not(kpC)) then desConectar();
             end;

          end);
      end).Start

  end;
  Result := isOK;
end;


//===========================================
function TMC2000T2.send(linha: string): boolean;
begin
  Result := False;

  if (not(comPort.Connected)) then conectar();

  if (comPort.Connected) then
    begin
      enviando := True;
      if (comPort.SendString(linha)) then Result := true;
    end;

  if (not(keepCon)) then desConectar();
end;


//===========================================
procedure TMC2000T2.sendCmd(param: char);
begin

  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.CurrentThread.OnTerminate := finalizarEnvioCmd;
      TThread.Synchronize(TThread.CurrentThread,
        procedure
        var
          aux: string;
        begin
          aux := chr(16) + getDestinatario + chr(7) + chr(0) + param;
          aux := aux + CRC(aux);
          send(aux);
        end);
    end).Start
end;


//===========================================
procedure TMC2000T2.receberDados(Sender: TObject; DataPtr: Pointer;
  DataSize: DWORD);
var
  Str: String;
  tam: integer;
  I: Integer;
  aux : string;

  reader: TStreamReader;
  s: string;



begin
  reader := TStreamReader.Create(TPointerStream.Create(DataPtr, DataSize, False), TEncoding.ASCII);
  try

    reader.OwnStream;
//    while not InStream.EndOfStream do

    i := Random(1000);
    s := reader.ReadToEnd;
//    ShowMessage(i.ToString + '(1):'+  s);
    s := reader.ReadToEnd;
//      ShowMessage(i.ToString + '(2): '+  s);
//    tam := Length(str);

  finally
//    reader.Free;
//    desconectar();
//    ShowMessage(s);
  end;


{
tam := Length(str);


aux := '';
for I := 0 to tam do
  try
   aux := aux + '-' + IntToStr( byte( str[I]));
  except

  end;

      Memo1.Lines.Add(aux);
 }


end;


//===========================================
function TMC2000T2.getEnviando: Boolean;
begin
  Result := enviando;
end;

//===========================================
procedure TMC2000T2.finalizarEnvio(Sender: TObject);
begin
  enviando  := False;
end;

//===========================================
procedure TMC2000T2.finalizarEnvioCmd(Sender: TObject);
begin
  enviando  := False;
end;



//===========================================
//==== FUNÇÕES PARA A GERAÇÃO DAS LINHAS ====
//===========================================

function TMC2000T2.CRC(data: string): string;
begin
  Result := chr(3) + chr(3);
end;

//===========================================
function TMC2000T2.getInicioLinha(): string;
begin
  Result := chr(16) + chr(2);
end;

//===========================================
function TMC2000T2.getFimLinha(): string;
begin
  Result := chr(3) + chr(3);
end;

//===========================================
function TMC2000T2.converter(valorIn, tam: integer): string;
var
  hex, hexAux, hexSaida, hexAuxCHR: string;
  fim, I: integer;
begin
    hex := IntToHex(valorIn, (tam * 2));

    //inverter o byte mais significativo
    hexAux   := '';
    hexSaida := '';
    fim      := Length(hex);
    i        := fim;

    repeat
      hexAux    := hex[i - 1] + hex[i];
      hexAuxCHR := Chr (StrToInt('$'+hexAux));
      hexSaida  := hexSaida + hexAuxCHR;
      i         := i - 2;
    until i <= 0;

    Result := hexSaida;
end;


//===========================================
function TMC2000T2.validar(qual, valor: integer): boolean;
var
  min, max: integer;
  funcao: string;
  saidaTxt: string;
begin

  Result := False;
  min := listFuncaoes[qual].min;
  max := listFuncaoes[qual].max;

  if ((valor >= min) and (valor <= max)) then
  begin
    Result := true;
    listFuncaoes[qual].val := converter(valor, listFuncaoes[qual].size);
  end
  else
  begin
    funcao := listFuncaoes[qual].funcao;
    saidaTxt := 'O valor para ' + funcao + ' deve ser' + #13 + #13;
    saidaTxt := saidaTxt + ' Maior que: ' + min.ToString + #13;
    saidaTxt := saidaTxt + ' Menor que: ' + max.ToString + #13;
    saidaTxt := saidaTxt + ' valor informado:  ' + valor.ToString;
    ShowMessage(saidaTxt);
  end;

  listFuncaoes[qual].status := Result;
end;





//===========================================
//============ CONTROLE DA LISTA ============
//===========================================

//===========================================
procedure TMC2000T2.iniciarLista();
begin

  linha := 0;
  enviando := False;
  SetLength(listFuncaoes, totalFuncoes + 1);
  setItemDefaultValues();
end;

//===========================================
procedure TMC2000T2.setItemDefaultValues();
var
  I, pos: integer;
begin

  // for o := 0 to linha do
  for I := 0 to totalFuncoes do
    begin
    case I of
      0:
        begin
          item.funcao := 'Altura';
          item.min := 0;
          item.max := 400;
          item.size := 2;
        end;

      1:
        begin
          item.funcao := 'Largura';
          item.min := 0;
          item.max := 200;
          item.size := 1;
        end;

      2:
        begin
          item.funcao := 'Densidade';
          item.min := 1;
          item.max := 101;
          item.size := 1;
        end;

      3:
        begin
          item.funcao := 'Pos X';
          item.min := 0;
          item.max := 10000;
          item.size := 2;
        end;

      4:
        begin
          item.funcao := 'Pos Y';
          item.min := 0;
          item.max := 10000;
          item.size := 2;
        end;

      5:
        begin
          item.funcao := 'Angulo';
          item.min := 0;
          item.max := 3600;
          item.size := 2;
        end;

      6:
        begin
          item.funcao := 'Velocidade';
          item.min := 1;
          item.max := 10;
          item.size := 1;
        end;

      7:
        begin
          item.funcao := 'Força';
          item.min := 1;
          item.max := 10;
          item.size := 1;
        end;

      8:
        begin
          item.funcao := 'Dados';
          item.min := 0;
          item.max := 200;
          item.size := 1;
        end;

    end;

    item.status  := False;
    item.command := '';

    pos := I + (totalFuncoes * linha - 1) + 1;
    if (linha >= 1) then pos := pos - totalFuncoes;
    if (linha >= 2) then pos := pos + 1;

    listFuncaoes[pos] := item;
   end;

end;

//===========================================
function TMC2000T2.getItemFuncao(qual: integer): string;
begin
  Result := listFuncaoes[qual].funcao;
end;

//===========================================
function TMC2000T2.getItemMax(qual: integer): integer;
begin
  Result := listFuncaoes[qual].max;
end;

//===========================================
function TMC2000T2.getItemMin(qual: integer): integer;
begin
  Result := listFuncaoes[qual].min;
end;

//===========================================
function TMC2000T2.getPosNaLista(pos: integer): integer;
var
  resp: integer;
begin
  resp := pos + (linha * totalFuncoes - totalFuncoes);
  if (linha >= 2) then resp := resp + 1;
  Result := resp;
end;

end.
