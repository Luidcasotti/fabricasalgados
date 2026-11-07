> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Melhorias de gestão — Fábrica de Salgados

Entrega local de 28/10/2026, fuso America/Rio_Branco.

## Projeto e proteção

O projeto ativo é `C:/Users/Luid Casotti/GameMakerProjects/fabrica/BLANK GAMEFabricaDeSalgados/BLANK GAMEFabricaDeSalgados.yyp`, conforme o workspace do VS Code. A pasta `C:/fabrica/FabricaDeSalgados` contém apenas os recursos iniciais e não foi usada para recriar o jogo.

- Branch de segurança: `seguranca/antes-melhorias-20261028`, apontando para o histórico anterior.
- Backup integral dos arquivos versionados e locais não ignorados: `C:/fabrica/.backups/antes-melhorias-20261028.zip`. Os 377 arquivos foram conferidos por conteúdo/SHA-256; o ZIP também guarda o diff Git anterior.
- Trabalho na branch `melhorias/gestao-fabrica-20261028`, construído sobre os arquivos locais existentes. As alterações permanecem disponíveis para revisão, sem commit ou push desta tarefa.
- Nenhum arquivo anterior removido. Salas, sprites, portas, cozinheiro e geometria preservados.

## Melhorias implementadas

1. **Introdução:** cinco falas curtas do funcionário, retrato do personagem existente, Enter, Espaço ou clique para avançar, botão PULAR INTRODUÇÃO e Esc para pular. Objetivo atual, lista de missões e ajuda continuam acessíveis.
2. **Missões presenciais:** corredor → consulta confirmada no computador de Caio no Estoque → encomenda de Marta → consulta à mesa de preparo → retirada e depósito dos ingredientes → produção → entrega e avaliação. Entrar na sala não conclui a consulta. Retirar materiais não substitui a conferência da receita. As APIs validam proximidade e preservam operações inválidas sem alterar recursos.
3. **Pedidos variados:** 20, 30, 40 e 50 unidades, usando uma bolsa de quantidades sem repetições consecutivas no conjunto padrão. Primeiro pedido: 20 bolinhas de queijo; segundo pedido do turno guiado: 30 coxinhas. Os três produtos existentes continuam disponíveis no modo livre. Pedidos exibem identificação, produto, quantidade, prazo e valor, com aceite/recusa únicos. A análise informa falta de ingredientes, capacidade comprometida e tempo de preparo. Aceitar um risco continua sendo uma decisão do jogador.
4. **Estoque fixo no topo:** Farinha, Frango, Queijo, Óleo e Embalagens. A barra representa o **total físico da empresa**, com Estoque, Cozinha e Mochila discriminados abaixo. As cores usam mínimo, nível crítico e referência máxima do ingrediente. Transferências preservam o total; consumo reduz o total; compras só entram quando recebidas. Uma borda discreta sinaliza atualização dos locais. Dados são lidos do estado real, sem um segundo saldo.
5. **Máquinas:** estado persistente na partida; padrão de três máquinas de 100 salgados/hora. O painel na Produção informa total, funcionando, paradas, capacidade nominal e disponível. Máquina em manutenção conta como indisponível.
6. **Falha e manutenção:** um evento previsível durante o primeiro preparo da feira, ou no segundo pedido do turno completo. Uma máquina parada reduz a taxa real de 300 para 200 salgados/hora e a cota disponível para novos lotes. A animação passa a progredir mais devagar. As três escolhas têm consequências descritas antes do clique:
   - Manutenção: R$ 15 e 8 segundos por padrão, enquanto as outras máquinas continuam trabalhando.
   - Continuar: mantém a capacidade reduzida, sem custo de reparo.
   - Reorganizar: usa a equipe para um reparo gratuito, com duração dobrada (16 segundos por padrão).
   O reparo recupera a capacidade. O custo é lançado uma única vez. Pausa congela preparo, manutenção e relógio. Com apenas uma máquina, a escolha gratuita permite recuperar a operação.
7. **Orientação:** mensagens curtas sobre falta local ou na empresa, próximo ingrediente, mochila cheia, depósito, preparo, entrega e escolhas de manutenção. Perguntas com bônus continuam opcionais. A receita só é consumida ao concluir e validar o lote.
8. **Resultados reais:** pedidos recebidos, aceitos, recusados, entregues e atrasados; unidades produzidas; consumo por ingrediente; falhas; tempo efetivo de manutenção; vendas, custos, bônus e resultado de caixa. A manutenção entra nos custos. O resumo pedagógico depende das entregas, atrasos e estoques reais. No dashboard completo, a aba Estoque ganhou a coluna CONSUMIDO e a aba Produção mostra falhas e manutenção.
9. **Feira:** padrão de quatro minutos, cozinha e mochila vazias, ingredientes no Estoque. Primeiro lote exige duas viagens por causa da mochila de 80 unidades. O prazo não é renovado por recusa. Timeout não entrega, não recebe receita e cancela o lote pendente sem consumir ingredientes. O resultado fica 30 segundos, com botão para o próximo colega. CONTINUAR / NOVOS PEDIDOS preserva o patrimônio; após derrota, retoma o pedido pendente. Após vitória, oferece outra encomenda. O modo completo também permite novos pedidos com Marta antes de encerrar os resultados.

## Parâmetros e escala de tempo

