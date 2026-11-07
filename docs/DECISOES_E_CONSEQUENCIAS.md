> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Decisões e consequências — 05/11/2026

As duas situações fornecidas foram integradas à história guiada e ao JOGAR.
Cada uma mostra alternativas A/B, a consequência da escolha e o aprendizado.
Elas não pagam bônus nem tratam as duas alternativas de equipamento como
certa/errada. As perguntas opcionais anteriores continuam disponíveis.

## Decisão 1: como resolver o defeito?

Surge quando a máquina falha durante o preparo.

- A: chamar o técnico. O lote aguarda o conserto seguro (8 segundos e R$ 15
  nos padrões atuais). Depois a máquina volta a funcionar e a capacidade é
  recuperada. A produção fica suspensa durante essa espera.
- B: usar outra máquina disponível. O lote continua imediatamente nas máquinas
  que estão funcionando. A defeituosa permanece parada e a taxa disponível
  fica reduzida. Se não houver outra máquina funcionando, essa alternativa
  explica a impossibilidade e mantém a decisão aberta.
- Uma alternativa de reorganizar a equipe, já existente, permanece acessível
  para evitar um bloqueio quando faltar dinheiro para o técnico.

Aprendizado: **É importante avaliar tempo, segurança e recursos disponíveis.**

## Decisão 2: como organizar os ingredientes?

Surge no primeiro contato com Caio, no Estoque.

- A: conferir o estoque antes de produzir. Registra a conferência presencial
  e orienta ir ao Comercial. A explicação mostra como isso ajuda a evitar
  desperdícios e falta de ingredientes.
- B: começar sem conferir. Explica que pode faltar ingrediente e atrasar o
  pedido. A conferência continua pendente; o jogador pode corrigir a escolha
  usando CONFERIR ESTOQUE. Não há perda artificial de materiais ou punição
  financeira. A validação existente impede produzir sem receita/ingredientes.

Aprendizado: **O controle do estoque ajuda a evitar problemas na produção.**

## Tempo, registro e interface

O dia agora tem 300 segundos (cinco minutos). O relógio congela durante a escolha e a
leitura da consequência. Preparo e manutenção também ficam parados durante
essa leitura; voltam ao fechar a tela. A espera real pelo técnico conta no
tempo do dia. As escolhas e aprendizados são registrados no diário e na aba
Aprendizagem do modo completo. Responder repetidamente não duplica registros.

As telas de ingredientes podem ser fechadas com E, Esc, X ou VOLTAR AO JOGO.
Fechar sem responder não inventa uma escolha. A decisão de máquina continua
exigindo uma solução para retomar o lote.

## Validação

GameMaker runtime 2026.0.0.23, Windows VM:

- 372 verificações de lógica, zero falhas (84 relativas à feira/decisões).
- JOGAR: 65 verificações de percurso completo, com decisões, manutenção,
  coleta assistida, produção e entrega.
- Turno guiado completo: 170 verificações, dois pedidos e sete abas do resumo.
- Parser: 79 arquivos GML, zero erros sintáticos; 101 recursos válidos.
- As quatro telas de pergunta/consequência foram inspecionadas em capturas.

Os testes de lógica cobrem as quatro alternativas, respostas inválidas,
repetição, conservação de ingredientes, recuperação após começar sem conferir,
falta de máquina alternativa, espera do técnico, retomada do lote e suspensão
do relógio durante a leitura. Os percursos automatizados aceleram caminhada
e preparo; não substituem uma rodada manual cronometrada.

Logs e capturas: [evidencias-decisoes-20261105](evidencias-decisoes-20261105).
Cópias completas de teste em `.testes/20261105-081358-053494` (lógica),
`.testes/20261105-081252-396423` (JOGAR) e
`.testes/20261105-081421-520020` (turno).

## Uso

Pare a execução anterior e pressione F5 no projeto GameMaker ativo. Escolha
JOGAR / 5 MIN e visite Caio; a decisão sobre defeito aparece no preparo.

As decisões também foram publicadas na atualização do dia de cinco minutos:
[jogar no site](https://fabrica-salgados-mundo-senai.casottimarinetti.chatgpt.site).
Não houve push ao GitHub original. Backup dos fontes anteriores:
`C:/fabrica/.backups/antes-decisoes-20261105-081119.zip`.
