# Validação — missões e história

Windows/VM, IDE GameMaker 2026.0.0.16 e runtime 2026.0.0.23. ProjectTool oficial
abriu e normalizou os recursos (PROJECT SAVE/OPEN, código 0). Projeto principal
compilado sem injeção de testes. Validação estática: **44 recursos**, referências,
eventos, ordem de salas, instâncias e todos os quadros/camadas do sprite.

## Execuções aprovadas

| Conjunto | Verificações executadas | Falhas |
| --- | ---: | ---: |
| Regras anteriores da simulação | 72 | 0 |
| Interface anterior | 22 | 0 |
| Aprendizado/dashboard V0.1 | 54 | 0 |
| Logística/exploração anterior | 83 | 0 |
| Missões e história novas | 66 | 0 |
| Partida completa no modo livre | 123 | 0 |
| História: negociar e entregar no prazo | 206 | 0 |
| História: aceitar prazo original e entregar atrasado | 205 | 0 |
| História: recusar segundo pedido | 132 | 0 |
| **Total executado** | **963** | **0** |

As 963 verificações ocorreram em cinco execuções: uma suíte de regras e quatro
partidas. Há verificações comuns repetidas entre ramos; não são 963 cenários
independentes nem uma métrica de aprendizagem. Logs resultaram em
FDS_SIMULACAO_APROVADA ou FDS_PARTIDA_APROVADA. Evidências atuais:
evidencias-historia.json e imagens/historia-*.png. evidencias-exploracao.json
refere-se ao snapshot anterior, commit 3717f4f, não aos hashes da história atual.

## Cobertura nova

Introdução completa, leitura persistente, receita inicial viável e conservação
da transferência de preparação; proximidade e conversa real; entrar em sala
não avança etapa; ação fora da ordem não consome recursos; primeira recusa com
nova oferta sem apagar histórico; falta local/geral; retirada excessiva e falta
de dinheiro; pausa da barra, confirmação única do lote; lead time e recebimento
único; negociação/recusa/atraso; checkpoint financeiro e físico; período/fim;
dashboard com problemas, evidências e respostas reais; reinício e continuar.

Os três percursos da história atravessam as salas reais e usam E pelo Step normal,
hit tests da GUI, movimento com colisão e barra real. O driver opcional apenas
acelera caminhada por trajetos calculados; não teletransporta para as ações.
Ver informações da encomenda, ajuda e repetição de explicações foram exercitados.
Cada ramo chegou ao dashboard, navegou sete abas e iniciou outra sessão guiada.
O modo livre continua percorrendo seu ciclo e seis abas.

Resultados didáticos comparados aos dados reais, com os padrões:

| Ramo | Recebidos / entregues / recusados | Compras | Receitas | Variáveis | Resultado de caixa | Atrasos |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Negociar | 2 / 2 / 0 | R$ 14,00 | R$ 100,00 | R$ 5,00 | R$ 81,00 | 0 |
| Prazo original | 2 / 2 / 0 | R$ 14,00 | R$ 100,00 | R$ 5,00 | R$ 81,00 | 1 entrega / 1 dia |
| Recusar | 2 / 1 / 1 | R$ 0,00 | R$ 60,00 | R$ 2,50 | R$ 57,50 | 0 |

O prazo original do segundo pedido é dia 2; a compra no dia 1 chega no dia 3;
negociar combina dia 4. Capacidade total usada: 20 pontos em três dias observados
nos ramos de duas entregas; 10 em um dia no ramo de recusa. Todos os estoques,
lotes, movimentos e IDs foram auditados. Resultado de caixa não é lucro contábil.

## Reproduzir

```powershell
python tools/verificar_projeto.py
python tools/verificar_simulacao.py
python tools/verificar_simulacao.py --partida
python tools/verificar_simulacao.py --historia negociar
python tools/verificar_simulacao.py --historia comprar
python tools/verificar_simulacao.py --historia recusar
```

Python serve apenas ao desenvolvimento. Requer runtime/usuário GameMaker local;
--runtime e --usuario-runtime permitem outros caminhos. Cada execução copia o
projeto para destino novo (.testes por padrão), compila, roda e guarda logs e
capturas. Não sobrescreve destino existente; testes não executam na partida normal.
Uma execução não pode combinar --partida e --historia. Limite do Runner: 30 s.
Cada partida exige capturas das seis ou sete abas antes de aprovar.

## Limites

Automação usa APIs de entrada do GameMaker e hit tests; não comprova conforto de
teclado/mouse físicos, acessibilidade ou aprendizagem de estudantes reais.
Faltam avaliação humana e outras plataformas/resoluções/YYC. Arte e retratos
provisórios. Não há persistência em disco: checkpoint e Continuar duram somente
enquanto o programa está aberto. Nenhum bloqueador apareceu nos percursos testados.


## Preparação visual para a aula — 22/10/2026

O [relatório da aula](RELATORIO_AULA.md) e `evidencias-aula.json` registram os
checks atuais. ProjectTool SAVE/OPEN aceitou os 91 recursos; a compilação normal
Windows/VM confirmou 24 sprites, 30 objetos e dez salas. A suíte de regras
passou com 297 checks; o modo livre com 123 e a história negociada com 206
(total 626, com verificações comuns). A missão inicial foi executada até a
entrega; a história também concluiu o segundo pedido e o dashboard/reinício.

`python tools/verificar_visuais.py` valida 24 sprites/31 quadros PNG, dimensões,
origens, transparência, associações, 28 instâncias e hashes dos 26 módulos de
lógica anteriores. Só funções de desenho receberam integração visual.
Os ramos comprar/recusar conservam os testes da etapa anterior; não foram
reexecutados nesta alteração exclusivamente visual. A avaliação humana da turma
e a execução em outros computadores/plataformas continuam pendentes.
