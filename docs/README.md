# Como jogar e desenvolver

Projeto: `BLANK GAMEFabricaDeSalgados.yyp`, na raiz deste repositório.
Versões verificadas: GameMaker IDE 2026.0.0.16 e runtime 2026.0.0.23.
Abra o projeto no GameMaker e execute com **F5**, alvo Windows/VM.

## Controles

- Use **Novo jogo / Parâmetros** para configurar uma simulação nova.
- A tela de parâmetros tem 50 campos em nove páginas. Use **Anterior/Próxima**,
  os botões **+ / -**, ou clique no valor para digitar um inteiro.
  No editor numérico, valores monetários são digitados em **centavos**;
  os limites ficam visíveis. Confirme ou cancele pelo botão, ENTER ou ESC.
- **Iniciar simulação** valida todos os valores e aplica a configuração.
- Na fábrica, clique no piso, nas etiquetas ou nos três botões inferiores
  para abrir Comercial, Estoque e Produção na mesma sala.
- **X**, clique fora ou ESC fecham o painel. As abas inferiores trocam de setor.
- **Comercial**: consulte Ofertas, Fila e Histórico; use Anterior/Próximo para
  selecionar um pedido e Aceitar/Recusar para decidir uma oferta.
- **Estoque**: selecione o ingrediente, ajuste a quantidade e pague a compra.
  O painel mostra quantidade física, mínima, reservada, livre, em trânsito,
  próxima chegada, custo e prazo de uma nova compra.
- **Produção**: selecione o produto e a quantidade. Planejar reserva recursos
  para o próximo dia; não produz instantaneamente. A aba Planos permite
  consultar e cancelar planos que ainda não foram executados.
- **Avançar dia** recebe compras previstas, executa planos, tenta entregas
  e atualiza prazos/ofertas, nessa ordem. O resumo é paginado. Feche o resumo
  ou selecione outro setor antes de avançar novamente.
- **Último resumo** reabre os acontecimentos do dia mais recente.
- **Resultados** mostra receitas, compras, custos variáveis, resultado de caixa
  e indicadores de entrega. É possível voltar à fábrica sem reiniciar.
- **Menu → Continuar** mantém a sessão em memória. Não existe save/load em disco.

## Edição no VS Code

Use `ABRIR_NO_VSCODE.cmd` na raiz. Na máquina de desenvolvimento, o workspace
`C:\fabrica\FabricaDeSalgados.code-workspace` aponta para o projeto real em:

`C:\Users\Luid Casotti\GameMakerProjects\fabrica\BLANK GAMEFabricaDeSalgados`.

GMSync 0.1.0 fornece a associação de linguagem GML e leitura de recursos.
Stitch 1.81.0 está desabilitado na sessão dedicada por incompatibilidade com
o formato da IDE instalada. Nenhuma extensão é necessária para rodar o jogo.

Feche o projeto na IDE antes de alterar metadados por ferramentas externas;
reabra-o depois. Ao receber aviso de alteração externa, use **Recarregar**
para evitar salvar a versão antiga mantida em memória sobre os arquivos novos.

## Testes e Git

Consulte [VALIDACAO.md](VALIDACAO.md) para executar as 94 verificações pelo
runtime do GameMaker e conferir referências/instâncias/eventos do projeto.

Repositório: https://github.com/Luidcasotti/fabricasalgados.
Branch principal: main. Autor local: Luidcasotti, com e-mail privado noreply
do GitHub escolhido pelo usuário. Backups ficam fora do repositório, em
`C:\fabrica\.backups`. Não versionar caches e cópias de execução dos testes.
