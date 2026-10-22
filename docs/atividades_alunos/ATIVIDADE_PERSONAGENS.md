# Grupo Personagens — funções reconhecíveis

Objetivo: reconhecer as pessoas da fábrica por roupa, silhueta e acessórios. As falas, a movimentação e as missões já existem.

## Recursos liberados

| Personagem | Sprite real | Objeto associado | Tamanho / origem X,Y |
| --- | --- | --- | --- |
| Cozinheiro principal, controlado pelo jogador | `spr_cozinheiro_temp` | `obj_cozinheiro` | 16×32 / (8,31) |

| Elemento | Sprite real (pesquisar no GameMaker) | Objeto associado | Tamanho / origem X,Y |
| --- | --- | --- | --- |
| Atendente Marta | `spr_atendente_aula` | `obj_aula_atendente` | 24×40 / (12,35) |
| Estoquista Caio | `spr_estoquista_aula` | `obj_aula_estoquista` | 24×40 / (12,35) |
| Gerente | `spr_gerente_aula` | `obj_aula_gerente` | 24×40 / (12,35) |
| Cozinheira Bia | `spr_cozinheira_bia_aula` | `obj_aula_cozinheira_bia` | 24×40 / (12,35) |

Marta está no Comercial, Caio no Estoque e Bia na Produção. O gerente aparece no Corredor durante a história guiada e no retrato das falas de gestão. O retrato do cozinheiro também usa seu sprite real. **Não troque o personagem controlável por Bia**: são recursos distintos.

O cozinheiro principal tem **oito quadros**, nesta ordem: 0–1 baixo, 2–3 esquerda, 4–5 direita, 6–7 cima. Preserve os oito quadros e os pés na mesma posição. Sugestão de primeira edição: alterar as cores da roupa em todos os quadros, sem deslocar a silhueta. Os quatro NPCs novos têm um quadro cada; uma animação simples é opcional conforme o guia.

## Como editar e testar

1. Abra `BLANK GAMEFabricaDeSalgados.yyp` da cópia entregue ao grupo. Localize a **raiz que contém o .yyp**, sem criar outro projeto.
2. No **Asset Browser / Navegador de recursos**, pesquise o nome exato do sprite da tabela. Abra-o com dois cliques e entre em **Edit Image / Editar imagem**.
3. Use lápis e cores para modificar a imagem existente. Preserve dimensões, origem, transparência e o nome do recurso. Não use redimensionamento automático da tela. Veja o [guia de sprites](GUIA_DE_SPRITES.md).
4. Salve com **Ctrl+S**. Selecione **Windows / VM** e pressione **F5**. Entre por **Novo jogo / Parâmetros**, mantendo **HISTÓRIA GUIADA** e os padrões para comparar com a versão original.
5. Leia as falas com **CONTINUAR**. Caminhe com **WASD/setas**, entre nas portas e interaja com **E**. Feche os painéis com **FECHAR / E**. O botão **Ajuda / Objetivo** indica a etapa atual.
6. Confira a aparência de perto, durante a caminhada e com painel aberto/fechado. Não basta conferir a imagem no editor. Finalize o teste específico abaixo.
7. Pare a execução, salve e entregue uma captura antes/depois, os nomes dos sprites editados e duas frases sobre sua escolha visual. O professor integra as mudanças de um grupo por vez.

Edite somente as imagens autorizadas. Não arraste objetos nas salas, não troque associações e não altere eventos, máscaras, scripts ou parâmetros da simulação nesta atividade. A geometria de colisão e os alvos E já estão prontos.

## Teste específico

Leia a introdução e confira os retratos do gerente e do cozinheiro. Caminhe nas quatro direções, pare e volte a andar: a roupa deve permanecer consistente e os pés não devem saltar. Contorne balcões, bancadas e pessoas. Entre nos três setores, converse com Marta, Caio e Bia quando a interação estiver disponível e confirme que as falas continuam. Complete a primeira entrega. As interações são definidas por proximidade, não pelos pixels do desenho.

Pergunta para apresentar: quais características diferenciam cada função sem usar estereótipos?
