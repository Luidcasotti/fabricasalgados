# Verificação da simulação — 21/10/2026

Fuso de referência: America/Rio_Branco.
GameMaker IDE 2026.0.0.16, runtime 2026.0.0.23, Windows/VM.

## Resultado

**94 verificações passaram no runtime GameMaker: 72 de domínio e conservação,
22 de interação com os controladores.** Executadas em cópia descartável do
projeto. Nenhum teste é executado automaticamente durante uma partida.

Marcadores efetivamente emitidos:

```text
FDS_SIMULACAO_TESTES: 72 / FALHAS: 0
FDS_INTERFACE_TESTES: 22 / FALHAS: 0
FDS_SIMULACAO_APROVADA
```

O projeto também compila para Windows/VM. A conferência estrutural encontrou
26 recursos registrados, com referências, eventos, instâncias e ordem de salas
válidos. Room1 e quatro arquivos de opções originais foram preservados.

## Executar novamente

Na raiz, com Python disponível apenas para automação:

```powershell
python tools/verificar_projeto.py
python tools/verificar_simulacao.py
```

A ferramenta de simulação cria uma pasta nova em `.testes/`, copia apenas os
recursos necessários, injeta as chamadas dos testes no Create de obj_game da
cópia e usa Igor/Runner da instalação local. Não modifica a fonte principal e
não apaga resultados anteriores. A pasta é ignorada pelo Git.

Padrões de runtime/usuário correspondem à instalação testada. Para outra
máquina/versão, ajuste os argumentos (consulte `--help`):

```powershell
python tools/verificar_simulacao.py --runtime "CAMINHO_DO_RUNTIME" --usuario-runtime "PASTA_DE_USUARIO_DO_GAMEMAKER" --destino "PASTA_NOVA_DE_TESTE"
```

Compilação e execução ficam em `compilacao.log` e `execucao.log` no destino.
Timeout ou ausência do marcador aprovado causa falha. Os testes são GML em
scr_testes_simulacao; as funções também podem ser chamadas em uma cópia de
desenvolvimento pelo GameMaker. O teste de interface cria objetos temporários
e restaura a sessão; não deve ser invocado em uma partida de aluno.

## Cobertura

- Inicialização independente, catálogo solicitado, limites e validação de receitas.
- Compras pagas no ato, sem chegada instantânea, prazos de um/dois dias,
  recebimento único, limite físico incluindo trânsito e falta de dinheiro.
- Cálculo puro de lote, quantidades escolhidas, reservas de capacidade/insumos/
  caixa, cancelamento, falta de embalagem, custo zero e receita/capacidade alteradas.
- Execução apenas no dia previsto, consumo correto, custo variável único e
  reinício da capacidade diária sem perder produção acumulada.
- Geração idempotente com chave única, aceite/recusa, fila por aceite,
  entrega pontual/atrasada, oferta expirada, estoque insuficiente e ausência de
  cobrança/receita duplicada. Pedidos aceitos não são apagados ao atrasar.
- Vários dias de evolução, histórico preservado e auditoria de estoque/caixa.
- Despacho dos cliques reais dos controladores: setores, quantidade, compra,
  agendamento/cancelamento, avanço/resumo, paginação, fechamento e parâmetros.

## Cenários manuais no GameMaker

### Compra com prazo

No dia 1, compre 10 porções de farinha. Caixa: R$ 994,00. Farinha física:
120, trânsito: 10, chegada: dia 2. Avance sem produção: físico 130 no dia 2.
No frango, prazo padrão de dois dias: comprado no dia 1, chega no dia 3.

### Compra, produção e entrega no mesmo processamento

Inicie com os padrões. Aceite a primeira oferta (5 coxinhas, R$ 30,00,
prazo dia 3), compre 10 de farinha por R$ 6,00 e planeje 5 coxinhas.
Antes de avançar: nenhum produto pronto; compra em trânsito; plano reservado.
Avance para o dia 2:

1. Farinha: 120 + 10 = 130.
2. Produção consome 5 farinha, 5 frango, 5 óleo e 5 embalagens; paga R$ 1,25
   de variável. Ficam 125 farinha e cinco coxinhas prontas.
3. Entrega baixa as cinco coxinhas e recebe R$ 30,00; pontual.
4. Caixa: R$ 1.000,00 − R$ 6,00 − R$ 1,25 + R$ 30,00 = **R$ 1.022,75**.
   Resultado de caixa: **R$ 22,75**, diferente dos R$ 30,00 de receita.

O custo informativo dos ingredientes do lote é R$ 8,75; não é pago outra vez.

### Atraso preservado

Configure prazo de entrega de um dia. Aceite a primeira oferta no dia 1 e
avance sem produzir: no dia 2 ela segue na fila, ainda no prazo. No dia 3,
segue aceita com um dia de atraso. Planeje as cinco coxinhas e avance para o
dia 4: entrega atrasada em dois dias, registrada no Histórico e nos Resultados.

### Falhas sem consumir recursos

Configure embalagem inicial zero e tente planejar coxinhas. O plano deve ser
recusado. Com capacidade dez, planeje cinco unidades e tente outro lote de seis:
o segundo deve ser recusado sem alterar estoque, caixa ou reservas do primeiro.
Com dinheiro insuficiente, a compra deve falhar sem criar registro nem trânsito.

## Evidências locais e limites

Em `C:\fabrica\.backups`: antes-simulacao-principal.zip, teste-simulacao-02
(logs/compilação da suíte), simulacao-compile.log e capturas simulacao-*.png.
Os testes conferem o runtime VM e os controladores; não certificam YYC,
instaladores, exportação ou outras plataformas. Não há teste de save/load,
pois esse recurso não faz parte desta implementação.
