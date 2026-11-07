> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Campanha de cinco pedidos — 05/11/2026

O botão JOGAR inicia uma campanha cronometrada de cinco entregas, com 300
segundos após a introdução. A história sem relógio também tem cinco missões.
Na configuração, JOGAR HISTÓRIA / 5 PEDIDOS inicia diretamente; mudar entre
história e modo livre usa outro botão, com mensagem de seleção explícita.

Sequência: 20 bolinhas de queijo, 30 coxinhas, 20 pastéis, 30 coxinhas e 20
bolinhas de queijo. O estoque padrão cobre exatamente os 120 salgados sem
compra obrigatória. Cada entrega paga uma vez, registra progresso e gera
somente a próxima oferta com Marta. O painel fecha após a entrega. O HUD
mostra Missão N/5. Recusar permite uma oferta substituta da mesma missão,
sem marcar a missão como concluída. O calendário não encerra a história
antes das cinco entregas.

A quinta entrega abre a confirmação VOCÊ ZEROU O JOGO, seguida pelo final,
sem retorno automático ao menu em caso de vitória. Há JOGAR NOVAMENTE e
VOLTAR AO MENU. Encerrar jogo abre confirmação com CONTINUAR JOGANDO ou
ENCERRAR / IR AO MENU. CONTINUAR no menu retoma os dados da sessão. A saída
não é persistência entre recarregamentos do navegador. Encerrar dia permanece
uma ação separada, com confirmação e atualização de compras e prazos.

Os quizzes de tempo e dez oportunidades de resgate continuam funcionando.

Validação: 546 verificações no Runner oficial, sem falhas. Percursos reais:
171 etapas da campanha cronometrada, 170 da história e 178 com recusa e
substituição de pedido. No Edge, cinco ciclos completos com botões e teclas,
checagem de 120 produzidos e R$620 de vendas, mensagem final e novo jogo.
Botões de história, saída, cancelar, continuar e encerrar dia foram testados.
Posicionamento do ator é instrumentado apenas no teste web; receitas,
estoques, produção, pagamentos, respostas e entregas usam a lógica real.

Na exportação HTML5 foi detectado um arquivo JavaScript sintaticamente inválido
gerado pelo compilador (placeholder de função sem parênteses). O exportador
agora executa node --check em todos os arquivos JS e bloqueia o pacote se
houver erro. Foi gerada uma nova exportação válida, sem alterar preferências
ou instalação do GameMaker. Exportação final: build/html5-20261105-102414.

Na exportação final, a revisão no Edge confirmou novamente início da história,
saída/cancelamento/continuação, encerrar dia e os dois primeiros ciclos de
pedido. Ambos os painéis fecharam após entregar e a terceira missão ficou
disponível. Nenhum erro JavaScript. Relatórios JSON e capturas na pasta
`docs/evidencias-campanha-20261105`.
