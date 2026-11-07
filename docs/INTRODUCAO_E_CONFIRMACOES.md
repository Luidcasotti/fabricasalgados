> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Introdução sem contagem e confirmações — 05/11/2026

JOGAR mantém os cinco minutos completos enquanto a introdução estiver aberta.
Avançar uma fala ainda não inicia a contagem. O relógio começa quando a última
fala termina ou quando o jogador pula/fecha a introdução. Ela informa essa regra.

Depois dos atos principais aparece uma mensagem com botão CONFIRMAR / CONTINUAR:

- Pedido aceito ou recusado.
- Ingredientes separados, pelo canhoto ou por retirada individual.
- Ingredientes depositados na cozinha.
- Início do preparo e pedido pronto, em avisos separados.
- Compra registrada e conferência de estoque pela interface.
- Pedido entregue; nesse caso, o botão é VER RESULTADO / ENTER.

Enter e Espaço também confirmam. O clique que realizou a ação não confirma
automaticamente o aviso. Esc e E não dispensam essa confirmação.

O relógio, preparo, movimento e manutenção ficam parados durante a confirmação.
As ações são executadas uma vez, antes de mostrar a mensagem. O botão apenas
fecha o aviso; não compra, transfere, produz ou paga novamente. Outras ações
ficam bloqueadas enquanto o aviso estiver aberto. Ações inválidas continuam
mostrando o erro e não geram uma falsa confirmação de sucesso.

Após entregar, o pagamento já está registrado. A tela de resultado só é
liberada depois de confirmar, e seu retorno automático de 30 segundos só
começa nesse momento. As decisões educativas já possuem consequência e
botão de retorno; não ganham outro aviso duplicado.

## Verificação

- GameMaker Windows VM: 410 verificações de lógica, zero falhas.
- JOGAR completo: 39 verificações, incluindo os botões de cada confirmação.
- Modo livre completo: 123 verificações, incluindo oito teclas de movimento,
  compra, transporte, produção, entrega e retorno ao dashboard.
- Parser: 79 arquivos GML sem erro; 105 recursos com referências válidas.
- Exportação HTML5 oficial: `build/html5-20261105-091726`.

Casos novos: ler as cinco falas sem gastar tempo, pular a introdução, início
do relógio após sair dela, congelamento em cada confirmação, bloqueio de
repetição de aceite/retirada/entrega, confirmação do preparo, pagamento único,
resultado sem expirar durante a leitura e reinício sem confirmação fantasma.

Lógica: `.testes/qa-confirmacoes-logica-d`. Percursos:
`.testes/qa-confirmacoes-feira-a` e `.testes/qa-confirmacoes-livre-b`.
Capturas e relatório de navegador: `.testes/browser/atos-*.png` e `atos-qa.json`.

Backup dos fontes anteriores:
`C:/fabrica/.backups/antes-confirmacoes-20261105-091051.zip`.
O projeto GameMaker ativo segue sendo o apontado pelo workspace.

Edge/HTML5: introdução lida e pulada sem consumir tempo, seis mensagens de
confirmação com botão, confirmação por Enter, contagem congelada durante a
leitura, produção, entrega e encerramento aos 300 segundos. Zero erros JS.
Logs e capturas: `docs/evidencias-confirmacoes-20261105`.
O QA posiciona o ator e adianta o relógio apenas no navegador de teste.

## Publicação

[Site atualizado](https://fabrica-salgados-mundo-senai.casottimarinetti.chatgpt.site):
versão 7, publicação confirmada com status `succeeded`, acesso público preservado.
Fonte publicada: `1ce2e02e7bfd7e900cf38c45847d072d5f7530b9`.
Registro: `C:/fabrica/entregas/publicacao-confirmacoes.json`.
