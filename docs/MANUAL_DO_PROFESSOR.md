# Manual do professor — V0.1

Público de referência: estudantes de 16 a 24 anos. A atividade explora estoque,
reposição com prazo, capacidade, compromisso de entrega, caixa e argumentação
sobre decisões. Não representa uma fábrica ou uma demonstração contábil real.
Todos os preços, receitas e porções são fictícios e ajustáveis.

## Preparação e aplicação

Abra `BLANK GAMEFabricaDeSalgados.yyp` na IDE GameMaker 2026.0.0.16 com runtime
2026.0.0.23, Windows/VM, e execute com F5. Não é necessário instalar pacotes de
assets ou a extensão do VS Code para jogar. Consulte RELATORIO_V01.md para a validação.

Use Novo jogo / Parâmetros. A tela oferece 51 campos gerados a partir dos dados:
duração (1–60 dias de operação), saldo, estoques, mínimos, custos unitários,
preços, receitas, capacidade por unidade, custo variável e prazos. A edição
aceita inteiros e mostra limites; valores monetários são digitados em centavos.
Restaurar padrões recupera a configuração completa. Alterações só se aplicam ao iniciar.

**Cronologia:** dia 1 é preparação. Cada avanço processa o dia seguinte. Cinco
dias de operação significam cinco processamentos, nos dias 2–6. O encerramento
depende apenas da duração; um resultado negativo não encerra a atividade antes.

Sugestão de condução, a adaptar à turma:

1. Peça que cada grupo escreva uma hipótese e antecipe um risco antes de jogar.
2. Faça uma rodada com os padrões, permitindo pausar e consultar o diário.
3. No dashboard, compare escolhas com prazos, sobras, trânsito e caixa.
4. Reinicie com a mesma configuração para testar outra estratégia.
5. Altere uma variável por vez para comparar cenários, evitando atribuir a um
   único fator efeitos de várias mudanças simultâneas.

Não utilize apenas o maior caixa como critério de avaliação. Considere se o
aluno consegue localizar evidências, distinguir hipótese de resultado e explicar
uma revisão de estratégia. Feedbacks são perguntas de investigação, não notas.

## Cenários sugeridos

| Caso | Alteração ou decisão | Questão de análise |
| --- | --- | --- |
| Reposição demorada | Aumentar prazo do frango ou iniciar com pouco frango. | Quando o dinheiro sai e quando o insumo pode ser usado? |
| Capacidade disputada | Reduzir a capacidade e aceitar produtos diferentes. | Que compromisso deixa de caber no dia? |
| Compra antecipada/excessiva | Comprar acima da demanda aceita ou perto do fim. | A reserva tem uma hipótese de uso? Quanto fica em trânsito? |
| Produção para previsão | Planejar sem pedidos aceitos. | Que demanda foi prevista? O que fazer com sobras? |
| Atraso | Aceitar com prazo curto e adiar a produção. | Quando o prazo se tornou incompatível com o plano? |
| Revisão | Repetir os mesmos parâmetros com outra sequência de ações. | Quais diferenças são sustentadas pelo diário? |

O jogo não possui perecimento, juros, multas ou crédito. Não inferir esses
efeitos a partir de sobras ou atrasos: eles não foram simulados.

## Indicadores e cuidados de interpretação

Recebidos são ofertas únicas geradas; aceitos são o total cumulativo de aceites,
incluindo entregues. Recusados e expirados não são aceitos. Entregas atrasadas
são diferentes de pedidos ainda abertos com atraso. O fim não apaga esses registros.

Vendas são somente receitas de entregas efetivas. Compras são pagas no ato e
custos variáveis na execução do lote. O resultado é **de caixa**, não lucro
contábil. A avaliação do estoque inicial e o custo da mercadoria vendida não
são contabilizados como lucro; não comparar esse número a uma DRE real.

Pontualidade divide entregas pontuais pelas realizadas. Capacidade divide
pontos executados pela capacidade dos dias realmente processados. Sem
denominador, a interface mostra não aplicável. Não interpretar esse texto como 0%.
As fórmulas ficam na interface e em REGRAS_SIMULACAO.md.

## Novos casos pedagógicos em GML

Arquivo: `scripts/scr_pedagogia/scr_pedagogia.gml`, função pedagogia_casos_criar.
Cada caso tem ID único, evento, prioridade, personagem, flag positivo, predicado
e função de mensagem. As regras pedagógicas não movimentam estoque nem dinheiro.
Exemplo de item a acrescentar ao array (não duplicar IDs):

```gml
{id:"reflexao_capacidade", evento:"plano", prioridade:30,
 personagem:"BIA / PRODUÇÃO", positivo:false,
 verificar:function(_j,_c) {
     return producao_reserva_capacidade(_j) == _j.parametros.capacidade_diaria;
 },
 mensagem:function(_j,_c) {
     return "Toda a capacidade foi reservada. Que margem resta para uma mudança no plano?";
 }}
```

Eventos disponíveis: **aceite** (contexto.pedido), **compra** (contexto.compra),
**plano** (contexto.plano), **entrega** (contexto.pedido) e **fim_dia** (contexto vazio).
Use somente campos válidos para o evento. Predicados devem ser consultas sem
efeitos. Prefira mensagens com até cerca de 180 caracteres, perguntas claras
e sem afirmar que uma estratégia é errada apenas por existir um alerta.
Todos os casos disparados vão ao diário; a maior prioridade aparece no balão.
Para um evento novo, acrescente o disparo explícito no ponto da decisão e um teste.

Para novos produtos/insumos, modifique produtos_catalogo_criar, mantenha IDs
únicos e referências válidas nas receitas e inicie uma nova sessão. Os campos
e seletores acompanham os arrays. Ajuste as expectativas dos testes de catálogo
quando modificar o cenário padrão. Feche a IDE antes de alterações estruturais
externas e use a IDE/GMSync para registrar recursos; não monte .yy/.yyp incompatíveis.

## Testar e registrar evidências

```powershell
python tools/verificar_projeto.py
python tools/verificar_simulacao.py
python tools/verificar_simulacao.py --partida
```

Python é só automação: as regras e os testes executados são GML no runtime.
As ferramentas criam cópias, sem alterar o projeto principal. Documente também
observações da turma e diferenças entre suas hipóteses e os dados do diário.
Não há exportação ou salvamento persistente da sessão nesta versão; faça
anotações/capturas antes de reiniciar ou fechar.
