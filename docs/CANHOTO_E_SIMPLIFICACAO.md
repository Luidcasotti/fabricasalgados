> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Canhoto, fluxo simples e legibilidade — 05/11/2026

## Como jogar

1. Aceite o pedido com Marta no Comercial.
2. O canhoto aparece à esquerda com produto, quantidade e ingredientes.
3. No Estoque, use E em Caio e PEGAR INGREDIENTES DO PEDIDO.
4. Deposite na Mesa de depósito da Produção.
5. Cozinhe na Mesa de preparo e entregue no Comercial.

O primeiro pedido cabe numa viagem: 20 farinha, 40 queijo, 20 óleo e 20
embalagens. A mochila guiada comporta 120 porções. Pedidos maiores usam mais
viagens, indicadas somente enquanto ainda há material a retirar. O modo
livre mantém a capacidade anterior de 80.

## Canhoto e Estoque

O canhoto é derivado de pedido, receita e quantidades reais. Desconta mochila
e cozinha, mostra prontos e mantém a receita original após consumir os
ingredientes. Retirar não é comprar. O painel de Caio deixa isso explícito
quando os materiais já existem na empresa.

O botão único separa somente os faltantes, respeita capacidade e prateleira
e exige presença no Estoque. Repetir o clique não duplica nem retira a mais.
Quando há falta na empresa, a compra guiada pede apenas o faltante e desconta
o que já está em trânsito. Ela não inventa entrega imediata: reposições de
fornecedor pertencem ao modo completo e chegam no dia previsto.

Foram removidas as exigências de visitar o Estoque antes do aceite e de
visitar a bancada antes de retirar ingredientes. Conferência e decisões
educativas continuam disponíveis sem obrigar essas voltas. Aceitar, separar
e depositar fecham o painel e deixam o próximo destino evidente.

## Texto e interface

- Quatro atlas de fonte Segoe UI incorporados, com antisserrilhamento,
  acentos e caixa original, usados no jogo inteiro; sem depender de fonte
  dinâmica no navegador. Tamanhos base: 16, 22, 30 e 40 pixels.
- Cabeçalho com local, caixa e relógio; retiradas as cinco barras duplicadas
  do topo. O canhoto concentra as quantidades do pedido.
- Botões ajustam o texto à largura. Fundos claros usam texto escuro; títulos
  e estados verdes ganharam contraste. Corrigido o botão quase branco sobre branco.
- Placas no mundo usam a mesma fonte. Ajuda, quiz, aviso de tempo, destino,
  informações de máquina e controles foram reposicionados para evitar sobreposição.
- O aviso de metade do tempo não cobre mesas abertas, ajuda ou decisões.
- O destaque E aparece para o destino atual, sem incentivar repetir a estação
  anterior depois de aceitar, separar ou depositar.
- CONTINUAR fica desabilitado sem partida iniciada.

## Validação

Motor GameMaker 2026.0.0.23 Windows VM:

| Verificação | Resultado |
| --- | --- |
| Lógica e regressão | 390 verificações, zero falhas |
| JOGAR completo | 33 verificações, entrega e manutenção |
| Turno completo, dois pedidos e sete abas | 68 verificações |
| Recusa e conclusão | 43 verificações |
| Modo livre, oito teclas, compra, produção e entrega | 123 verificações |
| Geometria independente | 56 verificações |
| Recursos e parser | 105 recursos e 79 GML válidos |
| Visuais | 24 sprites, 31 quadros válidos |

Os novos casos verificam aceite sem visitas extras, receita do canhoto,
presença no Estoque, retirada em uma viagem, repetição, transporte, depósito,
pedido de 50 unidades com várias viagens, compra necessária e não duplicação
de compras em trânsito. As regressões exercitam pausa, manutenção, recursos,
recusa, timeout, pagamento único e reinício.

Edge/HTML5: percurso de aceite → Caio → depósito → produção → entrega,
com uma viagem e duas decisões; pausa e encerramento aos 300 segundos;
menu sem partida, parâmetros, tela cheia e janela de 1024 pixels. Zero erros
JavaScript. Telas de menu, canhoto, estoque, mochila, depósito, decisões,
resultados e parâmetros inspecionadas em capturas.

O QA usa cliques/teclas reais. Os percursos nativos aceleram deslocamento e
preparo. No navegador, o ator é posicionado nas estações e o relógio é
adiantado para testar os limites; não é uma rodada manual de cinco minutos.

## Evidências e fonte

- Lógica: `.testes/qa-canhoto-logica-final-20261105`.
- Turno: `.testes/20261105-084839-306654`.
- JOGAR: `.testes/20261105-084619-964943`.
- Livre: `.testes/qa-canhoto-livre-20261105-a`.
- Recusa: `.testes/qa-canhoto-recusa-20261105-a`.
- Navegador: `.testes/browser/canhoto-qa.json` e capturas `canhoto-*.png`.
- Cópia dos logs e capturas: `docs/evidencias-canhoto-20261105`.
- Exportação final: `build/html5-20261105-090014`.
- Backup anterior: `C:/fabrica/.backups/antes-simplificacao-20261105-083426.zip`.

Os fontes GML ativos ficam no projeto apontado pelo workspace. O site usa o
mesmo projeto Sites público, com uma nova exportação oficial, sem recriar o
jogo em JavaScript e sem push ao GitHub original.

## Publicação

[Versão publicada](https://fabrica-salgados-mundo-senai.casottimarinetti.chatgpt.site),
versão 6, acesso público preservado e status `succeeded` confirmado pelo Sites.
Commit do site: `26e4c066283a8d34d181ceb04d657eb2007723a3`.
Registro: `C:/fabrica/entregas/publicacao-canhoto.json`.
