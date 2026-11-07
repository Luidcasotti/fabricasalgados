/// Total físico sem dupla contagem. Localização detalhada abaixo de cada barra.
function hud_estoque_config(_j,_id) {
    var _i=ingrediente_obter(_j.catalogo,_id);
    var _max=variable_struct_exists(_i,"estoque_maximo")?_i.estoque_maximo:max(1,_i.estoque_inicial,_i.estoque_minimo*4);
    var _crit=variable_struct_exists(_i,"estoque_critico")?_i.estoque_critico:floor(_i.estoque_minimo*.5);
    return {maximo:max(1,_max),minimo:_i.estoque_minimo,critico:clamp(_crit,0,_i.estoque_minimo)};
}
function hud_estoque_nivel(_q,_cfg) {
    if(_q<=0)return 0;
    if(_q<=_cfg.critico)return 1;
    if(_q<=_cfg.minimo)return 2;
    return 3;
}
function hud_estoque_iniciar(_c) {
    _c.hud_valores=[];_c.hud_niveis=[];_c.hud_alerta="";_c.hud_alerta_tempo=0;
    _c.hud_ids=["farinha","frango","queijo","oleo","embalagens"];_c.hud_pulsos=[0,0,0,0,0];_c.hud_fisicos=[];
    for(var _i=0;_i<array_length(_c.hud_ids);_i++) {
        var _id=_c.hud_ids[_i],_q=estoque_quantidade(global.jogo.cozinha,_id);
        array_push(_c.hud_fisicos,"");array_push(_c.hud_valores,_q);array_push(_c.hud_niveis,-1);
    }
    if(variable_struct_exists(global.jogo.exploracao,"avisos_estoque"))_c.hud_niveis=global.jogo.exploracao.avisos_estoque;
    _c.objetivo_anterior=missoes_ativa(global.jogo)?global.jogo.missoes.etapa:-1;
    _c.objetivo_toast=0;_c.interacao_tempo=0;_c.porta_destino="";_c.porta_tempo=0;_c.porta_enviada=false;
}
function hud_estoque_passo(_c,_dt) {
    _c.hud_alerta_tempo=max(0,_c.hud_alerta_tempo-_dt);
    if(!historia_modal(_c) && is_undefined(_c.painel))_c.objetivo_toast=max(0,_c.objetivo_toast-_dt);
    _c.interacao_tempo=max(0,_c.interacao_tempo-_dt);
    var _alertou=false;
    for(var _i=0;_i<array_length(_c.hud_ids);_i++) {
        var _id=_c.hud_ids[_i],_q=exploracao_total_insumo(global.jogo,_id);
        var _locais=string(estoque_quantidade(global.jogo.estoque.materias_primas,_id))+":"+string(estoque_quantidade(global.jogo.cozinha,_id))+":"+string(estoque_quantidade(global.jogo.carregados,_id));
        if(_locais!=_c.hud_fisicos[_i]){_c.hud_fisicos[_i]=_locais;_c.hud_pulsos[_i]=.7;}
        else _c.hud_pulsos[_i]=max(0,_c.hud_pulsos[_i]-_dt);
        _c.hud_valores[_i]=_q;
        var _nivel=hud_estoque_nivel(_q,hud_estoque_config(global.jogo,_id));
        if(_nivel<3 && _nivel!=_c.hud_niveis[_i]) {
            _c.hud_alerta="Atenção! Estoque de "+ingrediente_obter(global.jogo.catalogo,_id).nome+(_q==0?" esgotado.":" baixo.")+" Verifique o almoxarifado e planeje a reposição.";
            _c.hud_alerta_tempo=7;if(!_alertou)feedback_som("alerta");_alertou=true;
        }
        _c.hud_niveis[_i]=_nivel;
    }
    global.jogo.exploracao.avisos_estoque=_c.hud_niveis;
    if(missoes_ativa(global.jogo) && _c.objetivo_anterior!=global.jogo.missoes.etapa) {
        _c.objetivo_anterior=global.jogo.missoes.etapa;_c.objetivo_toast=2.5;feedback_som("objetivo");
    }
}
function hud_ingrediente_icone(_x,_y,_i) {
    var _cores=[make_color_rgb(236,216,169),make_color_rgb(223,147,103),make_color_rgb(247,199,72),make_color_rgb(145,190,98),make_color_rgb(190,160,115)];
    draw_set_color(_cores[_i]);
    if(_i==1) {draw_ellipse(_x,_y+4,_x+22,_y+19,false);draw_set_color(c_white);draw_rectangle(_x+18,_y+10,_x+29,_y+14,false);}
    else if(_i==2){draw_triangle(_x,_y+22,_x,_y+2,_x+28,_y+22,false);draw_set_color(make_color_rgb(185,131,41));draw_circle(_x+6,_y+14,2,false);draw_circle(_x+17,_y+19,2,false);}
    else {draw_rectangle(_x+4,_y+5,_x+24,_y+26,false);draw_rectangle(_x+9,_y,_x+19,_y+6,false);draw_set_color(global.visual.tinta);draw_rectangle(_x+8,_y+12,_x+20,_y+18,false);}
}
/// Cabeçalho simples. Quantidades do pedido ficam no canhoto, sem cinco barras duplicadas.
function hud_estoque_desenhar(_c){
    var _j=global.jogo,_v=global.visual;
    ui_cartao(16,12,1248,86,_v.claro);
    ui_texto(32,22,"Fábrica de Salgados",3,_v.tinta);
    ui_texto(32,64,_c.mundo.nome+" · Dia "+string(_j.dia)+" · Caixa "+financas_formatar(_j.financas.saldo_centavos),1,_v.suave);
}
function canhoto_desenhar(_j){
    var _v=global.visual,_c=canhoto_dados(_j);
    ui_cartao(16,200,320,398,_v.claro);
    if(is_undefined(_c)){
        ui_texto(32,220,"Seu canhoto",2,_v.tinta);
        ui_paragrafo(32,264,"Aceite um pedido com Marta no Comercial para receber sua lista.",276,_v.suave);
        var _nomes=["1. Aceitar o pedido","2. Separar no Estoque","3. Depositar na cozinha","4. Cozinhar","5. Entregar no Comercial"];
        for(var _i=0;_i<5;_i++)ui_texto(32,380+_i*36,_nomes[_i],1,_v.tinta);return;
    }
    ui_texto(32,218,"Canhoto #"+string(_c.pedido.id),2,_v.ciano);
    ui_texto_ajustado(32,252,string(_c.pedido.quantidade)+" × "+_c.produto,2,288,_v.tinta);
    ui_texto(32,286,"Prontos: "+string(_c.pedido.quantidade-_c.restante)+" / "+string(_c.pedido.quantidade),1,_v.suave);
    ui_texto(32,322,"Ingredientes do pedido",1,_v.suave);
    for(var _i=0;_i<array_length(_c.linhas);_i++){
        var _d=_c.linhas[_i],_y=352+_i*42,_cor=_d.comprar_quantidade>0?_v.vermelho:(_d.retirar>0 || _d.falta_empresa>0?_v.ouro:_v.verde);
        ui_texto(32,_y,_d.nome+" · "+string(_d.total_pedido),1,_v.tinta);
        var _estado=_c.restante==0?"Preparado":(_d.comprar_quantidade>0?"Comprar "+string(_d.comprar_quantidade):(_d.retirar>0?"Retirar "+string(_d.retirar):(_d.falta_empresa>0?"A caminho":"Separado")));
        ui_texto_ajustado(32,_y+21,_estado+" · Mochila "+string(_d.mochila)+" · Cozinha "+string(_d.cozinha),1,288,_cor);
    }
    ui_texto(32,570,"Mochila: "+string(exploracao_carregado_total(_j))+" / "+string(_j.exploracao.limite_transporte),1,_v.ciano);
}
