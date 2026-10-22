# Arquitetura — Fábrica de Salgados

Protótipo visual em GameMaker/GML Code, verificado em 21/10/2026.

## Projeto preservado

Raiz: `C:\Users\Luid Casotti\GameMakerProjects\fabrica\BLANK GAMEFabricaDeSalgados`.
Arquivo principal: `BLANK GAMEFabricaDeSalgados.yyp` nessa raiz.
O projeto não foi recriado nem renomeado. O projeto provisório em C:\fabrica
não é o alvo do desenvolvimento. O workspace de C:\fabrica aponta para a raiz real.

IDE 2026.0.0.16, runtime 2026.0.0.23, alvo verificado Windows/VM.
São **22 recursos** registrados no .yyp: cinco salas, cinco objetos e doze scripts.
Cada recurso tem seu .yy. Metadados novos foram criados pelos escritores do
GMSync 0.1.0 e normalizados pelo ProjectTool 2024.14.165 da instalação local,
usando os tipos da própria IDE. Toda lógica e desenho do jogo são GML.

## Salas e controladores

| Ordem | Sala | Objeto local | Responsabilidade |
| --- | --- | --- | --- |
| 1 | rm_menu | obj_menu | Novo jogo e continuação da sessão em memória. |
| 2 | rm_parametros | obj_parametros | Capacidade diária e entrada na fábrica. |
| 3 | rm_fabrica | obj_fabrica | Cenário isométrico, HUD, cliques e painéis dos setores. |
| 4 | rm_resultados | obj_resultados | Consulta de indicadores e retorno à fábrica/menu. |
| 5 | Room1 | Original | Recurso original preservado, fora do fluxo principal. |

Cada sala nova tem obj_game primeiro na ordem de criação, seguido de seu
controlador local. **obj_game** é persistente, destrói duplicatas e inicializa
global.jogo somente quando necessário. A GUI e a janela usam 1280 × 720;
as dimensões originais dos recursos de sala foram preservadas.

Arquivos: `rooms/<nome>/<nome>.yy` e `objects/<nome>/`.
Os controladores locais usam Create_0.gml, Step_0.gml e Draw_64.gml (Draw GUI).
obj_menu e obj_fabrica também usam **CleanUp_0.gml**, registrado como evento
12/0, para liberar a superfície do cenário. A limpeza tolera encerramento
antes da inicialização completa. obj_game usa somente Create_0.gml.

O estado local de um painel não persiste entre salas. Estoque, pedidos,
produção e dinheiro persistem em global.jogo. O próximo clique só é aceito
após soltar o botão que provocou uma troca de sala.

## Scripts e responsabilidades

Todos ficam em `scripts/<nome>/<nome>.gml`, acompanhados do respectivo .yy.
Carregar um script apenas declara funções; a inicialização é explícita.

| Script | Responsabilidade / funções principais |
| --- | --- |
| scr_estado | Estado, parâmetros, reinício e navegação: jogo_criar, jogo_novo, jogo_ir_para, enum FaseJogo. |
| scr_produtos | Catálogo central de produtos, ingredientes, receitas e preços; produto_obter, ingrediente_obter. |
| scr_estoque | Saldos e ajustes inteiros validados; estoque_quantidade, estoque_ajustar. |
| scr_pedidos | Criação de pedidos e contagem de status; pedido_adicionar, pedidos_contar_status. |
| scr_producao | Planejamento puro de ingredientes, capacidade e custo; producao_planejar. |
| scr_financas | Movimentação em centavos, saldo e formatação; financas_registrar, financas_formatar. |
| scr_indicadores | Consulta pura dos indicadores; indicadores_calcular. |
| **scr_operacoes** | Ciclo mínimo: fabrica_receber, fabrica_produzir, fabrica_entregar, fabrica_repor e avisos. |
| **scr_interface** | Tema, fonte bitmap original com acentos, textos, botões, áreas e liberação da entrada. |
| **scr_isometria** | Projeção/inversa, prismas, mobiliário e quatro personagens desenhados por primitivas. |
| **scr_cenario** | Dados dos três setores e 17 elementos; ordenação, desenho e superfície 640 × 360 ampliada 2×. |
| **scr_fabrica_interface** | Layout compartilhado pelos desenhos/cliques, HUD, painéis e despacho de ações. |

