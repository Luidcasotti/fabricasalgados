var _v=global.visual;ui_fundo();ui_titulo("FINANÇAS / VALORES FICTÍCIOS PARA APRENDIZAGEM");
ui_cartao(150,124,980,518,_v.claro);
ui_centro(640,152,"RESULTADOS ATÉ O DIA "+string(resumo.dia),3,_v.tinta);
var _nomes=["RECEITAS DE ENTREGAS","COMPRAS PAGAS","CUSTOS VARIÁVEIS PAGOS","RESULTADO DE CAIXA","SALDO EM CAIXA",
    "ENTREGAS PONTUAIS / ATRASADAS","PEDIDOS NA FILA / ATRASADOS","UNIDADES PRODUZIDAS / PRONTAS"];
var _valores=[financas_formatar(resumo.receitas_centavos),financas_formatar(resumo.compras_centavos),
    financas_formatar(resumo.variaveis_centavos),financas_formatar(resumo.resultado_caixa_centavos),
    financas_formatar(resumo.saldo_centavos),string(resumo.entregas_pontuais)+" / "+string(resumo.entregas_atrasadas),
    string(resumo.pedidos_pendentes)+" / "+string(resumo.abertos_atrasados),
    string(resumo.unidades_produzidas)+" / "+string(resumo.unidades_em_estoque)];
for(var _i=0;_i<8;_i++) {
    ui_texto(180,222+_i*36,_nomes[_i],2,_v.suave);
    ui_texto(840,222+_i*36,_valores[_i],2,_i==3?_v.laranja:_v.tinta);
}
ui_centro(640,524,"RESULTADO DE CAIXA = RECEITAS - COMPRAS - CUSTOS VARIÁVEIS.",1,_v.tinta);
ui_centro(640,542,"FATURAMENTO NÃO É LUCRO. ESTOQUE INICIAL NÃO REPRESENTA SAÍDA DE CAIXA.",1,_v.suave);
ui_botao(botao_voltar,"VOLTAR À FÁBRICA",_v.laranja);ui_botao(botao_menu,"MENU",_v.tinta);
