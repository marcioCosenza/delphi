unit untBuscaCEP;

interface

uses
  System.JSON, System.SysUtils, System.Types,
  FMX.Forms, FMX.Objects, FMX.Types, FMX.Dialogs, FMX.StdCtrls,
  REST.Client, Wininet;

Type TBuscaCEP = Class
  public
    constructor create(frm: TForm);
    destructor  destroy();

    procedure resgatar(param: string);
    function  getStatus():Integer;

    function  getLogradouro() :string;
    function  getBairro():     string;
    function  getUF():         string;
    function  getCidade():     string;
    function  getComplemento():string;

  private
    var
      logradouro  :string;
      bairro      :string;
      estado      :string;
      cidade      :string;
      complemento :string;

      status      : Integer;    // 0: OK; 1: desconectado; 2: falha ao localizar registro; 3: digitado incorretamente
      rctFundo    : TRectangle; //usado para exibir msg de aguarde enquantó procura o CEP
End;

implementation

uses untMask;

{ TBuscaCEP }

procedure TBuscaCEP.resgatar(param: string);
var
  data         : TJSONObject;
  RESTClient   : TRESTClient;
  RESTRequest  : TRESTRequest;
  RESTResponse : TRESTResponse;
  flags        : dword;
  mask         : TMask;
begin

  logradouro  := '';
  bairro      := '';
  estado      := '';
  cidade      := '';
  complemento := '';
  status      := 2; // seta como nao encontrado, caso encontre ou 'sem conexao' o valor será alterado

  mask := TMask.create(nil);

  if (not(mask.isCEP(param))) then status := 3
  else
    begin
      param:=  mask.limparTxt(param);
      mask.Destroy;

      if not (InternetGetConnectedState(@flags, 0)) then status := 1
      else
        begin
          RESTClient           := TRESTClient.Create(nil);
          RESTRequest          := TRESTRequest.Create(nil);
          RESTResponse         := TRESTResponse.Create(nil);
          RESTRequest.Client   := RESTClient;
          RESTRequest.Response := RESTResponse;
          RESTClient.BaseURL   := 'https://viacep.com.br/ws/' + param + '/json';

          try
            RESTRequest.Execute;
          except
            status := 4;
          end;

          data := RESTResponse.JSONValue as TJSONObject;
          try
            if (Assigned(data) and (data.Count <> 1)) then
              begin
                status := 0;
                logradouro  := data.Values['logradouro'].Value;
                bairro      := data.Values['bairro'].Value;
                estado      := data.Values['uf'].Value;
                cidade      := data.Values['localidade'].Value;
                complemento := data.Values['complemento'].Value;
              end;
          finally
            case  (getStatus()) of
              1: ShowMessage('Não foi possível resgatar as informações');
              2: ShowMessage('Verifique se foi digitado corretamente');
              3: ShowMessage('O CEP digitado é inválido');
              4: ShowMessage('A conexão atingiu o tempo limite');
            end;
            FreeAndNil(data);
          end;
       end;

    end;
end;


constructor TBuscaCEP.create(frm: TForm);
var
  rctBase : TRectangle;
  lbl     : TLabel;
  pBar    : TAniIndicator;
  tamRctW : integer;
  tamRctH : integer;
  I       : Integer;
begin
  // fundo transparente
  rctFundo := TRectangle.Create(frm);
  rctFundo.Parent := frm;
  rctFundo.Align := TAlignLayout.Contents;
  rctFundo.Fill.Color := $C8BABABA;
  rctFundo.Visible := True;

  // rectangle principal
  tamRctW := 300;
  tamRctH := 230;

  rctBase := TRectangle.Create(rctFundo);
  rctBase.Parent         := rctFundo;
  rctBase.Align          := TAlignLayout.Center;
  rctBase.Width          := tamRctW;
  rctBase.Height         := tamRctH;
  rctBase.Fill.Color     := $AAAAAAAA;
  rctBase.Padding.Top    := 30;
  rctBase.Padding.Bottom := 30;
  rctBase.Visible        := True;

  for I := 1 to 2 do
    begin
      lbl := TLabel.Create(rctBase);
      case I of
        1:begin
            lbl.Align := TAlignLayout.Bottom;
            lbl.Text := 'Aguarde';
            lbl.TextSettings.Font.Size := 20;
          end;

        2:begin
            lbl.Align := TAlignLayout.Top;
            lbl.Text := 'Pesquisando CEP';
            lbl.TextSettings.Font.Size := 25;
          end;
      end;

      lbl.Parent  := rctBase;
      lbl.StyledSettings := lbl.StyledSettings - [TStyledSetting.Size];
      lbl.TextSettings.HorzAlign := TTextAlign.Center;
      lbl.Width   := tamRctW;
      lbl.Height  := 40;
      lbl.Visible := True;
    end;

  //indicador de tempo
  pBar := TAniIndicator.Create(rctBase);
  pBar.Parent := rctBase;
  pBar.Align := TAlignLayout.Center;
  pBar.Enabled := true;
  pBar.Visible := True;
end;

destructor TBuscaCEP.destroy;
begin
  rctFundo.Visible := false;
  rctFundo.Destroy;
end;


function TBuscaCEP.getBairro: string;
begin
  Result := bairro;
end;

function TBuscaCEP.getCidade: string;
begin
  Result := cidade;
end;

function TBuscaCEP.getComplemento: string;
begin
  Result := complemento;
end;

function TBuscaCEP.getLogradouro: string;
begin
  Result := logradouro;
end;

function TBuscaCEP.getStatus: integer;
begin
  Result := status;
end;

function TBuscaCEP.getUF: string;
begin
  Result := estado;
end;

end.
