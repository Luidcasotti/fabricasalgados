# Grupo Produção — organizar a cozinha

Objetivo: tornar visível a diferença entre guardar ingredientes, preparar e cozinhar, sem implementar receitas ou alterar equipamentos funcionais.

## Recursos liberados

Sala de teste: **rm_producao**. A mesma bancada aparece **duas vezes**, em Mesa / Depositar e Bancada / Cozinhar; a alteração vale para ambas. A prateleira de utensílios e o quadro HIGIENE são apenas decoração.

| Elemento | Sprite real (pesquisar no GameMaker) | Objeto associado | Tamanho / origem X,Y |
| --- | --- | --- | --- |
| Bancada de preparo e mesa de depósito | `spr_prod_bancada_aula` | `obj_aula_prod_bancada` | 128×128 / (64,80) |
| Fogão industrial | `spr_prod_fogao_aula` | `obj_aula_prod_fogao` | 128×128 / (64,80) |
| Prateleira de utensílios de parede | `spr_prod_utensilios_aula` | `obj_aula_prod_utensilios` | 128×128 / (64,80) |
| Placa PRODUÇÃO | `spr_prod_placa_aula` | `obj_aula_prod_placa` | 128×32 / (64,16) |
| Quadro HIGIENE | `spr_prod_decoracao_aula` | `obj_aula_prod_decoracao` | 64×64 / (32,48) |

Sugestões: reforçar materiais e bordas da bancada, melhorar os botões do fogão, desenhar conchas/panelas e criar um símbolo de higiene. Preserve a palavra PRODUÇÃO. Não acrescente uma bancada desenhada no piso, pois ela não teria colisão. Bia fica com o grupo Personagens.

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

Na história guiada, receba o pedido e consulte a **Bancada / Cozinhar**. A cozinha começa sem frango: busque-o na prateleira de FRANGO do Estoque, carregue-o até a **Mesa / Depositar**, deposite e volte à bancada. Inicie as 10 coxinhas, aguarde a barra e confira que o lote termina uma única vez. Contorne os dois móveis. Confira fogão e utensílios ao explorar a cozinha, inclusive quando a câmera se move. O fogão é cenário; a produção continua acionada pela bancada existente.

Pergunta para apresentar: quais pistas visuais ajudam o jogador a entender a sequência de trabalho?
