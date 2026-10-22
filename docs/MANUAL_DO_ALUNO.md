# História guiada — atualização

Escolha HISTÓRIA GUIADA nos parâmetros para a sequência educativa, ou LIVRE
para as atividades descritas abaixo. Alternar modo reaplica seus padrões.
Leia [Missões e história](MISSOES_E_HISTORIA.md) para etapas, escolhas e recuperação.

A primeira encomenda guiada é de **10 coxinhas**. Demais ingredientes já estão
separados na cozinha; busque somente o frango e deposite. A barra registra o lote
uma vez. No segundo caso, falta queijo na empresa: comprar exige espera; negociar
muda o prazo com registro; recusar também conclui o desafio. Perguntas erradas
explicam sem penalizar. A ajuda mostra missão/ação/local/motivo e repete falas.

Reiniciar missão restaura início da história ou capítulo do segundo pedido,
com confirmação; todas as alterações posteriores ao checkpoint são desfeitas.
Isso não salva em disco. APRENDIZAGEM mostra problemas/prática/respostas,
sem atribuir nota ou garantir domínio do conteúdo.

---

## Exploração e atividades no modo livre

# Manual do aluno — explore, decida e compare

Você administra a fábrica enquanto controla um cozinheiro. Combine pedidos,
ingredientes, capacidade e dinheiro. Valores/receitas são fictícios; resultados
negativos também servem para aprender.

## Começar

Abra o .yyp original no GameMaker e F5 com Windows/VM. Escolha Novo jogo /
Parâmetros; confira duração, capital, estoques, mínimos, custos, preços,
capacidade, prazos e receitas. Use páginas, clique no valor para editar ou +/−.
Valores inválidos são recusados. Restaurar padrões repõe a configuração;
Iniciar cria nova sessão no corredor.

## Controles

| Controle | Ação |
| --- | --- |
| WASD ou setas | Caminhar em quatro direções na tela. |
| E | Interagir com porta/NPC/equipamento próximo; também fecha painel. |
| Mouse | Selecionar pedido/produto, quantidade e confirmar no painel aberto. |
| Esc | Fechar ajuda/painel; se nada estiver aberto, pausar/retomar. |
| Ajuda / objetivo | Consultar controles e o ciclo da fábrica. |
| Resultados | Pausar e rever indicadores/diário/eventos; depois retomar. |
| Encerrar dia | Confirmar fechamento do dia; não cozinha nem entrega. |

O personagem para ao abrir painel; feche-o para andar. Móveis, equipamentos,
funcionários e bordas bloqueiam passagem. A câmera acompanha o cozinheiro.
Procure plataformas amarelas com placa PORTA / E. No corredor, Comercial vem
primeiro; seguindo para a direita e para baixo ficam Produção e Estoque.
Posições e recursos são preservados ao trocar salas.

## Primeiro ciclo

1. No **Comercial**, visite a mesa de Marta e E. Analise produto, quantidade,
   valor e prazo. Aceite ou recuse. Aceitar não recebe dinheiro.
2. Na **Produção**, consulte a receita na bancada. São mostradas as quantidades
   necessárias para o lote e as disponíveis **na cozinha**.
3. No **Estoque**, visite cada prateleira necessária. Retire para a mochila
   (limite 80 unidades somadas); isso reduz o depósito.
4. Caminhe até a **mesa de depósito** na Produção e transfira a mochila.
   Nada é duplicado: o que sai da mochila passa para a cozinha.
5. Na **bancada**, selecione salgado/quantidade e Cozinhar. Faltas de ingredientes,
   capacidade ou dinheiro bloqueiam o lote inteiro, sem consumo.
6. Retorne ao **balcão do Comercial**, E e Entregar pedido. Só então saem os
   produtos prontos e entra a receita da venda.

Com os padrões, o primeiro pedido é de cinco coxinhas. Retirar cinco unidades
de cada um dos quatro ingredientes usados no lote cabe na mochila. Não é preciso
comprar antes desse lote: já existe estoque inicial. Essa é uma experiência
inicial, não uma estratégia obrigatória.

## Reposição, dias e reflexão

No computador do Estoque, escolha ingrediente/quantidade. Compra sai do caixa
e chega ao depósito após o prazo. Depois é preciso transportá-la. O mínimo é
aviso, não reposição automática.

Encerrar dia registra suas ações, recebe compras no próximo dia, atualiza prazos,
gera ofertas e renova capacidade. **Pedidos prontos não se entregam sozinhos.**
Ao fechar o último dia, o dashboard abre preservando registros. Pedidos atrasados
continuam na fila e podem ser entregues enquanto o período estiver aberto.

Observe objetivo, pedido atual, mochila e mensagens. Balões perguntam sobre
aceite, excesso, reposição e atraso; não são multas. Compare vendas, custos,
resultado de caixa, produção, capacidade e estoques por local. Leia as fórmulas:
faturamento não é lucro; sem entregas não há taxa de pontualidade.

O diário registra dia, ação e consequência. O que você previa, o que aconteceu
e qual hipótese quer testar? Reiniciar volta aos parâmetros; Continuar usa a
sessão aberta. **Fechar o programa perde a partida**, pois não há salvamento em
disco. Guarde observações antes de reiniciar ou fechar.
