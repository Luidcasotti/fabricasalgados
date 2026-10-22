# Arquitetura — Fábrica de Salgados

Projeto original preservado: `BLANK GAMEFabricaDeSalgados.yyp`.
GameMaker IDE 2026.0.0.16, runtime 2026.0.0.23; lógica e desenho inteiramente GML.
São **29 recursos**: cinco salas, cinco objetos e dezenove scripts, todos com
metadados .yy registrados no .yyp. Room1 e as opções originais permanecem intactas.

## Salas e controladores

| Ordem | Sala | Controlador | Responsabilidade |
| --- | --- | --- | --- |
| 1 | rm_menu | obj_menu | Nova configuração ou continuação em memória. |
| 2 | rm_parametros | obj_parametros | Editor paginado de parâmetros e receitas; validação ao iniciar. |
| 3 | rm_fabrica | obj_fabrica | Cenário, HUD, compras, encomendas, planos e avanço manual. |
| 4 | rm_resultados | obj_resultados | Resultado de caixa e indicadores de entrega/produção. |
| 5 | Room1 | Original | Sala original preservada, fora do fluxo principal. |

Cada sala nova cria obj_game primeiro e o controlador local depois. obj_game
é persistente, destrói duplicatas e inicializa uma sessão somente quando ainda
não existe. Trocar de sala não reinicia os dados. Os controladores locais não
são persistentes. A GUI usa 1280×720 e preserva os recursos de sala originais.

Arquivos: `rooms/<nome>/<nome>.yy`, `objects/<nome>/<nome>.yy` e eventos GML.
Create_0 inicializa, Step_0 recebe entrada e Draw_64 desenha a GUI. Menu e fábrica
possuem CleanUp_0 (evento 12/0) para liberar superfícies. A liberação tolera
encerramento antes do fim da inicialização. O clique de troca de sala precisa
ser solto antes de ativar uma ação da sala seguinte.

## Scripts

Cada script fica em `scripts/<nome>/<nome>.gml` com seu .yy; declara funções
sem executar a simulação no carregamento.

| Script | Responsabilidade |
| --- | --- |
| scr_estado | FaseJogo, parâmetros padrão, cópia independente e criação/reinício da sessão, transições de sala. |
| scr_produtos | Catálogo central de cinco insumos e três produtos, receitas, preços, capacidade e custos fictícios. |
| scr_estoque | Criação e consulta de saldos; ajustes inteiros limitados, sem saldo físico negativo. |
| scr_compras | Pagamento, compras em trânsito, prazo, próxima chegada e recebimento único. |
| scr_producao | Cálculo puro de plano, reservas de insumos/capacidade/caixa, agendamento, cancelamento e execução diária. |
| scr_pedidos | Geração única por dia/produto, aceite/recusa, fila por aceite, entregas e atualização de atrasos. |
| scr_tempo | simulacao_avancar_dia: chegadas → produção → entregas → prazos/ofertas → resumo. |
| scr_financas | Livro de movimentos por referência única, entradas/saídas, receitas, compras, custos variáveis, caixa livre. |
| scr_indicadores | Consultas puras: caixa, resultado, pontualidade, atrasos, produção e produtos prontos. |
| scr_operacoes | Consultas de interface para ofertas/fila/histórico, planos e aviso de estoque mínimo livre. |
| scr_parametros | Validação, descritores editáveis e interface paginada de configuração/receitas. |
| scr_interface | Tema, fonte bitmap original com acentos, texto, botões, áreas e liberação de entrada. |
| scr_isometria | Projeção e inversa, prismas, mobiliário e quatro pessoas por primitivas GML. |
| scr_cenario | Dados dos setores, ordenação, desenho em superfície 640×360 ampliada 2×. |
| scr_fabrica_interface | Layout, prioridade de cliques, seletores, painéis de ações e resumo diário. |
| scr_pedagogia | Diário, balões e catálogo de casos por evento, sem alterar economia. |
| scr_dashboard | Agregação real, fórmulas, reflexão e seis abas da análise final/parcial. |
| scr_testes_v01 | Testes de período, métricas, feedback e driver opcional de partida. |
| scr_testes_simulacao | Auditoria de conservação e testes opcionais; não executam na sessão normal. |

## Estado compartilhado e registros

`global.jogo` é a sessão. `global.visual` contém somente tema/fonte.
As funções de domínio recebem a sessão ou o subsistema explicitamente.
Funções de interface da fábrica e parâmetros usam o contexto de seus objetos;
não devem ser chamadas a partir de outro controlador sem esse contexto.

