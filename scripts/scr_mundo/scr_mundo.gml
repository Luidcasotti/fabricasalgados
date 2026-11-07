/// Geometria única para desenho, colisão e proximidade. Unidades: ladrilhos.
function mundo_projetar(_u,_v) {return {x:600+(_u-_v)*18,y:140+(_u+_v)*9};}
function mundo_sala(_setor) {
    switch(_setor) {case "comercial":return rm_comercial;case "producao":return rm_producao;case "estoque":return rm_estoque;}
    return rm_corredor;
}
function mundo_setor() {
    switch(room) {case rm_comercial:return "comercial";case rm_producao:return "producao";case rm_estoque:return "estoque";}
    return "corredor";
}
function mundo_criar(_setor) {
    var _m={setor:_setor,nome:"CORREDOR",w:24,h:14,entrada:{u:3,v:10,face:0},moveis:[],alvos:[],bloqueios:[]};
    if(_setor=="corredor") {
        if(variable_global_exists("jogo") && missoes_ativa(global.jogo))array_push(_m.moveis,{tipo:"npc",papel:"gestor",u:5,v:3,w:.5,h:.5});
        _m.w=36;_m.h=10;_m.entrada={u:4,v:5,face:0};
        var _setores=["comercial","producao","estoque"],_nomes=["COMERCIAL","PRODUÇÃO","ESTOQUE"];
        for(var _i=0;_i<3;_i++) array_push(_m.alvos,{id:"porta_"+_setores[_i],tipo:"porta",nome:_nomes[_i],u:7+_i*11,v:2,raio:1.6,destino:_setores[_i]});
        array_push(_m.moveis,{tipo:"planta",u:2,v:2,w:.6,h:.6});
        array_push(_m.moveis,{tipo:"planta",u:33,v:7,w:.6,h:.6});
    } else {
        array_push(_m.alvos,{id:"saida",tipo:"porta",nome:"CORREDOR",u:3,v:11,raio:1.6,destino:"corredor"});
        switch(_setor) {
            case "comercial":
                _m.nome="COMERCIAL";
                array_push(_m.moveis,{tipo:"mesa",u:9,v:3,w:2.2,h:1.2});
                array_push(_m.moveis,{tipo:"balcao",u:16,v:7,w:1.3,h:2.3});
                array_push(_m.moveis,{tipo:"cadeira",u:9,v:2,w:.8,h:.8});
                array_push(_m.alvos,{id:"vendas",tipo:"vendas",nome:"MARTA / ENCOMENDAS",u:10,v:5.2,raio:1.6});
                array_push(_m.alvos,{id:"entrega",tipo:"entrega",nome:"BALCÃO / ENTREGAR",u:15,v:8.2,raio:1.6});
                array_push(_m.moveis,{tipo:"npc",papel:"atendente",u:12,v:4,w:.5,h:.5});
                break;
            case "producao":
                _m.nome="PRODUÇÃO";
                array_push(_m.moveis,{tipo:"bancada",u:10,v:5,w:2.9,h:1.5});
                array_push(_m.moveis,{tipo:"bancada",u:5,v:4,w:2.9,h:1.5});
                array_push(_m.moveis,{tipo:"fogao",u:17,v:2,w:1.5,h:1.8});
                array_push(_m.moveis,{tipo:"fritadeira",u:20.5,v:2,w:1.4,h:1.4});
                array_push(_m.moveis,{tipo:"pia",u:13,v:2,w:2.7,h:1.2});
                array_push(_m.moveis,{tipo:"forno",u:20,v:5,w:1.5,h:1.6});
                array_push(_m.alvos,{id:"deposito",tipo:"deposito",nome:"MESA DE DEPÓSITO",u:6.5,v:6.3,raio:1.6});
                array_push(_m.alvos,{id:"bancada",tipo:"bancada",nome:"MESA DE PREPARO",u:11.4,v:7.2,raio:1.6});
                array_push(_m.moveis,{tipo:"npc",papel:"cozinheiro",u:15,v:5,w:.5,h:.5});
                break;
            case "estoque":
                _m.nome="ESTOQUE";
                var _ids=["farinha","frango","queijo","oleo","embalagens"];
                for(var _i=0;_i<5;_i++) {
                    var _u=5+_i*3.4;
                    array_push(_m.moveis,{tipo:"prateleira",u:_u,v:3,w:1.1,h:2.2});
                    array_push(_m.alvos,{id:"prateleira_"+_ids[_i],tipo:"prateleira",ingrediente_id:_ids[_i],nome:string_upper(ingrediente_obter(global.jogo.catalogo,_ids[_i]).nome),u:_u+.5,v:6,raio:1.35});
                }
                array_push(_m.moveis,{tipo:"mesa",u:15,v:9,w:2.2,h:1.2});
                array_push(_m.alvos,{id:"compras",tipo:"compras",nome:"CAIO / REPOSIÇÃO",u:15.8,v:11.5,raio:1.6});
                array_push(_m.moveis,{tipo:"npc",papel:"estoquista",u:18,v:10,w:.5,h:.5});
                array_push(_m.moveis,{tipo:"caixas",u:20,v:8,w:1.6,h:1.4});
                break;
        }
    }
    for(var _i=0;_i<array_length(_m.moveis);_i++) {
        var _p=_m.moveis[_i];array_push(_m.bloqueios,{u:_p.u,v:_p.v,w:_p.w,h:_p.h});
    }
    _m.piso_logo=mundo_mosaico_piso(_m);
    return _m;
}
function mundo_livre(_m,_u,_v) {
    var _r=.25;
    if(_u<.6 || _v<.6 || _u>_m.w-.6 || _v>_m.h-.6) return false;
    for(var _i=0;_i<array_length(_m.bloqueios);_i++) {
        var _b=_m.bloqueios[_i];
        var _dx=_u-clamp(_u,_b.u,_b.u+_b.w),_dy=_v-clamp(_v,_b.v,_b.v+_b.h);
        if(_dx*_dx+_dy*_dy<_r*_r) return false;
    }
    return true;
}
/// Passos pequenos impedem atravessar um móvel mesmo em deslocamentos de teste maiores.
function mundo_mover(_ator,_m,_du,_dv) {
    var _n=max(1,ceil(max(abs(_du),abs(_dv))/.12)),_ou=_ator.u,_ov=_ator.v;
    for(var _i=0;_i<_n;_i++) {
        if(mundo_livre(_m,_ator.u+_du/_n,_ator.v)) _ator.u+=_du/_n;
        if(mundo_livre(_m,_ator.u,_ator.v+_dv/_n)) _ator.v+=_dv/_n;
    }
    var _p=mundo_projetar(_ator.u,_ator.v);_ator.x=_p.x;_ator.y=_p.y;
    return abs(_ator.u-_ou)+abs(_ator.v-_ov)>.0001;
}
function mundo_guardar(_ator) {
    var _e=global.jogo.exploracao;
    variable_struct_set(_e.posicoes,_e.setor,{u:_ator.u,v:_ator.v,face:_ator.face});
}
function mundo_perto(_jogo,_tipo) {
    if(!exploracao_ativa(_jogo)) return true;
    var _e=_jogo.exploracao;
    if(!variable_struct_exists(_e.posicoes,_e.setor)) return false;
    var _p=variable_struct_get(_e.posicoes,_e.setor),_m=mundo_criar(_e.setor);
    for(var _i=0;_i<array_length(_m.alvos);_i++) {
        var _a=_m.alvos[_i];if((_a.id==_tipo || _a.tipo==_tipo) && point_distance(_p.u,_p.v,_a.u,_a.v)<=_a.raio) return true;
    }
    return false;
}
function mundo_alvo_proximo(_ator,_m) {
    var _melhor=undefined,_d=1000;
    for(var _i=0;_i<array_length(_m.alvos);_i++) {
        var _a=_m.alvos[_i],_dist=point_distance(_ator.u,_ator.v,_a.u,_a.v);
        if(_dist<=_a.raio && _dist<_d) {_d=_dist;_melhor=_a;}
    }
    return _melhor;
}
function mundo_interagir(_controle,_alvo) {
    var _j=global.jogo;
    if(is_undefined(_alvo) || historia_aberta(_j) || simulacao_bloqueio(_j)!="" || !mundo_perto(_j,_alvo.id)) return false;
    _j.fala_visivel=false;
    if(_alvo.tipo=="porta") {
        if(_controle.porta_destino!="")return false;
        _controle.porta_destino=_alvo.destino;_controle.porta_tempo=0;_controle.porta_alvo=_alvo;
        feedback_som("porta");return true;
    }
    _controle.interacao_tempo=.35;_controle.painel=_alvo;_controle.selecao=0;_controle.quantidade=5;
    _controle.mensagem="Converse, confira e tome sua decisão.";
    missoes_evento(_j,"interacao",{id:_alvo.id});
    if(missoes_ativa(_j)){
        var _pedido=missoes_atual(_j);
        if(_alvo.id=="bancada")historia_selecionar_pedido(_controle);
        if(_alvo.tipo=="prateleira"){
            var _id=_alvo.ingrediente_id,_req=exploracao_necessidade_atual(_j,_id);
            _controle.quantidade=max(1,min(estoque_quantidade(_j.estoque.materias_primas,_id),_j.exploracao.limite_transporte-exploracao_carregado_total(_j),_req-estoque_quantidade(_j.cozinha,_id)-estoque_quantidade(_j.carregados,_id)));
        }
        if(_alvo.id=="compras"){
            var _g=missoes_fluxo(_j);
            for(var _i=0;_i<array_length(_j.catalogo.ingredientes);_i++){
                var _in=_j.catalogo.ingredientes[_i],_d=exploracao_insumo_diagnostico(_j,_in.id,exploracao_necessidade_atual(_j,_in.id));
                if(_d.comprar_quantidade>0){_controle.selecao=_i;_controle.quantidade=_d.comprar_quantidade;break;}
            }
        }
        _controle.mensagem=missoes_fluxo(_j).acao;_controle.mensagem_tempo=5;
    }
    return true;
}
function mundo_camera(_c,_ator) {
    if(global.jogo.exploracao.setor=="corredor"){
        camera_set_view_size(_c,1088,612);
        camera_set_view_pos(_c,clamp(round(_ator.x-400),0,512),clamp(round(_ator.y-230),0,388));
    }else{
        camera_set_view_size(_c,640,360);
        camera_set_view_pos(_c,clamp(round(_ator.x-320),0,960),clamp(round(_ator.y-175),0,640));
    }
}
function mundo_porta_transitar(_c) {
    var _j=global.jogo,_ant=_j.exploracao.setor,_dest=_c.porta_destino;
    if(_dest=="" || _c.porta_enviada)return;
    _c.porta_enviada=true;
    if(_dest=="corredor") {
        var _u=7;if(_ant=="producao")_u=18;if(_ant=="estoque")_u=29;
        variable_struct_set(_j.exploracao.posicoes,_dest,{u:_u,v:3.7,face:0});
    } else variable_struct_set(_j.exploracao.posicoes,_dest,{u:3,v:10,face:3});
    _j.exploracao.setor=_dest;room_goto(mundo_sala(_dest));
}
/// Arte vetorial em coordenadas inteiras, coerente com os sprites pixel art existentes.
function mundo_porta_desenhar(_a) {
    var _c=instance_find(obj_exploracao,0),_abertura=0;
    if(instance_exists(_c) && _c.porta_destino!="" && _c.porta_alvo.id==_a.id)_abertura=clamp(_c.porta_tempo/.18,0,1);
    var _u=_a.u-1,_v=_a.v-1.05,_metal=make_color_rgb(57,81,94),_cor=global.visual.azul;
    if(_a.destino=="producao")_cor=global.visual.laranja;
    if(_a.destino=="estoque")_cor=global.visual.verde;
    iso_laje(_u-.2,_v-.2,2.4,2.4,.2,make_color_rgb(139,160,160),true);
    iso_caixa(_u-.12,_v,2.24,.24,49,_metal);
    var _a1=iso_ponto(_u,_v+.26,44),_b=iso_ponto(_u+2,_v+.26,44),_c1=iso_ponto(_u+2,_v+.26,2),_d=iso_ponto(_u,_v+.26,2);
    iso_quad(_a1,_b,_c1,_d,make_color_rgb(21,37,49),true);
    var _largura=max(.04,2*(1-_abertura));
    iso_caixa(_u,_v+.28,_largura,.08,42,_cor,2);
    if(_abertura<.75) {
        iso_laje(_u+.2,_v+.39,max(.03,_largura-.4),.03,31,make_color_rgb(154,209,218));
        iso_linha(_u+_largura-.22,_v+.42,19,_u+_largura-.22,_v+.42,14,global.visual.ouro);
    }
    iso_caixa(_u-.12,_v-.02,2.24,.30,4,global.visual.ouro,49);
    iso_laje(_u-.2,_v+1.4,2.4,.28,.4,global.visual.ouro,true);
}
function mundo_detalhes_desenhar(_m) {
    var _branco=make_color_rgb(231,241,229),_azul=make_color_rgb(91,139,155);
    // Luminárias e rodapé: decoração sem alterar a malha de colisão.
    for(var _u=3;_u<_m.w;_u+=7) {
        iso_caixa(_u,0,.95,.15,3,_azul,23);
        iso_caixa(_u+.1,.02,.75,.18,1,_branco,23);
    }
    iso_caixa(.02,.02,_m.w-.04,.14,3,_azul);
    if(_m.setor=="corredor") {
        for(var _u=1;_u<_m.w-1;_u+=2)iso_laje(_u,8.8,1,.14,.3,global.visual.ouro);
        iso_caixa(25,.5,.35,.4,11,make_color_rgb(188,69,59));
        var _p=iso_ponto(12,.3,16);ui_centro(_p.x,_p.y,"FÁBRICA / SENAI",1,_branco);
    }
    if(_m.setor=="producao") {
        // Vapor sutil acima do fogão, sem superfícies temporárias.
        var _p=iso_ponto(17.5,2.5,25);
        draw_set_alpha(.4);draw_set_color(_branco);
        for(var _k=0;_k<3;_k++) {var _t=(current_time/85+_k*6) mod 18;draw_circle(_p.x+_k*3,_p.y-_t,1+_t/10,true);}
        draw_set_alpha(1);
    }
    if(_m.setor=="estoque"){
        var _doca=make_color_rgb(235,65,13);
        iso_laje(11,10.6,3,.08,.2,_doca);iso_laje(11,12.5,3,.08,.2,_doca);
        iso_laje(11,10.6,.08,1.9,.2,_doca);iso_laje(14,10.6,.08,1.9,.2,_doca);
        var _p=iso_ponto(12.5,13.2);ui_centro(_p.x,_p.y,"RECEBIMENTO",1,global.visual.claro);
    }
    if(_m.setor=="comercial") {
        // Telefone e folhas na área do balcão existente.
        iso_caixa(16.2,7.3,.5,.4,3,make_color_rgb(39,62,74),19);
        iso_laje(16.1,8.2,.7,.5,19.1,_branco,true);
    }
}
function mundo_desenhar(_m) {
    global.iso_mundo=true;
    draw_clear(make_color_rgb(38,58,67));
    for(var _u=0;_u<_m.w;_u++) for(var _v=0;_v<_m.h;_v++)
        iso_laje(_u,_v,1,1,0,((_u+_v) mod 2==0)?make_color_rgb(190,202,182):make_color_rgb(181,194,176),true);
    iso_caixa(-.2,-.2,_m.w+.4,.2,30,make_color_rgb(143,167,155));
    iso_caixa(-.2,0,.2,_m.h,30,make_color_rgb(129,152,148));
    mundo_detalhes_desenhar(_m);
    mundo_mosaico_desenhar(_m.piso_logo);
    visuais_alunos_ambiente(_m.setor);
    for(var _i=0;_i<array_length(_m.alvos);_i++) {
        var _a=_m.alvos[_i],_p=mundo_projetar(_a.u,_a.v);
        if(_a.tipo=="porta")mundo_porta_desenhar(_a);
    }
    var _lista=[];
    for(var _i=0;_i<array_length(_m.moveis);_i++) {
        var _p=_m.moveis[_i];array_push(_lista,{tipo:"movel",dados:_p,ordem:_p.u+_p.v+(_p.w+_p.h)*.5});
    }
    if(_m.setor=="estoque"){
        var _moto=compras_motoboy_visual(global.jogo);
        if(!is_undefined(_moto))array_push(_lista,{tipo:"motoboy",dados:_moto,ordem:_moto.u+_moto.v});
    }
    var _ator=instance_find(obj_cozinheiro,0);
    if(instance_exists(_ator))array_push(_lista,{tipo:"jogador",dados:_ator,ordem:_ator.u+_ator.v});
    array_sort(_lista,function(_a,_b){return _a.ordem-_b.ordem;});
    for(var _i=0;_i<array_length(_lista);_i++) {
        var _o=_lista[_i];
        if(_o.tipo=="jogador") {
            var _a=_o.dados;draw_set_color(make_color_rgb(119,137,119));draw_ellipse(_a.x-6,_a.y-2,_a.x+6,_a.y+2,false);
            var _c=instance_find(obj_exploracao,0),_bob=(_c.interacao_tempo>0)?-1:0;
            draw_sprite(object_get_sprite(obj_cozinheiro),_a.face*2+(floor(_a.animacao/9) mod 2),round(_a.x),round(_a.y)+_bob);
            if(feira_ativa(global.jogo) && global.jogo.missoes.etapa==EtapaMissao.ENTREGAR) {
                draw_set_color(make_color_rgb(191,208,212));draw_rectangle(_a.x+5,_a.y-16,_a.x+19,_a.y-13,false);
                draw_set_color(global.visual.ouro);for(var _s=0;_s<3;_s++)draw_triangle(_a.x+6+_s*4,_a.y-17,_a.x+9+_s*4,_a.y-17,_a.x+8+_s*4,_a.y-21,false);
            }
        } else if(_o.tipo=="motoboy")mundo_motoboy_desenhar(_o.dados);
        else if(visuais_alunos_movel(_o.dados,_m.setor))continue;
        else if(_o.dados.tipo=="npc")iso_pessoa(_o.dados.u,_o.dados.v,_o.dados.papel);
        else iso_movel(_o.dados);
    }
    // Placas e nomes ficam legiveis sobre o mobiliario, sem alterar os alvos E.
    for(var _i=0;_i<array_length(_m.alvos);_i++) {
        var _a=_m.alvos[_i],_p=mundo_projetar(_a.u,_a.v);
        if(!visuais_alunos_rotulo(_a))ui_centro(_p.x,_p.y-(_a.tipo=="porta"?82:47),_a.nome,1,global.visual.claro);
        if(_a.tipo=="porta")ui_centro(_p.x,_p.y-70,"PORTA / E",1,global.visual.ouro);
    }
    global.iso_mundo=false;draw_set_color(c_white);
}

