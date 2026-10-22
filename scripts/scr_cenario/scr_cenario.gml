/// Dados expansíveis do cenário. U/V em ladrilhos; renderização em meia resolução.
function cenario_criar() {
    var _moveis = [
        {tipo:"planta",u:.5,v:.7}, {tipo:"mesa",u:1.0,v:1.0},
        {tipo:"cadeira",u:1.3,v:2.4}, {tipo:"atendente",u:1.6,v:2.2},
        {tipo:"balcao",u:3.5,v:.5}, {tipo:"gestor",u:4.0,v:3.1},
        {tipo:"prateleira",u:.4,v:4.7}, {tipo:"prateleira",u:.4,v:7.3},
        {tipo:"caixas",u:2.6,v:7.3}, {tipo:"estoquista",u:3.9,v:8.8},
        {tipo:"pia",u:6.5,v:.5}, {tipo:"fogao",u:10.0,v:.7},
        {tipo:"bancada",u:6.7,v:4.1}, {tipo:"fritadeira",u:10.0,v:4.1},
        {tipo:"cozinheiro",u:8.0,v:6.5}, {tipo:"forno",u:10.0,v:7.4},
        {tipo:"planta",u:5.6,v:8.7}
    ];
    // Ordem do pintor: objetos e pessoas usam a mesma profundidade.
    array_sort(_moveis, function(_a,_b) {return (_a.u+_a.v)-(_b.u+_b.v);});
    return {moveis:_moveis, setores:[
        {id:"comercial",nome:"COMERCIAL",cor:make_color_rgb(218,193,148),u:0,v:0,w:5,d:4},
        {id:"estoque",nome:"ESTOQUE",cor:make_color_rgb(160,190,153),u:0,v:4,w:5,d:6},
        {id:"producao",nome:"PRODUÇÃO",cor:make_color_rgb(166,194,193),u:5,v:0,w:7,d:10}
    ]};
}

function cenario_setor_em(_cenario, _gui_x, _gui_y) {
    var _p=iso_inverter(_gui_x/2,_gui_y/2);
    for(var _i=0;_i<array_length(_cenario.setores);_i++) {
        var _s=_cenario.setores[_i];
        if(_p.u>=_s.u && _p.u<_s.u+_s.w && _p.v>=_s.v && _p.v<_s.v+_s.d) return _s.id;
    }
    return "";
}

function cenario_desenhar(_cenario, _destaque) {
    // Sombra da plataforma e faces frontais; paredes apenas ao fundo.
    iso_laje(.25,.25,12,10,-9,make_color_rgb(203,208,186));
    iso_caixa(0,0,12,10,8,make_color_rgb(165,175,158),-8);
    for(var _u=0;_u<12;_u++) for(var _v=0;_v<10;_v++) {
        var _indice=_u>=5 ? 2 : (_v>=4 ? 1 : 0);
        var _s=_cenario.setores[_indice];
        var _cor=_s.cor;
        if((_u+_v) mod 2==0) _cor=merge_color(_cor,c_white,.06);
        if(_destaque==_s.id) _cor=merge_color(_cor,c_white,.12);
        iso_laje(_u,_v,1,1,0,_cor,true);
    }
    var _parede=make_color_rgb(229,227,202), _rodape=make_color_rgb(119,150,141);
    iso_caixa(0,0,12,.12,38,_parede); iso_caixa(0,0,.12,10,38,_parede);
    iso_caixa(.12,.12,11.88,.08,5,_rodape); iso_caixa(.12,.12,.08,9.88,5,_rodape);
    // Janelas e quadro no escritório, revestimento da cozinha.
    for(var _i=0;_i<3;_i++) {
        var _u=1+_i*1.15;
        iso_quad(iso_ponto(_u,.14,29),iso_ponto(_u+.8,.14,29),
            iso_ponto(_u+.8,.14,13),iso_ponto(_u,.14,13),make_color_rgb(131,185,184),true);
        iso_linha(_u+.4,.15,29,_u+.4,.15,13,make_color_rgb(239,236,208));
    }
    for(var _u=6;_u<12;_u++) for(var _z=8;_z<31;_z+=8) {
        iso_linha(_u,.15,_z,_u+1,.15,_z,make_color_rgb(196,204,187));
        iso_linha(_u,.15,_z,_u,.15,_z+8,make_color_rgb(196,204,187));
    }
    // Faixas de circulação delimitam setores sem ocultar o mobiliário.
    iso_laje(4.82,.25,.15,9.5,.25,make_color_rgb(240,218,131));
    iso_laje(.25,3.83,4.57,.15,.25,make_color_rgb(240,218,131));
    for(var _i=0;_i<array_length(_cenario.moveis);_i++) iso_movel(_cenario.moveis[_i]);
}

function cenario_exibir(_superficie, _cenario, _destaque) {
    // Superfícies são voláteis: recriar após perda de foco/dispositivo.
    if(!surface_exists(_superficie)) _superficie=surface_create(640,360);
    if(surface_exists(_superficie)) {
        surface_set_target(_superficie);
        draw_clear_alpha(c_black,0);
        cenario_desenhar(_cenario,_destaque);
        surface_reset_target();
        var _filtro=gpu_get_texfilter(); gpu_set_texfilter(false);
        draw_set_alpha(1); draw_set_color(c_white);
        draw_surface_stretched(_superficie,0,0,1280,720);
        gpu_set_texfilter(_filtro);
    } else {
        // Fallback mantém os botões funcionais caso não haja memória de vídeo.
        ui_texto(420,340,"CENÁRIO INDISPONÍVEL",2,global.visual.suave);
    }
    return _superficie;
}