O domínio recebe o jogo ou seu subsistema por argumento. As funções de interface
da fábrica trabalham no contexto de obj_fabrica; fabrica_clicar e fabrica_notificar
acessam seus campos locais. Não devem ser chamadas a partir de outro controlador.
global.visual guarda somente tema/fonte e não contém estado econômico.

## Estado inicial e dados

| Dado | Valor |
| --- | --- |
| Dia e fase | 1 e MENU |
| Caixa | 100000 centavos = R$ 1.000,00 |
| Capacidade | 100 unidades; ajuste inicial de 10 a 500, passo 10 |
| Ingredientes | Massa 120, frango 60, queijo 100, óleo 200 porções |
| Produtos prontos | Zero |
| Pedidos, lotes e movimentos | Vazios |
| Próximo pedido | ID 1 |

Produtos: coxinha, pastel e bolinha de queijo. Custos por porção em centavos:
massa 60, frango 80, queijo 70, óleo 20. Preços de venda em centavos: coxinha
600, pastel 500, bolinha de queijo 400. São dados didáticos; não são receitas
culinárias ou preços de mercado. O estoque inicial já pertence à fábrica.

## Ciclo demonstrativo e contratos

- **Receber**: cria pedido de cinco unidades, alternando produtos do catálogo;
  no máximo três pendentes. Não movimenta estoque nem dinheiro.
- **Planejar**: producao_planejar só calcula, sem efeitos. Valida produto,
  quantidade, receita, capacidade e ingredientes.
- **Produzir**: valida o plano e espaço, consome os insumos, soma cinco produtos
  prontos e registra o lote com custo em centavos. Não debita dinheiro: os
  ingredientes são pagos na compra, evitando cobrar o mesmo custo duas vezes.
- **Entregar**: atende o pedido pendente mais antigo se houver produtos prontos;
  recebe o valor combinado, baixa o estoque e marca o pedido como atendido.
- **Repor**: valida espaço e dinheiro, paga e acrescenta 20 porções de cada
  ingrediente do catálogo. Custo inicial R$ 46,00.
- Operações recusadas retornam ok=false e mensagem sem alterações parciais.
  Estoque não pode ficar negativo nem ultrapassar um milhão por item.
- Indicadores são calculados a partir da sessão. Entradas menos saídas são
  **variação do caixa**, sem serem apresentadas como lucro contábil.

O dia fica em 1. Funcionários são representações visuais estáticas. Não há
filas de trabalho, duração de produção, IA, passagem de dias, save/load,
salários, contratação ou simulação contábil completa nesta etapa.

## Expansão pelos alunos

Acrescente dados em produtos_catalogo_criar usando IDs únicos, ingredientes
existentes e quantidades/custos inteiros válidos. Não duplique ingredientes
na mesma receita. Comece uma nova sessão para reconstruir os saldos.
As operações percorrem os dados; produtos não precisam de recursos GameMaker
individuais. O painel atual tem três espaços de produto e quatro linhas de
ingredientes: adapte o layout/paginação ao ampliar o catálogo.

Mantenha regras em scripts de domínio e visuais na interface. Para alterar
mobiliário e substituir primitivas por sprites, siga [VISUAIS.md](VISUAIS.md).
O hit test dos setores usa a inversa da mesma projeção usada no desenho.

## Ferramentas e verificação

GMSync 0.1.0: [Marketplace](https://marketplace.visualstudio.com/items?itemName=atennebris.gmsync),
[código-fonte](https://github.com/Atennebris/GMSync), publisher atennebris;
origem e manifesto conferidos na preparação do ambiente. Não é dependência
do jogo. A ponte TCP não foi instalada. Associações GML/YY/YYP estão em
.vscode/settings.json, com formatação automática de metadados desativada.

Stitch 1.81.0 permanece desabilitado no lançador da sessão devido à
[incompatibilidade reportada com a IDE 2026.0.0.16](https://github.com/bscotch/stitch/issues/306).
Use ABRIR_NO_VSCODE.cmd. Não foi certificado IntelliSense semântico completo.

Carga nativa, compilação, execução, cliques, referências e integridade dos
arquivos originais foram verificados. Detalhes e evidências em [ETAPAS.md](ETAPAS.md).
