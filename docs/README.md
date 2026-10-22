# Fábrica de Salgados

Primeiro protótipo visual jogável, em GameMaker LTS2026 e GML Code.
O projeto existente conserva o nome `BLANK GAMEFabricaDeSalgados.yyp`.

Raiz: `C:\Users\Luid Casotti\GameMakerProjects\fabrica\BLANK GAMEFabricaDeSalgados`.
Abra o .yyp dessa pasta no GameMaker e use **F5**, alvo Windows/VM.
Versões verificadas: IDE 2026.0.0.16 e runtime 2026.0.0.23.

## Como jogar

1. Clique em **Novo jogo**, ajuste a capacidade com **+ / -** e clique em **Abrir fábrica**.
2. Clique no piso, na etiqueta ou no botão **Comercial**; receba uma encomenda.
3. Abra **Produção**, escolha o produto solicitado e produza um lote de cinco.
4. Retorne ao **Comercial** e clique em **Entregar próxima** para receber o valor.
5. Consulte e reponha ingredientes no **Estoque**. A compra de 20 porções de cada
   ingrediente custa inicialmente R$ 46,00, calculados pelo catálogo.
6. Abra **Ver resultados** para consultar o resumo e voltar à fábrica.

Os painéis abrem na própria fábrica. **X**, clique fora ou **ESC** fecham o painel.
Os três botões inferiores permitem trocar diretamente de setor. **Menu → Continuar**
preserva os dados em memória. **Novo jogo** reinicia os dados imediatamente.
O protótipo representa o dia 1; não há passagem de dias nem salvamento em disco.

Teclado opcional: ENTER no menu inicia uma sessão; ENTER em parâmetros abre a
fábrica; CIMA/BAIXO ajustam a capacidade; ESC volta ao menu, fechando primeiro
o painel na fábrica. Nos resultados, ENTER volta à fábrica.

## Edição

Execute `ABRIR_NO_VSCODE.cmd` na raiz ou:

```powershell
code.cmd --new-window "C:\fabrica\FabricaDeSalgados.code-workspace" --disable-extension bscotch.bscotch-stitch-vscode
```

O workspace aponta para o projeto real. GMSync 0.1.0 fornece a associação GML
e a leitura dos recursos. Stitch permanece desabilitado nessa sessão por
incompatibilidade com o formato da IDE instalada. Nenhuma extensão é necessária
para executar o jogo; não há ponte TCP, assets pagos ou dependências externas.

Feche o projeto na IDE antes de alterar metadados por ferramentas externas e
reabra-o depois. Ao receber aviso de alteração externa, use **Recarregar**.
Isso evita salvar sobre o disco uma versão antiga do projeto mantida na memória.

Documentação: [arquitetura](ARQUITETURA.md), [visuais e troca de sprites](VISUAIS.md),
[etapas e evidências](ETAPAS.md), [plano do jogo](PLANO_DO_JOGO.md).

Git inicializado em `main`, sem commit por falta de identidade configurada.
Backups e registros locais: `C:\fabrica\.backups`.
