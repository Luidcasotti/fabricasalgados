function fabrica_layout() {
    return {menu:ui_area(1090,22,166,52),resultados:ui_area(24,622,250,56),
        painel:ui_area(600,110,656,494),fechar:ui_area(1192,122,48,48),
        abas:[ui_area(300,622,300,56),ui_area(614,622,300,56),ui_area(928,622,328,56)],
        etiquetas:[ui_area(592,151,200,38),ui_area(356,352,176,38),ui_area(1038,290,202,38)],
        avancar:ui_area(42,536,214,52),resumo:ui_area(42,464,214,48),
        subtabs:[ui_area(624,184,190,44),ui_area(824,184,190,44),ui_area(1024,184,206,44)],
        anterior:ui_area(624,244,140,44),proximo:ui_area(1090,244,140,44),
        aceitar:ui_area(624,488,288,56),recusar:ui_area(934,488,296,56),
        menos:ui_area(624,396,64,48),mais:ui_area(1166,396,64,48),
        confirmar:ui_area(624,494,606,56),
        resumo_anterior:ui_area(624,546,190,42),resumo_proximo:ui_area(1040,546,190,42)};
}
function fabrica_notificar(_r) {mensagem=_r.mensagem;mensagem_ok=_r.ok;mensagem_tempo=room_speed*10;}
function fabrica_clicar(_mx,_my) {
    var _l=layout,_j=global.jogo;
    if(ui_contem(_l.menu,_mx,_my)) {jogo_ir_para(FaseJogo.MENU);return;}
    if(ui_contem(_l.resultados,_mx,_my)) {jogo_ir_para(FaseJogo.RESULTADOS);return;}
    if(ui_contem(_l.resumo,_mx,_my)) {painel="resumo";resumo_pagina=0;return;}
    if(ui_contem(_l.avancar,_mx,_my)) {
        if(painel!="resumo") {
            fabrica_notificar(simulacao_avancar_dia(_j));painel="resumo";resumo_pagina=0;
        }
        return;
    }
    for(var _i=0;_i<3;_i++) if(ui_contem(_l.abas[_i],_mx,_my)) {painel=cenario.setores[_i].id;return;}
    if(painel!="") {
        if(ui_contem(_l.fechar,_mx,_my)) {painel="";return;}
        if(ui_contem(_l.painel,_mx,_my)) {
            switch(painel) {
                case "comercial":fabrica_clique_comercial(_mx,_my);break;
                case "estoque":fabrica_clique_estoque(_mx,_my);break;
                case "producao":fabrica_clique_producao(_mx,_my);break;
                case "resumo":
                    if(ui_contem(_l.resumo_anterior,_mx,_my)) resumo_pagina=max(0,resumo_pagina-1);
                    if(ui_contem(_l.resumo_proximo,_mx,_my)) resumo_pagina=min(ceil(array_length(_j.ultimo_resumo.eventos)/3)-1,resumo_pagina+1);
                    break;
            }
            return;
        }
        painel="";return;
    }
    for(var _i=0;_i<3;_i++) if(ui_contem(_l.etiquetas[_i],_mx,_my)) {painel=cenario.setores[_i].id;return;}
    painel=cenario_setor_em(cenario,_mx,_my);
}
function fabrica_clique_comercial(_mx,_my) {
    var _abas=["ofertas","fila","historico"];
    for(var _i=0;_i<3;_i++) if(ui_contem(layout.subtabs[_i],_mx,_my)) {comercial_aba=_abas[_i];pedido_indice=0;return;}
    var _lista=fabrica_pedidos_visiveis(global.jogo,comercial_aba);
    if(array_length(_lista)==0) return;
    pedido_indice=clamp(pedido_indice,0,array_length(_lista)-1);
    if(ui_contem(layout.anterior,_mx,_my)) pedido_indice=max(0,pedido_indice-1);
    if(ui_contem(layout.proximo,_mx,_my)) pedido_indice=min(array_length(_lista)-1,pedido_indice+1);
    if(comercial_aba=="ofertas") {
        var _pedido=_lista[pedido_indice];
        if(ui_contem(layout.aceitar,_mx,_my)) fabrica_notificar(pedido_decidir(global.jogo,_pedido.id,true));
        if(ui_contem(layout.recusar,_mx,_my)) fabrica_notificar(pedido_decidir(global.jogo,_pedido.id,false));
    }
}
function fabrica_clique_estoque(_mx,_my) {
    var _n=array_length(global.jogo.catalogo.ingredientes);
    if(ui_contem(layout.anterior,_mx,_my)) ingrediente_indice=(ingrediente_indice+_n-1) mod _n;
    if(ui_contem(layout.proximo,_mx,_my)) ingrediente_indice=(ingrediente_indice+1) mod _n;
    if(ui_contem(layout.menos,_mx,_my)) compra_quantidade=max(1,compra_quantidade-1);
    if(ui_contem(layout.mais,_mx,_my)) compra_quantidade=min(1000,compra_quantidade+1);
    if(ui_contem(layout.confirmar,_mx,_my)) fabrica_notificar(compra_realizar(global.jogo,
        global.jogo.catalogo.ingredientes[ingrediente_indice].id,compra_quantidade));
}
function fabrica_clique_producao(_mx,_my) {
    if(ui_contem(layout.subtabs[0],_mx,_my)) {producao_aba="novo";return;}
    if(ui_contem(layout.subtabs[1],_mx,_my)) {producao_aba="planos";return;}
    if(producao_aba=="planos") {
        var _planos=fabrica_planos_pendentes(global.jogo);if(array_length(_planos)==0) return;
        plano_indice=clamp(plano_indice,0,array_length(_planos)-1);
        if(ui_contem(layout.anterior,_mx,_my)) plano_indice=max(0,plano_indice-1);
        if(ui_contem(layout.proximo,_mx,_my)) plano_indice=min(array_length(_planos)-1,plano_indice+1);
        if(ui_contem(layout.confirmar,_mx,_my)) fabrica_notificar(producao_cancelar(global.jogo,_planos[plano_indice].id));
        return;
    }
    var _n=array_length(global.jogo.catalogo.produtos);
    if(ui_contem(layout.anterior,_mx,_my)) produto_indice=(produto_indice+_n-1) mod _n;
    if(ui_contem(layout.proximo,_mx,_my)) produto_indice=(produto_indice+1) mod _n;
    if(ui_contem(layout.menos,_mx,_my)) producao_quantidade=max(1,producao_quantidade-1);
    if(ui_contem(layout.mais,_mx,_my)) producao_quantidade=min(1000,producao_quantidade+1);
    if(ui_contem(layout.confirmar,_mx,_my)) fabrica_notificar(producao_agendar(global.jogo,
        global.jogo.catalogo.produtos[produto_indice].id,producao_quantidade));
}
function fabrica_cabecalho() {
    var _v=global.visual,_j=global.jogo;ui_titulo("SIMULAÇÃO / VALORES FICTÍCIOS");
    ui_texto(528,24,"DIA",2,_v.ouro);ui_texto(528,50,string(_j.dia),3,_v.claro);
    ui_texto(644,24,"CAIXA",2,_v.ouro);ui_texto(644,52,financas_formatar(_j.financas.saldo_centavos),2,_v.claro);
    ui_texto(896,24,"PEDIDOS",2,_v.ouro);ui_texto(896,52,"FILA: "+string(pedidos_contar_status(_j.pedidos,"aceito")),2,_v.claro);
    ui_botao(layout.menu,"MENU",_v.azul);
}
function fabrica_guia() {
    var _v=global.visual,_j=global.jogo,_r=indicadores_calcular(_j);
    ui_cartao(24,112,250,492,_v.claro);ui_texto(42,136,"PAINEL DO GESTOR",2,_v.tinta);
    draw_set_color(_v.laranja);draw_rectangle(42,168,254,172,false);
    ui_texto(42,198,"PLANEJE O DIA",2,_v.suave);ui_texto(42,230,string(_j.dia+1),3,_v.tinta);
    ui_texto(42,262,"CAIXA LIVRE: "+financas_formatar(financas_livre(_j)),1,_v.verde);
    ui_texto(42,280,"CAP. RESERVADA",2,_v.suave);
    ui_texto(42,312,string(producao_reserva_capacidade(_j))+" / "+string(_j.parametros.capacidade_diaria),2,_v.azul);
    ui_texto(42,356,"PRODUTOS PRONTOS",2,_v.suave);ui_texto(42,388,string(_r.unidades_em_estoque),2,_v.tinta);
    ui_texto(42,428,"ATRASADOS NA FILA: "+string(_r.abertos_atrasados),1,_v.laranja);
    ui_botao(layout.resumo,"ÚLTIMO RESUMO",_v.tinta);
    ui_botao(layout.avancar,"AVANÇAR DIA",_v.laranja,painel!="resumo");
}
function fabrica_seletor(_texto) {
    ui_botao(layout.anterior,"ANTERIOR",global.visual.tinta);
    ui_botao(layout.proximo,"PRÓXIMO",global.visual.tinta);
    ui_centro(927,260,_texto,ui_texto_largura(_texto,2)>310?1:2,global.visual.tinta);
}
function fabrica_quantidade(_prefixo,_quantidade) {
    ui_botao(layout.menos,"-",global.visual.tinta);ui_botao(layout.mais,"+",global.visual.tinta);
    ui_centro(927,413,_prefixo+": "+string(_quantidade),2,global.visual.tinta);
}
function fabrica_painel_comercial() {
    var _v=global.visual,_j=global.jogo;
    var _abas=["ofertas","fila","historico"],_nomes=["OFERTAS","FILA","HISTÓRICO"];
    for(var _i=0;_i<3;_i++) ui_botao(layout.subtabs[_i],_nomes[_i],_v.azul,true,comercial_aba==_abas[_i]);
    var _lista=fabrica_pedidos_visiveis(_j,comercial_aba);
    if(array_length(_lista)==0) {ui_paragrafo(624,310,"Nenhum pedido nesta lista. Confira as ofertas ou avance o dia.",606,_v.suave);return;}
    pedido_indice=clamp(pedido_indice,0,array_length(_lista)-1);var _p=_lista[pedido_indice];
    fabrica_seletor(string(pedido_indice+1)+" / "+string(array_length(_lista))+"  #"+string(_p.id));
    ui_texto(624,310,string(_p.quantidade)+" X "+produto_obter(_j.catalogo,_p.produto_id).nome,2,_v.tinta);
    ui_texto(624,346,"UN.: "+financas_formatar(_p.preco_unitario_centavos)+" / TOTAL: "+financas_formatar(_p.total_centavos),2,_v.tinta);
    ui_texto(624,382,"ENTREGAR ATÉ DIA "+string(_p.prazo_dia),2,_v.suave);
    var _status="STATUS: "+_p.status;
    if(_p.status=="aceito") _status+=" / ATRASO: "+string(max(0,_j.dia-_p.prazo_dia))+" DIA(S)";
    if(_p.status=="entregue") _status+=" / "+(_p.pontual?"PONTUAL":"ATRASADA");
    ui_texto(624,418,_status,2,_v.laranja);
    if(comercial_aba=="ofertas") {
        ui_botao(layout.aceitar,"ACEITAR PEDIDO",_v.verde);ui_botao(layout.recusar,"RECUSAR",_v.laranja);
        ui_texto(624,568,"ACEITE ATÉ DIA "+string(_p.aceitar_ate_dia)+". ENTREGA AO AVANÇAR O DIA.",1,_v.suave);
    } else {
        if(_p.status=="entregue") ui_texto(624,470,"DIA ENTREGA: "+string(_p.dia_entrega)+" / ATRASO: "+string(_p.atraso_dias)+" DIA(S)",2,_v.tinta);
        else ui_texto(624,470,"PRODUTOS PRONTOS: "+string(estoque_quantidade(_j.estoque.produtos,_p.produto_id)),2,_v.tinta);
        ui_paragrafo(624,516,_p.status=="aceito"?"Sem estoque, o pedido permanece na fila. Não há entrega parcial.":"Histórico preservado. Pedidos entregues não geram nova receita.",606,_v.suave);
    }
}
function fabrica_painel_estoque() {
    var _v=global.visual,_j=global.jogo,_item=_j.catalogo.ingredientes[ingrediente_indice];
    ui_texto(624,190,"COMPRA COM PRAZO / UNIDADES DIDÁTICAS",2,_v.suave);
    fabrica_seletor(_item.nome);
    var _q=estoque_quantidade(_j.estoque.materias_primas,_item.id),_res=producao_reserva_ingrediente(_j,_item.id);
    ui_texto(624,310,"FÍSICO: "+string(_q)+" / MÍNIMO: "+string(_item.estoque_minimo),2,_q<_item.estoque_minimo?_v.laranja:_v.tinta);
    ui_texto(624,340,"RESERVADO: "+string(_res)+" / LIVRE: "+string(_q-_res),2,_v.suave);
    var _chegada=compras_proxima_chegada(_j,_item.id);
    ui_texto(624,370,"EM TRÂNSITO: "+string(compras_pendentes_quantidade(_j,_item.id))+" / CHEGADA: "+(_chegada==0?"-":"DIA "+string(_chegada)),2,_v.suave);
    fabrica_quantidade("COMPRAR",compra_quantidade);
    var _custo=_item.custo_centavos*compra_quantidade;
    ui_texto(624,462,"UN.: "+financas_formatar(_item.custo_centavos)+" / TOTAL: "+financas_formatar(_custo),2,_v.tinta);
    ui_botao(layout.confirmar,"PAGAR E ENCOMENDAR",_v.verde,_custo<=financas_livre(_j));
    ui_texto(624,570,"NOVA COMPRA: PRAZO "+string(_item.prazo_dias)+" DIA(S); CHEGA NO DIA "+string(_j.dia+_item.prazo_dias)+".",1,_v.suave);
}
function fabrica_painel_producao() {
    var _v=global.visual,_j=global.jogo;
    ui_botao(layout.subtabs[0],"NOVO LOTE",_v.azul,true,producao_aba=="novo");
    ui_botao(layout.subtabs[1],"PLANOS",_v.azul,true,producao_aba=="planos");
    if(producao_aba=="planos") {
        var _lista=fabrica_planos_pendentes(_j);
        if(array_length(_lista)==0) {ui_texto(624,320,"NENHUM LOTE PLANEJADO.",2,_v.suave);return;}
        plano_indice=clamp(plano_indice,0,array_length(_lista)-1);var _p=_lista[plano_indice];
        fabrica_seletor("LOTE #"+string(_p.id));
        ui_texto(624,316,string(_p.quantidade)+" X "+produto_obter(_j.catalogo,_p.produto_id).nome,2,_v.tinta);
        ui_texto(624,358,"CAPACIDADE RESERVADA: "+string(_p.capacidade),2,_v.suave);
        ui_texto(624,400,"CUSTO VARIÁVEL: "+financas_formatar(_p.variavel_centavos),2,_v.suave);
        ui_texto(624,442,"EXECUÇÃO A PARTIR DO DIA "+string(_p.dia_execucao),2,_v.tinta);
        ui_botao(layout.confirmar,"CANCELAR ESTE PLANO",_v.laranja);
        ui_texto(624,570,"CANCELAR LIBERA RESERVAS. O HISTÓRICO É MANTIDO.",1,_v.suave);return;
    }
    var _p=_j.catalogo.produtos[produto_indice];fabrica_seletor(_p.nome);
    ui_texto(624,312,"PRONTOS: "+string(estoque_quantidade(_j.estoque.produtos,_p.id))+" / CAPACIDADE POR UN.: "+string(_p.capacidade_unidade),2,_v.suave);
    var _plano=producao_planejar(_j,_p.id,producao_quantidade);
    ui_texto(624,344,"VARIÁVEL POR UN.: "+financas_formatar(_p.custo_variavel_centavos),2,_v.suave);
    if(_plano.ok) ui_texto(624,374,"INGREDIENTES DO LOTE: "+financas_formatar(_plano.custo_ingredientes_centavos),2,_v.suave);
    fabrica_quantidade("PRODUZIR",producao_quantidade);
    if(_plano.ok) ui_texto(624,462,"CAP.: "+string(_plano.capacidade)+" / VARIÁVEL: "+financas_formatar(_plano.variavel_centavos),2,_v.tinta);
    else ui_texto(624,464,_plano.mensagem,1,_v.laranja);
    ui_botao(layout.confirmar,"PLANEJAR PARA O PRÓXIMO DIA",_v.azul,_plano.ok);
    ui_texto(624,570,"RESERVA AGORA; CONSOME E PRODUZ AO AVANÇAR O DIA.",1,_v.suave);
}
function fabrica_painel_resumo() {
    var _v=global.visual,_j=global.jogo,_eventos=_j.ultimo_resumo.eventos;
    ui_texto(624,190,"DIA "+string(_j.ultimo_resumo.dia)+" / ORDEM FIXA DE PROCESSAMENTO",2,_v.suave);
    var _paginas=ceil(array_length(_eventos)/3);resumo_pagina=clamp(resumo_pagina,0,_paginas-1);
    for(var _i=0;_i<3;_i++) {
        var _idx=resumo_pagina*3+_i;if(_idx>=array_length(_eventos)) break;
        ui_paragrafo(624,244+_i*94,_eventos[_idx],606,_v.tinta);
    }
    ui_botao(layout.resumo_anterior,"ANTERIOR",_v.tinta,resumo_pagina>0);
    ui_botao(layout.resumo_proximo,"PRÓXIMA",_v.tinta,resumo_pagina<_paginas-1);
    ui_centro(926,560,string(resumo_pagina+1)+" / "+string(_paginas),2,_v.tinta);
}
function fabrica_desenhar_painel() {
    var _v=global.visual;draw_set_alpha(.14);draw_set_color(_v.tinta);draw_rectangle(300,100,1279,610,false);draw_set_alpha(1);
    ui_cartao(600,110,656,494,_v.claro);
    ui_texto(624,140,painel=="producao"?"PRODUÇÃO":string_upper(painel),3,_v.tinta);
    ui_botao(layout.fechar,"X",_v.tinta);
    switch(painel) {
        case "comercial":fabrica_painel_comercial();break;
        case "estoque":fabrica_painel_estoque();break;
        case "producao":fabrica_painel_producao();break;
        case "resumo":fabrica_painel_resumo();break;
    }
}
function fabrica_desenhar() {
    var _v=global.visual;ui_fundo();
    tela_cenario=cenario_exibir(tela_cenario,cenario,painel==""?cenario_setor_em(cenario,ui_mouse_x(),ui_mouse_y()):painel);
    fabrica_guia();var _cores=[_v.laranja,_v.verde,_v.azul];
    for(var _i=0;_i<3;_i++) {
        if(painel=="") ui_botao(layout.etiquetas[_i],cenario.setores[_i].nome,_cores[_i]);
        ui_botao(layout.abas[_i],cenario.setores[_i].nome,_cores[_i],true,painel==cenario.setores[_i].id);
    }
    ui_botao(layout.resultados,"RESULTADOS",_v.tinta);
    if(painel!="") fabrica_desenhar_painel();fabrica_cabecalho();
    draw_set_color(_v.tinta);draw_rectangle(24,692,1256,718,false);
    ui_texto(38,700,mensagem_tempo>0?mensagem:fabrica_aviso(global.jogo),1,
        mensagem_tempo>0 && !mensagem_ok?_v.ouro:_v.claro);
}
