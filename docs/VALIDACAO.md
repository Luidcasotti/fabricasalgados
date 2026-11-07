# Validação

## Estado verificado em 06/11/2026

A suíte foi executada no Runner oficial Windows/VM, runtime GameMaker **2026.0.0.23**. Python 3.12.10 e Node 24.19.0 foram usados na automação. Os testes rodam em uma cópia do projeto; não são acionados ao abrir o jogo normal.

| Conjunto | Verificações | Falhas |
| --- | ---: | ---: |
| Simulação e auditoria | 72 | 0 |
| Interface de simulação | 22 | 0 |
| Regressão V0.1 | 54 | 0 |
| Exploração e logística | 83 | 0 |
| Missões | 64 | 0 |
| Campanha, tempo, confirmações e motoboy | 270 | 0 |
| **Total da suíte** | **565** | **0** |

O percurso completo `--historia feira` também passou, com **171 verificações**, até a quinta entrega. A verificação de projeto confirmou **105 recursos**, referências, eventos e quadros de sprites. A verificação visual confirmou 24 sprites, 31 quadros PNG, 23 objetos visuais e 28 instâncias. O registro estruturado desta execução está em [evidencias-validacao-20261106.json](evidencias-validacao-20261106.json).

## Comandos suportados

Na raiz do repositório:

```powershell
python tools/verificar_projeto.py
python tools/verificar_visuais.py
python tools/verificar_simulacao.py
```

Para informar explicitamente o ambiente GameMaker:

```powershell
$gmRuntime = 'C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes\runtime-2026.0.0.23'
$gmProfile = 'C:\Users\SEU_USUARIO\AppData\Roaming\GameMakerStudio2-LTS2026\SEU_PERFIL'
python tools/verificar_simulacao.py --runtime "$gmRuntime" --usuario-runtime "$gmProfile"
```

Substitua os caminhos pelo runtime e perfil locais. O perfil precisa estar configurado no GameMaker; não envie a licença ao GitHub. `--destino` escolhe uma pasta nova para preservar as evidências. Os padrões de caminho do script são conveniências da máquina original e podem não existir em outra instalação.

### Percursos reais da história

```powershell
python tools/verificar_simulacao.py --historia feira
python tools/verificar_simulacao.py --historia turno
python tools/verificar_simulacao.py --historia recusar
```

O driver percorre a malha e usa botões reais do jogo, acelerando a caminhada e a espera de produção para o teste. `recusar` exercita oferta substituta e depois completa a campanha. Os nomes `negociar` e `comprar` continuam aceitos pelo CLI por compatibilidade; não representam mais o antigo roteiro de dois pedidos. `--partida` é o driver histórico do modo livre e não pode ser combinado com `--historia`.

### Verificações auxiliares em Node

```powershell
node tools/verificar_geometria.mjs
npm install --prefix .testes/gml-parser --ignore-scripts @bscotch/gml-parser@1.17.2
node tools/verificar_gml.mjs
```

O parser analisa a sintaxe de 79 arquivos GML, sem executar o motor. O verificador de geometria testa a matemática extraída de funções compatíveis com JavaScript; não testa desenho nem substitui colisão/entrada no Runner.

## Evidências e cobertura

A suíte cobre conservação de estoque, caixa e IDs, presença, operação inválida sem efeitos parciais, pagamento e recebimento únicos, cinco missões, recusa/reoferta, bônus únicos, dez resgates, timeout, confirmação, retomada e entrega após resgate.

O motoboy tem verificações de prazo exato, pausa, confirmação e quiz, chegada em outro setor, recebimento de vários volumes, pagamento único e uso do material recebido no pedido. Logs completos e pacotes de teste ficam em `.testes/`, fora do Git; resultados e capturas selecionadas ficam em `docs/evidencias-*`.

As revisões Web de 05/11/2026 usaram Edge/Playwright com botões e teclas reais. A posição do ator foi instrumentada para reduzir caminhada; não é um teste de acessibilidade ou conforto humano. Foram exercitadas cinco entregas, ida e volta dos resultados e duas reposições reais com queijo inicial configurado em 40. Consulte os [registros históricos](HISTORICO.md) para o escopo de cada execução.

## Exportação e limites

`tools/exportar_web.py` usa o exportador HTML5 oficial e bloqueia o pacote se `node --check` encontrar JavaScript inválido. Uma exportação aprovada ainda precisa ser aberta no navegador. Um erro de geração desse tipo foi observado e não deve ser ignorado ou publicado.

Os resultados acima não certificam outras plataformas, YYC, toque, acessibilidade completa, aprendizagem da turma ou ausência de todos os bugs. Capturas de etapas antigas não representam necessariamente o layout atual. Veja [melhorias futuras](MELHORIAS_FUTURAS.md).
