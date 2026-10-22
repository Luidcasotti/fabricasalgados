# Grupo Estoque — identificar e localizar

Objetivo: facilitar a localização dos ingredientes e diferenciar armazenamento de compras, com etiquetas legíveis e cores que também funcionem com texto.

## Recursos liberados

Sala de teste: **rm_estoque**. Um sprite de prateleira é compartilhado pelas cinco prateleiras. Cada ingrediente tem uma placa própria: preserve os nomes FARINHA, FRANGO, QUEIJO, ÓLEO e EMBALAGENS. Quantidades e mínimos continuam nos painéis funcionais.

| Elemento | Sprite real (pesquisar no GameMaker) | Objeto associado | Tamanho / origem X,Y |
| --- | --- | --- | --- |
| Caixas de ingredientes | `spr_est_caixas_aula` | `obj_aula_est_caixas` | 128×128 / (64,80) |
| Prateleira de ingredientes | `spr_est_prateleira_aula` | `obj_aula_est_prateleira` | 128×128 / (64,80) |
| Mesa com computador de compras | `spr_est_computador_aula` | `obj_aula_est_computador` | 128×128 / (64,80) |
| Placa ESTOQUE | `spr_est_placa_aula` | `obj_aula_est_placa` | 128×32 / (64,16) |
| Placa FARINHA | `spr_est_placa_farinha_aula` | `obj_aula_est_placa_farinha` | 96×24 / (48,12) |
| Placa FRANGO | `spr_est_placa_frango_aula` | `obj_aula_est_placa_frango` | 96×24 / (48,12) |
| Placa QUEIJO | `spr_est_placa_queijo_aula` | `obj_aula_est_placa_queijo` | 96×24 / (48,12) |
| Placa ÓLEO | `spr_est_placa_oleo_aula` | `obj_aula_est_placa_oleo` | 96×24 / (48,12) |
| Placa EMBALAGENS | `spr_est_placa_embalagens_aula` | `obj_aula_est_placa_embalagens` | 96×24 / (48,12) |
| Quadro ENTRADAS | `spr_est_decoracao_aula` | `obj_aula_est_decoracao` | 64×64 / (32,48) |

Sugestões: melhorar caixas e volumes, desenhar ícones pequenos nas etiquetas e destacar o computador de compras. Não represente a quantidade atual com caixas fixas: o desenho é decorativo e não muda conforme o estoque. O computador deste grupo é independente daquele do Comercial. Caio fica com o grupo Personagens.

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

Caminhe até cada prateleira, confira que sua placa corresponde ao ingrediente mostrado ao pressionar **E**, e feche o painel. Retire o frango solicitado pela missão: o ingrediente deve sair do depósito e aparecer na mochila. Leve-o à Produção e deposite. Abra **Caio / Compras** no computador; uma compra deve consumir dinheiro e ficar em trânsito até o prazo, sem chegada instantânea. Não encerre dias sem necessidade na primeira missão. A falta de queijo e a compra com prazo são trabalhadas na segunda missão.

Confira os nomes enquanto caminha por todo o Estoque: nem todas as prateleiras cabem ao mesmo tempo na câmera. Não mova as placas na sala; modifique a imagem no sprite.

Pergunta para apresentar: como localizar o ingrediente sem depender somente da cor?
