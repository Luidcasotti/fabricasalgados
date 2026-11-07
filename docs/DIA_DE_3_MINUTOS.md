> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Dia de três minutos e orientação — 05/11/2026

Registro da alteração anterior. O padrão atual passou para cinco minutos;
consulte [dia de cinco minutos](DIA_DE_5_MINUTOS.md).

No JOGAR, o dia dura 180 segundos (3:00). O lembrete aparece uma vez aos
90 segundos e desaparece após cinco segundos. Pausa congela o relógio;
o tempo inclui a introdução. A entrega deve ocorrer antes dos 180 segundos.
Os valores personalizados do professor continuam sendo respeitados.
Na atualização de [decisões e consequências](DECISOES_E_CONSEQUENCIAS.md),
o relógio também congela enquanto o jogador escolhe e lê essas duas decisões.

A interface apresenta sete passos com destaque para a ação atual, destino
nomeado e seta de direção. A seta continua funcionando perto de objetos que
não são o destino. Ao chegar ao alvo indicado, aparece E. Os controles de
movimento, interação e ajuda ficam visíveis durante a rodada.

Na prateleira do modo guiado, PEGAR O NECESSÁRIO calcula a quantidade que
falta para o pedido, descontando cozinha e mochila. A coleta respeita o saldo
da prateleira e a capacidade de transporte. Cliques repetidos não coletam
mais do que o necessário. O modo livre mantém o seletor manual.

O pedido inicial de 20 bolinhas requer duas viagens. Quando a mochila enche,
o guia pede depósito na Produção; em seguida indica o ingrediente restante.
A lista só marca busca e depósito como concluídos quando a cozinha está
abastecida. O botão de pergunta opcional não cobre as sete etapas.

## Validação

- GameMaker 2026.0.0.23 Windows VM: 354 verificações de lógica, zero falhas.
- Fronteiras: aviso aos 90 segundos, vitória em 179,9 segundos, encerramento
  e entrega bloqueada aos 180, pausa, conservação e clique repetido na coleta.
- Percurso completo: 66 verificações, com os botões reais de coleta assistida,
  duas viagens, manutenção e entrega; zero falhas.
- Parser independente: 79 arquivos GML, zero erros sintáticos.
- Recursos: 101 recursos com referências, eventos e frames válidos.
- Telas de introdução, prateleira e rota inspecionadas em capturas do Runner.

Evidências de lógica: `.testes/20261105-080657-484909`.
Percurso e capturas: `.testes/20261105-080815-830619`.
O percurso automatizado acelera caminhada e preparo. Os testes de estado
exercitam os limites do relógio; não representam uma rodada manual cronometrada.

## Abrir

Abra o projeto ativo `BLANK GAMEFabricaDeSalgados.yyp`, pare a execução anterior
e pressione F5 no GameMaker (Windows/VM). Escolha JOGAR / 3 MIN.

Alterações locais, sem publicação Web ou push. O projeto ativo é o indicado
pelo workspace em `C:/Users/Luid Casotti/GameMakerProjects/fabrica/BLANK GAMEFabricaDeSalgados`.
Backup dos arquivos alterados antes desta tarefa em
`C:/fabrica/.backups/antes-dia-3min-20261105-080355.zip`; o driver de percurso
anterior está em `.backups/scr_testes_missoes-antes-3min-20261105.gml`.