| Campo da sessão | Conteúdo |
| --- | --- |
| parametros / catalogo | Cópia validada de números iniciais e dados configuráveis; não alterada durante a sessão. |
| dia / fase | Dia atual e tela atual. |
| estoque | Arrays de matérias-primas e produtos, com IDs e saldos físicos. |
| compras | Histórico completo: snapshot de custo, quantidade, pagamento, chegada e status. |
| pedidos | Histórico único, com chave dia/produto, preço contratado, prazo, aceite, entrega e atraso. |
| producao | Planos com snapshots/reservas, lotes executados, capacidade/unidades diárias e total acumulado. |
| financas | Capital, saldo, totais por categoria e movimentos identificados. |
| historico_dias / ultimo_resumo | Eventos pagináveis e resumo de cada avanço. |
| IDs e ultimo_dia_gerado | Sequências locais e proteção contra geração repetida. |
| avancando | Trava síncrona contra reentrada do processamento diário. |

Não se apagam compras, pedidos ou planos por conclusão/cancelamento/vencimento.
Listas da GUI são filtros dos registros. Arrays de eventos são devolvidos
explicitamente entre etapas para respeitar a semântica de cópia de arrays GML.

## Contratos e invariantes

- Quantidades físicas são inteiras, de zero a um milhão por item. Operações
  exigem quantidade positiva, IDs conhecidos e validam todos os efeitos antes de alterar.
- Agendamento não consome estoque; reserva insumos, capacidade do próximo dia
  e caixa do custo variável. Compras em trânsito não são utilizáveis no plano.
- Cancelamento libera reservas sem estornar um custo que ainda não foi pago.
- Execução e entrega revalidam recursos, e status/referências impedem duplicação.
- Compra congela o custo e o dia de chegada; pedido congela o preço/prazo;
  plano congela receita, capacidade e custos calculados.
- Dinheiro usa centavos inteiros. Resultado de caixa não é receita nem lucro contábil.
- Auditoria confere: inicial + chegadas − consumo = estoque de insumos;
  produção − entregas = produtos; inicial + movimentos = saldo em caixa.

Regras completas e exemplos numéricos: [REGRAS_SIMULACAO.md](REGRAS_SIMULACAO.md).

## Expansão e ferramentas

Acrescente produtos/ingredientes com IDs únicos no catálogo e inicialize uma nova
sessão. As receitas referenciam ingredientes existentes sem repetição. O editor
gera campos e páginas a partir dos dados, e os seletores da fábrica percorrem
os arrays; não há limite fixo de três botões de produto ou quatro linhas de estoque.
Use nomes de exibição curtos para manter a leitura dos painéis.

Mantenha regras nos scripts de domínio. Para sprites definitivos, preserve as
âncoras e o hit test descritos em [VISUAIS.md](VISUAIS.md). Nenhum asset externo
foi adicionado nesta etapa. O layout isométrico foi preservado.

Metadados novos foram criados pelos escritores do GMSync 0.1.0 e normalizados
pelo ProjectTool da IDE com seus tipos locais. GMSync lê o projeto; não é uma
dependência de execução. Stitch permanece desabilitado no lançador da sessão.
Python em tools é somente automação de desenvolvimento; nenhum código Python,
JavaScript ou C# participa da lógica do jogo.

Verificações reproduzíveis em [VALIDACAO.md](VALIDACAO.md).

## Extensão V0.1

global.jogo acrescenta duracao_dias nos parâmetros e, na sessão, dias_processados,
encerrado, pausado, diario, feedbacks e fala_atual. Guardas de domínio impedem
ações durante a pausa ou após o fim. A rotina diária encerra depois do número
configurado de processamentos, sem novas ofertas no último dia. A interface
encaminha para rm_resultados, que agora é o dashboard completo.

dashboard_calcular usa registros de pedidos, lotes, estoque, movimentos e
histórico de dias. Proporções sem denominador retornam undefined e são formatadas
como não aplicável. Dashboard e feedback final são consultas sem efeitos.
O catálogo pedagógico contém funções fora do estado serializado; as falas e
o diário armazenam somente dados. Professores podem ampliar predicados/mensagens
conforme MANUAL_DO_PROFESSOR.md. Casos não cobram nem retiram recursos.

O modo --partida substitui eventos Step apenas na cópia de teste e navega pelas
salas reais. O jogo normal nunca inicia o driver nem executa as suítes sozinho.
