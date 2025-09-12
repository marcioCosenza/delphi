unit untMask;

interface

uses
  System.SysUtils, System.Classes, System.UITypes, System.RegularExpressions,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit, FMX.Objects, FMX.SpinBox, FMX.ListBox,
  untBuscaCEP;

Type TMask = Class
  public
    type charList = record
      id: integer;
      ch: Char;
    end;

    constructor create(frm: TForm);
    procedure setExibirMsg(param: Boolean);

    procedure start(frm: TForm);
    procedure validaAllEdtColor(frm: TForm);
    function limparTxt    (param: string):string;//remove os caracteres especiais, retornando apenas os numeros

    //configura os edts
    procedure defCEP      (cep, endereco, complemento, bairro, cidade: TEdit; UF: TComboBox);
    procedure defFoneFixo (quem: TEdit);
    procedure defFoneCel  (quem: TEdit);
    procedure defCPF      (quem: TEdit);
    procedure defCNPJ     (quem: TEdit);
    procedure defPlacaOld (quem: TEdit);
    procedure defPlacaMS  (quem: TEdit);
    procedure defEmail    (quem: TEdit);

    //formatar
    function formatarCEP  (param: Double): string;
    function formatarFone (param: Double):  string;
    function formatarCel  (param: Double):  string;
    function formatarCPF  (param: Double):  string;
    function formatarCNPJ (param: Double):  string;
    function formatarPlacaOld (param: string):  string;
    function formatarPlacaMS (param: string):  string;
    function formatarEmail (param: Double):  string;

    //validacao
    function isCNPJ  (param: string): boolean;
    function isCPF   (param: string): boolean;
    function isCEP   (param: string): boolean;
    function isFone  (param: string): boolean;
    function isCel   (param: string): boolean;
    function isPlacaOld (param: string): boolean;
    function isPlacaMS (param: string): boolean;
    function isEmail (param: string): boolean;

  private
    procedure setEditColor   (cmp: TComponent);
    procedure validaEdtColor (Sender: TObject);

    //vefifica se esta correto
    procedure validarGeral (edt: TComponent; tam: integer);
    procedure validarCEP   (Sender: TObject);
    procedure validarFone  (Sender: TObject);
    procedure validarCel   (Sender: TObject);
    procedure validarCPF   (Sender: TObject);
    procedure validarCNPJ  (Sender: TObject);
    procedure validarPlacaOld (Sender: TObject);
    procedure validarPlacaMS (Sender: TObject);
    procedure validarEmail (Sender: TObject);

    //Auxilio
    procedure fechaRct(Sender: TObject);
    procedure soNum   (Sender: TObject; var Key: Word;  var KeyChar: Char; Shift: TShiftState);
    procedure addExecao(quem: TEdit; funcao: integer);
    function  procuraPorExcecao(cmp: TComponent): integer;
    procedure maisculas(Sender: TObject; var Key: Word;  var KeyChar: Char; Shift: TShiftState);

    //OnKeyUp
    procedure keyYUpGeral   (Sender: TObject; var KeyChar: Char; var tamConst: integer; var lista: array of charList);
    procedure CEPKeyUp      (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure foneFixoKeyUp (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure foneCelKeyUp  (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure CPFKeyUp      (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure CNPJKeyUp     (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure placaOldKeyUp (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure placaMSKeyUp (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure emailKeyUp    (Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);

    procedure showMSG(param: string);
    procedure buscaCep(Sender: TObject);

    const corEdtOk  = $2E09F611;
    const corEdtNOk = $64C85D5D;

    const tamCNPJ  = 14;
    const tamCPF   = 11;
    const tamCEP   =  8;
    const tamCel   = 11;
    const tamFone  = 10;
    const tamPlaca = 7;

    const vcCEP      = 0;
    const vcCPF      = 1;
    const vcCNPJ     = 2;
    const vcTelCel   = 3;
    const vcTelFix   = 4;
    const vcPlacaOld = 5;
    const vcPlacaMS  = 6;
    const vcEmail    = 7;

    type excecoes = record
      name  : string;
      funcao: integer; //identificado pelas constantes 'vcNOME'
    end;

    type dadosCEP = record
      cep         : TEdit;
      endereco    : TEdit;
      complemento : TEdit;
      bairro      : TEdit;
      cidade      : TEdit;
      UF          : TComboBox;
    end;

    var
      listaExcecoes: Array of excecoes;
      listaCEP     : Array of dadosCEP;
      posLista     : integer;
      exibirMsg    : boolean;
      form         : TForm;
End;

implementation

{ TMask }

// =====================================================
// ====================+ VERIFICACAO ===================
// =====================================================

function TMask.isCEP(param: string): boolean;
begin
  Result := false;
  param :=   limparTxt(param);
  if (param.Length = tamCEP) then Result := True
  else showMsg('CEP inv�lido');
end;

// =========================================
function TMask.isCel(param: string): boolean;
begin
  Result := false;
  param := limparTxt(param);
  if (param.Length = tamCel) then Result := True
  else showMsg('Telefone celular inv�lido');
end;

// =========================================
function TMask.isFone(param: string): boolean;
begin
  Result := false;
  param := limparTxt(param);
  if (param.Length = tamFone) then Result := True
  else showMsg('Telefone fixo inv�lido');
end;


// =========================================
function TMask.isCNPJ(param: string): boolean;
var
  dig13, dig14: string;
  sm, i, r, peso: integer;
  CNPJ: string;
begin
  CNPJ :=limparTxt(param);

  // length - retorna o tamanho da string do CNPJ (CNPJ � um n�mero formado por 14 d�gitos)
  if ((CNPJ = '00000000000000') or (CNPJ = '11111111111111') or
      (CNPJ = '22222222222222') or (CNPJ = '33333333333333') or
      (CNPJ = '44444444444444') or (CNPJ = '55555555555555') or
      (CNPJ = '66666666666666') or (CNPJ = '77777777777777') or
      (CNPJ = '88888888888888') or (CNPJ = '99999999999999') or
      (length(CNPJ) <> 14))
     then
      begin
        Result := false;
        exit;
      end;

// "try" - protege o c�digo para eventuais erros de convers�o de tipo atrav�s da fun��o "StrToInt"
  try
{ *-- C�lculo do 1o. Digito Verificador --* }
    sm := 0;
    peso := 2;
    for i := 12 downto 1 do
    begin
// StrToInt converte o i-�simo caractere do CNPJ em um n�mero
      sm := sm + (StrToInt(CNPJ[i]) * peso);
      peso := peso + 1;
      if (peso = 10)
         then peso := 2;
    end;
    r := sm mod 11;
    if ((r = 0) or (r = 1))
       then dig13 := '0'
    else str((11-r):1, dig13); // converte um n�mero no respectivo caractere num�rico

{ *-- C�lculo do 2o. Digito Verificador --* }
    sm := 0;
    peso := 2;
    for i := 13 downto 1 do
    begin
      sm := sm + (StrToInt(CNPJ[i]) * peso);
      peso := peso + 1;
      if (peso = 10)
         then peso := 2;
    end;
    r := sm mod 11;
    if ((r = 0) or (r = 1))
       then dig14 := '0'
    else str((11-r):1, dig14);

{ Verifica se os digitos calculados conferem com os digitos informados. }
    if ((dig13 = CNPJ[13]) and (dig14 = CNPJ[14]))
       then Result := true
    else Result := false;
  except
    Result := false
  end;

  if not(Result) then showMsg('CNPJ inv�lido');
end;

// =======================
function TMask.isCPF(param: string): boolean;
var
  dig10, dig11: string;
  s, i, r, peso: integer;
  CPF: string;
begin
  CPF := limparTxt(param);

  // length - retorna o tamanho da string (CPF � um n�mero formado por 11 d�gitos)
  if ((CPF = '00000000000') or (CPF = '11111111111') or
      (CPF = '22222222222') or (CPF = '33333333333') or
      (CPF = '44444444444') or (CPF = '55555555555') or
      (CPF = '66666666666') or (CPF = '77777777777') or
      (CPF = '88888888888') or (CPF = '99999999999') or
      (length(CPF) <> 11))
     then begin
              Result := false;
              exit;
            end;

  // try - protege o c�digo para eventuais erros de convers�o de tipo na fun��o StrToInt
  try
  { *-- C�lculo do 1o. Digito Verificador --* }
    s := 0;
    peso := 10;
    for i := 1 to 9 do
      begin
        // StrToInt converte o i-�simo caractere do CPF em um n�mero
        s := s + (StrToInt(CPF[i]) * peso);
        peso := peso - 1;
      end;

    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11))  then dig10 := '0'
    else str(r:1, dig10); // converte um n�mero no respectivo caractere num�rico

{ *-- C�lculo do 2o. Digito Verificador --* }
    s := 0;
    peso := 11;
    for i := 1 to 10 do
    begin
      s := s + (StrToInt(CPF[i]) * peso);
      peso := peso - 1;
    end;
    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11))
       then dig11 := '0'
    else str(r:1, dig11);

{ Verifica se os digitos calculados conferem com os digitos informados. }
    if ((dig10 = CPF[10]) and (dig11 = CPF[11])) then Result := true
    else Result := false;

  except
    Result := false
  end;

  if not(Result) then showMsg('CPF inv�lido');
end;

// =========================================
function TMask.isPlacaMS(param: string): boolean;

begin
  Result := false;
  if (TRegEx.IsMatch(param, '^[A-Z]{3}\d{1}[A-Z]{1}\d{2}$')) then Result := True
  else showMsg('Placa inv�lida');
end;

// =========================================
function TMask.isPlacaOld(param: string): boolean;

begin
  Result := false;
  if (TRegEx.IsMatch(param, '^[A-Z]{3}-\d{4}$')) then Result := True
  else showMsg('Placa inv�lida');
end;

// =======================
function TMask.isEmail(param: string): boolean;

begin
  Result := false;
  if (TRegEx.IsMatch(param, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')) then Result := True
  else showMsg('Email inv�lido');
end;



// =====================================================
// ======================  KEY UP ======================
// =====================================================

procedure TMask.keyYUpGeral(Sender: TObject; var KeyChar: Char; var tamConst: integer; var lista: array of charList);
var
  value    : string;
  aux      : string;
  I, I2    : Integer;
  tam      : integer;
  tamLista : integer;
  edt      : TEdit;
  rct      : TRectangle;
begin
  edt := TEdit (Tcontrol(Sender));
  rct := TRectangle (Tcontrol(Sender).Children[2]);

  if ((KeyChar <> #0)  and (edt.Text <> '')) then
    begin
      value := edt.Text;
      value :=limparTxt( value);
      tam   := Length(value);
      aux := edt.Text;

      if tam > tamConst then
        begin
          rct.Visible := true;
          tam := tam - 1;
        end
      else rct.Visible := False;

      aux      := '';
      I2       := 0;
      tamLista := Length(lista);

      for I := 1 to tamConst  do
        begin
          if I <= tam then
            begin

            if (I2 <= tamLista) then
              begin
                if lista[I2].id  = I then
                  begin
                    aux := aux + lista[I2].ch;
                    if (I2 < tamlista -1) then Inc(I2);
                  end;
                aux := aux + value[I];
              end;
            end;
        end;
      edt.Text := aux;
      edt.SelStart := Length( aux );
    end;

end;


//============== FONE CEL ==============
//======================================
procedure TMask.foneCelKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  lista: array of charList;
  tam: Integer;
begin
  tam := tamCel;
  SetLength(lista, 3);

  lista[0].id := 1; lista[0].ch := '(';
  lista[1].id := 3; lista[1].ch := ')';
  lista[2].id := 8; lista[2].ch := '-';

  keyYUpGeral(Sender, KeyChar, tam, lista);
  validarGeral(TEdit ( Tcontrol(Sender)), tamCel);
end;

//============== FONE FIXO =============
//======================================
procedure TMask.foneFixoKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  lista: array of charList;
  tam: Integer;
begin
  tam := tamFone;
  SetLength(lista, 3);

  lista[0].id := 1; lista[0].ch := '(';
  lista[1].id := 3; lista[1].ch := ')';
  lista[2].id := 7; lista[2].ch := '-';

  keyYUpGeral(Sender, KeyChar, tam, lista);
  validarGeral(TEdit ( Tcontrol(Sender)), tamFone);
end;


//================ CNPJ ================
//======================================
procedure TMask.CNPJKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);

var
  lista: array of charList;
  tam: Integer;
begin

  tam := tamCNPJ;
  SetLength(lista, 4);

  lista[0].id :=  3; lista[0].ch := '.';
  lista[1].id :=  6; lista[1].ch := '.';
  lista[2].id :=  9; lista[2].ch := '/';
  lista[3].id := 13; lista[3].ch := '-';

  keyYUpGeral(Sender, KeyChar, tam, lista);
  validarCNPJ(Sender);
end;


//================= CPF ================
//======================================
procedure TMask.CPFKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  lista: array of charList;
  tam: Integer;
begin

  tam := tamCPF;
  SetLength(lista, tam);

  lista[0].id :=  4; lista[0].ch := '.';
  lista[1].id :=  7; lista[1].ch := '.';
  lista[2].id := 10; lista[2].ch := '-';

  keyYUpGeral(Sender, KeyChar, tam, lista);
  validarCPF(Sender);
end;


procedure TMask.placaMSKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  lista: array of charList;
  tam: Integer;
begin
  tam := tamPlaca;
  SetLength(lista, tam);

  lista[0].id :=  4; lista[0].ch := ' ';
  keyYUpGeral(Sender,  KeyChar, tam, lista);
  validarPlacaMS(Sender);
end;

// =========================================
procedure TMask.placaOldKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  lista: array of charList;
  tam: Integer;
begin
  tam := tamPlaca;
  SetLength(lista, tam);

  lista[0].id :=  4; lista[0].ch := '-';

  keyYUpGeral(Sender,  KeyChar, tam, lista);
  validarPlacaOld(Sender);
end;

// =========================================
procedure TMask.emailKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  validarEmail(Sender);
end;


constructor TMask.create(frm: TForm);
begin
  form := frm;
  exibirMsg := False;
  posLista:= 0;
  SetLength(listaExcecoes, 0);
  SetLength(listaCEP, 0);
end;

//================ CEP =================
//======================================


procedure TMask.buscaCep(Sender: TObject);
var
  buscaCEP: TBuscaCEP;
begin
  validarGeral(TEdit (TComponent(Sender)), tamCEP);

  TThread.CreateAnonymousThread(procedure
    begin
      TThread.CurrentThread.FreeOnTerminate := true;
      buscaCEP:= TBuscaCEP.Create(Form);
      buscaCEP.resgatar(TEdit (TComponent(Sender)).Text);
      TThread.Synchronize(TThread.CurrentThread, procedure
        var
          I: Integer;
          uf: string;
          ufIndex: integer;
        begin

          for I := 0 to Length(listaCEP) - 1 do
            if listaCEP[I].cep.Name = TEdit (TComponent(Sender)).Name then
              begin
                listaCEP[I].endereco.Text     := buscaCEP.getLogradouro();
                listaCEP[I].complemento.Text  := buscaCEP.getComplemento();
                listaCEP[I].bairro.Text       := buscaCEP.getBairro();
                listaCEP[I].cidade.Text       := buscaCEP.getCidade();
                uf := buscaCEP.getUF();
                ufIndex :=  listaCEP[I].UF.Items.IndexOf(uf);
                listaCEP[I].UF.ItemIndex      := ufIndex;
              end;
          buscaCEP.Destroy;
        end);
    end).Start;
end;

procedure TMask.CEPKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  lista: array of charList;
  tam: Integer;
begin
  tam := tamCEP;
  SetLength(lista, 2);

  lista[0].id := 3; lista[0].ch := '.';
  lista[1].id := 6; lista[1].ch := '-';

  keyYUpGeral(Sender, KeyChar, tam, lista);
end;



//======================================
//=============== CRIAR ================
//======================================

procedure TMask.setEditColor(cmp: TComponent);
var
  rct: TRectangle;
  pode: Boolean;
begin
  pode := False;
  if ((cmp is TEdit) or (cmp is TComboBox) or (cmp is TSpinBox)) then pode := True;

  if pode then
    begin
      rct := TRectangle.Create(cmp);
      rct.Align   := TAlignLayout.Client;
      rct.Visible := True;

      if (cmp is TEdit) then
        begin
          rct.Parent  := cmp as TEdit;

          if (procuraPorExcecao(cmp) = -1) then
            (cmp as TEdit).OnExit  := validaEdtColor;
        end;

      if (cmp is TSpinBox) then
        begin
          rct.Parent  := cmp as TSpinBox;
          (cmp as TSpinBox).OnExit  := validaEdtColor;
        end;

      if (cmp is TComboBox) then
        begin
          rct.Parent  := cmp as TComboBox;
          (cmp as TComboBox).OnExit  := validaEdtColor;
        end;

      rct.OnClick := fechaRct;
      validaEdtColor(cmp);
      end;
end;


// =========================================
procedure TMask.setExibirMsg(param: Boolean);
begin
  exibirMsg := param;
end;

// =========================================
procedure TMask.showMSG(param: string);
begin
if exibirMsg then ShowMessage(param);
end;

//======================================
//============== VALIDAR ===============
//======================================



procedure TMask.validaAllEdtColor(frm: TForm);
var
  I, aux: Integer;
begin
  for I := 1  to frm.ComponentCount  - 1 do
    begin
      aux := procuraPorExcecao(frm.Components[I]);
      if (aux = -1 ) then validaEdtColor(frm.Components[I])
      else
        begin
          case listaExcecoes[aux].funcao of
            0:validarCEP(frm.Components[I]);
            1:validarCPF(frm.Components[I]);
            2:validarCNPJ(frm.Components[I]);
            3:validarCel(frm.Components[I]);
            4:validarFone(frm.Components[I]);
          end;
        end;
    end;
end;

procedure TMask.validaEdtColor(Sender: TObject);
var
  I   : Integer;
  ok  : Boolean;
  cor : TAlphaColor;
  permitido: Boolean;
begin
  permitido := false;
  ok        := true;
  I         := 2;

  if (TControl(Sender) is TEdit)      then begin if TEdit      (Tcontrol(Sender)).Text      = '' then ok := false; permitido:= true; end;
  if (TControl(Sender) is TSpinbox)   then begin if TSpinbox   (Tcontrol(Sender)).Value     =  0 then ok := false; permitido:= true; end;
  if (TControl(Sender) is TComboBox)  then begin if TComboBox  (Tcontrol(Sender)).ItemIndex = -1 then ok := false; permitido:= true; end;

  if permitido then
    if (Tcontrol(Sender).ChildrenCount > I) then
      begin
        if ok then cor := corEdtOk
        else cor := corEdtNOk;
        TRectangle (Tcontrol(Sender).Children[I]).Fill.Color := cor;
        TRectangle (Tcontrol(Sender).Children[I]).Visible := true;
      end;
end;

//========================
//========================

procedure TMask.validarGeral(edt: TComponent; tam: integer);
var
  rct: TComponent;
  cor: TAlphaColor;
  txt: string;
  tamAferido: Integer;
begin
  cor := corEdtNOk;
  rct := TEdit (edt).Children[2];
  txt := TEdit (edt).Text;
  txt := limparTxt(txt);

  tamAferido:=   Length(txt);

  if (tamAferido = tam) then cor := corEdtOk;

  TRectangle (rct).Fill.Color := cor;
  TRectangle (rct).Visible    := true;
end;

//========================
procedure TMask.validarPlacaMS(Sender: TObject);
var
  rct: TComponent;
  cor: TAlphaColor;
  placa: string;
begin

  placa := TEdit (TComponent(Sender)).Text;
  placa := limparTxt(placa);

  cor := corEdtNOk;

  if (isPlacaMS(placa)) then cor := corEdtOk;

  rct := TEdit (TComponent(Sender)).Children[2];
  TRectangle (rct).Fill.Color := cor;
  TRectangle (rct).Visible    := true;
end;

//========================
procedure TMask.validarPlacaOld(Sender: TObject);
var
  rct: TComponent;
  cor: TAlphaColor;
begin
  cor := corEdtNOk;

  if (isPlacaOld(TEdit (TComponent(Sender)).Text)) then cor := corEdtOk;

  rct := TEdit (TComponent(Sender)).Children[2];
  TRectangle (rct).Fill.Color := cor;
  TRectangle (rct).Visible    := true;
end;

//========================
procedure TMask.validarCPF(Sender: TObject);
var
  rct: TComponent;
  cor: TAlphaColor;
begin
  cor := corEdtNOk;

  if (isCPF(TEdit (TComponent(Sender)).Text)) then cor := corEdtOk;

  rct := TEdit (TComponent(Sender)).Children[2];
  TRectangle (rct).Fill.Color := cor;
  TRectangle (rct).Visible    := true;
end;

//========================
procedure TMask.validarEmail(Sender: TObject);
var
  rct: TComponent;
  cor: TAlphaColor;
begin
  cor := corEdtNOk;

  if (isEmail(TEdit (TComponent(Sender)).Text)) then cor := corEdtOk;

  rct := TEdit (TComponent(Sender)).Children[2];
  TRectangle (rct).Fill.Color := cor;
  TRectangle (rct).Visible    := true;

end;

//========================
procedure TMask.validarCNPJ(Sender: TObject);
var
  rct: TComponent;
  cor: TAlphaColor;
begin
  cor := corEdtNOk;

  if (isCNPJ(TEdit (TComponent(Sender)).Text)) then cor := corEdtOk;

  rct := TEdit (TComponent(Sender)).Children[2];
  TRectangle (rct).Fill.Color := cor;
  TRectangle (rct).Visible    := true;
end;


//========================
procedure TMask.validarCel(Sender: TObject);
begin
  validarGeral(TEdit (TComponent(Sender)), tamCel);
end;

//========================
procedure TMask.validarFone(Sender: TObject);
begin
  validarGeral(TEdit (TComponent(Sender)), tamFone);
end;

//========================
procedure TMask.validarCEP(Sender: TObject);
begin
  validarGeral(TEdit (TComponent(Sender)), tamCEP);
end;


//=========== DEFINICAO ===========

procedure TMask.start(frm: TForm);
var
  I: Integer;
begin
  for I := 0  to frm.ComponentCount  - 1 do setEditColor(frm.Components[I]);
end;



procedure TMask.defCEP(cep, endereco, complemento, bairro, cidade: TEdit; UF: TComboBox);
var
  qtd: integer;
begin
  addExecao(cep, vcCEP);

  qtd := Length(listaCEP);
  SetLength(listaCEP, qtd + 1);

  listaCEP[qtd].cep         := cep;
  listaCEP[qtd].endereco    := endereco;
  listaCEP[qtd].complemento := complemento;
  listaCEP[qtd].bairro      := bairro;
  listaCEP[qtd].cidade      := cidade;
  listaCEP[qtd].UF          := UF;

  listaCEP[qtd].UF.Items.Clear;
  listaCEP[qtd].UF.Items.Add('AC');
  listaCEP[qtd].UF.Items.Add('AL');
  listaCEP[qtd].UF.Items.Add('AP');
  listaCEP[qtd].UF.Items.Add('AM');
  listaCEP[qtd].UF.Items.Add('BA');
  listaCEP[qtd].UF.Items.Add('CE');
  listaCEP[qtd].UF.Items.Add('DF');
  listaCEP[qtd].UF.Items.Add('ES');
  listaCEP[qtd].UF.Items.Add('GO');
  listaCEP[qtd].UF.Items.Add('MA');
  listaCEP[qtd].UF.Items.Add('MT');
  listaCEP[qtd].UF.Items.Add('MS');
  listaCEP[qtd].UF.Items.Add('MG');
  listaCEP[qtd].UF.Items.Add('PA');
  listaCEP[qtd].UF.Items.Add('PB');
  listaCEP[qtd].UF.Items.Add('PR');
  listaCEP[qtd].UF.Items.Add('PE');
  listaCEP[qtd].UF.Items.Add('PI');
  listaCEP[qtd].UF.Items.Add('RJ');
  listaCEP[qtd].UF.Items.Add('RN');
  listaCEP[qtd].UF.Items.Add('RS');
  listaCEP[qtd].UF.Items.Add('RO');
  listaCEP[qtd].UF.Items.Add('RR');
  listaCEP[qtd].UF.Items.Add('SC');
  listaCEP[qtd].UF.Items.Add('SP');
  listaCEP[qtd].UF.Items.Add('SE');
  listaCEP[qtd].UF.Items.Add('TO');

  cep.OnKeyUp   := CEPKeyUp;
  cep.OnExit    := buscaCEP;
  cep.OnKeyDown := soNum;
end;

// =========================================
procedure TMask.defCNPJ(quem: TEdit);
begin
  addExecao(quem, vcCNPJ);

  quem.OnKeyUp := CNPJKeyUp;
  quem.OnExit  := validarCNPJ;
  quem.OnKeyDown := soNum;
end;

// =========================================
procedure TMask.defCPF(quem: TEdit);
begin
  addExecao(quem, vcCPF);

  quem.OnKeyUp := CPFKeyUp;
  quem.OnExit  := validarCPF;
  quem.OnKeyDown := soNum;
end;

// =========================================
procedure TMask.defFoneCel(quem: TEdit);
begin
  addExecao(quem, vcTelCel);

  quem.OnKeyUp := foneCelKeyUp;
  quem.OnExit  := validarCel;
  quem.OnKeyDown := soNum;
end;

// =========================================
procedure TMask.defFoneFixo(quem: TEdit);
begin
  addExecao(quem, vcTelFix);

  quem.OnKeyUp := foneFixoKeyUp;
  quem.OnExit  := validarFone;
  quem.OnKeyDown := soNum;
end;

procedure TMask.defPlacaMS(quem: TEdit);
begin
  addExecao(quem, vcPlacaMS);

  quem.OnKeyUp := placaMSKeyUp;
  quem.OnExit  := validarPlacaMS;
  quem.OnKeyDown := maisculas;
end;

procedure TMask.defPlacaOld(quem: TEdit);
begin
  addExecao(quem, vcPlacaOld);

  quem.OnKeyUp := placaOldKeyUp;
  quem.OnExit  := validarPlacaOld;
  quem.OnKeyDown := maisculas;
end;

// =========================================
procedure TMask.defEmail(quem: TEdit);
begin
  addExecao(quem, vcEmail);
  quem.OnKeyUp := emailKeyUp;
  quem.OnExit  := validarEmail;
end;


//=================== FOMATAR ===================
function TMask.formatarCEP(param: Double): string;
begin
  if (param = 0) then Result := ''
  else result := copy(param.ToString, 1, 2) + '.' + copy(Param.ToString, 3, 3) + '-' + copy(Param.ToString, 6, 3) ;
end;

// =========================================
function TMask.formatarCNPJ(param: Double): string;
var
  str: string;
begin
  if (param = 0) then Result := ''
  else
    begin
      str := param.ToString;
      if Length(str) <> 11 then str := '0' + str;

      result :=
        copy(str, 1, 2)  + '.' +
        copy(str, 3, 3)  + '.' +
        copy(str, 6, 3)  + '/' +
        copy(str, 9, 4) + '-' +
        copy(str, 13, 2);
    end;
end;

// =========================================
function TMask.formatarCPF(param: Double): string;
begin
  if (param = 0) then Result := ''
  else
    begin
      result := copy(param.ToString, 1, 3) + '.' + copy(Param.ToString, 4, 3) + '.' +
      copy(Param.ToString, 7, 3) + '-' + copy(Param.ToString, 10, 2);
    end;
end;

// =========================================
function TMask.formatarEmail(param: Double): string;
begin
//
end;

// =========================================
function TMask.formatarCel(param: Double): string;
begin
  if (param = 0) then Result := ''
  else result := '(' + copy(param.ToString, 1, 2) + ')' + copy(Param.ToString, 3, 5) + '-' + copy(Param.ToString, 8, 4) ;
end;

// =========================================
function TMask.formatarFone(param: Double): string;
begin
  if (param = 0) then Result := ''
  else result := '(' + copy(param.ToString, 1, 2) + ')' + copy(Param.ToString, 3, 4) + '-' + copy(Param.ToString, 7, 4) ;
end;

function TMask.formatarPlacaMS(param: string): string;
begin
  if (param = '0') then Result := ''
  else result := copy(param, 1, 3) + ' ' + copy(Param, 4, 5);
end;

// =========================================
function TMask.formatarPlacaOld(param: string): string;
begin
  if (param = '0') then Result := ''
  else result := copy(param, 1, 3) + '-' + copy(Param, 4, 5);
end;

//=================== AUX ===================
function TMask.limparTxt(param: string): string;
begin
if param = '' then Result := '0'
else
  begin
  param := Trim(param);
  param := StringReplace(param, '.', '', [rfReplaceAll]);
  param := StringReplace(param, '-', '', [rfReplaceAll]);
  param := StringReplace(param, '/', '', [rfReplaceAll]);
  param := StringReplace(param, '(', '', [rfReplaceAll]);
  param := StringReplace(param, ')', '', [rfReplaceAll]);
  param := StringReplace(param, ' ', '', [rfReplaceAll]);

  Result := param;
  end;
end;


procedure TMask.maisculas(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  KeyChar := UpCase(KeyChar);
end;

// =========================================
procedure TMask.soNum(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if (not (KeyChar in ['0'..'9'])) then KeyChar := #0;
end;

// =========================================
procedure TMask.fechaRct(Sender: TObject);
begin
  Tcontrol(Sender).Visible := false;
  TEdit (Tcontrol(Sender).Parent).SetFocus;
end;

// =========================================
procedure TMask.addExecao(quem: TEdit; funcao: integer);
begin
  SetLength(listaExcecoes, posLista + 1);
  listaExcecoes[posLista].name := quem.Name;
  listaExcecoes[posLista].funcao := funcao;

  posLista := posLista + 1;
end;

// =========================================
function TMask.procuraPorExcecao(cmp: TComponent): integer;
var
  nome: string;
  tam : Integer;
  I   : Integer;
begin
  Result := -1;
  tam    := Length(listaExcecoes) - 1;
  nome   := TEdit(cmp).Name;

  for I := 0 to tam  do
    if listaExcecoes[I].name = nome then
      Result := I;
end;

end.


