> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# JOGAR — um dia de dois minutos na fábrica

Jogo público: [https://fabrica-salgados-mundo-senai.cometknoll12.chatgpt.site](https://fabrica-salgados-mundo-senai.cometknoll12.chatgpt.site). Atualização de 27/10/2026.

## Rodada inicial

Ao apertar JOGAR, começa um único dia de 120 segundos com a cozinha e a
mochila inteiramente vazias. O almoxarifado conserva os ingredientes iniciais.
Aceite o pedido de 10 bolinhas de queijo com Marta no Comercial e confira
a Mesa de preparo na Produção.

Busque no Estoque: 10 porções de farinha, 20 de queijo, 10 de óleo e 10
embalagens. Tudo cabe na mochila, cuja capacidade é 80. A orientação aponta
para o próximo ingrediente, permitindo uma só viagem de abastecimento.
Deposite na Mesa de depósito, cozinhe na Mesa de preparo e entregue no Comercial.
Produto e quantidade continuam selecionados automaticamente.

## Barras de ingredientes

As barras de Farinha, Frango, Queijo e Óleo mostram somente a quantidade
disponível na COZINHA. Zero deixa a barra completamente vazia. Com um pedido
aceito, o preenchimento compara o disponível com a quantidade necessária.
O rótulo ESTOQUE abaixo mostra somente o que ficou na prateleira; MOCHILA
mostra o que está sendo transportado. Retirar não enche a barra: depositar
na cozinha enche, e consumir no preparo esvazia imediatamente.

## Relógio e encerramento

A barra no alto à direita mostra o tempo restante, de 2:00 até zero.
A metade do tempo dispara uma vez o lembrete: “Seu tempo está acabando!
Você vai conseguir entregar o pedido?”. Ele some em cinco segundos sem
interromper os controles nem esconder o botão de fechar as mesas.

O relógio começa no JOGAR, inclui ajuda e perguntas opcionais, e congela
somente durante a pausa explícita. Este modo não permite pular dias pelo
antigo comando Encerrar dia. Recusar e pedir outra oferta não renovam o tempo.

A entrega antes dos 120 segundos encerra com vitória. Ao atingir 120, a
rodada encerra sem entrega ou pagamento automático; o preparo ainda em
andamento é cancelado sem consumir ingredientes. Uma entrega tardia não
pode converter a derrota em vitória.

Nos dois resultados, o cabeçalho grande mostra MUNDO SENAI / GESTÃO NA PRÁTICA.
Na vitória: “Parabéns! Você conseguiu superar um dia na fábrica de salgados.”
Na derrota: mensagem positiva pela participação e indicação de tempo encerrado.
Ambos mostram “Deixe o próximo coleguinha jogar agora”.

A tela final fica 12 segundos para leitura e volta automaticamente ao menu.
PRÓXIMO COLEGA / INÍCIO permite antecipar a volta. A nova pessoa aperta
JOGAR para começar com tempo, estoque, caixa e bônus novos. O relógio não
fica gastando o tempo da próxima pessoa enquanto ela está no menu.

As perguntas opcionais e os bônus de R$ 10 continuam disponíveis.
O modo completo e o modo livre mantêm suas regras anteriores; a rodada
cronometrada desta atualização é o modo inicial JOGAR.

## Verificação

- 336 verificações de lógica aprovadas no Runner oficial; 48 da feira.
- 79 arquivos GML no parser independente, sem erros sintáticos.
- 101 recursos com referências, eventos e frames válidos.
- Exportação HTML5 oficial do GameMaker 2026.0.0.23.
- Edge: cozinha vazia, quatro coletas, depósito, preparo, entrega e bônus.
- Relógio real, pausa, lembrete único, desaparecimento e fim exato testados.
- Derrota durante o preparo, vitória, volta automática e botão do próximo colega.
- Nenhum erro de JavaScript no teste do navegador.

O QA posiciona o ator nas estações e adianta o contador para verificar as
fronteiras de 60 e 120 segundos. Os controles, cliques e transições de estado
são reais; a espera de 12 segundos para reinício foi observada no navegador.
Esses saltos existem apenas no teste, sem código de QA publicado no jogo.
O relatório JSON e os logs estão em docs/evidencias-mundo-senai; capturas em
docs/imagens/day-*.png.

## Projeto e entrega

Projeto: `C:\Users\Luid Casotti\GameMakerProjects\fabrica\BLANK GAMEFabricaDeSalgados`; branch melhorias-mundo-senai, sem push ao GitHub original.
A publicação usa um checkout Sites separado em C:/fabrica/sites/fabrica-salgados-senai.
Backup anterior: C:/fabrica/.backups/antes-dia-dois-minutos-20261027.zip.
Pacotes novos em C:/fabrica/entregas com sufixo dia-2min.

```powershell
python tools/verificar_simulacao.py
node tools/verificar_gml.mjs
python tools/verificar_projeto.py
python tools/exportar_web.py
```

No navegador, atualize a página e aperte JOGAR. No GameMaker, pare e execute
novamente para carregar os arquivos alterados. Valores continuam fictícios,
sem salvamento em disco ou controles táteis. Outros navegadores não foram
retestados nesta atualização.
