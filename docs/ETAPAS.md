# Etapas e evidências — 21/10/2026

Fuso: America/Rio_Branco. Projeto real:
`C:\Users\Luid Casotti\GameMakerProjects\fabrica\BLANK GAMEFabricaDeSalgados\BLANK GAMEFabricaDeSalgados.yyp`.

## Ambiente e arquitetura preservados

- GameMaker IDE 2026.0.0.16 e runtime 2026.0.0.23 instalados e executados.
- VS Code, Codex e GMSync 0.1.0 disponíveis; workspace aponta para a raiz real.
- Stitch desabilitado na sessão dedicada por incompatibilidade com o formato.
- Git inicializado em main. Não há commit: nome/e-mail reais ainda não configurados.
- Room1 e os quatro arquivos originais de opções preservados por SHA-256.
- Ordem: rm_menu → rm_parametros → rm_fabrica → rm_resultados; Room1 mantida ao final.

## Primeira versão visual jogável

- Cenário isométrico original em GML, com três pisos/setores e mobiliário próprio.
- Gestor, atendente, estoquista e cozinheiro estáticos.
- Clique no piso, etiquetas ou botões grandes abre painéis na própria fábrica.
- Fechamento por X, clique fora e ESC; abas trocam de setor sem mudar de sala.
- HUD em português: dia, dinheiro, encomendas, capacidade e avisos.
- Novo jogo, parâmetros, fábrica, resultados, menu e continuação por mouse.
- Ciclo mínimo de receber encomenda, produzir cinco, entregar e repor ingredientes.
- Superfícies recriadas quando necessário e liberadas em Clean Up.
- Cinco scripts novos registrados pelo GMSync, normalizados pelo ProjectTool oficial.
  Total: 22 recursos (5 salas, 5 objetos, 12 scripts), com metadados e eventos conferidos.

## Verificação

Compilação Windows/VM pelo Igor e execução pelo runtime instalado.
Em cópia descartável, **64 verificações GML** de domínio e despacho de cliques
passaram (`FDS_TESTES_OK: 64`): estado, catálogo, finanças, estoque, pedidos,
planejamento puro, consumo real, entrega, reposição, falhas sem alterações
parciais, limites de capacidade/pedidos, inversa isométrica, áreas dos setores,
troca de produto, abertura/fechamento e prioridade dos painéis.

Também houve inspeção visual e cliques na janela real: novo jogo, ajuste de
capacidade 100 → 110, entrada na fábrica, setores, receber, produzir, entregar,
repor, resultados e retorno. Conferidos X e ESC. O estado da sessão é mantido
entre salas. Não foi realizado teste de exportação/instalador, YYC ou outras plataformas.

Registros em `C:\fabrica\.backups`:

- `antes-visual-isometrico.zip`: cópia anterior a esta implementação.
- `visual-compile.log`: compilação do projeto principal.
- `visual-test-compile.log`, `visual-test-stdout.log`, `visual-test-stderr.log`:
  teste em cópia descartável; nenhuma função de teste está no projeto principal.
- `visual-runtime.log`, `visual-runtime-stderr.log`: execução da janela real.
- `teste-01-menu.png`, `teste-03-capacidade.png`, `teste-04-fabrica.png` e demais
  capturas numeradas: inspeção da interface e navegação.
- `validacao-visual.json`: referências, eventos e integridade dos arquivos originais.

## Abertura final e integração

Projeto reaberto na IDE: SUCCESSFUL LOAD AND LINK e OnProjectLoaded confirmados
em visual-abertura-ide.log. VS Code reaberto no workspace real, com Stitch
desabilitado; GMSync confirmou Ready com 5 objetos, 12 scripts e 5 salas,
registrado em visual-gmsync.log. Os avisos conhecidos de atualização de pacotes,
Device Manager e layout da instalação não impediram a carga do projeto ou sua
compilação/execução. Não são erros de referência de recursos do jogo.

Cópia final: projeto-visual-isometrico-verificado.zip, com manifesto SHA-256,
em C:\fabrica\.backups. O ZIP foi relido e comparado aos arquivos de origem.

## Limites e próximos passos

O dia permanece em 1; produção é instantânea; funcionários são elementos visuais.
Não há salvamento, passagem de dias, animações complexas, IA ou filas de máquinas.
Valores e receitas são didáticos. O caixa não é apresentado como lucro contábil.

Próximas decisões: avaliar a clareza do ciclo com alunos, definir encerramento
e passagem do dia, adaptar paginação ao expandir o catálogo, e substituir a
arte provisória conforme [VISUAIS.md](VISUAIS.md). Criar um commit após configurar
a identidade real do autor. Backups não dependem desse commit.
