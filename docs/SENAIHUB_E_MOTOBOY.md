> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# SENAI HUB nas lajotas e motoboy — 05/11/2026

O corredor recebe SENAI HUB como mosaico do piso, com cada pixel ocupando
exatamente uma lajota. SENAI usa azul (20,61,137), HUB laranja (235,65,13),
com detalhe laranja no topo do i, conforme a imagem enviada. A câmera do
corredor foi aberta para o nome completo caber entre os painéis. Outras salas
mantêm a aproximação original. Colisões e alvos de interação não mudam.

Na exploração, toda compra válida é paga ao encomendar e entregue por motoboy
após 12 segundos de jogo. A moto se aproxima da área de recebimento do Estoque,
o estoque físico é atualizado uma vez na chegada e aparece um aviso. Depois
o entregador sai. A entrega funciona em qualquer setor, sem avançar dias.
Pausas, introdução, confirmações, quizzes, decisões e consulta a resultados
congelam a viagem junto com o cronômetro. Compras em trânsito impedem recomprar
o mesmo faltante; dinheiro não é cobrado de novo na chegada. Itens recebidos
ficam nas prateleiras, exigindo retirada e transporte até a cozinha.

A ação COMPRAR APENAS O FALTANTE está liberada na campanha. Enquanto houver
itens aguardados, o painel mostra o prazo e VER MOTOBOY fecha a janela para
acompanhar a chegada. Após receber, PEGAR INGREDIENTES DO PEDIDO volta a
ficar disponível. As mensagens que exigiam virar o dia foram substituídas.
A simulação abstrata sem exploração preserva a regra de compras por dias.

Validação: 565 verificações no Runner, sem falhas. Novas verificações cobrem
prazo exato, pausa, confirmação, quiz, recebimento em outro setor, pagamento
único, pedido em trânsito, idempotência, entrega de vários itens e produção
com o ingrediente recebido. No Edge, estoque inicial de queijo foi ajustado
pela própria tela de parâmetros para 40, exigindo reposições reais de 20 e
40 porções nas missões 3 e 5. As duas chegaram no dia 1, sem novo pagamento,
e permitiram concluir as cinco entregas (120 salgados, R$620 em vendas,
R$42 em compras e R$30 de preparo). Sem erros JavaScript. O posicionamento
do jogador é instrumentado no teste; compras, espera, estoque, pagamentos e
produção usam a lógica real e botões do jogo.

Ajuste final da câmera conferido no Edge, incluindo corredor e área de
recebimento no Estoque. Exportação final: build/html5-20261105-110128.
Capturas e relatório: docs/evidencias-senaihub-motoboy-20261105.
