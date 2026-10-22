# Cenário isométrico e substituição dos gráficos

Todos os gráficos desta etapa foram desenhados originalmente em GML.
Não há sprites baixados, fontes externas, assets pagos ou licenças de terceiros
associadas ao cenário. Os cinco novos scripts estão registrados no .yyp com .yy.
Não são necessários recursos GMSprite enquanto o desenho usa primitivas.

## Composição

- **Comercial**: piso bege, mesa com computador, cadeira, balcão de atendimento,
  janelas, planta, gestor com prancheta e atendente.
- **Estoque**: piso verde, duas prateleiras com caixas, pallet e estoquista.
- **Produção**: piso azulado, pia industrial, bancada com salgados, fogão/coifa,
  fritadeira, forno e cozinheiro com chapéu.

São quatro pessoas estáticas e 13 elementos de mobiliário. Os três setores
usam pisos distintos e faixas amarelas de circulação. Paredes ficam ao fundo
para manter o interior visível. Projeção de razão 2:1, inspirada em pixel art.

## Coordenadas, profundidade e interação

GUI: 1280 × 720. Cenário: superfície transparente 640 × 360, ampliada 2× com
filtro de textura desligado durante a cópia e restaurado depois. Perda da
superfície provoca sua recriação; Clean Up libera a memória.

Em scr_isometria, iso_ponto(u,v,z) retorna:

```gml
x = 386 + (u - v) * 18;
y = 95 + (u + v) * 9 - z;
```

U/V medem ladrilhos; Z mede altura em pixels da superfície. Objetos e pessoas
compartilham ordenação por U+V. Isso basta para esta composição estática;
objetos maiores/futuros personagens móveis podem exigir ordenação pelo pé
da imagem ou subdivisão de elementos que se cruzam.

cenario_setor_em converte o mouse GUI para meia resolução e usa iso_inverter.
Os retângulos U/V dos setores ficam em cenario_criar. O piso inteiro do setor
é clicável; móveis não têm mecânicas próprias nesta etapa. Etiquetas e botões
inferiores são alternativas de acesso com alvos grandes.

O painel tem prioridade sobre o cenário: cliques em seu interior não chegam
ao piso. X fecha sem reabrir nada atrás. Clique fora só fecha. Abas inferiores
trocam diretamente de setor; ESC fecha o painel antes de voltar ao menu.

## Onde trocar por sprites definitivos

| Elemento | Ponto de substituição |
| --- | --- |
| Pessoas | iso_pessoa, em scr_isometria |
| Mesas, prateleiras, caixas e equipamentos | casos de iso_movel, em scr_isometria |
| Piso e paredes | cenario_desenhar, em scr_cenario |
| Posições e tipos do mobiliário | array moveis em cenario_criar |
| Áreas dos setores | array setores em cenario_criar |
| Painéis, etiquetas e botões | fabrica_layout e funções de desenho em scr_fabrica_interface |
| Fonte e cores | visual_iniciar e ui_texto, em scr_interface |

Procedimento recomendado:

1. Guarde uma cópia do projeto. Importe a imagem pelo GameMaker como Sprite
   e confirme seu registro no .yyp e o .yy criado pela IDE.
2. Produza a arte na resolução do cenário. Um personagem tem aproximadamente
   15 × 34 pixels na superfície e aparece com o dobro no jogo.
3. Configure a origem do sprite no ponto de contato com o piso (pés/base).
   Preserve U/V como âncora e a razão isométrica dos ladrilhos (36 × 18 pixels).
4. Substitua somente o desenho correspondente por draw_sprite, usando o ponto
   retornado por iso_ponto. Mantenha a ordenação e as áreas de interação.
   Não aplique uma ampliação extra: a superfície já é ampliada 2×.
5. Preserve um fallback de primitivas durante a migração. Teste oclusão,
   abertura dos três painéis, clique fora, fechamento e resolução da GUI.
6. Guarde a autoria/licença de qualquer arte futura. Se substituir a fonte,
   inclua os glifos portugueses (Á, Ã, É, Í, Ó, Õ, Ú, Ç e acentos usados).

A fonte atual é um alfabeto bitmap 5×7 definido em GML com acentos desenhados.
Ela evita depender da fonte interna limitada e mantém a interface legível.
