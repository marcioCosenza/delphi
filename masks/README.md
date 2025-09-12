Funções de validação e tratamento para:

CEP, CNPJ, CPF, Telefone celular e Telefone fixo.

Quando o valor digitado estiver correto o Edit fica com a cor verde, caso esteja errado ele ficará vermelho.
Toda a configuração é feita em tempo de execução, o que agilia o desenvolvimento.
Busca o endereço pelo CEP.
Funciona offline, com exeção do BuscaCEP, mas a mascara funciona off-line.
Função para remover os caracteres especiais para o armazenamento em banco de dados (apenas os nnumeros devem ser gravados a fim de economizar espaço em disco).
Funções para formatar corretamente os valores numéricos com a mascara correta.

Usage:
Basta  adicionar 'untMask.pas' (não é necessário add o untBuscaCep.pas) no form que será usado.
Defina quais Edits serão usados (o exemplo está no onCreate do Main.pas).
As funções de validação, remoção dos caracteres especiais e a formatação para exibição estao no 'ConverterClick' do 'Main.pas'
No evento 'FormPaint' do TForm que vc usará é necessário que adicione a função: validaAllEdtColor(Self), como no main.pas.
