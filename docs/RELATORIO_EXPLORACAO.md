# Entrega — reformulação da jogabilidade

A fábrica agora é explorável em salas reais. O cozinheiro caminha, contorna móveis,
interage perto dos alvos e transporta ingredientes do almoxarifado à cozinha.
Sessão, parâmetros e aprendizado anteriores foram preservados.

## Arquivos e responsabilidades

- Salas novas: rm_corredor, rm_comercial, rm_producao, rm_estoque, rm_dashboard.
- Objetos novos: obj_exploracao (mundo/GUI/entrada/câmera) e obj_cozinheiro
  (posição, movimento, direção e animação), com .yy e eventos GML.
- Scripts novos: scr_mundo, scr_logistica, scr_exploracao_interface,
  scr_testes_exploracao, com .yy e .gml registrados.
- Sprite próprio spr_cozinheiro_temp: oito quadros com .yy e PNGs de quadro/camada.
- Adaptados: menu, parâmetros, estado/roteamento, projeção, compras, pedidos,
  produção, relógio, pedagogia, dashboard e auditoria.
- Ferramentas verificar_projeto.py/verificar_simulacao.py; documentação e capturas.

Modo físico bloqueia ações remotas e execução automática de lotes/entregas.
Dashboard soma os três estoques e inclui capacidade do dia aberto sem duplicá-lo.
Room1, opções originais e recursos V0.1 permanecem; tag v0.1 preserva etapa anterior.

## Funcionamento e verificação

WASD/setas, quatro direções, animação simples, colisões móveis/NPCs/bordas,
câmera nativa, portas/retorno, posição persistente, E, HUD, mochila, receitas,
retiradas, depósito, compras pagas com prazo, produção/entrega manuais,
aceite/recusa, pausa, diário, fim e reinício estão implementados.

**354 verificações aprovadas**, incluindo 123 na partida pelas salas reais do
GameMaker. ProjectTool oficial abriu/normalizou os recursos sem erro. Consulte
VALIDACAO.md para cobertura e limites. Não foi detectado bloqueador nos cenários.

## Abrir e executar

Abra `BLANK GAMEFabricaDeSalgados.yyp` na raiz pelo GameMaker; Windows/VM e F5.
Comece em Novo jogo / Parâmetros. WASD/setas/E e mouse nos painéis presenciais.
Ajuda / objetivo explica o ciclo. Dia 1 já conta no período.
Para editar no VS Code: ABRIR_NO_VSCODE.cmd.

## Limites e próximos passos

Faltam avaliação humana do ritmo/leitura/acessibilidade e testes em outras
plataformas/YYC. Arte temporária; portas por plataformas identificadas e colisões
por volumes simples. Transporte de salgados prontos é abstraído; só ingredientes
ocupam mochila. Sem devolução às prateleiras e sem salvar partidas em disco.
Persistência entre salas/menu foi testada em memória. Recomenda-se partida humana
curta pelo manual antes de investir em arte definitiva.

Backup anterior: C:\fabrica\.backups\antes-exploracao-jogavel.zip.
Histórico/publicação: https://github.com/Luidcasotti/fabricasalgados.
