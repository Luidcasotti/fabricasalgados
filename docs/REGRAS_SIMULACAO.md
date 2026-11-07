# Regras atuais do jogo

Valores e porções são fictícios. A campanha usa cinco missões e relógio em segundos; o modo livre usa dias de operação. O núcleo abstrato anterior permanece para regressão e não deve ser confundido com o fluxo presencial.

## Catálogo padrão

| Produto | Receita por unidade | Venda | Preparo variável |
| --- | --- | ---: | ---: |
| Coxinha | 1 farinha + 1 frango + 1 óleo + 1 embalagem | R$ 6,00 | R$ 0,25 |
| Pastel | 1 farinha + 1 queijo + 1 óleo + 1 embalagem | R$ 5,00 | R$ 0,25 |
| Bolinha de queijo | 1 farinha + 2 queijo + 1 óleo + 1 embalagem | R$ 4,00 | R$ 0,25 |

| Ingrediente | Inicial | Mínimo | Custo unitário |
| --- | ---: | ---: | ---: |
| Farinha | 120 | 30 | R$ 0,60 |
| Frango | 60 | 15 | R$ 0,80 |
| Queijo | 100 | 25 | R$ 0,70 |
| Óleo | 200 | 40 | R$ 0,20 |
| Embalagens | 120 | 30 | R$ 0,15 |

Caixa inicial: R$ 1.000,00. Capacidade configurada da história: 300; modo livre: 100. Há três máquinas de 100 salgados/hora fictícia, com 180 segundos de jogo por hora simulada. A produção efetiva também respeita a capacidade diária e o custo/capacidade de cada receita.

## Estoque e conservação

Almoxarifado recebe compras; mochila recebe retiradas; cozinha recebe depósitos; bancada consome somente da cozinha. Produtos prontos aumentam após o lote e diminuem na entrega. Seu transporte é abstraído, sem ocupar a mochila.

```text
físico do insumo = almoxarifado + mochila + cozinha
físico do insumo = inicial + compras recebidas - insumos consumidos
saldo de caixa = capital inicial + entradas - saídas
```

A mochila comporta 120 porções na história e 80 no modo livre. Valores são inteiros, não negativos e limitados pelas guardas. A operação inteira é validada antes de consumir recursos. O mínimo do estoque é um indicador, não uma compra automática.

A API confere setor e proximidade para aceitar, comprar, retirar, depositar, preparar e entregar. A interface aberta não substitui essa validação. Pausa, confirmações e encerramento bloqueiam operações.

## Compras e motoboy

A compra paga quantidade × custo unitário, usando referência única. Na exploração, fica em trânsito por **12 segundos de jogo**. Na chegada, o motoboy adiciona uma vez a quantidade às prateleiras, registra o recebimento e mostra um aviso. Não há nova cobrança nem abastecimento automático da cozinha.

A viagem funciona mesmo fora do Estoque e congela durante pausa, confirmação, introdução, quizzes, decisões e resultados. Compras a caminho são consideradas ao calcular o faltante. Avançar dias não antecipa a entrega do motoboy. No núcleo abstrato sem exploração, permanece a regra histórica de chegada por dias.

## Produção e equipamento

O preparo guiado tem progresso calculado pela quantidade e capacidade das máquinas. A barra representa esse progresso; não é um temporizador fixo de 90 frames. Antes de concluir, cancelar preserva insumos e pagamento do lote. Na conclusão, receita, dinheiro e capacidade são revalidados e registrados uma vez.

| Escolha diante do defeito | Efeito padrão |
| --- | --- |
| Chamar técnico | R$ 15,00, espera de 8 s, capacidade restaurada após reparo |
| Usar outra máquina | Defeituosa parada; outras continuam com capacidade reduzida |
| Reorganizar equipe | Reparo gratuito em 16 s; outras máquinas continuam |

As telas de decisão/consequência e confirmações suspendem relógio e preparo. A espera pelo conserto, depois de fechar a leitura, conta como jogo.

## Pedidos e finanças

Aceite cria compromisso, sem receita de venda. Entrega exige quantidade integral pronta, baixa os produtos e registra recebimento único. Recusa preserva histórico. Atrasos por dias continuam distintos entre pedido aberto e entrega efetuada no modo livre.

- **Vendas:** recebimentos efetivos das entregas.
- **Custos pagos:** compras + preparo variável + manutenção.
- **Resultado de caixa:** vendas + bônus financeiros existentes − custos pagos.
- **Saldo:** capital inicial + resultado de caixa.
- **Pontualidade:** entregas no prazo / entregas realizadas; sem entregas, não aplicável.

Na história atual, quizzes dão tempo, sem entrada financeira. O custo dos ingredientes comprados não é pago novamente ao cozinhar. Resultado de caixa não é lucro contábil: faltam custos e critérios de uma contabilidade completa.

## Tempo, consulta e final

A história começa com 300 segundos após a introdução. Cada quiz correto acrescenta 120 segundos uma vez; cada resgate correto acrescenta 120, até dez oportunidades. Errar o quiz opcional não encerra; errar o resgate encerra. A quinta entrega vence apenas se registrada antes do limite disponível.

RESULTADOS pausa e conserva o cronômetro. VOLTAR AO JOGO, Esc ou Enter retoma a mesma sessão. A vitória permanece visível até uma escolha; em derrota por tempo há retorno automático ao início após a tela de resultado. Reiniciar restaura checkpoint ou cria uma nova sessão conforme o botão usado.

No modo livre, encerrar dia registra o dia, atualiza prazos/ofertas e renova capacidade. Não produz nem entrega pedidos automaticamente. A campanha não termina só por consultar resultados ou entregar a primeira encomenda.
