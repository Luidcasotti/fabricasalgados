# Regras da simulação

Esta é uma simulação educacional. **Todos os valores, quantidades, unidades,
receitas e prazos são fictícios para aprendizagem.** Não representam preços
de mercado, receitas culinárias, orientação empresarial ou medidas reais.

## Parâmetros iniciais editáveis

Em Novo jogo / Parâmetros, são editáveis caixa inicial, capacidade diária,
quantidade mínima/máxima das ofertas, prazo de entrega, validade de aceite,
estoque inicial/mínimo, custo unitário e prazo de cada ingrediente, além de
preço de venda, custo variável, capacidade por unidade e cada quantidade de
ingrediente das receitas. São 50 campos no catálogo inicial, em nove páginas.
Os limites numéricos são validados antes de iniciar a sessão.

| Insumo | Inicial | Mínimo | Custo unitário | Reposição |
| --- | ---: | ---: | ---: | ---: |
| Farinha | 120 | 30 | R$ 0,60 | 1 dia |
| Frango | 60 | 15 | R$ 0,80 | 2 dias |
| Queijo | 100 | 25 | R$ 0,70 | 1 dia |
| Óleo | 200 | 40 | R$ 0,20 | 1 dia |
| Embalagens | 120 | 30 | R$ 0,15 | 2 dias |

Cada quantidade representa porções didáticas; embalagens são unidades.
Caixa inicial: R$ 1.000,00. Capacidade diária: 100 pontos.

| Produto | Farinha | Frango | Queijo | Óleo | Embalagem | Preço de venda |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Coxinha | 1 | 1 | 0 | 1 | 1 | R$ 6,00 |
| Pastel | 1 | 0 | 1 | 1 | 1 | R$ 5,00 |
| Bolinha de queijo | 1 | 0 | 2 | 1 | 1 | R$ 4,00 |

Padrão: um ponto de capacidade e R$ 0,25 de custo variável adicional por
salgado. Esse custo representa energia/consumíveis fictícios, separado dos
insumos da receita. Quantidade zero na receita exclui aquele insumo; pelo
menos um insumo precisa permanecer positivo. IDs não podem se repetir.
Novos parâmetros só valem para uma sessão nova; não alteram pedidos ou planos
já registrados. Os dados da sessão são uma cópia independente da configuração.

## Estoque e compras

- **Físico** é o saldo realmente disponível no depósito. **Reservado** é a soma
  comprometida por planos; **livre = físico − reservado**.
- **Em trânsito** não é físico e não pode ser reservado para produção.
- Comprar valida ID, quantidade inteira positiva, limite físico e dinheiro livre.
  O dinheiro é pago imediatamente; o estoque físico permanece inalterado.
- A compra guarda quantidade, custo vigente, pagamento, dia da compra, dia de
  chegada e status. Comprada no dia D com prazo P, chega ao iniciar D+P.
- Cada compra só pode ser recebida uma vez. Não há reposição automática por
  estoque baixo e não há cancelamento/reembolso de compra nesta etapa.
- O aviso de mínimo compara o saldo **livre** ao mínimo configurado. Ele informa;
  não realiza uma compra. Prazo mínimo de reposição: um dia.
- Saldos físicos são inteiros, nunca negativos, com limite de um milhão por item.
  Compras pendentes também ocupam esse limite para evitar excesso na chegada.

## Planejamento e execução da produção

O aluno seleciona produto e quantidade (1 a 1.000 por clique na interface).
O domínio também valida quantidades e os limites físicos/capacidade.
O plano é para o **próximo dia**, não para um horário do dia atual.

Ao planejar, são conferidos os insumos livres, capacidade ainda não reservada
do próximo dia, espaço para produtos acabados e caixa livre para o custo variável.
Todos os planos competem pelas mesmas reservas: não se pode comprometer o
mesmo frango, capacidade ou dinheiro duas vezes. Compras futuras não contam
como estoque até chegarem. O caixa livre é o saldo menos os custos variáveis
reservados. Compras não podem gastar esse dinheiro reservado.

Planejar não consome estoque, não produz unidades e não paga o custo variável.
Cancelar um plano ainda pendente libera todas as reservas sem produzir e mantém
o registro como cancelado. Cada execução valida novamente todos os efeitos;
uma falha mantém o plano pendente, sem consumo parcial ou cobrança parcial.

