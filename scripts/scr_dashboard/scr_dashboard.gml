function indicador_percentual(_numerador,_denominador) {
    if(_denominador<=0) return undefined;
    return 100*_numerador/_denominador;
}
function indicador_percentual_texto(_valor) {
    return is_undefined(_valor)?"NÃO APLICÁVEL":string_replace_all(string_format(_valor,0,2),".",",")+"%";
}
function dashboard_calcular(_jogo) {
    var _r=indicadores_calcular(_jogo);
    _r.recebidos=array_length(_jogo.pedidos);_r.aceitos=0;
    _r.recusados=pedidos_contar_status(_jogo.pedidos,"recusado");
    _r.expirados=pedidos_contar_status(_jogo.pedidos,"expirado");
    _r.sem_decisao=pedidos_contar_status(_jogo.pedidos,"ofertado");
    for(var _i=0;_i<array_length(_jogo.pedidos);_i++) if(_jogo.pedidos[_i].sequencia_aceite>0) _r.aceitos++;
    _r.producao_por_produto=[];_r.estoque_final=[];_r.capacidade_usada_total=0;
    for(var _i=0;_i<array_length(_jogo.catalogo.produtos);_i++) {
        var _p=_jogo.catalogo.produtos[_i],_q=0;
        for(var _k=0;_k<array_length(_jogo.producao.lotes);_k++) {
            var _l=_jogo.producao.lotes[_k];if(_l.produto_id==_p.id) _q+=_l.quantidade;
        }
        array_push(_r.producao_por_produto,{id:_p.id,nome:_p.nome,produzida:_q,
            prontos:estoque_quantidade(_jogo.estoque.produtos,_p.id),pendente:pedagogia_demanda_produto(_jogo,_p.id)});
    }
    for(var _i=0;_i<array_length(_jogo.catalogo.ingredientes);_i++) {
        var _p=_jogo.catalogo.ingredientes[_i];
        array_push(_r.estoque_final,{id:_p.id,nome:_p.nome,fisico:estoque_quantidade(_jogo.estoque.materias_primas,_p.id),
            minimo:_p.estoque_minimo,reservado:producao_reserva_ingrediente(_jogo,_p.id),transito:compras_pendentes_quantidade(_jogo,_p.id)});
    }
    for(var _i=0;_i<array_length(_jogo.historico_dias);_i++) _r.capacidade_usada_total+=_jogo.historico_dias[_i].capacidade_usada;
    _r.dias_processados=array_length(_jogo.historico_dias);
    _r.capacidade_disponivel_total=_r.dias_processados*_jogo.parametros.capacidade_diaria;
    _r.utilizacao_capacidade=indicador_percentual(_r.capacidade_usada_total,_r.capacidade_disponivel_total);
    _r.taxa_pontualidade=indicador_percentual(_r.entregas_pontuais,_r.pedidos_atendidos);
    _r.custos_pagos_centavos=_r.compras_centavos+_r.variaveis_centavos;
    _r.compras_em_transito=pedidos_contar_status(_jogo.compras,"em_transito");
    return _r;
}
function dashboard_reflexoes(_jogo,_r) {
    var _lista=[];
    if(_r.entregas_pontuais>0) array_push(_lista,{titulo:"PONTO POSITIVO / PRAZOS",texto:string(_r.entregas_pontuais)+" entrega(s) no prazo. Quais decisões de aceite, compra e produção você repetiria?"});
    if(_r.receitas_centavos>0 && _r.resultado_caixa_centavos>=0)
        array_push(_lista,{titulo:"PONTO POSITIVO / CAIXA",texto:"As receitas cobriram os pagamentos registrados. O resultado de caixa foi "+financas_formatar(_r.resultado_caixa_centavos)+". Isso ainda não representa lucro contábil."});
    if(_r.entregas_atrasadas+_r.abertos_atrasados>0)
        array_push(_lista,{titulo:"OPORTUNIDADE / PRAZOS",texto:"Houve "+string(_r.entregas_atrasadas)+" entrega(s) atrasada(s) e "+string(_r.abertos_atrasados)+" pedido(s) ainda atrasado(s). Onde a previsão inicial diferiu do que aconteceu?"});
    if(_r.resultado_caixa_centavos<0)
        array_push(_lista,{titulo:"OPORTUNIDADE / CAIXA",texto:"Os pagamentos superaram as receitas em "+financas_formatar(-_r.resultado_caixa_centavos)+". Quanto ficou em estoque ou em compras ainda não recebidas?"});
    if(_r.compras_em_transito>0)
        array_push(_lista,{titulo:"OPORTUNIDADE / REPOSIÇÃO",texto:"Restaram "+string(_r.compras_em_transito)+" compra(s) em trânsito. Compare seus dias de compra e chegada com o período da atividade."});
    var _sobras=0;for(var _i=0;_i<array_length(_r.producao_por_produto);_i++) {
        var _p=_r.producao_por_produto[_i];_sobras+=max(0,_p.prontos-_p.pendente);
    }
    if(_sobras>0) array_push(_lista,{titulo:"OPORTUNIDADE / DEMANDA",texto:"Há "+string(_sobras)+" produto(s) pronto(s) acima dos pedidos aceitos ainda abertos. Qual demanda você imaginou ao planejar esses lotes?"});
    if(_r.pedidos_atendidos==0) array_push(_lista,{titulo:"DADOS AINDA INSUFICIENTES",texto:"Sem entregas, a taxa de pontualidade é não aplicável. Reveja os aceites e os planos antes de interpretar o desempenho."});
    if(_r.dias_processados==0) array_push(_lista,{titulo:"ANTES DE COMPARAR",texto:"Nenhum dia foi processado. A utilização da capacidade é não aplicável: ainda não existe capacidade diária observada no período."});
    if(array_length(_lista)==0) array_push(_lista,{titulo:"REVEJA O PROCESSO",texto:"Compare o diário com os estoques e os pedidos. Que hipótese você gostaria de testar em outra partida?"});
    return _lista;
}
function dashboard_eventos(_jogo) {
    var _lista=[];
    for(var _i=array_length(_jogo.historico_dias)-1;_i>=0;_i--) {
        var _dia=_jogo.historico_dias[_i];
        for(var _k=0;_k<array_length(_dia.eventos);_k++) array_push(_lista,{dia:_dia.dia,texto:_dia.eventos[_k]});
    }
    return _lista;
}
function dashboard_layout() {
    var _tabs=[];for(var _i=0;_i<6;_i++) array_push(_tabs,ui_area(24+_i*208,110,192,44));
    return {tabs:_tabs,anterior:ui_area(24,584,180,44),proxima:ui_area(220,584,180,44),
        voltar:ui_area(24,644,280,56),reiniciar:ui_area(322,644,518,56),menu:ui_area(858,644,398,56)};
}
function dashboard_paginas() {
    switch(aba_dashboard) {
        case 1:return max(1,ceil(array_length(resumo.producao_por_produto)/4));
        case 2:return max(1,ceil(array_length(resumo.estoque_final)/5));
        case 3:return max(1,array_length(reflexoes));
        case 4:return max(1,array_length(global.jogo.diario));
        case 5:return max(1,ceil(array_length(eventos)/3));
    }
    return 1;
}
function dashboard_clicar(_mx,_my) {
    for(var _i=0;_i<6;_i++) if(ui_contem(layout.tabs[_i],_mx,_my)) {aba_dashboard=_i;pagina_dashboard=0;return;}
    if(ui_contem(layout.anterior,_mx,_my)) pagina_dashboard=max(0,pagina_dashboard-1);
    if(ui_contem(layout.proxima,_mx,_my)) pagina_dashboard=min(dashboard_paginas()-1,pagina_dashboard+1);
    if(ui_contem(layout.menu,_mx,_my)) jogo_ir_para(FaseJogo.MENU);
    if(ui_contem(layout.reiniciar,_mx,_my)) jogo_ir_para(FaseJogo.PARAMETROS);
    if(ui_contem(layout.voltar,_mx,_my)) {
        if(global.jogo.encerrado) {aba_dashboard=5;pagina_dashboard=0;}
        else {
            global.jogo.pausado=false;
            diario_registrar(global.jogo,"RETOMAR APÓS ANÁLISE","Retorno à fábrica sem avançar dias nem reiniciar recursos.");
            jogo_ir_para(FaseJogo.FABRICA);
        }
    }
}
function dashboard_linha(_x,_y,_nome,_valor) {
    ui_texto(_x,_y,_nome,2,global.visual.suave);
    ui_texto(_x+390,_y,_valor,2,global.visual.tinta);
}
function dashboard_panorama() {
    var _v=global.visual,_r=resumo;
    var _a=["PEDIDOS RECEBIDOS","PEDIDOS ACEITOS","PEDIDOS RECUSADOS","ENTREGUES NO PRAZO","ENTREGUES COM ATRASO","NA FILA / ATRASADOS"];
    var _b=[string(_r.recebidos),string(_r.aceitos),string(_r.recusados),string(_r.entregas_pontuais),string(_r.entregas_atrasadas),string(_r.pedidos_pendentes)+" / "+string(_r.abertos_atrasados)];
    var _c=["VENDAS / RECEITAS","COMPRAS PAGAS","VARIÁVEIS PAGOS","CUSTOS PAGOS / TOTAL","RESULTADO DE CAIXA","SALDO FINAL EM CAIXA"];
    var _d=[financas_formatar(_r.receitas_centavos),financas_formatar(_r.compras_centavos),financas_formatar(_r.variaveis_centavos),financas_formatar(_r.custos_pagos_centavos),financas_formatar(_r.resultado_caixa_centavos),financas_formatar(_r.saldo_centavos)];
    for(var _i=0;_i<6;_i++) {dashboard_linha(44,208+_i*42,_a[_i],_b[_i]);dashboard_linha(654,208+_i*42,_c[_i],_d[_i]);}
    dashboard_linha(44,460,"EXPIRADOS / SEM DECISÃO",string(_r.expirados)+" / "+string(_r.sem_decisao));
    dashboard_linha(654,460,"DIAS DE OPERAÇÃO",string(_r.dias_processados));
    ui_texto(44,492,"PONTUALIDADE: "+indicador_percentual_texto(_r.taxa_pontualidade),2,_v.azul);
    ui_texto(44,518,"PONTUALIDADE = ENTREGAS NO PRAZO / ENTREGAS REALIZADAS X 100. SEM ENTREGAS: NÃO APLICÁVEL.",1,_v.suave);
    ui_texto(44,542,"RESULTADO DE CAIXA = RECEITAS - COMPRAS - VARIÁVEIS. NÃO É FATURAMENTO NEM LUCRO CONTÁBIL.",1,_v.suave);
    ui_texto(44,560,"RECEBIDOS = OFERTAS ÚNICAS. ACEITOS INCLUEM OS JÁ ENTREGUES; RECUSADOS E EXPIRADOS NÃO SÃO ACEITOS.",1,_v.suave);
}
function dashboard_producao() {
    var _v=global.visual,_r=resumo;
    ui_texto(44,194,"SALGADO",2,_v.suave);ui_texto(420,194,"PRODUZIDO",2,_v.suave);
    ui_texto(710,194,"PRONTO",2,_v.suave);ui_texto(1000,194,"NA FILA / UN.",2,_v.suave);
    for(var _i=0;_i<4;_i++) {
        var _idx=pagina_dashboard*4+_i;if(_idx>=array_length(_r.producao_por_produto)) break;
        var _p=_r.producao_por_produto[_idx],_y=238+_i*56;
        ui_texto(44,_y,_p.nome,2,_v.tinta);ui_texto(420,_y,string(_p.produzida),2,_v.tinta);
        ui_texto(710,_y,string(_p.prontos),2,_v.tinta);ui_texto(1000,_y,string(_p.pendente),2,_v.tinta);
    }
    ui_texto(44,496,"CAPACIDADE: "+string(_r.capacidade_usada_total)+" / "+string(_r.capacidade_disponivel_total)+" = "+indicador_percentual_texto(_r.utilizacao_capacidade),2,_v.azul);
    ui_texto(44,534,"USO = PONTOS DOS LOTES EXECUTADOS / (DIAS PROCESSADOS X CAPACIDADE DIÁRIA) X 100.",1,_v.suave);
    ui_texto(44,552,"PLANOS CANCELADOS OU AINDA NÃO EXECUTADOS NÃO CONTAM COMO PRODUÇÃO.",1,_v.suave);
}
function dashboard_estoque() {
    var _v=global.visual,_r=resumo;
    var _titulos=["INSUMO","FÍSICO","MÍNIMO","RESERVADO","EM TRÂNSITO"],_xs=[44,450,630,820,1040];
    for(var _i=0;_i<5;_i++) ui_texto(_xs[_i],194,_titulos[_i],2,_v.suave);
    for(var _i=0;_i<5;_i++) {
        var _idx=pagina_dashboard*5+_i;if(_idx>=array_length(_r.estoque_final)) break;
        var _p=_r.estoque_final[_idx],_y=240+_i*48;
        var _val=[_p.nome,string(_p.fisico),string(_p.minimo),string(_p.reservado),string(_p.transito)];
        for(var _k=0;_k<5;_k++) ui_texto(_xs[_k],_y,_val[_k],2,_v.tinta);
    }
    ui_texto(44,514,"FÍSICO = ESTOQUE INICIAL + COMPRAS RECEBIDAS - INSUMOS CONSUMIDOS.",1,_v.suave);
    ui_texto(44,540,"RESERVA NÃO É CONSUMO. COMPRAS EM TRÂNSITO NÃO SÃO ESTOQUE FÍSICO.",1,_v.suave);
}
function dashboard_diario(_jogo,_pagina,_x,_y,_largura) {
    if(array_length(_jogo.diario)==0) {ui_texto(_x,_y,"NENHUMA DECISÃO REGISTRADA.",2,global.visual.suave);return;}
    var _idx=clamp(array_length(_jogo.diario)-1-_pagina,0,array_length(_jogo.diario)-1);
    var _d=_jogo.diario[_idx];
    ui_texto(_x,_y,_d.data+" / REGISTRO #"+string(_d.id),2,global.visual.azul);
    ui_paragrafo(_x,_y+42,_d.acao,_largura,global.visual.tinta);
    ui_paragrafo(_x,_y+106,_d.consequencia,_largura,global.visual.suave);
}
function dashboard_desenhar() {
    var _v=global.visual,_j=global.jogo;ui_fundo();
    ui_titulo(_j.encerrado?"V0.1 / PERÍODO ENCERRADO / REFLITA E EXPERIMENTE DE NOVO":"V0.1 / ACOMPANHAMENTO DA SIMULAÇÃO");
    var _nomes=["PANORAMA","PRODUÇÃO","ESTOQUE","REFLEXÃO","DIÁRIO","EVENTOS"];
    for(var _i=0;_i<6;_i++) ui_botao(layout.tabs[_i],_nomes[_i],_v.azul,true,aba_dashboard==_i);
    ui_cartao(24,174,1232,400,_v.claro);
    pagina_dashboard=clamp(pagina_dashboard,0,dashboard_paginas()-1);
    switch(aba_dashboard) {
        case 0:dashboard_panorama();break;
        case 1:dashboard_producao();break;
        case 2:dashboard_estoque();break;
        case 3:
            var _f=reflexoes[pagina_dashboard];ui_texto(44,214,_f.titulo,2,_v.azul);
            ui_paragrafo(44,276,_f.texto,1160,_v.tinta);
            ui_texto(44,516,"UM RESULTADO NEGATIVO É MATERIAL PARA INVESTIGAR, NÃO UM GAME OVER.",1,_v.suave);break;
        case 4:dashboard_diario(_j,pagina_dashboard,44,210,1150);break;
        case 5:
            if(array_length(eventos)==0) ui_texto(44,242,"NENHUM DIA PROCESSADO. NÃO HÁ EVENTOS DIÁRIOS.",2,_v.suave);
            for(var _i=0;_i<3;_i++) {
                var _idx=pagina_dashboard*3+_i;if(_idx>=array_length(eventos)) break;
                var _e=eventos[_idx];ui_texto(44,210+_i*110,"DIA "+string(_e.dia),2,_v.azul);
                ui_paragrafo(190,210+_i*110,_e.texto,1010,_v.tinta);
            }break;
    }
    ui_botao(layout.anterior,"ANTERIOR",_v.tinta,pagina_dashboard>0);
    ui_botao(layout.proxima,"PRÓXIMA",_v.tinta,pagina_dashboard<dashboard_paginas()-1);
    ui_texto(432,598,"PÁGINA "+string(pagina_dashboard+1)+" / "+string(dashboard_paginas())+" / OPERAÇÃO: "+string(_j.dias_processados)+" DE "+string(_j.parametros.duracao_dias)+" DIAS",2,_v.suave);
    ui_botao(layout.voltar,_j.encerrado?"REVER EVENTOS":"RETOMAR SIMULAÇÃO",_v.verde);
    ui_botao(layout.reiniciar,"REINICIAR / PARÂMETROS",_v.laranja);ui_botao(layout.menu,"VOLTAR AO MENU",_v.tinta);
}
