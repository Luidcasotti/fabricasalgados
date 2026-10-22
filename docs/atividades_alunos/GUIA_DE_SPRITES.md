# Guia de sprites — contrato visual da aula

Preparado para **23/10/2026**. São **24 sprites reais personalizáveis**: 23 novos e o cozinheiro existente. Todos estão registrados no .yyp com imagens PNG transparentes e metadados .yy. Arte própria exportada das primitivas GML do projeto; utensílios e placas também são desenhos próprios. Nenhum asset pago ou de terceiros é necessário.

## Encontrar e editar

No Asset Browser do GameMaker, pesquise o **nome exato** abaixo, abra o sprite e escolha Edit Image. As categorias deste guia são de organização da aula; os recursos usam os prefixos spr_com_, spr_prod_, spr_est_ e os nomes de personagens. Não é necessário criar pastas virtuais ou reorganizar o projeto.

Na raiz do projeto, cada recurso está em `sprites/<nome>/<nome>.yy`; as imagens ficam na mesma pasta e em `layers/`. **Edite pela IDE**: ela mantém quadros, camadas e referências. Não renomeie PNGs nem edite .yy/.yyp como texto. Ao compartilhar, entregue a pasta inteira do sprite, depois de salvar na IDE.

## Dimensões, origem e perspectiva

| Categoria | Dimensões em pixels | Origem X,Y | Quadros iniciais |
| --- | --- | --- | --- |
| Móveis, computadores e utensílios | 128×128 | 64,80 | 1 |
| Placas dos setores | 128×32 | 64,16 | 1 |
| Vaso e quadros decorativos | 64×64 | 32,48 | 1 |
| Etiquetas de ingredientes | 96×24 | 48,12 | 1 |
| NPCs | 24×40 | 12,35 | 1 |
| Cozinheiro principal | 16×32 | 8,31 | 8 |

A origem é a âncora que posiciona o desenho; não precisa ser o centro da imagem. Preserve os valores mostrados na IDE (origem personalizada quando necessário). A área transparente faz parte do alinhamento. Desenhe próximo da silhueta original, sem expandir a ocupação aparente do chão.

O piso tem proporção isométrica **2:1**: uma diagonal de dois pixels na horizontal sobe ou desce um na vertical; um ladrilho mede 36×18. Preserve as faces e a base dos móveis. Use lápis sem suavização, fundo transparente e contraste com o piso. A câmera 640×360 amplia para 1280×720; não duplique o tamanho do sprite. Placas devem manter os nomes e os acentos.

## Lista completa de recursos e associações

### COMERCIAL

| Elemento | Sprite real (pesquisar no GameMaker) | Objeto associado | Tamanho / origem X,Y |
| --- | --- | --- | --- |
| Balcão de entrega | `spr_com_balcao_aula` | `obj_aula_com_balcao` | 128×128 / (64,80) |
| Mesa com computador de vendas | `spr_com_computador_aula` | `obj_aula_com_computador` | 128×128 / (64,80) |
| Placa COMERCIAL | `spr_com_placa_aula` | `obj_aula_com_placa` | 128×32 / (64,16) |
| Vaso provisório | `spr_com_decoracao_aula` | `obj_aula_com_decoracao` | 64×64 / (32,48) |

### PRODUCAO

| Elemento | Sprite real (pesquisar no GameMaker) | Objeto associado | Tamanho / origem X,Y |
| --- | --- | --- | --- |
| Bancada de preparo e mesa de depósito | `spr_prod_bancada_aula` | `obj_aula_prod_bancada` | 128×128 / (64,80) |
| Fogão industrial | `spr_prod_fogao_aula` | `obj_aula_prod_fogao` | 128×128 / (64,80) |
| Prateleira de utensílios de parede | `spr_prod_utensilios_aula` | `obj_aula_prod_utensilios` | 128×128 / (64,80) |
| Placa PRODUÇÃO | `spr_prod_placa_aula` | `obj_aula_prod_placa` | 128×32 / (64,16) |
| Quadro HIGIENE | `spr_prod_decoracao_aula` | `obj_aula_prod_decoracao` | 64×64 / (32,48) |

### ESTOQUE

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

### PERSONAGENS

| Elemento | Sprite real (pesquisar no GameMaker) | Objeto associado | Tamanho / origem X,Y |
| --- | --- | --- | --- |
| Atendente Marta | `spr_atendente_aula` | `obj_aula_atendente` | 24×40 / (12,35) |
| Estoquista Caio | `spr_estoquista_aula` | `obj_aula_estoquista` | 24×40 / (12,35) |
| Gerente | `spr_gerente_aula` | `obj_aula_gerente` | 24×40 / (12,35) |
| Cozinheira Bia | `spr_cozinheira_bia_aula` | `obj_aula_cozinheira_bia` | 24×40 / (12,35) |

O recurso existente adicional é **spr_cozinheiro_temp → obj_cozinheiro**, 16×32, origem (8,31), oito quadros. Total: 24 sprites.

## Por que a colisão continua funcionando

A colisão usa círculo nos pés contra retângulos U/V, definidos em `mundo_criar`; os alvos E usam proximidade. Os pixels dos móveis e as máscaras destes novos sprites não comandam a simulação. Os 23 objetos `obj_aula_*` têm seu sprite associado e estão nas salas para identificação/preview; não têm Step, Create ou lógica de interação. O Draw local é suprimido e o controlador desenha o sprite associado na ordem de profundidade já existente. **Não mexa nesses eventos e não mova as instâncias.**

Alterar a imagem respeitando tamanho/origem não muda a colisão. Ampliar a silhueta pode criar uma diferença visual entre desenho e obstáculo; por isso mantenha a base original. A bancada é compartilhada por preparo/depósito, e a prateleira por cinco ingredientes. Piso, paredes, portas, pia, forno, cadeiras e plantas do corredor continuam desenhados em GML e ficam fora desta primeira edição.

## Animação simples opcional

Com autorização do professor, os **sprites novos** podem receber um segundo quadro com o mesmo tamanho/origem: um monitor piscando ou um personagem respirando. A apresentação alterna os quadros em ciclo de **4 por segundo**, sem mudar os sistemas. Não altere nomes, posição dos pés ou número de quadros do cozinheiro principal: ele mantém sua animação direcional original. Retratos usam o primeiro quadro para manter a leitura. Evite piscadas fortes.

## Conferência antes de entregar

1. Tamanho e origem conferem com a tabela; pixels vazios continuam transparentes.
2. F5 compila, a imagem aparece no setor certo e não há duplicação do desenho.
3. O personagem contorna os móveis e alcança as portas e os alvos E.
4. Painéis abrem/fecham e a primeira missão pode ser concluída.
5. Informe os nomes dos sprites editados e envie a pasta inteira de cada recurso. Não envie alterações de outros grupos ou arquivos da simulação.

O professor pode rodar `python tools/verificar_projeto.py` e `python tools/verificar_visuais.py` após integrar. O segundo valida dimensões, origens, imagens, associações, instâncias e a preservação dos módulos de lógica. Python é ferramenta opcional do desenvolvedor; não é necessário para jogar.
