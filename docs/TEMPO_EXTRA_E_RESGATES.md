> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Tempo extra e resgates — 05/11/2026

JOGAR começa com 300 segundos, depois da introdução. Os três quizzes opcionais
agora dão +120 segundos por acerto, uma vez por pergunta, em vez de dinheiro.
Leitura e feedback pausam relógio, manutenção e preparo. O modo completo,
sem limite em segundos, preserva o bônus financeiro existente.

Quando o relógio chega a zero, uma pergunta de resgate bloqueia as operações
sem encerrar o estado da partida. Acerto acrescenta +120 segundos ao limite,
sem apagar o tempo decorrido, e exige confirmação para retomar. O pedido,
preparo, estoque, mochila e caixa permanecem no mesmo estado. Cada resgate
usa uma pergunta diferente do banco de dez. Há no máximo dez resgates por
rodada: depois do último tempo extra, encerra sem uma 11ª pergunta.
Erro ou saída voluntária encerra a rodada, com explicação e confirmação.

Botões aceitam mouse; respostas de resgate também usam 1, 2 e 3. Enter ou
Espaço confirmam o tempo ganho. Uma resposta não pode ser enviada duas
vezes. Decisões de gestão continuam com suas consequências próprias.

Validação: 513 verificações no Runner oficial (225 da feira), sem falhas;
percurso completo da feira com 39 etapas; verificação de 79 arquivos GML.
Testes cobrem todos os dez ciclos, esgotamento, erro, saída, tentativa
inválida, idempotência, bônus do quiz, congelamento de recursos e entrega
após resgatar um preparo em andamento.

Evidências locais: `.testes/qa-extra-final`, `.testes/qa-extra-percurso`.
Exportação oficial HTML5: `build/html5-20261105-093639`.

QA no Edge: fluxo completo com quiz (+120s sem crédito financeiro),
resgate durante um preparo, entrega preservada, dez perguntas distintas,
alternância entre mouse e teclas 1/2/3, confirmação via botão e Enter,
encerramento no próximo zero depois do décimo resgate, erro e saída
voluntária. Nenhum erro JavaScript registrado. Os saltos do relógio e o
posicionamento do ator foram instrumentados apenas no navegador de teste;
respostas e confirmações usaram entradas reais. Evidências em
`docs/evidencias-tempo-extra-20261105`.