Ao executar, os insumos são consumidos conforme o snapshot da receita, o custo
variável é pago, a capacidade diária é ocupada e os produtos acabados entram
no estoque. O custo dos ingredientes é registrado no lote como informação;
não é debitado de novo, pois compras já foram pagas. Lotes executados nunca
voltam a executar. O total acumulado permanece; a capacidade usada e unidades
do dia são reiniciadas a cada novo dia.

## Encomendas, fila e atrasos

Uma oferta por produto é criada no início de cada dia, inclusive no dia 1.
Quantidades padrão variam de 5 a 15 por fórmula determinística para permitir
repetir os cenários: mínimo + ((dia−1)×7 + índice×5) módulo (máximo−mínimo+1).
Preço unitário e total são fixados quando a oferta é criada.

A identidade é **dia de geração + ID do produto**, além de um ID numérico único.
O marcador de dia e a chave por oferta impedem criar duas vezes o mesmo pedido,
mesmo se a rotina de geração for chamada novamente. Aceitar não clona a oferta.

- Padrão de entrega: até o dia de geração + 2, inclusive.
- Padrão de aceite: até o dia de geração + 1, inclusive, limitado ao prazo de entrega.
- Ofertas podem ser aceitas ou recusadas; recusas e ofertas expiradas são preservadas.
- Aceitos recebem uma sequência de aceite e entram em fila nessa ordem.
- No processamento diário, cada pedido aceito é tentado uma vez. Sem produtos
  suficientes para a quantidade inteira, permanece na fila e o processamento
  segue para os demais; não há entrega parcial. Produtos não são reservados por
  pedido, e o primeiro elegível na ordem de aceite tem prioridade de uso.
- Só uma entrega efetiva reduz produtos acabados e registra receita.
- Entregue no prazo: dia de entrega ≤ prazo. Atraso: máximo(0, entrega − prazo).
- Pedidos aceitos vencidos continuam aceitos, com atraso atualizado. Nunca
  expiram como ofertas nem são apagados por falta de estoque.
- Estados: ofertado, aceito, recusado, expirado e entregue. Filas, ofertas e
  histórico da interface são consultas desse mesmo conjunto persistente.

## Avançar um dia: ordem fixa

O botão avança de D para **D+1** e executa, sincronicamente:

1. **Chegadas:** receber compras em trânsito com chegada ≤ D+1.
2. **Produção:** zerar uso diário, executar os planos elegíveis em ordem de
   agendamento, consumir insumos, pagar custos variáveis e adicionar produtos.
3. **Entregas:** tentar cada pedido aceito em ordem de aceite, baixando produtos
   e recebendo dinheiro quando há estoque suficiente.
4. **Prazos e ofertas:** marcar ofertas vencidas, atualizar atrasos de aceitos
   e gerar o lote único de ofertas do novo dia.
5. Registrar o resumo no histórico de dias e mostrá-lo paginado.

Assim, uma chegada ocorre antes do consumo, e um produto concluído pode ser
entregue no mesmo processamento. O prazo de entrega é inclusivo. Uma rotina
não é chamada por frame; apenas o botão dispara a transição. A trava de
reentrada e o resumo aberto bloqueiam avanço repetido acidental. Fechar o
resumo ou trocar de setor permite planejar/avançar novamente.

## Finanças e resultado

Dinheiro é inteiro em centavos. Cada movimento guarda tipo, dia, descrição,
valor assinado e referência única à compra, lote ou pedido. Repetir a mesma
referência não gera nova cobrança/receita. Caixa negativo é proibido.

- Capital inicial não é receita de venda.
- Compra paga é saída no dia da contratação; chegada não paga novamente.
- Custo variável adicional é saída na execução do lote.
- Receita de entrega só é entrada quando o pedido é efetivamente atendido.
- **Resultado de caixa = receitas de entregas − compras pagas − custos variáveis pagos.**
- **Saldo em caixa = capital inicial + resultado de caixa.**

Faturamento/receita não é lucro. O resultado mostrado é de caixa, e não lucro
contábil: não há depreciação, salários, impostos, perdas, avaliação contábil do
estoque inicial ou custo de mercadoria vendida por FIFO. O custo de ingredientes
dos lotes é informativo e não pode ser subtraído de novo como pagamento.

## Limites desta etapa

Não há save/load, perecimento, entregas parciais, contratação ou IA de empregados.
A produção tem execução diária, sem animação de duração intradiária. Os gráficos
isométricos e funcionários são preservados como representações visuais.
Não há juros, crédito, multa por atraso ou pedido sumindo por vencimento.
