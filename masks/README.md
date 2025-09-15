Funções de validação, mascaras e tratamento para:

* Email,<br> 
* CEP,<br> 
* CNPJ,<br> 
* CPF,<br> 
* Telefone celular,<br> 
* Telefone fixo,<br> 
* Placa de veicular no formato antigo<br> 
* Placa de veicular formato mercosul<br> 

<p>A classe <b>TMask</b> faz todo o trabalho de validação e máscara para as opções acima descritas, basta especificar quais Edits serão usados para cada campo. </p>
<p>A mascara é criada em tempo de execução alterando a cor do Edit de verde e vermelho indicando ao usuário se o valor digitado está correto ou não.Quando o valor digitado estiver correto o Edit fica com a cor verde, caso esteja errado ele ficará vermelho.</p>
<p>Funciona offline, com exeção do BuscaCEP, porem a mascara funciona off-line.</p>

<p>Para o armazenamento em banco de dados os caracteres especiais são removidos (economizando espaço em disco), e para a exibição serão formatados com a mascara correta.</p>

<p>Busca o endereço pelo CEP, unica função que necessita de conexão com a Internet.</p>

<h3>Como usar:</h3>

Basta  adicionar '<b>untMask.pas</b>' (não é necessário add o untBuscaCep.pas, mas deve ser adicionado ao projeto) no form que será usado.
Defina quais Edits serão usados (o exemplo está no onCreate do Main.pas).
As funções de validação, remoção dos caracteres especiais e a formatação para exibição estao no 'ConverterClick' do 'Main.pas'
No evento 'FormPaint' do TForm que vc usará é necessário que adicione a função: validaAllEdtColor(Self), como no main.pas.

Delphi 12/Firemonkey.
