/// Layout único usado pelo desenho e pelos cliques. Medidas no GUI 1280x720.
function fabrica_layout() {
    return {
        menu:ui_area(1090,22,166,52), resultados:ui_area(24,622,250,56),
        painel:ui_area(834,110,422,494), fechar:ui_area(1192,122,48,48),
        abas:[ui_area(300,622,300,56),ui_area(614,622,300,56),ui_area(928,622,328,56)],
        etiquetas:[ui_area(592,151,200,38),ui_area(356,352,176,38),ui_area(1038,290,202,38)],
        receber:ui_area(858,394,374,56), entregar:ui_area(858,468,374,56),
        repor:ui_area(858,480,374,56), produzir:ui_area(858,492,374,56),
        produtos:[ui_area(858,216,374,48),ui_area(858,276,374,48),ui_area(858,336,374,48)]
    };
}

function fabrica_notificar(_resultado) {
    mensagem=_resultado.mensagem;
    mensagem_ok=_resultado.ok;
    mensagem_tempo=room_speed*8;
}

function fabrica_clicar(_mx,_my) {
    var _l=layout;
    if(ui_contem(_l.menu,_mx,_my)) {jogo_ir_para(FaseJogo.MENU);return;}
    if(ui_contem(_l.resultados,_mx,_my)) {jogo_ir_para(FaseJogo.RESULTADOS);return;}
    for(var _i=0;_i<3;_i++) if(ui_contem(_l.abas[_i],_mx,_my)) {
        painel=cenario.setores[_i].id; return;
    }
    if(painel!="") {
        if(ui_contem(_l.fechar,_mx,_my)) {painel="";return;}
        if(ui_contem(_l.painel,_mx,_my)) {
            switch(painel) {
                case "comercial":
                    if(ui_contem(_l.receber,_mx,_my)) fabrica_notificar(fabrica_receber(global.jogo));
                    else if(ui_contem(_l.entregar,_mx,_my)) fabrica_notificar(fabrica_entregar(global.jogo));
                    break;
                case "estoque":
                    if(ui_contem(_l.repor,_mx,_my)) fabrica_notificar(fabrica_repor(global.jogo));
                    break;
                case "producao":
                    for(var _i=0;_i<array_length(_l.produtos);_i++) {
                        if(ui_contem(_l.produtos[_i],_mx,_my)) produto_selecionado=global.jogo.catalogo.produtos[_i].id;
                    }
                    if(ui_contem(_l.produzir,_mx,_my)) fabrica_notificar(fabrica_produzir(global.jogo,produto_selecionado));
                    break;
            }
            return; // o clique no painel nunca atravessa para o cenário.
        }
        painel=""; return; // clique fora fecha; outro clique escolhe o próximo setor.
    }
    for(var _i=0;_i<3;_i++) if(ui_contem(_l.etiquetas[_i],_mx,_my)) {
        painel=cenario.setores[_i].id;return;
    }
    painel=cenario_setor_em(cenario,_mx,_my);
}

function fabrica_cabecalho() {
    var _v=global.visual, _j=global.jogo;
    ui_titulo("GESTÃO NA PRÁTICA");
    ui_texto(528,24,"DIA",2,_v.ouro); ui_texto(528,50,string(_j.dia),3,_v.claro);
    ui_texto(644,24,"DISPONÍVEL",2,_v.ouro); ui_texto(644,52,financas_formatar(_j.financas.saldo_centavos),2,_v.claro);
    ui_texto(896,24,"ENCOMENDAS",2,_v.ouro);
    ui_texto(896,52,string(pedidos_contar_status(_j.pedidos,"pendente"))+" PENDENTES",2,_v.claro);
    ui_botao(layout.menu,"MENU",_v.azul);
}

function fabrica_guia() {
    var _v=global.visual, _j=global.jogo;
    var _resumo=indicadores_calcular(_j);
    ui_cartao(24,112,250,492,_v.claro);
    ui_texto(42,134,"PAINEL DO GESTOR",2,_v.tinta);
    draw_set_color(_v.laranja); draw_rectangle(42,164,254,168,false);
    ui_texto(42,192,"PRIMEIRA ENTREGA",2,_v.tinta);
    var _etapas=["RECEBA PEDIDO","PRODUZA LOTE","FAÇA A ENTREGA"];
    var _feito=[_resumo.pedidos_total>0,array_length(_j.producao.lotes)>0,_resumo.pedidos_atendidos>0];
    for(var _i=0;_i<3;_i++) {
        var _yy=236+_i*62;
        draw_set_color(_feito[_i] ? _v.verde : _v.linha); draw_rectangle(42,_yy,66,_yy+24,false);
        ui_texto(49,_yy+5,_feito[_i]?"+":string(_i+1),2,_v.claro);
        ui_texto(78,_yy+6,_etapas[_i],2,_v.tinta);
    }
    ui_texto(42,438,"PRODUÇÃO DO DIA",2,_v.suave);
    ui_texto(42,470,string(_j.producao.unidades_produzidas)+" / "+string(_j.parametros.capacidade_diaria)+" UN.",2,_v.tinta);
    draw_set_color(_v.linha); draw_rectangle(42,502,254,514,false);
    draw_set_color(_v.verde);
    var _fracao=clamp(_j.producao.unidades_produzidas/_j.parametros.capacidade_diaria,0,1);
    if(_fracao>0) draw_rectangle(42,502,42+212*_fracao,514,false);
    ui_paragrafo(42,544,"Lotes de 5 unidades.",212,_v.suave);
}

