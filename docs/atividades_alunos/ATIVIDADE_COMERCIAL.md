# Grupo Comercial — atendimento claro

Objetivo: ajudar o jogador a reconhecer onde recebe pedidos e onde entrega os salgados. Proponha uma identidade visual simples para a fábrica, mantendo a leitura dos textos.

## Recursos liberados

Sala de teste: **rm_comercial**. São quatro sprites independentes; a mesa já inclui o computador na mesma imagem.

| Elemento | Sprite real (pesquisar no GameMaker) | Objeto associado | Tamanho / origem X,Y |
| --- | --- | --- | --- |
| Balcão de entrega | `spr_com_balcao_aula` | `obj_aula_com_balcao` | 128×128 / (64,80) |
| Mesa com computador de vendas | `spr_com_computador_aula` | `obj_aula_com_computador` | 128×128 / (64,80) |
| Placa COMERCIAL | `spr_com_placa_aula` | `obj_aula_com_placa` | 128×32 / (64,16) |
| Vaso provisório | `spr_com_decoracao_aula` | `obj_aula_com_decoracao` | 64×64 / (32,48) |

Sugestões: mudar as cores do balcão, melhorar o monitor, redesenhar a placa mantendo a palavra COMERCIAL e decorar o vaso. Não desenhe produtos ou símbolos que pareçam novos botões. Marta fica com o grupo Personagens.

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

Converse com **Marta / Encomendas** e aceite o primeiro pedido de 10 coxinhas. Contorne mesa e balcão sem atravessá-los. Confira o texto COMERCIAL ao caminhar para dentro da sala, pois a câmera acompanha o personagem. Complete a produção com ajuda dos outros grupos e entregue em **Balcão / Entregar**. A imagem nova deve aparecer nos dois momentos, sem cobrir a identificação das interações.

Pergunta para apresentar: como sua mudança diferencia receber um pedido de entregar uma encomenda?
