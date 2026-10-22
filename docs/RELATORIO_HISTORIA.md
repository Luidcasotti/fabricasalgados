# Entrega — missões, história e aprendizagem

A fábrica existente ganhou uma História guiada completa, sem substituir o
modo livre. Introdução com gerente/cozinheiro; primeiro pedido de 10 coxinhas;
falta local de frango; retirada, transporte e produção com barra; entrega com
pagamento; segundo pedido com falta geral de queijo, reposição e negociação;
perguntas contextualizadas, recuperação e dashboard de aprendizagem.

## Alterações

Três novos recursos GameMaker registrados pelo GMSync: scr_missoes, scr_historia,
scr_testes_missoes (cada um com .yy e .gml). Total: 44 recursos = 10 salas,
7 objetos, 26 scripts e 1 sprite. Nenhuma sala, objeto ou sprite válido foi removido.

Adaptados: parâmetros (modo/preset/validação), obj_cozinheiro (bloqueio durante
leitura), obj_exploracao (barra/confirmar reinício), scr_mundo (interações/guias),
compras, pedidos, logística, fonte GML (&), dashboard e seu controlador.
O harness opcional ganhou --historia negociar|comprar|recusar. Documentação,
manual de aluno/professor e capturas foram atualizados.

Progresso depende de eventos confirmados nas APIs. História e perguntas não
criam dinheiro ou materiais. O primeiro preparo separa materiais por transferência.
Estoque/receita/capacidade continuam auditáveis; compras mantêm prazo e pagamento.
Guardas bloqueiam ações fora da ordem; decisões erradas permitem recuperação.

## Testes

66 verificações novas de missões, mais regressões e quatro partidas completas
no Runner: livre, negociar, aceitar com atraso e recusar. Consulte VALIDACAO.md
para contagens observadas, cobertura, limites e comandos reproduzíveis.
Recursos abertos/normalizados pelo ProjectTool oficial. As evidências da história
estão em evidencias-historia.json e imagens/historia-*.png.

Nenhum bloqueador foi encontrado nos percursos executados. A automação usa
entrada/colisões/GUI do GameMaker em cópias, sem substituir teste humano de
usabilidade. A arte e os retratos são provisórios; ainda não há salvamento em
disco. O checkpoint existe apenas durante a sessão. Falta avaliar a experiência
com alunos/professores, outras resoluções e YYC/plataformas adicionais.

## Executar

Abra BLANK GAMEFabricaDeSalgados.yyp na raiz pelo GameMaker e use F5 com Windows/VM.
Novo jogo / Parâmetros → HISTÓRIA GUIADA → Iniciar. Leia e use CONTINUAR;
WASD/setas movem, E interage e o mouse decide nos painéis. O que preciso fazer?
mostra o próximo passo. LIVRE mantém parâmetros e exploração sem a sequência.

Backup anterior: C:\fabrica\.backups\antes-missoes-historia.zip.
Repositório: https://github.com/Luidcasotti/fabricasalgados.
