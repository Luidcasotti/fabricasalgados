> **Registro histórico.** Este documento descreve uma etapa anterior e pode conter regras ou números já substituídos. Para o funcionamento atual, consulte o [índice](README.md) e as [regras atuais](REGRAS_SIMULACAO.md).

# Correção das barras de ingredientes

As barras mostram somente a COZINHA. ESTOQUE e MOCHILA aparecem por extenso
abaixo e mostram quantidades distintas. Antes do depósito, não há barra verde.
Após o depósito, a barra compara a cozinha com a receita do pedido aceito;
após o consumo, esvazia sem manter preenchimento residual de animação.

Verificação no Edge: início vazio, coleta para a mochila, depósito e consumo.
A leitura dos pixels confirmou zero preenchimento verde no início, na mochila
e após o consumo. Depois do depósito, somente farinha, queijo e óleo ficaram
verdes; frango continuou vazio. O estoque embaixo não inclui cozinha nem mochila.
Nenhum erro JavaScript; 336 verificações de lógica no Runner aprovadas.

Backup anterior: C:/fabrica/.backups/antes-barras-cozinha-20261027.zip.
Fonte e ZIP Web desta etapa têm sufixo hud-cozinha em C:/fabrica/entregas.
