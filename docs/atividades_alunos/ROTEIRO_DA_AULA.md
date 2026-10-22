# Roteiro da aula — personalizar a Fábrica de Salgados

**Data sugerida: 23/10/2026. Duração: 50 minutos, ajustável.**

## Objetivo pedagógico

Relacionar comunicação visual, funções profissionais e organização dos setores de uma fábrica. Ao melhorar um recurso real do jogo, o estudante pratica pixel art, trabalho em equipe e teste de software, observando como atendimento, estoque e produção se conectam. Os sistemas de gestão já estão prontos; não é necessário programá-los nesta aula.

## Preparação do professor

1. Disponibilize uma **cópia independente do projeto completo** por grupo; abra `BLANK GAMEFabricaDeSalgados.yyp` no GameMaker 2026.0.0.16 com runtime 2026.0.0.23 ou no ambiente previamente validado. Não abra a mesma pasta compartilhada em vários computadores.
2. Execute F5 em Windows/VM e confira o início antes da aula. Demonstre caminhar, usar E, ler falas e abrir Ajuda / Objetivo. O progresso dura apenas enquanto o jogo está aberto: fechar o Runner começa outra sessão.
3. Mantenha uma cópia original para comparação e integração. Combine exatamente quais sprites cada grupo editará, especialmente bancada/prateleira compartilhadas. Se faltarem máquinas/licenças, distribua os papéis de artista, testador e relator em uma máquina por grupo.
4. Mostre o [guia com todos os nomes reais](GUIA_DE_SPRITES.md). Esta aula altera imagens pela IDE, sem trocar scripts nem arquivos estruturais.

## Divisão dos grupos

| Grupo | Recursos autorizados | Entrega sugerida |
| --- | --- | --- |
| [Comercial](ATIVIDADE_COMERCIAL.md) | spr_com_balcao_aula, spr_com_computador_aula, spr_com_placa_aula, spr_com_decoracao_aula | Um móvel e uma placa/decoração. |
| [Produção](ATIVIDADE_PRODUCAO.md) | spr_prod_bancada_aula, spr_prod_fogao_aula, spr_prod_utensilios_aula, spr_prod_placa_aula, spr_prod_decoracao_aula | Bancada ou fogão e um detalhe de cozinha. |
| [Estoque](ATIVIDADE_ESTOQUE.md) | spr_est_caixas_aula, spr_est_prateleira_aula, spr_est_computador_aula, spr_est_placa_aula, cinco spr_est_placa_<ingrediente>_aula, spr_est_decoracao_aula | Prateleira e uma etiqueta legível. |
| [Personagens](ATIVIDADE_PERSONAGENS.md) | spr_cozinheiro_temp, spr_atendente_aula, spr_estoquista_aula, spr_gerente_aula, spr_cozinheira_bia_aula | Um NPC; cozinheiro com oito quadros se houver tempo. |

## Sequência de 50 minutos

1. **0–8 min — jogar e observar:** apresente a fábrica, o pedido de 10 coxinhas e os três setores. Peça que cada grupo identifique uma dificuldade de leitura visual.
2. **8–13 min — planejar:** escolha um ou dois sprites, registre os nomes e esboce a mudança. Confira tamanho e origem antes da edição.
3. **13–30 min — desenhar:** abra o sprite → Edit Image, preserve tela/transparência/origem. Salve frequentemente. Evite efeitos e animações maiores nesta primeira atividade.
4. **30–42 min — testar:** F5 → Novo jogo / Parâmetros → HISTÓRIA GUIADA → iniciar. Leia as falas; receba o pedido com Marta; consulte a bancada; retire o frango no Estoque; deposite na Produção; cozinhe 10 coxinhas e entregue no balcão. Use a ajuda se necessário. Não encerre dias na primeira missão. Verifique caminhada, colisões e painéis nos três setores.
5. **42–50 min — compartilhar:** apresente antes/depois, explique a relação com o trabalho do setor e entregue os recursos. O professor integra e executa novamente a missão inicial.

Caso o ciclo completo não caiba no tempo de cada grupo, o professor faz a verificação conjunta após receber os sprites. Isso deve ser registrado como pendente, não como teste executado pelos alunos.

## Passo a passo da integração

Pare o jogo e feche a IDE da cópia de destino antes de copiar recursos, para evitar gravações antigas. Faça um backup ou commit. Copie **somente as pastas inteiras dos sprites autorizados**, com .yy, PNGs e layers; preservando nome e estrutura. Abra o mesmo .yyp novamente, confira origem/quadros e pressione F5. A atividade não exige novos recursos nem mudanças no .yyp. Não copie toda a pasta do projeto de um aluno sobre a versão do professor.

Reexecute os checks opcionais `python tools/verificar_projeto.py` e `python tools/verificar_visuais.py`. Para testar o ciclo completo no Runner: `python tools/verificar_simulacao.py --historia negociar`. Os checks precisam do Python e o último também do runtime GameMaker; a aula e o jogo não dependem dessas ferramentas.

## Critérios simples de avaliação

| Critério | Evidência observável |
| --- | --- |
| Clareza | Setor, ingrediente ou função reconhecível; texto legível. |
| Consistência | Perspectiva, tamanho, origem e pés preservados. |
| Funcionamento | Jogo inicia; portas, colisões, E e missão continuam utilizáveis. |
| Processo | Capturas antes/depois, nomes dos sprites e relato do teste. |
| Justificativa | Grupo explica como sua arte ajuda a aprender ou orientar decisões. |

Cada critério pode receber **atendido / em desenvolvimento**, com oportunidade de revisão. Não avalie pela complexidade do desenho nem pelo resultado financeiro da partida.

## Arquivos que os alunos não devem modificar

- `BLANK GAMEFabricaDeSalgados.yyp`, seu `.resource_order` e `options/`.
- Todos os arquivos de `rooms/` e `objects/`, inclusive associações de sprite e eventos de `obj_aula_*`.
- Todos os `.gml` e `.yy` de `scripts/`. Em especial: `scr_estado`, `scr_produtos`, `scr_estoque`, `scr_compras`, `scr_producao`, `scr_pedidos`, `scr_tempo`, `scr_financas`, `scr_indicadores`, `scr_logistica`, `scr_mundo`, `scr_missoes`, `scr_historia`, `scr_parametros`, `scr_pedagogia`, `scr_dashboard`, `scr_exploracao_interface` e o adaptador `scr_visuais_alunos`.
- `tools/`, inclusive `recursos_visuais_alunos.json`, validadores e cenários automatizados.
- Sprites de outros grupos, sem acordo com o professor.

O trabalho autorizado fica em `sprites/<nome_autorizado>/`, **pela interface do GameMaker**. Não altere máscaras, origens, nomes ou referências. A explicação técnica fica no guia para o professor; o aluno pode concentrar-se na arte e no teste.

## Registro da entrega

Anote grupo, integrantes, sprites alterados, justificativa, testes realmente executados e dificuldades. Faça um commit por grupo após conferir a integração. Preserve a versão original para comparar e voltar a uma etapa anterior quando necessário.