Em **MODO COMPLETO**, as páginas de parâmetros permitem ajustar quantidade de máquinas, produção por hora de cada uma, falhas (0 desliga / 1 ativa), custo e duração da manutenção, segundos da demonstração e segundos reais por hora simulada. O botão **TESTAR DEMONSTRAÇÃO** inicia a feira com esses valores. JOGAR usa os padrões.

A referência de estoque de cada ingrediente também é configurável. Ela determina a escala da barra; compras acima dessa referência continuam mostrando a quantidade numérica real, com preenchimento limitado a 100%.

Uma hora simulada corresponde a 180 segundos reais por padrão. Assim, 20 unidades a 300/h exigem 12 segundos de preparo sem falha. A taxa é recalculada durante o progresso. A cota diária existente permanece como limite adicional. O modo livre preserva o preparo imediato existente, com a validação da capacidade disponível; o evento guiado e a animação com decisões pertencem à feira e ao turno guiado.

O estado persiste entre as salas e pelo menu durante a execução. O salvamento em disco continua fora do escopo do projeto existente.

## Arquivos alterados

Inventário completo: [ARQUIVOS_MELHORIAS_20261028.txt](ARQUIVOS_MELHORIAS_20261028.txt), comparado com o ZIP inicial para separar esta tarefa das alterações locais anteriores.

| Área | Arquivos principais |
| --- | --- |
| Introdução e missões | `scr_historia`, `scr_missoes`, `scr_exploracao_interface` |
| Pedidos e configuração | `scr_pedidos`, `scr_estado`, `scr_parametros`, `obj_parametros/Create_0.gml` |
| Estoque e transporte | `scr_hud_estoque`, `scr_produtos`, `scr_logistica` |
| Máquinas, custos e resultados | `scr_producao`, `scr_financas`, `scr_indicadores`, `scr_dashboard`, `scr_feira` |
| Menu | `obj_menu/Draw_64.gml` |
| Testes | `scr_testes_missoes`, `scr_testes_feira`, `scr_testes_exploracao`, `scr_testes_simulacao`, `scr_testes_v01`, `tools/verificar_simulacao.py` |
| Documentação | `README.md`, `docs/REGRAS_SIMULACAO.md`, este relatório, inventário e evidências |

Os casos econômicos históricos usam uma configuração de teste explícita com as quantidades antigas para manter a comparação numérica. As novas regras têm casos próprios; não foram removidos os testes de conservação e finanças.

## Testes executados

Compilação e execução com **GameMaker runtime 2026.0.0.23, Windows VM**, instalados no computador. Python prepara cópias em `.testes`; o jogo continua inteiramente em GML.

| Verificação | Resultado |
| --- | --- |
| Lógica no Runner oficial | **345 verificações, zero falhas**: simulação 72, interface 22, V0.1 54, exploração 83, missões 57, feira 57 |
| Feira completa | **66 verificações**, iniciadas por TESTAR DEMONSTRAÇÃO, com consulta ao Estoque, mochila, depósitos, falha, manutenção e entrega |
| Turno completo | **171 verificações**, dois pedidos e sete abas do dashboard |
| Recusa do segundo pedido | **98 verificações**, recusa registrada e finalização preservada |
| Modo livre | **123 verificações**, oito teclas reais de movimento, colisões, salas/corredor, compra, produção, entrega, dashboard e reinício |
| Recursos GameMaker | 101 recursos: referências, eventos e frames válidos |
| Parser GML independente | 79 arquivos, zero erros sintáticos |
| Visuais existentes | 24 sprites / 31 PNGs, dimensões, origens, transparência e associações válidas |
| Geometria independente | 56 verificações aprovadas |

Os testes cobrem consumo único, transferência sem duplicação, chegada de compras, objetivos por ação, pausa, orçamento de manutenção, reparo gratuito, eventos desativados, restauração 200→300/h, timeout durante preparo, pagamento tardio bloqueado e retomada após derrota. Foram corrigidos um erro na nova coluna do dashboard e expectativas antigas do driver de interface; as execuções aprovadas estão preservadas.

Os percursos de QA atravessam a geometria com colisão e acionam os painéis/botões reais. A espera de preparo e manutenção é acelerada no teste; os limites do relógio são exercitados separadamente. Isso não mede a duração de um visitante nem substitui uma rodada presencial com os alunos. A interface foi inspecionada nas capturas. O botão TESTAR DEMONSTRAÇÃO foi exercitado na partida completa final; os valores personalizados foram validados na suíte final de lógica.

Logs, resultados JSON e capturas: [evidencias-gestao-20261028](evidencias-gestao-20261028/resultados.json).

## Abrir e verificar

Abra o `.yyp` do projeto ativo no GameMaker, pare a execução anterior e pressione **F5** com Windows/VM. Use **JOGAR** para a feira ou **MODO COMPLETO** para configurar o turno e testar a demonstração.

```powershell
python tools/verificar_projeto.py
python tools/verificar_simulacao.py
python tools/verificar_simulacao.py --historia feira
python tools/verificar_simulacao.py --historia turno
python tools/verificar_simulacao.py --historia recusar
python tools/verificar_simulacao.py --partida
node tools/verificar_gml.mjs
```

Execute as partidas com entrada de teclado uma por vez. A publicação Web e o GitHub não foram atualizados nesta tarefa.
