# Validação V0.1 — 21/10/2026

GameMaker IDE 2026.0.0.16, runtime 2026.0.0.23, Windows/VM.
**172 verificações aprovadas: 148 de regras/controladores + 24 da partida real.**

```text
FDS_SIMULACAO_TESTES: 72 / FALHAS: 0
FDS_INTERFACE_TESTES: 22 / FALHAS: 0
FDS_V01_TESTES: 54 / FALHAS: 0
FDS_SIMULACAO_APROVADA
FDS_PARTIDA_APROVADA: 24 verificações
```

## Reproduzir

```powershell
python tools/verificar_projeto.py
python tools/verificar_simulacao.py
python tools/verificar_simulacao.py --partida
```

Python é somente automação; as verificações e a partida são GML no runtime.
Cada comando de execução cria uma cópia nova em .testes (ignorada pelo Git),
sem alterar a fonte principal ou apagar resultados anteriores. Use --help
para configurar --runtime, --usuario-runtime e --destino em outra instalação.

O modo normal chama três suítes registradas no Create da cópia e termina.
O modo --partida usa um driver GML nos eventos Step já existentes da cópia:
percorre menu → parâmetros → fábrica → resultados parciais → fábrica → fim,
visita as seis abas, reinicia uma segunda partida, conclui e volta pelo menu.
Os eventos Draw e os recursos de sala são os mesmos do jogo. Entrada física
não controla essa cópia de teste. O driver nunca é chamado na partida normal.

Cada destino guarda compilacao.log e execucao.log. A partida também produz
capturas PNG; a ferramenta as recolhe do sandbox do GameMaker quando necessário.
Ausência de marcador, erro, timeout ou falta das capturas das abas causa falha.

## Cobertura

- IDs e geração única, aceite/recusa, filas, vencimento, entregas sem duplicação.
- Chegada após prazo, pagamento único, reserva de caixa e limite incluindo trânsito.
- Receitas/quantidades, capacidade, cancelamento, embalagem, falhas sem consumir.
- Conservação de insumos/produtos/caixa em vários dias e no fim do período.
- Duração mínima/máxima, bloqueio após fim, retomada, reinício e padrões.
- Métricas por dados reais, denominadores zero, capacidade acumulada e resultado financeiro.
- Feedbacks de aceite, excesso, reposição, produção, pontualidade e atraso.
- Diário com sequência, data simulada, ação e consequência.
- Navegação pelas salas reais e inspeção visual de parâmetros, fábrica, balões,
  resumo e todas as abas do dashboard.

## Exemplo auditado

Aceitar a primeira oferta (5 coxinhas), comprar 10 farinha e planejar 5 coxinhas.
No primeiro avanço: farinha = 120 + 10 − 5 = 125; embalagens = 120 − 5 = 115;
cinco coxinhas produzidas e entregues; receita R$ 30,00; compra R$ 6,00;
variável R$ 1,25; resultado de caixa R$ 22,75; saldo R$ 1.022,75.

Na partida automatizada com dois dias, só esse lote de cinco foi executado:
capacidade usada 5 / (2×100) = **2,50%**. Uma entrega pontual entre uma realizada
gera **100%**; sem entregas, seria **não aplicável**, não 0%.

## Evidências e limites

Locais: C:\fabrica\.backups\teste-v01-03, partida-v01-final, v01-compile.log,
v01-native-open.log; capturas selecionadas em docs/imagens.
Foram corrigidos os erros encontrados antes da aprovação, incluindo o registro
da pausa. Não há bloqueador conhecido para início/término no Windows/VM testado.
Não foram testados YYC, instalador, outras plataformas ou save/load inexistente.
