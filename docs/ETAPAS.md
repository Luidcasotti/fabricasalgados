# Etapas — 21/10/2026

## Implementado e verificado

- Projeto existente preservado em GameMaker/GML, com fábrica isométrica e três setores.
- Cinco insumos: farinha, frango, queijo, óleo e embalagens; dados iniciais editáveis.
- Receitas, preços, custo variável e capacidade por salgado configuráveis.
- Compras pagas no ato, trânsito e chegada por prazo; mínimo gera aviso, não compra.
- Quantidades selecionáveis; planejamento com reservas e cancelamento antes da execução.
- Encomendas únicas por produto/dia, aceite/recusa, fila e histórico preservados.
- Entregas por produtos acabados, pontualidade e atrasos registrados.
- Avanço manual: chegadas → produção → entregas → prazos/ofertas → resumo paginado.
- Finanças separadas em receitas, compras, custos variáveis e resultado de caixa.
- Aviso explícito de números fictícios para aprendizagem nas telas e documentação.
- 26 recursos com referências, eventos e instâncias válidos.
- 94 verificações passaram no runtime Windows/VM, sem falhas: [VALIDACAO.md](VALIDACAO.md).
- Git inicializado em main, com autor Luidcasotti e endereço privado noreply escolhido.

## Preservação

Antes desta tarefa foi feita a cópia `C:\fabrica\.backups\antes-simulacao-principal.zip`.
O protótipo anterior foi preservado como primeiro commit do repositório; esta
etapa é uma evolução separada. Room1, opções, cenário isométrico e recursos
válidos não foram recriados. Novos .yy foram gerados pelo GMSync e normalizados
pelo ProjectTool da instalação.

Repositório de destino: https://github.com/Luidcasotti/fabricasalgados.
A sincronização final é conferida comparando o commit local ao main remoto.

## Próximos passos

Avaliar as regras com alunos, calibrar números didáticos e objetivos de
aprendizagem, decidir persistência de partidas e encerramento da atividade.
Funcionários seguem estáticos; não há IA, perecimento, contabilidade completa,
multas, crédito ou entregas parciais. As regras atuais estão em
[REGRAS_SIMULACAO.md](REGRAS_SIMULACAO.md).
