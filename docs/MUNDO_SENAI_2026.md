> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Fábrica de Salgados — história intuitiva, 27/10/2026

**Atualização do modo JOGAR:** cozinha vazia, dia de 120 segundos, lembrete e reinício para o próximo colega. Veja [regras e validação atuais](DIA_DE_2_MINUTOS.md). O roteiro abaixo continua descritivo do modo completo; a preparação inicial da cozinha não se aplica mais ao JOGAR.

Jogo público: [https://fabrica-salgados-mundo-senai.cometknoll12.chatgpt.site](https://fabrica-salgados-mundo-senai.cometknoll12.chatgpt.site). Esta versão substitui o roteiro guiado anterior.

## O turno

JOGAR começa um pedido de 10 bolinhas de queijo. O percurso é:

1. Comercial: E com Marta, ACEITAR.
2. Produção: E na MESA DE PREPARO para ver a receita.
3. Estoque: E na prateleira QUEIJO, BUSCAR INGREDIENTE. A sugestão é 20 porções.
4. Produção: E na MESA DE DEPÓSITO, DEPOSITAR.
5. Mesa de preparo: COZINHAR PEDIDO. O produto e a quantidade já estão selecionados.
6. Comercial: E no balcão ENTREGAR, confirmar e receber o pagamento.

A equipe já separou farinha, óleo e embalagens, retirando do estoque real.
Há 100 porções de queijo no Estoque; basta buscar, sem compra obrigatória.
O modo completo oferece depois 10 coxinhas, pelo mesmo percurso, buscando
frango. O modo livre continua disponível.

A lista à esquerda e a linha AGORA mostram o próximo passo. O avanço depende
do pedido e dos ingredientes reais. Retirar ou depositar antes de conferir a
mesa é permitido. Retiradas e lotes parciais não prendem a história: a mesa
calcula o que falta preparar. Compras continuam possíveis, com prazo real;
se faltar na empresa inteira, a orientação leva à reposição e à espera.

## Avisos e perguntas

Erros aparecem somente no rodapé, com uma ação concreta. O aviso some em
cinco segundos, pode ser fechado pelo X e é descartado na próxima interação
válida. Não há janela persistente da gestora nem pergunta abstrata anexada
a uma tentativa inválida.

PERGUNTA / +R$ 10 abre uma pergunta opcional sobre buscar, depositar ou entregar.
Cada acerto soma R$ 10 ao caixa uma única vez por pergunta e sessão. Um erro
mostra a explicação, sem desconto. Fechar por X, E ou Esc sem responder
preserva a chance. A produção e a entrega não exigem responder perguntas.
Os bônus têm movimentos financeiros próprios, separados da receita de vendas,
e entram no resultado de caixa, na auditoria e na tela final.

## Controles

WASD/setas: mover. E: abrir/fechar uma mesa ou prateleira. H: ajuda.
Esc: fechar pergunta ou painel, ou pausar. M: silenciar. F11: tela cheia no
Windows. Na Web, use o botão Tela cheia. Atualize a página para carregar a
versão nova e inicie outra partida. No GameMaker, pare e rode novamente.

## Verificação desta versão

| Verificação | Resultado |
| --- | --- |
| Registro do projeto | 101 recursos; referências, eventos e frames válidos |
| Parser GML | 79 arquivos; zero erros sintáticos |
| Lógica no Runner oficial | 309 verificações aprovadas |
| Turno completo / duas entregas | 124 verificações aprovadas nas salas reais |
| Recusa do segundo pedido | 75 verificações aprovadas |
| Web no Edge | Pedido completo, teclado/E, aviso/X/expiração, quiz/Esc/E, bônus e caixa |

O teste Web concluiu 10 bolinhas: R$ 40 de venda, R$ 20 em dois acertos,
uma resposta incorreta sem desconto e R$ 2,50 de preparo. Saldo final R$ 1.057,50.
Nenhum erro no console. Para acelerar o percurso de QA, o teste posiciona
o ator perto das estações; os cliques e teclas são reais. O teste nativo
percorre os mapas com as funções reais de movimento e colisão.
Logs, JSON e capturas estão em docs/evidencias-mundo-senai e docs/imagens.

```powershell
python tools/verificar_projeto.py
node tools/verificar_gml.mjs
python tools/verificar_simulacao.py
python tools/verificar_simulacao.py --historia turno
python tools/verificar_simulacao.py --historia recusar
python tools/exportar_web.py
```

## Projeto, exportação e limites

Projeto original: `C:\Users\Luid Casotti\GameMakerProjects\fabrica\BLANK GAMEFabricaDeSalgados`. Branch melhorias-mundo-senai; sem push ao GitHub
original. A publicação Sites usa repositório separado em
C:/fabrica/sites/fabrica-salgados-senai. O HTML5 é a exportação oficial do
GameMaker, sem reescrever as regras em JavaScript. Runtime 2026.0.0.23.

Backup anterior a esta alteração: C:/fabrica/.backups/antes-historia-intuitiva-20261027.zip.
Os pacotes desta etapa têm sufixo historia-intuitiva em C:/fabrica/entregas.
O ZIP Web deve ser servido por HTTP/HTTPS. Não contém credenciais de licença.
O inventário está em docs/ARQUIVOS_MUNDO_SENAI.txt. Relatórios anteriores
descrevem versões históricas e podem citar o roteiro antigo.

Ainda sem salvamento em disco ou controles táteis. Outros navegadores e a
duração com visitantes não foram aferidos. Valores e receitas são fictícios
para aprendizagem. A alteração de segurança autorizada na etapa anterior
permanece sem novas modificações nesta tarefa.
