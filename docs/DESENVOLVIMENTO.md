# Desenvolvimento

## Ambiente e instalação

O ambiente de validação usa Windows, GameMaker IDE **2026.0.0.16**, runtime **2026.0.0.23**, Python **3.12.10** e Node **24.19.0**. Outras versões não foram certificadas por esta documentação.

```powershell
git clone https://github.com/Luidcasotti/fabricasalgados.git
cd fabricasalgados
```

Abra `BLANK GAMEFabricaDeSalgados.yyp` na IDE. Windows/VM e F5 executam o jogo. HTML5 exige o módulo correspondente disponível no GameMaker e no perfil de licença local.

Python é necessário para as automações em `tools/`. Os verificadores de recursos e visuais usam a biblioteca padrão. Node é usado pelos verificadores opcionais de GML/geometria e pela validação de JavaScript exportado. Para **regenerar fontes**, instale a dependência opcional:

```powershell
python -m pip install -r requirements-dev.txt
```

Os atlas e sons já estão versionados; não é necessário regenerá-los para abrir o projeto.

## Estrutura

```text
BLANK GAMEFabricaDeSalgados.yyp    manifesto do projeto
objects/                         eventos e metadados dos objetos
scripts/                         módulos GML e testes
rooms/                           salas e instâncias
sprites/  fonts/  sounds/         assets usados no jogo
options/                         configuração das plataformas
tools/                           verificação, geração e exportação
web/                             página HTML e preparação do exportado
docs/                            guias, aulas, histórico e evidências
```

`.testes/`, `build/` e `web/dist/` são saídas locais ignoradas pelo Git. Não copie executáveis, caches da IDE, perfis de licença ou dependências `node_modules` para o repositório.

## Editar com segurança

A IDE mantém `.yy`, `.yyp` e `.resource_order`; registre novos recursos antes de referenciá-los. Arquivos GML podem ser editados no VS Code. `ABRIR_NO_VSCODE.cmd` abre a pasta com GMSync recomendado e Stitch desabilitado conforme a configuração existente. Essas extensões não são necessárias para jogar.

Evite salvar alterações estruturais simultaneamente na IDE e em ferramentas externas. Revise o diff para preservar sprites, origens, instâncias e recursos que não fazem parte da alteração.

## Pontos de configuração

| Mudança | Local principal |
| --- | --- |
| Capital, capacidade e duração | `parametros_padrao()` em `scr_estado` |
| Preset da história e sequência | `missoes_parametros()` e `missoes_plano()` em `scr_missoes` |
| Produtos, receitas e custos | `produtos_catalogo_criar()` em `scr_produtos` |
| Prazo do motoboy | Compra e atualização em `scr_compras` (atualmente 12 s) |
| Perguntas e introdução | `historia_conteudo()` em `scr_historia` |
| Banco de resgates | `feira_banco_resgates()` em `scr_feira` |
| Geometria, portas e alvos | `mundo_criar()` em `scr_mundo` |
| Nome no piso e moto | Funções de desenho em `scr_mundo` |
| Fontes e cores | `scr_interface` e `fonts/fnt_interface_*` |

Adicionar um ingrediente exige receita, catálogo, prateleira/alvo e validação; não basta criar um saldo. Ao ampliar missões, revise meta, estoque, textos de final e testes. Novos móveis precisam de alvos acessíveis fora do seu volume de colisão.

## Testar alterações

Comece pelos comandos de [Validação](VALIDACAO.md). Para mudanças de regra, rode a suíte no Runner. Para interface, confira a versão real no jogo/navegador: testes de estado não comprovam leitura ou posição dos botões. O código não precisa de uma conexão de rede para executar regras locais.

## Fontes e sons

`python tools/gerar_feedback.py` gera os efeitos curtos a partir de síntese local. `python tools/gerar_fontes.py` gera os quatro atlas usando Segoe UI instalada no Windows e Pillow. O caminho da fonte está nesse script; outro sistema precisa ajustá-lo antes de regenerar. Consulte a [proveniência dos assets](ASSETS_E_CREDITOS.md).

## Limites de implementação

A sessão vive em memória. Checkpoint, troca de sala e CONTINUAR não criam save em disco. Não há backend de jogadores, multiplayer ou integração com serviços externos. No Web, o HTML apenas hospeda o exportado GameMaker. O núcleo por dias permanece como compatibilidade histórica.
