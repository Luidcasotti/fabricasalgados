# Regras da exploração jogável

Valores e porções são fictícios, para aprendizagem. Padrões: cinco dias,
R$ 1.000,00, capacidade 100 pontos/dia. Coxinha, pastel e bolinha de queijo têm
receitas por farinha, frango, queijo, óleo e embalagens. Estoques, mínimos,
custos, preços, capacidade, duração, prazos e receitas são editáveis antes da partida.

## Estoques e presença

- Depósito: estoque inicial; compras recebidas entram nele.
- Mochila: retiradas da prateleira correspondente; até 80 unidades somadas.
- Cozinha: recebe a mochila na mesa de depósito; única fonte da bancada.
- Produtos prontos: aumentam ao cozinhar e diminuem ao entregar no Comercial.
  Seu transporte é abstraído; não ocupa a mochila de ingredientes nesta etapa.

Total físico por insumo = depósito + cozinha + mochila = inicial + compras
recebidas − consumo dos lotes. Transferência não altera total nem caixa.
Quantidades são inteiras, não negativas, até um milhão por item/local.
Retirada/depósito validam a operação inteira antes de alterar saldos. Mínimo é
alvo do depósito, não gatilho de compra automática.

E abre somente ações próximas no setor correto. APIs repetem essa verificação.
Só o computador do Estoque compra; só Marta analisa ofertas; só a bancada cozinha;
só o balcão do Comercial entrega. Pausa bloqueia ações e movimento.

## Produção, compras e pedidos

Cozinhar executa imediatamente o lote escolhido: exige receita completa na
cozinha, capacidade restante, espaço para acabados e dinheiro para custo variável.
Falha não consome recursos. Lote registra receita, quantidades e custos.
Depósito e mochila não abastecem a bancada automaticamente.

Compra paga quantidade × custo unitário ao confirmar. Fica em trânsito até
dia da compra + prazo; recebimento único não cobra novamente. Compras após o
horizonte podem terminar pagas e em trânsito, visíveis no dashboard.

Cada produto gera oferta única por dia; repetição não duplica. Aceitar entra
na fila por aceite; recusar preserva o registro. Preço contratado e prazo ficam
no pedido. Entrega manual exige quantidade integral pronta, baixa acabados e
registra receita única. Pedidos não atendidos permanecem aceitos, mesmo atrasados.
Não há entrega parcial. Atraso = máximo(0, dia da entrega − prazo).
Pedido aberto atrasado é distinto de entrega atrasada.

## Ordem fixa de Encerrar dia

O dia 1 já permite jogar. Duração é o número de dias jogáveis, sem dia extra.

1. Registrar produção/capacidade efetivas e fechar o dia atual.
2. Se for o último, encerrar preservando pendências e abrir dashboard.
3. Senão, incrementar o dia e receber no depósito as compras vencidas.
4. Atualizar prazos: expirar ofertas sem decisão; manter os aceitos atrasados.
5. Gerar ofertas únicas com chave dia/produto.
6. Renovar capacidade diária; orientar o jogador e guardar resumo nos eventos.

**Nada é produzido ou entregue pelo relógio.** Essas ações ocorreram no local.
Ajuda, pausa, menu e resultados não avançam dias. Resultado negativo não encerra.
Ao terminar, consulta, reinício e menu continuam disponíveis.

## Finanças e dashboard

- Receita/vendas: soma dos recebimentos de entregas confirmadas.
- Custos pagos: compras + custos variáveis. Ingrediente não é pago de novo ao
  cozinhar; sua compra já movimentou caixa. O inicial é dotação didática.
- Resultado de caixa = receitas − compras − variáveis. Não é faturamento nem
  lucro contábil. Saldo final = capital inicial + resultado de caixa.
- Capacidade usada: pontos dos lotes realmente executados.
- Utilização = pontos usados / (dias observados × capacidade diária) × 100.
  Na exploração, o dia aberto já é observado; fechá-lo não conta outra vez.
- Pontualidade = entregas no prazo / entregas realizadas × 100. Denominador
  zero mostra não aplicável, sem inventar percentual.

Dashboard mostra depósito/cozinha/mochila, total físico, trânsito, produção por
produto, prontos, pendências, pedidos, finanças, reflexões e diário. Eventos do
fechamento não substituem o diário das ações individuais.

Agendamento/execução automática antigos sobrevivem apenas nos recursos/testes
históricos da V0.1, fora do fluxo normal da exploração.
