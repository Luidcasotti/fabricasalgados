# Relatório de entrega — V0.1

Data: 21/10/2026, fuso America/Rio_Branco.
Repositório: https://github.com/Luidcasotti/fabricasalgados.

## Funcionalidades entregues

- Projeto GameMaker/GML existente preservado, com salas reais de menu,
  parâmetros, fábrica e dashboard/resultados; Room1 original mantida.
- Fábrica isométrica com Comercial, Estoque, Produção, gestor e funcionários.
- 51 parâmetros editáveis, duração validada e restauração completa dos padrões.
- Receitas configuráveis, cinco insumos, compras pagas com prazo e trânsito.
- Produção planejada por quantidade, reservas de recursos/capacidade/caixa,
  cancelamento e execução sem saldos físicos negativos.
- Ofertas únicas, aceite/recusa, fila, histórico, entregas e atrasos preservados.
- Avanço manual em ordem fixa e encerramento pelo número de dias processados.
- Pausa, consulta durante a partida, retomada, reinício e retorno ao menu.
- Dashboard de seis abas: Panorama, Produção, Estoque, Reflexão, Diário, Eventos.
- Indicadores calculados dos registros, fórmulas visíveis e não aplicável sem denominador.
- Feedbacks curtos de Marta, Caio e Bia e diário com dia, ação e consequência.
- Resultado negativo permitido até o fim do período; sem Game Over definitivo.
- Arquitetura de casos pedagógicos extensível, manuais e ferramentas de teste.

## Revisão técnica e testes efetivamente realizados

**172 verificações aprovadas**, executadas em GML pelo runtime GameMaker:

| Grupo | Verificações | Resultado |
| --- | ---: | --- |
| Domínio e conservação | 72 | Zero falhas |
| Interação com controladores | 22 | Zero falhas |
| V0.1: fim, métricas, pausa e pedagogia | 54 | Zero falhas |
| Partida pelas salas reais, término, análise, reinício e menu | 24 | Aprovada |

Durante os testes foi corrigida uma referência de variável no registro da pausa.
As execuções posteriores passaram. A partida completa verificou compra com
chegada, produção, entrega, custo/receita, pausa, resultados parciais, encerramento
automático, seis abas, reinício com novos dados e reabertura do fim pelo menu.

O projeto principal compilou em Windows/VM na IDE/runtime instalados.
Há **29 recursos** (5 salas, 5 objetos, 19 scripts); .yyp/.yy, eventos GML,
referências, persistência, inicialização e ordem de salas foram conferidos.
Os novos .yy foram criados com GMSync e normalizados pelo ProjectTool da IDE.
Room1, opções e desenho isométrico existentes foram preservados.

O projeto foi reaberto na IDE: SUCCESSFUL LOAD AND LINK e OnProjectLoaded
confirmados. No workspace real, GMSync confirmou 5 objetos, 19 scripts e 5 salas.
A leitura de recursos/linguagem foi verificada; isso não certifica IntelliSense
semântico completo. Os avisos conhecidos de instalação não bloquearam o projeto.

As capturas das seis abas, parâmetros e balões foram inspecionadas. Exemplos
estão em docs/imagens. Logs e cópias ficam em C:\fabrica\.backups; comandos e
marcadores reproduzíveis em [VALIDACAO.md](VALIDACAO.md).

Não há teste pendente que impeça iniciar e terminar a partida em Windows/VM
na instalação verificada. YYC, instalador, exportações e outras plataformas
não foram certificados. Limites funcionais estão em MELHORIAS_FUTURAS.md.

## Abrir e executar

1. Clone/baixe o repositório e abra **BLANK GAMEFabricaDeSalgados.yyp** no GameMaker.
2. Ambiente verificado: **IDE 2026.0.0.16**, **runtime 2026.0.0.23**.
3. Selecione **Windows / VM** e pressione **F5**.
4. Clique em **Novo jogo / Parâmetros**, defina a duração e inicie.
5. No fim, examine o dashboard ou use **Reiniciar / Parâmetros**.

Não é preciso instalar extensões para jogar. Para editar no VS Code, execute
ABRIR_NO_VSCODE.cmd. Toda lógica do jogo e dos testes é GML; Python é só uma
ferramenta opcional de desenvolvimento. Os gráficos são originais e não dependem
de pacotes pagos ou de licença não verificada.

## Problemas conhecidos e cuidados

Não existe salvamento de sessão em disco. Fechar ou iniciar outra partida
perde os dados atuais. Não há contabilidade completa, perdas, perecimento,
IA, crédito, multa ou entregas parciais. Resultado de caixa não é lucro.
Esses limites não impedem a atividade de duração finita implementada.

O dia 1 é preparação; duração de cinco significa cinco dias de operação,
processados nos dias 2–6. Esse critério está visível na configuração e nos manuais.