function fabrica_painel_comercial() {
    var _v=global.visual, _j=global.jogo;
    ui_texto(858,183,"ATENDIMENTO E PEDIDOS",2,_v.suave);
    var _pedido=fabrica_pedido_pendente(_j);
    if(is_undefined(_pedido)) {
        ui_paragrafo(858,234,"Nenhuma encomenda pendente. Receba seu primeiro pedido!",364,_v.tinta);
    } else {
        var _produto=produto_obter(_j.catalogo,_pedido.produto_id);
        ui_texto(858,226,"PRÓXIMA: #"+string(_pedido.id),2,_v.laranja);
        ui_texto(858,262,string(_pedido.quantidade)+" X "+_produto.nome,2,_v.tinta);
        ui_texto(858,298,"VALOR: "+financas_formatar(_pedido.total_centavos),2,_v.tinta);
        ui_texto(858,334,"PRONTOS: "+string(estoque_quantidade(_j.estoque.produtos,_produto.id)),2,_v.suave);
    }
    ui_botao(layout.receber,"RECEBER ENCOMENDA",_v.laranja,pedidos_contar_status(_j.pedidos,"pendente")<3);
    ui_botao(layout.entregar,"ENTREGAR PRÓXIMA",_v.verde,!is_undefined(_pedido));
    ui_paragrafo(858,554,"Pedidos de 5 unidades. Limite: 3 pendentes.",364,_v.suave);
}

function fabrica_painel_estoque() {
    var _v=global.visual, _j=global.jogo;
    ui_texto(858,183,"INGREDIENTES EM PORÇÕES",2,_v.suave);
    ui_texto(858,222,"INGREDIENTE",2,_v.tinta); ui_texto(1164,222,"QTD",2,_v.tinta);
    for(var _i=0;_i<array_length(_j.catalogo.ingredientes);_i++) {
        var _item=_j.catalogo.ingredientes[_i];
        var _qtd=estoque_quantidade(_j.estoque.materias_primas,_item.id);
        ui_texto(858,258+_i*30,_item.nome,2,_v.suave);
        ui_texto(1152,258+_i*30,string(_qtd),2,_qtd<20 ? _v.laranja : _v.tinta);
    }
    ui_texto(858,402,"COMPRA: +20 DE CADA",2,_v.tinta);
    var _custo=fabrica_custo_reposicao(_j);
    ui_texto(858,434,"TOTAL: "+financas_formatar(_custo),2,_v.suave);
    ui_botao(layout.repor,"REPOR INGREDIENTES",_v.verde,_j.financas.saldo_centavos>=_custo);
    ui_paragrafo(858,558,"A compra desconta do dinheiro disponível.",364,_v.suave);
}

function fabrica_painel_producao() {
    var _v=global.visual, _j=global.jogo;
    ui_texto(858,183,"ESCOLHA O LOTE DE 5",2,_v.suave);
    for(var _i=0;_i<array_length(_j.catalogo.produtos);_i++) {
        var _p=_j.catalogo.produtos[_i];
        ui_botao(layout.produtos[_i],_p.nome,_p.id==produto_selecionado ? _v.azul : _v.suave,true,_p.id==produto_selecionado);
    }
    var _plano=producao_planejar(_j,produto_selecionado,5);
    if(_plano.ok) {
        ui_texto(858,414,"CUSTO DOS INGREDIENTES:",2,_v.tinta);
        ui_texto(858,444,financas_formatar(_plano.custo_centavos)+" / LOTE",2,_v.suave);
    } else ui_paragrafo(858,412,_plano.mensagem,364,_v.laranja);
    ui_botao(layout.produzir,"PRODUZIR 5 UNIDADES",_v.azul,_plano.ok);
    ui_texto(858,572,"USA INGREDIENTES DO ESTOQUE.",1,_v.suave);
}

function fabrica_desenhar_painel() {
    var _v=global.visual;
    // A sobreposição sinaliza foco, preservando controles de navegação.
    draw_set_alpha(.14); draw_set_color(_v.tinta); draw_rectangle(300,100,1279,610,false); draw_set_alpha(1);
    ui_cartao(834,110,422,494,_v.claro);
    var _titulo=painel=="producao" ? "PRODUÇÃO" : string_upper(painel);
    ui_texto(858,140,_titulo,3,_v.tinta);
    ui_botao(layout.fechar,"X",_v.tinta);
    switch(painel) {
        case "comercial":fabrica_painel_comercial();break;
        case "estoque":fabrica_painel_estoque();break;
        case "producao":fabrica_painel_producao();break;
    }
}

function fabrica_desenhar() {
    var _v=global.visual;
    ui_fundo();
    var _hover=painel=="" ? cenario_setor_em(cenario,ui_mouse_x(),ui_mouse_y()) : painel;
    tela_cenario=cenario_exibir(tela_cenario,cenario,_hover);
    fabrica_guia();
    var _cores=[_v.laranja,_v.verde,_v.azul];
    for(var _i=0;_i<3;_i++) {
        if(painel=="") ui_botao(layout.etiquetas[_i],cenario.setores[_i].nome,_cores[_i]);
        ui_botao(layout.abas[_i],cenario.setores[_i].nome,_cores[_i],true,painel==cenario.setores[_i].id);
    }
    ui_botao(layout.resultados,"VER RESULTADOS",_v.tinta);
    if(painel!="") fabrica_desenhar_painel();
    fabrica_cabecalho();
    draw_set_color(_v.tinta); draw_rectangle(24,692,1256,718,false);
    var _texto=mensagem_tempo>0 ? mensagem : fabrica_aviso(global.jogo);
    ui_texto(38,700,_texto,2,mensagem_tempo>0 && !mensagem_ok ? _v.ouro : _v.claro);
}
