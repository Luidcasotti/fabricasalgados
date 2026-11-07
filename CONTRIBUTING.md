# Contribuir

1. Leia o [desenvolvimento](docs/DESENVOLVIMENTO.md), a [arquitetura](docs/ARQUITETURA.md) e as [regras](docs/REGRAS_SIMULACAO.md).
2. Crie uma branch para uma alteração de escopo definido.
3. Preserve referências e recursos do GameMaker; revise `.yy`, `.yyp` e `.resource_order` ao criar ou remover algo.
4. Atualize documentação e testes quando mudar comportamento.
5. Execute as verificações apropriadas de [Validação](docs/VALIDACAO.md) e revise o diff antes de enviar.

## Critérios de revisão

Operações inválidas não devem consumir recursos. Transferências precisam conservar os materiais; compras/entregas/pagamentos devem ocorrer uma vez. A consulta de resultados não finaliza missões. Leituras pausam o tempo e a viagem do motoboy. O final depende das cinco entregas.

Para alterações visuais, confira o jogo real: texto, botões, mapa e câmeras. Para regras, use a suíte no Runner. Não acrescente testes que apenas repitam um detalhe de desenho sem verificar um comportamento relevante.

Documente o problema, o efeito da mudança, o que foi testado e os limites. Novas imagens e sons precisam de autoria/proveniência registrada em [assets e créditos](docs/ASSETS_E_CREDITOS.md). Arte dos alunos deve preservar dimensões e origens do [guia](docs/atividades_alunos/GUIA_DE_SPRITES.md).

Não versione builds, `.testes`, `node_modules`, perfis locais ou credenciais. Registros históricos podem continuar no projeto, mas devem ser identificados como históricos; os guias principais precisam refletir o código atual.
