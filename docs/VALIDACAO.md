# Validação — exploração jogável

Windows, IDE GameMaker 2026.0.0.16, runtime 2026.0.0.23, Windows/VM.
Recursos novos pelos escritores GMSync; ProjectTool oficial executou PROJECT SAVE
e PROJECT OPEN com código 0 e SUCCESSFUL LOAD AND LINK.

| Conjunto | Verificações | Resultado |
| --- | ---: | --- |
| Regras anteriores | 72 | Zero falhas |
| Interface anterior | 22 | Zero falhas |
| Aprendizado/dashboard V0.1 | 54 | Zero falhas |
| Logística/receitas/geometria | 83 | Zero falhas |
| Partida nas salas reais | 123 | Zero falhas |
| **Total no runtime** | **354** | **Aprovadas** |

Validação estática: 41 recursos, referências, eventos, ordem das salas, instâncias,
oito quadros/camadas do sprite. GMSync confirmou no VS Code 7 objetos, 23 scripts,
10 salas e 1 sprite. Room1 e opções originais sem mudanças. A auditoria
soma depósito+cozinha+mochila e verifica consumo, prontos, dinheiro e unicidade.

Os 83 casos novos abrangem retirada remota/errada/excessiva, limite da mochila,
depósito repetido, falta na cozinha, capacidade/custo, compra paga com prazo,
recebimento único, relógio sem ações automáticas, pausa/fim/dashboard, receitas
dos três produtos (também receita alterada), entrega atrasada, paredes/móveis
e caminhos até todos os alvos E.

A partida usa salas/controladores reais em uma **cópia**: menu → parâmetros →
corredor → Comercial → Estoque → Produção → Comercial → resultados parcial →
fim → seis abas do dashboard → reinício → segundo fim → menu/continuar.
O ator usa movimento/colisão reais. BFS somente do teste encontra caminho e
acelera o percurso, sem teletransportar. WASD/setas são pressionadas pela API de
entrada do GameMaker; E abre painéis pelo Step normal. Botões usam hit tests GUI;
portas usam a função de E com proximidade e room_goto. Não simula cliques físicos
do Windows nem substitui uma partida humana.

Caso completo: cinco coxinhas; retira 5 farinha+5 frango+5 óleo+5 embalagens;
compra dez farinhas por R$ 6,00; deposita; cozinha com variável R$ 1,25; entrega
por R$ 30,00. Final de dois dias: saldo R$ 1.022,75, resultado R$ 22,75, farinha
125, capacidade 5/200=2,5%, seis ofertas e uma entrega pontual. Valores conferidos
nos registros reais do Runner. Capturas exploracao-*.png foram inspecionadas;
evidencias-exploracao.json registra versões, contagens e hashes centrais.

## Reproduzir

```powershell
python tools/verificar_projeto.py
python tools/verificar_simulacao.py
python tools/verificar_simulacao.py --partida
```

Python só no desenvolvimento, além do runtime/usuário GameMaker instalados.
Use --runtime e --usuario-runtime para outros caminhos. Cada execução cria cópia
nova em .testes; nunca sobrescreve destino existente. Logs: compilacao.log e
execucao.log. --partida coleta capturas e exige as seis abas. Limite: 30 segundos.
Nenhum teste executa na partida normal; falha não aprova a entrega.

## Limites

Automação comprova regras, entrada no runtime, navegação e desenho, sem avaliar
leitura, ritmo e acessibilidade com pessoas. Não foram validados YYC, outras
plataformas/resoluções ou restauração após fechar. Não existe salvamento em disco.
Arte/colisões/animação provisórias. Esses limites não impediram iniciar, completar,
encerrar e reiniciar a partida no Windows/VM testado.
