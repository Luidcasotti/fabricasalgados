> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Dia de cinco minutos — 05/11/2026

JOGAR começa com 5:00 (300 segundos). O lembrete único é exibido aos
150 segundos, na metade do tempo. O menu e a introdução mostram a duração
atual; os valores personalizados do professor continuam sendo respeitados.

Pausa e leitura das duas decisões congelam o relógio. O preparo e a espera
pelo técnico contam no tempo de jogo. Entregar antes dos 300 segundos vence;
atingir o limite encerra a rodada sem entrega ou pagamento automáticos.

A exportação Web inclui as melhorias locais anteriores: sete etapas, seta
de destino, coleta assistida e decisões sobre ingredientes e defeito, com
consequências e aprendizados. O Como jogar do site foi ajustado para o
pedido inicial de 20 bolinhas, duas viagens e cinco minutos.

## Validação

- GameMaker Windows VM: 372 verificações de lógica, zero falhas.
- Parser GML: 79 arquivos, zero erros sintáticos.
- Exportação HTML5 oficial: `build/html5-20261105-082036`.
- Edge: início em cinco minutos, avanço real do relógio, pausa, aviso aos
  150 segundos, decisões com relógio congelado, duas viagens, preparo usando
  outras máquinas, entrega de 20 bolinhas e receita de R$ 80.
- Encerramento aos 300 segundos sem vitória, produção ou pagamento inventado.
- Zero erros JavaScript no percurso de navegador.

O QA de navegador usa cliques e teclas reais, posiciona o ator nas estações
e adianta o contador para testar os limites sem esperar cinco minutos.
Logs, resultado JSON e capturas: [evidencias-dia-5min](evidencias-dia-5min).

Backup anterior: `C:/fabrica/.backups/antes-dia-5min-20261105-082034.zip`.
Arquivo de publicação: `C:/fabrica/entregas/FabricaDeSalgados-5min-site.tar.gz`.

## Publicação confirmada

[Abrir o jogo publicado](https://fabrica-salgados-mundo-senai.casottimarinetti.chatgpt.site).
Mesmo projeto Sites, público; versão 5. Hospedagem confirmou `succeeded`.
Fonte da publicação: `e5525f892eebd5c504573844549ceeaa6b4e431e`.
Registro completo: `C:/fabrica/entregas/publicacao-dia-5min.json`.
