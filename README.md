# Fábrica de Salgados

Jogo educacional de gestão de estoque, produção, encomendas e caixa.
Implementado em **GameMaker / GML Code**, com fábrica isométrica desenhada em GML.
Todos os números, preços, prazos e receitas são **fictícios para aprendizagem**.

## Executar

1. Abra `BLANK GAMEFabricaDeSalgados.yyp` no GameMaker.
2. Use o alvo Windows/VM e pressione **F5**.
3. Selecione **Novo jogo / Parâmetros**, ajuste os valores e inicie a simulação.
4. Aceite ofertas no **Comercial**, compre insumos no **Estoque** e planeje
   quantidades na **Produção**. Clique em **Avançar dia** para executar o ciclo.

O arquivo mantém o nome original do projeto. Verificado na IDE 2026.0.0.16,
runtime 2026.0.0.23. Não há dependências externas obrigatórias, assets pagos
ou ponte TCP. Execute `ABRIR_NO_VSCODE.cmd` para editar com GMSync e Stitch
desabilitado na sessão por incompatibilidade com o formato instalado.

## Documentação

- [Como jogar e editar](docs/README.md)
- [Regras da simulação e ordem diária](docs/REGRAS_SIMULACAO.md)
- [Arquitetura e responsabilidades](docs/ARQUITETURA.md)
- [Verificações e cenários reproduzíveis](docs/VALIDACAO.md)
- [Substituir gráficos provisórios](docs/VISUAIS.md)
- [Etapas e próximos passos](docs/ETAPAS.md)

Os testes são escritos em GML. Ferramentas Python opcionais em `tools/`
validam os metadados e executam os testes em uma cópia pelo runtime instalado;
Python não é utilizado pela lógica do jogo.

O protótipo não salva a sessão em disco. **Continuar** mantém a sessão apenas
enquanto o programa está aberto. **Novo jogo** restaura os parâmetros padrão;
as opções editadas são aplicadas ao clicar em **Iniciar simulação**.
