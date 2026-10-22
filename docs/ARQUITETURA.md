# Arquitetura — exploração da fábrica

Projeto existente: `BLANK GAMEFabricaDeSalgados.yyp`, GameMaker/GML Code.
44 recursos: **10 salas, 7 objetos, 26 scripts, 1 sprite**. Os recursos novos
foram criados pelos escritores do GMSync e normalizados/abertos pelo ProjectTool
oficial. Não houve recriação do projeto. Room1 e opções originais foram preservadas.

## Salas e ciclo de vida

| Ordem | Sala | Controlador local | Papel |
| --- | --- | --- | --- |
| 1 | rm_menu | obj_menu | Nova configuração ou continuar em memória. |
| 2 | rm_parametros | obj_parametros | 51 parâmetros, receitas, validação e padrões. |
| 3 | rm_corredor | obj_exploracao | Caminho entre as três portas. |
| 4 | rm_comercial | obj_exploracao | Ofertas com Marta; entrega manual no balcão. |
| 5 | rm_producao | obj_exploracao | Depósito da mochila e bancada de receitas. |
| 6 | rm_estoque | obj_exploracao | Cinco prateleiras, retirada e computador de compras. |
| 7 | rm_dashboard | obj_resultados | Seis abas, parcial/final, diário e reinício. |
| 8 | rm_fabrica | obj_fabrica | Protótipo V0.1 preservado, fora do fluxo normal. |
| 9 | rm_resultados | obj_resultados | Sala anterior preservada. |
| 10 | Room1 | Original | Recurso original preservado. |

Cada sala contém obj_game primeiro: persistente, destrói a própria duplicata e
cria global.jogo apenas se necessário. Os quatro ambientes físicos também têm
obj_exploracao e obj_cozinheiro, locais e não persistentes. Somente os dados da
sessão atravessam salas; não se acumulam atores, câmeras ou controladores.

obj_exploracao: Create prepara mapa/câmera; Step processa E, Esc e cliques;
Draw normal desenha o mundo; Draw GUI desenha HUD/painéis; CleanUp libera câmera
e desativa views. obj_cozinheiro: Create restaura posição válida; Step aplica
entrada, colisão, animação e câmera; seu Draw é suprimido porque o controlador
ordena pessoas e móveis por profundidade. Arquivos em objects/<nome>/ e rooms/<nome>/.

Câmera nativa 640×360, ampliada para 1280×720 sem filtragem. Ambientes são maiores
que a view. U/V são coordenadas do piso: X=600+(U−V)×18, Y=140+(U+V)×9.
Colisão circular nos pés contra retângulos U/V dos móveis/NPCs e limites do piso;
subpassos até .12 evitam atravessamentos. O mesmo mapa desenha e define colisão.
Profundidade usa U+V/base do móvel. Portas são plataformas amarelas; E troca salas.

## Scripts

Cada script tem .gml e .yy em scripts/<nome>/, registrados no .yyp.

| Script | Responsabilidade |
| --- | --- |
| scr_estado | Sessão, fases, padrões, pausa e roteamento. |
| scr_produtos | Catálogo central, receitas, custos, preços e tempos fictícios. |
| scr_estoque | Consulta e ajuste inteiro, sem saldo negativo. |
| scr_compras | Compra paga, trânsito, recebimento único; presença no computador. |
| scr_producao | Validação pura; rotinas V0.1 preservadas e bloqueadas no modo físico. |
| scr_pedidos | Ofertas únicas, aceite, fila, entrega no balcão e atrasos. |
| scr_tempo | Despacha relógio para o ciclo físico quando em exploração. |
| scr_financas | Movimentos por referência única e resultado de caixa. |
| scr_indicadores | Pedidos, produção, caixa e atrasos reais. |
| scr_operacoes | Consultas e suporte aos controladores anteriores. |
| scr_parametros | 51 campos, receitas, validação e interface paginada. |
| scr_interface | Fonte própria com acentos, cores e componentes GUI. |
| scr_isometria | Projeção, pessoas e mobiliário GML. |
| scr_cenario | Cenário estático do menu e protótipo anterior. |
| scr_fabrica_interface | Interface V0.1 mantida para regressão. |
| scr_pedagogia | Casos por evento, diário e balões reflexivos. |
| scr_dashboard | Agregações reais, estoques por local, seis abas e fórmulas. |
| scr_mundo | Mapas, alvos E, colisão, movimento, câmera, posições e portas. |
| scr_logistica | Estoques físicos, retirada, depósito, produção, objetivos e relógio. |
| scr_exploracao_interface | HUD, ajuda, hit tests e painéis de proximidade. |
| scr_testes_simulacao | Auditoria e regressão de regras/controladores. |
| scr_testes_v01 | Regressão de aprendizado e driver histórico opcional. |
| scr_testes_exploracao | 83 verificações novas e driver da partida física. |

## Estado compartilhado

`global.jogo` é único. `exploracao_iniciar` adiciona campos somente uma vez,
preserva estado nas transições e é chamado ao iniciar pelos parâmetros.

| Campo | Uso |
| --- | --- |
| estoque.materias_primas | Ingredientes no depósito; compras chegam aqui. |
| carregados | Mochila; limite agregado 80 unidades fictícias. |
| cozinha | Ingredientes depositados; única origem da receita física. |
| estoque.produtos | Salgados prontos; transporte destes é abstraído. |
| exploracao | Setor, posições U/V/face por sala, limite e transferências. |
| pedidos / compras | Históricos, IDs únicos, snapshots e pendências. |
| producao | Lotes, insumos/custos e capacidade diária usada. |
| financas | Capital, saldo, receitas, pagamentos e referências. |
| historico_dias / diario | Dias fechados; decisões com data/ação/consequência. |

Transferências conservam depósito+cozinha+mochila. Produção valida todos os efeitos,
consome cozinha e gera acabados. APIs de compra, aceite, retirada, depósito,
produção e entrega verificam posição/setor, não apenas painel aberto. Pausa e fim
bloqueiam mutações. IDs/referências impedem dupla geração, pagamento ou entrega.
A auditoria soma os três locais e confere insumos, produtos, caixa e unicidade.
Parâmetros são clonados por sessão. Arrays de eventos são reatribuídos explicitamente.
Testes não executam no carregamento; o harness injeta chamadas só em cópias.

## Compatibilidade e expansão

Sem campo exploracao, o núcleo mantém regras V0.1 para recursos/testes históricos.
O fluxo normal nasce em rm_corredor e fecha em rm_dashboard, sem oferecer acesso
ao painel remoto antigo. Agendamento legado é recusado no modo físico.

Novos produtos seguem o catálogo e seletores. Novos ingredientes exigem também
prateleira/alvo em mundo_criar e ajuste dos validadores/testes do catálogo padrão.
Novos móveis precisam de volume e alvo fora da colisão. Registre recursos pela
IDE/GMSync e confirme .yy/.yyp antes de publicar.

## História guiada

scr_missoes, scr_historia e scr_testes_missoes foram adicionados. Estado fica em
global.jogo.missoes; não há novo singleton. Etapas, guardas e eventos confirmados
controlam o avanço; fila de falas/respostas persiste entre salas. Produção guiada
é confirmada após 90 frames; checkpoint serializa somente dados, sem referências
a instâncias. Leia MISSOES_E_HISTORIA.md para contratos e extensão por alunos.
O modo livre e as rotinas de regressão continuam sem estado de missões.
