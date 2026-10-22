# Visuais provisórios e substituição

A aula usa **24 sprites reais**: o cozinheiro já existente e 23 novos. Foram
exportados dos desenhos próprios em GML; placas e utensílios também são próprios.
São PNGs transparentes com metadados .yy compatíveis, registrados no .yyp.
Não há assets pagos ou de terceiros. Capturas na documentação não são sprites.

O inventário completo com nome real, objeto, tamanho e origem está no
[Guia de sprites](atividades_alunos/GUIA_DE_SPRITES.md). A atividade é editar
imagens existentes pela IDE, sem programação de sistemas.

| Área | Recursos personalizáveis |
| --- | --- |
| Comercial | Balcão, mesa com computador, placa COMERCIAL, vaso. |
| Produção | Bancada compartilhada, fogão, utensílios, placa PRODUÇÃO, quadro HIGIENE. |
| Estoque | Caixas, prateleira compartilhada, computador, placa ESTOQUE, cinco etiquetas, quadro ENTRADAS. |
| Pessoas | Cozinheiro principal, Marta, Caio, gerente, Bia. |

Projeção 2:1 (36×18 por ladrilho), câmera 640×360 e viewport 1280×720 sem
filtragem. Os móveis mantêm suas bases e a ordenação por profundidade. As placas
de ingredientes são desenhadas sobre o mobiliário para não perder legibilidade.
Piso, paredes, portas, pia, forno, cadeiras e plantas do corredor continuam por
primitivas GML; não são recursos liberados para a primeira aula.

O cozinheiro conserva 16×32 e origem (8,31), oito quadros: baixo, esquerda,
direita, cima, dois por direção. NPCs novos têm 24×40, origem (12,35). Móveis têm
128×128, origem (64,80). Placas e decorações possuem dimensões específicas no
guia. A apresentação dos sprites novos aceita quadros extras em ciclo de 4 fps;
o cozinheiro usa seu controle direcional original e deve manter oito quadros.
Retratos usam o primeiro quadro dos sprites reais do gerente e do cozinheiro.

O controlador consulta `spriteId` dos objetos `obj_aula_*` para desenhar. As
instâncias de apresentação estão nas salas e seus Draws locais ficam suprimidos,
sem comportamento. Não mova instâncias nem troque os eventos para editar aparência.
Colisões efetivas e alvos E continuam no mapa U/V; não dependem das máscaras ou
dos pixels desses sprites. Preserve tela e origem para manter a aparência
alinhada à geometria. Não amplie a ocupação aparente no chão.

Para arte definitiva que exija outra ocupação física, o professor/desenvolvedor
precisará adaptar mapa/colisão/alvos e refazer os testes. Isso fica fora desta
aula. Registre autoria e licença se importar arte externa futuramente.
