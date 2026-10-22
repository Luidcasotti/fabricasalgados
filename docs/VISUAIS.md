# Visuais provisórios e substituição

Arte própria: móveis, NPCs, piso e paredes por primitivas GML; cozinheiro com
spr_cozinheiro_temp, sprite real registrado no .yyp, com .yy e PNGs de quadro/camada.
Sem assets externos pagos ou com licença pendente. Imagens da documentação são
capturas do Runner, não recursos de execução.

Sprite 16×32, origem (8,31) nos pés. Oito quadros: baixo, esquerda, direita, cima,
dois por direção; animação avança ao andar. Caixa nos pés consta no recurso;
colisão efetiva usa círculo U/V contra volumes dos móveis/bordas, não a roupa.

Projeção 2:1 (36×18 por ladrilho), câmera nativa 640×360 e viewport 1280×720 sem
filtragem. Profundidade usa base dos móveis/pessoas. Portas são plataformas
amarelas identificadas, com troca real de sala por E. A GUI não desloca com câmera.

| Elemento | Ponto de substituição |
| --- | --- |
| Cozinheiro | spr_cozinheiro_temp e ator em mundo_desenhar. |
| NPCs | iso_pessoa / entradas tipo npc em mundo_criar. |
| Equipamentos | iso_movel e volumes em mundo_criar. |
| Piso, paredes, portas, placas | mundo_desenhar / alvos de mundo_criar. |
| HUD e painéis | scr_exploracao_interface. |
| Fonte e cores | scr_interface, preservando acentos. |
| Menu/protótipo anterior | scr_cenario / scr_isometria. |

Faça backup e importe Sprite pela IDE. Confira .yy/.yyp, preserve origem nos pés
e âncora U/V, adapte explicitamente direções/quadros. Não amplie de novo: a view
já amplia. Se mudar ocupação no chão, atualize volume de colisão e deixe alvo E
alcançável fora do móvel. Teste oclusão, quatro direções, contorno dos equipamentos,
portas e transporte antes de trocar próxima arte. Registre autoria/licença futura;
não remova colisão/interação ao substituir apenas o desenho.
