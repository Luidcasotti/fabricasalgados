> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Retorno dos resultados e cronômetro — 05/11/2026

A tela de resultados parciais é uma consulta: não finaliza a história nem
muda o modo da partida. VOLTAR AO JOGO / ESC aparece no cabeçalho e no
rodapé. Ambos retornam ao setor e ao pedido atuais; Esc ou Enter também
retornam. O mesmo cronômetro fica visível no painel, com Tempo pausado.
Ao voltar, retoma do mesmo valor, preservando bônus, recursos e progresso.
Resultados agora está disponível também na campanha cronometrada.

A entrada pela história guiada usa os mesmos cinco minutos e bônus de JOGAR,
em todas as cinco missões. O modo livre continua separado. Foi removido o
caminho antigo que apagava o estado feira ao continuar pelos resultados.
Em partidas já concluídas, o retorno aponta para o final; no modo livre
encerrado, volta ao menu sem reabrir a simulação.

Validação: 550 verificações no Runner sem falhas; percurso de 171 etapas pela
entrada JOGAR HISTÓRIA até completar cinco entregas com cronômetro.
Exportação oficial HTML5: build/html5-20261105-103440, validada com node --check.

QA no Edge com a exportação final: cinco entregas, seis idas e voltas ao
painel de resultados, botões superior e inferior, Esc e Enter. Os testes
conferiram pausa do relógio, continuidade do contador, pedido, estoque,
mochila, vendas e bônus de +120 segundos. A história iniciada pela configuração
também mostrou os cinco minutos e voltou dos resultados corretamente.
Nenhum erro JavaScript. Relatório e capturas: docs/evidencias-resultados-relogio-20261105.
