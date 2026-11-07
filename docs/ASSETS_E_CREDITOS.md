# Assets e créditos

## Código, cenário e atividade visual

O projeto mantém o código GML e os recursos desenvolvidos para a atividade Fábrica de Salgados. Os sprites da aula ficam em `sprites/` e são associados aos objetos `obj_aula_*`; dimensões, origens e objetos estão no [guia dos sprites](atividades_alunos/GUIA_DE_SPRITES.md). O cozinheiro mantém oito quadros direcionais.

Piso, paredes, parte dos móveis, portas e motoboy usam desenho GML. O texto SENAI HUB no chão usa a fonte normal do jogo, com SENAI azul e HUB laranja, conforme a orientação do responsável pelo projeto. As capturas em `docs/` são evidências do jogo, não assets de cenário.

## Fontes e áudio

Os quatro atlas `fonts/fnt_interface_*` foram gerados a partir de **Segoe UI** instalada no Windows, pelo script `tools/gerar_fontes.py`. Os arquivos `.ttf` da fonte não são incluídos. O script requer Pillow somente para regeneração; os atlas já fazem parte dos recursos GameMaker.

Os seis efeitos curtos em `sounds/` são gerados por síntese no script `tools/gerar_feedback.py`, usando a biblioteca padrão do Python. Não há biblioteca sonora externa carregada durante o jogo.

## Ferramentas e licenciamento

GameMaker/GML é a plataforma de execução. Python, Node e o parser GML opcional são ferramentas de desenvolvimento. A página Web usa HTML/CSS/JavaScript e hospeda o exportado oficial.

Não existe arquivo `LICENSE` definindo uma licença geral do projeto nesta versão. Este registro documenta a proveniência dos arquivos; não atribui uma licença de terceiros a eles. Novas contribuições devem registrar autor e origem dos assets adicionados.