/// Nome escrito com a fonte normal do jogo, em posição fixa no chão.
function mundo_mosaico_piso(_m){return _m.setor=="corredor"?{u:19,v:6}:undefined;}
function mundo_mosaico_desenhar(_nome){
    if(is_undefined(_nome))return;
    var _fonte=draw_get_font(),_ha=draw_get_halign(),_va=draw_get_valign(),_cor=draw_get_color(),_filtro=gpu_get_texfilter();
    draw_set_font(ui_fonte(4));draw_set_halign(fa_left);draw_set_valign(fa_top);gpu_set_texfilter(true);
    var _p=iso_ponto(_nome.u,_nome.v),_senai="SENAI ",_hub="HUB",_w=string_width(_senai),_x=round(_p.x-(_w+string_width(_hub))/2),_y=round(_p.y-string_height(_hub)/2);
    draw_set_color(make_color_rgb(20,61,137));draw_text(_x,_y,_senai);
    draw_set_color(make_color_rgb(235,65,13));draw_text(_x+_w,_y,_hub);
    draw_set_font(_fonte);draw_set_halign(_ha);draw_set_valign(_va);draw_set_color(_cor);gpu_set_texfilter(_filtro);
}
/// Moto, entregador de capacete e baú: arte vetorial coerente com o cenário.
function mundo_motoboy_desenhar(_moto){
    var _p=iso_ponto(_moto.u,_moto.v),_x=round(_p.x),_y=round(_p.y),_azul=make_color_rgb(20,61,137),_laranja=make_color_rgb(235,65,13),_preto=make_color_rgb(25,34,42),_metal=make_color_rgb(176,194,200);
    draw_set_alpha(.3);draw_set_color(c_black);draw_ellipse(_x-20,_y-5,_x+20,_y+8,false);draw_set_alpha(1);
    draw_set_color(_preto);draw_circle(_x-12,_y,5,false);draw_circle(_x+13,_y+4,5,false);
    draw_set_color(_metal);draw_circle(_x-12,_y,2,false);draw_circle(_x+13,_y+4,2,false);
    draw_set_color(_laranja);draw_rectangle(_x-12,_y-9,_x+5,_y-4,false);draw_triangle(_x+3,_y-8,_x+13,_y+1,_x-3,_y+1,false);
    draw_set_color(_metal);draw_line_width(_x+9,_y-13,_x+13,_y+3,2);draw_line_width(_x+5,_y-13,_x+12,_y-13,2);
    draw_set_color(_preto);draw_rectangle(_x-8,_y-12,_x+5,_y-9,false);
    draw_set_color(_azul);draw_rectangle(_x-5,_y-25,_x+3,_y-13,false);
    draw_set_color(_preto);draw_line_width(_x,_y-13,_x+8,_y-6,3);
    draw_set_color(make_color_rgb(235,190,151));draw_line_width(_x+2,_y-23,_x+8,_y-15,2);
    draw_set_color(_azul);draw_circle(_x,_y-31,6,false);draw_set_color(_metal);draw_rectangle(_x+1,_y-33,_x+6,_y-29,false);
    draw_set_color(_laranja);draw_rectangle(_x-20,_y-25,_x-7,_y-12,false);draw_set_color(c_white);draw_rectangle(_x-17,_y-23,_x-10,_y-20,false);
    ui_centro(_x,_y-54,"MOTOBOY",1,global.visual.claro);
    ui_centro(_x,_y-44,_moto.saindo?"ENTREGUE!":"CHEGA EM "+string(_moto.restante)+" s",1,global.visual.ouro);
}
