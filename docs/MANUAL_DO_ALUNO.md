# Manual do aluno — V0.1

Você administra uma fábrica de coxinha, pastel e bolinha de queijo. O desafio
é testar suas decisões e explicar o que aconteceu. Não existe uma única
estratégia certa, e um resultado negativo não elimina você da atividade.
**Os valores, receitas e unidades são fictícios para aprendizagem.**

## Antes de começar

Abra o arquivo `BLANK GAMEFabricaDeSalgados.yyp` no GameMaker, selecione
Windows/VM e pressione F5. Na tela inicial, clique em **Novo jogo / Parâmetros**.

Há 51 campos em nove páginas: duração, saldo, estoque, mínimos, custos,
preços, capacidade, receitas e prazos. Use Anterior/Próxima e +/−, ou clique
no valor para digitar. Dinheiro é digitado em **centavos**: 100000 corresponde
a R$ 1.000,00. Confirme pelo botão ou ENTER; ESC cancela a edição.
**Restaurar padrões** recupera os números iniciais, inclusive as receitas.
A nova configuração só substitui a sessão quando você clica em Iniciar simulação.

O dia 1 é preparação. A duração mede **dias de operação processados**, não
cliques nos setores. Com duração de cinco, você processará os dias 2 a 6 e
verá o dashboard após o quinto avanço. Pausar e abrir resultados não contam dias.

## Um ciclo de decisões

1. **Comercial:** veja produto, quantidade, preço e prazo de cada oferta.
   Aceite ou recuse. Aceitar não entrega nem recebe dinheiro.
2. **Estoque:** selecione um insumo e uma quantidade. Pagar a compra reduz o
   caixa agora; a chegada ocorre depois do prazo. Não há reposição automática.
3. **Produção:** selecione um salgado e uma quantidade. Planejar reserva
   ingredientes, capacidade e dinheiro do custo variável para o próximo dia.
   A aba Planos permite consultar ou cancelar um lote ainda pendente.
4. **Avançar dia:** o jogo recebe compras previstas, executa os lotes, tenta
   entregar os pedidos aceitos e atualiza os prazos, nessa ordem. Leia o resumo.

Os pisos, as etiquetas e os botões inferiores abrem os mesmos setores.
Feche painéis pelo X, clique fora ou ESC. Feche o resumo ou troque de setor
antes de avançar novamente. Os botões +/− permitem ajustar quantidades.

## Entenda os recursos

| Termo | Significado |
| --- | --- |
| Estoque físico | O que já está no depósito. |
| Reservado | O que foi comprometido nos planos, mas ainda não consumido. |
| Livre | Físico menos reservado. |
| Em trânsito | Compra paga que ainda não chegou; não pode ser usada no plano. |
| Capacidade | Pontos disponíveis para executar lotes em um dia. |
| Caixa livre | Saldo menos o custo variável reservado nos planos. |

Se faltar ingrediente, embalagem, capacidade ou caixa livre, o plano não é
aceito. Uma tentativa recusada não consome recursos. Embalagens fazem parte
das receitas e são consumidas na produção. Produtos acabados são separados dos insumos.

## Prazos e pedidos

Cada dia tem ofertas únicas. Você pode ver **Ofertas**, **Fila** e **Histórico**.
O prazo de entrega é inclusivo: entregar no dia indicado ainda é pontual.
A entrega é tentada ao avançar, na ordem de aceite. Sem produtos suficientes
para atender o pedido inteiro, ele permanece na fila; os demais são examinados.
Não há entrega parcial. Um pedido aceito atrasado não desaparece.

## Feedback e diário

Marta (gestora), Caio (estoque) e Bia (produção) aparecem em balões curtos.
Eles levantam perguntas sobre suas escolhas, como aceitar sem produtos prontos,
comprar acima da demanda aceita ou produzir um excedente. Um alerta não quer
dizer que toda reserva é errada: compare sua hipótese com os resultados.
O X do balão fecha apenas a conversa.

**Diário / Resumo** registra data da simulação, ação e consequência. O registro
mais recente aparece primeiro; Anterior/Próxima percorrem os demais. A data é
o número do dia da atividade, não a data do computador. Há também os eventos
de cada dia processado. Use o diário para reconstruir decisões, não só o saldo final.

## Pausar, analisar e reiniciar

**Pausar** bloqueia novas decisões econômicas e o avanço de dias. Você ainda
pode consultar setores, diário e resultados. **Retomar** libera a atividade.
Em Resultados, Retomar simulação retorna à fábrica sem reiniciar recursos.
**Menu → Continuar** mantém a sessão aberta; se o período acabou, reabre o dashboard.

Ao completar a duração, novas decisões são bloqueadas e o dashboard abre.
Pedidos não atendidos, insumos restantes e compras em trânsito continuam visíveis.
**Reiniciar / Parâmetros** permite usar os mesmos valores ou restaurar padrões,
e só cria outra partida ao clicar em Iniciar simulação. Não há Game Over por prejuízo.

## Leia o dashboard

- **Panorama:** recebidos, aceitos, recusados, entregas pontuais/atrasadas,
  fila, expirados, receitas, pagamentos, resultado e saldo.
- **Produção:** quantidade de cada salgado produzida, pronta e ainda demandada;
  utilização da capacidade realmente oferecida nos dias processados.
- **Estoque:** físico, mínimo, reservado e trânsito de cada insumo.
- **Reflexão:** pontos positivos e questões de melhoria ligados aos seus dados.
- **Diário e Eventos:** sequência das decisões e acontecimentos.

Receita não é lucro. **Resultado de caixa = receitas de entregas − compras
pagas − custos variáveis pagos**. O estoque inicial foi fornecido no cenário;
o custo informativo de seus ingredientes não é pago outra vez na produção.

**Pontualidade = entregas no prazo ÷ entregas realizadas × 100.** Sem entregas,
o jogo mostra **não aplicável**, pois não existe denominador.
**Uso da capacidade = pontos usados ÷ (dias processados × capacidade diária) × 100.**
Antes do primeiro dia, também é não aplicável. Se já houve dias, mas não houve
produção, 0% é um dado real, e não falta de informação.

Perguntas para sua análise: o que você esperava vender? Quais pedidos decidiu
não aceitar? Em que momento o prazo apertou? O saldo aumentou por vendas ou
você apenas deixou de comprar? O que mudaria mantendo as mesmas condições?

## Limite importante

Não há salvamento em disco nesta versão. Fechar o programa perde a sessão.
Anote ou faça capturas dos resultados/diário antes de sair ou iniciar outra partida.
