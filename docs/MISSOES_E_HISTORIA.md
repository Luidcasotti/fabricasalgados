# Missões, história e aprendizagem

A História guiada é o modo padrão de uma sessão nova. Na tela de parâmetros,
alterne HISTÓRIA GUIADA / MODO LIVRE. Alternar reaplica o preset do modo; depois
edite os valores. O modo livre preserva a exploração e a simulação anteriores.
Arte, personagens e lógica permanecem próprios, em GameMaker/GML.

## Sequência e ações verificadas

| Etapa identificável | O que a conclui |
| --- | --- |
| INTRO | Confirmar as três falas do gerente da Sabor & Gestão. |
| COMERCIAL / ANALISAR | Interagir por E com Marta, ler orientação e decidir. |
| CONSULTAR_BANCADA | Interagir com a bancada e identificar falta real de frango. |
| BUSCAR_FRANGO | Retirar o ingrediente da prateleira correta, sem exceder saldo. |
| DEPOSITAR_FRANGO | Transportar e depositar até completar a receita local. |
| COZINHAR | Concluir o preparo das 10 coxinhas, com consumo real. |
| ENTREGAR | Confirmar entrega integral no balcão do Comercial. |
| DESAFIO | Analisar 10 bolinhas de queijo, sem queijo no estoque geral. |
| DESAFIO_ENTREGAR | Produzir e entregar o segundo pedido após o planejamento. |
| RESULTADOS / CONCLUIDA | Consultar o dashboard após resolver o desafio. |

Entrar numa sala, abrir menu ou apenas se aproximar não conclui a missão.
Objetivo fica no HUD. Uma seta indica a porta/alvo correspondente ao próximo passo;
O que preciso fazer? informa missão, ação, setor e motivo, com repetição de falas.
Conversas aguardam CONTINUAR; E/Esc não pulam leitura. Perguntas exigem uma
alternativa e mantêm sua explicação até continuar, sem punição ou Game Over.

## Primeiro pedido sempre viável

O preset mantém estoque inicial de frango suficiente para 10 coxinhas. Os demais
insumos desse lote são transferidos do depósito para a cozinha na preparação,
com registro e conservação. Só o frango falta localmente. Não são criados itens.
O relógio não avança antes da primeira entrega, evitando expiração do tutorial.

Validação guiada exige catálogo com coxinha/frango e bolinha/queijo, receita
inicial completa no estoque, capital para seu custo variável e capacidade para
o lote. Queijo inicial deve ser zero, para o segundo caso, e duração deve ser
pelo menos prazo do queijo + 2 dias. Configurações diferentes podem usar LIVRE.
A validação do núcleo continua aplicável. Nada é corrigido silenciosamente.

A produção guiada mostra barra de 90 frames (1,5 s na taxa de 60 FPS). Somente
no final revalida e consome receita/custo/capacidade, gerando um lote único.
Pausa congela a barra; cancelar antes do fim preserva materiais e dinheiro.

## Segundo pedido: escolhas e consequências

Com padrões: 10 bolinhas, 20 porções de queijo ausentes, reposição de 2 dias,
prazo original dia 2. A missão não compra nem entrega automaticamente.

- **Aceitar e comprar:** pedido vira compromisso; compra paga no Estoque chega
  no dia 3. Entrega no dia 3 tem atraso de 1 dia, registrado e explicado.
- **Negociar e aceitar:** proposta visível considera chegada dos materiais que
  faltam e mais um dia de organização (dia 4 no preset). Compra continua manual.
  Prazo original e combinado ficam no pedido; só há uma negociação.
- **Recusar:** preserva recusa, evita compromisso e abre mão da receita. A história
  pode terminar após essa escolha; não exige aceitar uma encomenda inviável.

Negociação recusa proposta fora do período ou lote maior que a capacidade diária.
Mesmo um prazo estimado viável exige comprar, esperar, retirar e transportar.
Falta de dinheiro ou escolha inadequada não obriga a continuar sem saída:
Reiniciar missão restaura um checkpoint com confirmação explícita.

Há dois checkpoints: início da história e início do segundo capítulo, após a
primeira entrega. Reiniciar capítulo restaura juntos caixa, materiais, compras,
pedidos, data e diálogos. Ações posteriores são desfeitas; não é uma reposição
mágica. Uma primeira recusa também permite Novo pedido guiado no Comercial:
cria outra oferta única, mantendo a recusada no histórico. Reiniciar a sessão
inteira continua disponível pelo dashboard/parâmetros.

## Perguntas e evidências

Três perguntas por evento, no máximo uma ocorrência de cada por capítulo:
conferir estoque, risco de aceite sem ingredientes e excesso de compra. Não
há disparo periódico nem questionário a cada troca de sala. Todas as alternativas
têm explicação; respostas erradas não bloqueiam a missão nem alteram finanças.
Repetir uma fala não dispara novamente uma pergunta já respondida.

O dashboard mantém seis abas da simulação e acrescenta APRENDIZAGEM: problemas
registrados, ações praticadas e respostas. Mostra pedidos, compras, receitas e
resultado de caixa calculados dos mesmos movimentos. Evidências de prática não
são nota, percentual de domínio ou certificação de que o aluno aprendeu.
História pode encerrar antes do limite de dias ao completar as ações. O dia
aberto é fechado uma vez, sem avançar data ou contar capacidade duas vezes.

## Arquivos e expansão por alunos

- scr_missoes: enum, validação, estado, eventos, guardas, pedidos dos casos,
  proposta de prazo, checkpoint e finalização.
- scr_historia: catálogo de falas/perguntas por ID, fila, respostas, guia dinâmico,
  seta, retratos provisórios, barra e UI de ajuda/reinício/aprendizagem.
- scr_testes_missoes: verificações opcionais e percursos reais dos três ramos.
- Integrações pequenas em parâmetros, exploração, personagem, compras, pedidos,
  produção, mundo e dashboard. A lógica econômica continua nos módulos anteriores.

Para nova fala, acrescente ID em historia_conteudo e enfileire por evento.
Para pergunta, forneça alternativas, índice correto e explicação de cada escolha.
Para nova missão, inclua etapa, guarda, evento de sucesso, orientação e teste;
não avance por room==... ou por um temporizador. Os dados da missão ficam em
global.jogo.missoes, sem novo objeto persistente. Salas/resources anteriores
foram preservados; somente três scripts novos foram registrados no .yyp.
