# Visuais e personalização

O jogo usa 24 sprites registrados, incluindo o cozinheiro e os recursos de aula; quatro atlas de fonte, seis sons e desenho GML complementam a apresentação. Veja [assets e créditos](ASSETS_E_CREDITOS.md) e o [guia dos sprites](atividades_alunos/GUIA_DE_SPRITES.md).

## Apresentação atual

O mapa usa projeção isométrica. A câmera do corredor é 1088×612, e a dos setores, 640×360, com GUI 1280×720. O nome **SENAI HUB** é texto horizontal normal pintado no chão; não utiliza o mosaico das revisões antigas.

Os componentes GUI usam fontes incorporadas nos tamanhos 16, 22, 30 e 40, com acentos e filtragem para leitura. O motoboy é desenhado em GML com moto, capacete e baú e acompanha as compras reais. A área de recebimento fica marcada no Estoque.

## Editar sprites

Use a IDE para editar os PNGs associados a `obj_aula_*`. Preserve origem, tamanho e ocupação do piso. O cozinheiro usa 16×32, origem (8,31), oito quadros direcionais. Recursos da atividade têm contratos próprios no guia; não altere o mapa por mover uma instância de apresentação.

O desenho é ordenado por profundidade. As colisões e os alvos E vêm do mapa U/V, não da aparência ou da máscara do sprite. Uma arte que ocupe outra área precisa de revisão do mapa e dos testes de passagem.

Execute `python tools/verificar_visuais.py` após mudar recursos. A opção `--logica-original-aula` verifica hashes do snapshot anterior da aula e não é uma condição de aprovação da lógica atual, que evoluiu desde aquela entrega.
