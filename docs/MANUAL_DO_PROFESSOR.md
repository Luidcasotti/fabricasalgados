# Manual do professor — gestão pela exploração

Para estudantes de 16 a 24 anos: planejamento de materiais, capacidade, prazos,
aceites e caixa. Porções/preços/receitas são fictícios, sem pretensão de reproduzir
uma cozinha real ou contabilidade completa.

Peça previsão de materiais/dinheiro/prazos antes do primeiro ciclo. Deixe a dupla
visitar os três setores, fazer uma entrega e explicar a conservação dos materiais.
Compare duas partidas mudando um parâmetro. Avalie justificativas, não apenas
saldo/pontualidade. Resultados negativos não geram Game Over.

Antes da partida, ajuste 51 campos: duração (1 a 60 dias), capital, capacidade,
faixa/prazos dos pedidos, validade das ofertas, estoque inicial/mínimo/custo/prazo
de cada insumo, preço/custo variável/capacidade de cada produto e cinco quantidades
de cada receita. O editor valida; Restaurar padrões reverte tudo. Os parâmetros
são copiados para a sessão, sem mudança silenciosa durante o jogo.

| Experimento | Mudança | Discussão |
| --- | --- | --- |
| Capacidade apertada | Reduzir capacidade | Que pedidos cabem no mesmo dia? |
| Reposição demorada | Aumentar prazo do frango | Quando a compra precisa ocorrer? |
| Caixa limitado | Reduzir capital/elevar custo | Compra corresponde à demanda aceita? |
| Transporte | Lote maior que mochila 80 | O que precisa chegar à cozinha antes? |
| Prazo curto | Reduzir prazo dos pedidos | Ter prontos basta sem voltar ao balcão? |
| Excesso | Produzir além dos aceites | Onde ficou o dinheiro? |

Dia 1 já é jogável. Encerrar dia não cozinha nem entrega. Mínimo é do depósito.
Use diário/seis abas para distinguir pedido aberto atrasado, entrega atrasada,
receita, custo e resultado de caixa. Na análise parcial, capacidade do dia aberto
entra como dia observado; ao fechar não se soma outra vez.

## Expandir dados e casos em GML

Dados: produtos_catalogo_criar em scr_produtos e parametros_padrao em scr_estado.
Novo produto precisa de ID único/receita válida; seletores acompanham o catálogo.
Novo ingrediente exige também validadores e prateleira/alvo/colisão em mundo_criar,
no scr_mundo. Não basta adicionar quantidade sem lugar para retirada. Inicie
nova sessão depois de mudar os dados e adapte testes do catálogo padrão.

Casos: pedagogia_casos_criar em scr_pedagogia. Item tem ID, evento, prioridade,
personagem, positivo, verificar e mensagem. Predicados apenas consultam dados.
Exemplo para produção presencial:

```gml
{id:"capacidade_esgotada",evento:"plano",prioridade:30,
 personagem:"BIA / PRODUÇÃO",positivo:false,
 verificar:function(_j,_c) {
     return _j.producao.capacidade_usada == _j.parametros.capacidade_diaria;
 },
 mensagem:function(_j,_c) {
     return "A capacidade de hoje acabou. Como isso afeta as encomendas ainda abertas?";
 }}
```

Eventos: aceite(contexto.pedido), compra(contexto.compra), plano(contexto.plano),
entrega(contexto.pedido), fim_dia(contexto vazio). Na exploração, plano dispara
após cozinhar, com lote já executado. Todos os casos ativados vão ao diário;
a maior prioridade aparece no balão. Prefira perguntas curtas e abertas.

Feche IDE antes de mudanças estruturais externas; mantenha backup/Git. Registre
recursos pela IDE/GMSync. Rode comandos de VALIDACAO.md e teste iniciar/terminar/
reiniciar. Python só automatiza; regras/testes executam em GML no GameMaker.
Ainda faltam avaliação com turmas, acessibilidade e persistência/exportação.
