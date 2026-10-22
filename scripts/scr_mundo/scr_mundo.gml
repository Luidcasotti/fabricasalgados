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
                array_push(_m.moveis,{tipo:"pia",u:13,v:2,w:2.7,h:1.2});
                array_push(_m.moveis,{tipo:"forno",u:20,v:5,w:1.5,h:1.6});
                array_push(_m.alvos,{id:"deposito",tipo:"deposito",nome:"MESA / DEPOSITAR",u:6.5,v:6.3,raio:1.6});
                array_push(_m.alvos,{id:"bancada",tipo:"bancada",nome:"BANCADA / COZINHAR",u:11.4,v:7.2,raio:1.6});
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
                array_push(_m.alvos,{id:"compras",tipo:"compras",nome:"CAIO / COMPRAS",u:15.8,v:11.5,raio:1.6});
                array_push(_m.moveis,{tipo:"npc",papel:"estoquista",u:18,v:10,w:.5,h:.5});
                array_push(_m.moveis,{tipo:"caixas",u:20,v:8,w:1.6,h:1.4});
                break;
        }
    }
    for(var _i=0;_i<array_length(_m.moveis);_i++) {
        var _p=_m.moveis[_i];array_push(_m.bloqueios,{u:_p.u,v:_p.v,w:_p.w,h:_p.h});
    }
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
    if(is_undefined(_alvo) || simulacao_bloqueio(_j)!="" || !mundo_perto(_j,_alvo.id)) return false;
    if(_alvo.tipo=="porta") {
        var _anterior=_j.exploracao.setor;
        _j.exploracao.setor=_alvo.destino;
        if(_alvo.destino=="corredor") {
            var _u=7;if(_anterior=="producao")_u=18;if(_anterior=="estoque")_u=29;
            variable_struct_set(_j.exploracao.posicoes,"corredor",{u:_u,v:3.7,face:0});
        }
        room_goto(mundo_sala(_alvo.destino));return true;
    }
    _controle.painel=_alvo;_controle.selecao=0;_controle.quantidade=5;
    _controle.mensagem="Converse, confira e tome sua decisão.";
    return true;
}
function mundo_camera(_c,_ator) {
    camera_set_view_pos(_c,clamp(round(_ator.x-320),0,960),clamp(round(_ator.y-175),0,640));
}
function mundo_desenhar(_m) {
    global.iso_mundo=true;
    draw_clear(make_color_rgb(38,58,67));
    for(var _u=0;_u<_m.w;_u++) for(var _v=0;_v<_m.h;_v++)
        iso_laje(_u,_v,1,1,0,((_u+_v) mod 2==0)?make_color_rgb(190,202,182):make_color_rgb(181,194,176),true);
    iso_caixa(-.2,-.2,_m.w+.4,.2,30,make_color_rgb(143,167,155));
    iso_caixa(-.2,0,.2,_m.h,30,make_color_rgb(129,152,148));
    for(var _i=0;_i<array_length(_m.alvos);_i++) {
        var _a=_m.alvos[_i],_p=mundo_projetar(_a.u,_a.v);
        if(_a.tipo=="porta") {iso_laje(_a.u-.8,_a.v-.8,1.6,1.6,.5,global.visual.ouro,true);}
        ui_centro(_p.x,_p.y-47,_a.nome,1,global.visual.claro);
        if(_a.tipo=="porta")ui_centro(_p.x,_p.y-35,"PORTA / E",1,global.visual.ouro);
    }
    var _lista=[];
    for(var _i=0;_i<array_length(_m.moveis);_i++) {
        var _p=_m.moveis[_i];array_push(_lista,{tipo:"movel",dados:_p,ordem:_p.u+_p.v+(_p.w+_p.h)*.5});
    }
    var _ator=instance_find(obj_cozinheiro,0);
    if(instance_exists(_ator))array_push(_lista,{tipo:"jogador",dados:_ator,ordem:_ator.u+_ator.v});
    array_sort(_lista,function(_a,_b){return _a.ordem-_b.ordem;});
    for(var _i=0;_i<array_length(_lista);_i++) {
        var _o=_lista[_i];
        if(_o.tipo=="jogador") {
            var _a=_o.dados;draw_set_color(make_color_rgb(119,137,119));draw_ellipse(_a.x-6,_a.y-2,_a.x+6,_a.y+2,false);
            draw_sprite(spr_cozinheiro_temp,_a.face*2+(floor(_a.animacao/9) mod 2),round(_a.x),round(_a.y));
        } else if(_o.dados.tipo=="npc")iso_pessoa(_o.dados.u,_o.dados.v,_o.dados.papel);
        else iso_movel(_o.dados);
    }
    global.iso_mundo=false;draw_set_color(c_white);
}
