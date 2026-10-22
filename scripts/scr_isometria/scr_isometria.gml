/// Projeção única compartilhada por desenho e hit test (superfície 640x360).
function iso_ponto(_u, _v, _z = 0) {
    return {x:386 + (_u - _v) * 18, y:95 + (_u + _v) * 9 - _z};
}
function iso_inverter(_x, _y) {
    var _a = (_x - 386) / 18;
    var _b = (_y - 95) / 9;
    return {u:(_a + _b) / 2, v:(_b - _a) / 2};
}
function iso_quad(_a, _b, _c, _d, _cor, _borda = false) {
    draw_set_color(_cor);
    draw_triangle(_a.x, _a.y, _b.x, _b.y, _c.x, _c.y, false);
    draw_triangle(_a.x, _a.y, _c.x, _c.y, _d.x, _d.y, false);
    if (_borda) {
        draw_set_color(merge_color(_cor, c_black, 0.18));
        draw_line(_a.x, _a.y, _b.x, _b.y); draw_line(_b.x, _b.y, _c.x, _c.y);
        draw_line(_c.x, _c.y, _d.x, _d.y); draw_line(_d.x, _d.y, _a.x, _a.y);
    }
}
function iso_laje(_u, _v, _w, _d, _z, _cor, _borda = false) {
    iso_quad(iso_ponto(_u,_v,_z), iso_ponto(_u+_w,_v,_z),
        iso_ponto(_u+_w,_v+_d,_z), iso_ponto(_u,_v+_d,_z), _cor, _borda);
}
function iso_caixa(_u, _v, _w, _d, _h, _cor, _z = 0) {
    var _a = iso_ponto(_u,_v,_z+_h), _b = iso_ponto(_u+_w,_v,_z+_h);
    var _c = iso_ponto(_u+_w,_v+_d,_z+_h), _d1 = iso_ponto(_u,_v+_d,_z+_h);
    iso_quad(_d1, _c, iso_ponto(_u+_w,_v+_d,_z), iso_ponto(_u,_v+_d,_z), merge_color(_cor,c_black,0.24),true);
    iso_quad(_b, iso_ponto(_u+_w,_v,_z), iso_ponto(_u+_w,_v+_d,_z), _c, merge_color(_cor,c_black,0.40),true);
    iso_quad(_a,_b,_c,_d1,_cor,true);
}
function iso_linha(_u1,_v1,_z1,_u2,_v2,_z2,_cor) {
    var _a=iso_ponto(_u1,_v1,_z1), _b=iso_ponto(_u2,_v2,_z2);
    draw_set_color(_cor); draw_line(_a.x,_a.y,_b.x,_b.y);
}

function iso_pessoa(_u,_v,_tipo) {
    var _p=iso_ponto(_u,_v); var _x=round(_p.x), _y=round(_p.y);
    var _pele=make_color_rgb(206,148,103), _cabelo=make_color_rgb(62,44,37);
    var _roupa=make_color_rgb(54,103,137), _calca=make_color_rgb(37,58,72);
    if (_tipo=="atendente") { _roupa=make_color_rgb(204,105,79); _pele=make_color_rgb(157,97,64); }
    if (_tipo=="estoquista") _roupa=make_color_rgb(221,155,61);
    if (_tipo=="cozinheiro") { _roupa=make_color_rgb(244,240,216); _pele=make_color_rgb(153,95,66); }
    draw_set_color(make_color_rgb(117,133,118)); draw_ellipse(_x-7,_y-2,_x+7,_y+3,false);
    draw_set_color(_calca); draw_rectangle(_x-4,_y-8,_x-1,_y,false); draw_rectangle(_x+1,_y-8,_x+4,_y,false);
    draw_set_color(make_color_rgb(31,41,44)); draw_rectangle(_x-5,_y-1,_x-1,_y+1,false); draw_rectangle(_x+1,_y-1,_x+5,_y+1,false);
    draw_set_color(_roupa); draw_rectangle(_x-5,_y-18,_x+5,_y-7,false); draw_rectangle(_x-7,_y-17,_x+7,_y-12,false);
    draw_set_color(_pele); draw_rectangle(_x-7,_y-11,_x-5,_y-8,false); draw_rectangle(_x+5,_y-11,_x+7,_y-8,false);
    draw_rectangle(_x-3,_y-26,_x+4,_y-18,false); draw_rectangle(_x+4,_y-23,_x+5,_y-20,false);
    draw_set_color(_cabelo); draw_rectangle(_x-4,_y-27,_x+4,_y-24,false); draw_rectangle(_x-4,_y-25,_x-3,_y-21,false);
    draw_set_color(make_color_rgb(38,39,41)); draw_point(_x+2,_y-22);
    if (_tipo=="gestor") {
        draw_set_color(make_color_rgb(247,236,198)); draw_rectangle(_x-1,_y-17,_x+1,_y-12,false);
        draw_set_color(make_color_rgb(194,148,83)); draw_rectangle(_x+3,_y-15,_x+8,_y-8,false);
        draw_set_color(c_white); draw_rectangle(_x+4,_y-14,_x+7,_y-10,false);
    }
    if (_tipo=="atendente") { draw_set_color(_cabelo); draw_rectangle(_x-6,_y-25,_x-4,_y-18,false); }
    if (_tipo=="estoquista" || _tipo=="cozinheiro") {
        draw_set_color(make_color_rgb(238,225,187)); draw_rectangle(_x-3,_y-15,_x+3,_y-7,false);
        draw_set_color(_roupa); draw_line(_x-2,_y-14,_x+2,_y-14);
    }
    if (_tipo=="cozinheiro") {
        draw_set_color(make_color_rgb(255,252,235)); draw_rectangle(_x-5,_y-30,_x+5,_y-25,false);
        draw_rectangle(_x-3,_y-32,_x+3,_y-29,false);
    }
}

function iso_movel(_m) {
    var _u=_m.u, _v=_m.v;
    var _metal=make_color_rgb(187,207,201), _madeira=make_color_rgb(199,159,102);
    var _escuro=make_color_rgb(53,76,80), _branco=make_color_rgb(239,236,210);
    switch (_m.tipo) {
        case "mesa":
            iso_caixa(_u,_v,2.0,1.0,10,_escuro);
            iso_caixa(_u-.08,_v-.08,2.16,1.16,3,_madeira,10);
            iso_caixa(_u+.55,_v+.22,.65,.15,10,_escuro,13);
            iso_caixa(_u+.60,_v+.23,.53,.16,6,make_color_rgb(119,187,179),16);
            iso_laje(_u+.65,_v+.62,.55,.23,13.4,_branco,true);
            iso_laje(_u+1.4,_v+.28,.35,.45,13.4,_branco,true);
            break;
        case "balcao":
            iso_caixa(_u,_v,1.1,2.1,16,make_color_rgb(202,120,74));
            iso_caixa(_u-.07,_v-.07,1.24,2.24,2,_branco,16);
            iso_caixa(_u+.2,_v+.2,.4,.4,4,_escuro,18);
            break;
        case "cadeira":
            iso_caixa(_u,_v,.65,.65,5,_escuro);
            iso_caixa(_u,_v+.5,.65,.15,13,make_color_rgb(97,137,133),4);
            break;
        case "prateleira":
            for (var _i=0;_i<3;_i++) {
                var _z=3+_i*11;
                iso_caixa(_u,_v,.9,2.0,2,_metal,_z);
                iso_caixa(_u+.12,_v+.12,.65,.7,7,make_color_rgb(211,177,113),_z+2);
                iso_caixa(_u+.12,_v+1.05,.65,.7,7,make_color_rgb(151,169,111),_z+2);
                iso_laje(_u+.3,_v+.32,.3,.3,_z+9.1,_branco);
            }
            iso_caixa(_u,_v,.10,.10,36,_escuro); iso_caixa(_u,_v+1.95,.10,.10,36,_escuro);
            iso_caixa(_u+.85,_v,.10,.10,36,_escuro); iso_caixa(_u+.85,_v+1.95,.10,.10,36,_escuro);
            break;
        case "caixas":
            iso_caixa(_u,_v,1.5,1.25,3,_madeira);
            iso_caixa(_u+.05,_v+.1,.65,1.0,10,make_color_rgb(215,181,123),3);
            iso_caixa(_u+.78,_v+.1,.65,1.0,10,make_color_rgb(175,144,91),3);
            iso_caixa(_u+.32,_v+.25,.8,.7,9,make_color_rgb(226,201,151),13);
            iso_laje(_u+.55,_v+.4,.3,.3,22.1,_branco);
            break;
        case "bancada":
            iso_caixa(_u,_v,2.7,1.3,12,_escuro);
            iso_caixa(_u-.06,_v-.06,2.82,1.42,3,_metal,12);
            iso_laje(_u+.3,_v+.2,1.1,.8,15.2,_madeira,true);
            for(var _i=0;_i<4;_i++) iso_caixa(_u+.4+_i*.23,_v+.48,.14,.2,2,make_color_rgb(240,192,83),15.4);
            iso_caixa(_u+1.8,_v+.2,.6,.8,1,_branco,15.4);
            break;
        case "pia":
            iso_caixa(_u,_v,2.5,1.0,17,_metal);
            iso_laje(_u+.4,_v+.16,1.1,.65,17.2,_escuro,true);
            iso_laje(_u+.52,_v+.24,.86,.45,17.4,make_color_rgb(109,158,159));
            iso_linha(_u+.8,_v+.08,17,_u+.8,_v+.08,25,_metal);
            iso_linha(_u+.8,_v+.08,25,_u+.8,_v+.45,25,_metal);
            break;
        case "fogao":
            iso_caixa(_u,_v,1.4,1.7,17,_metal);
            iso_laje(_u+.08,_v+.08,1.24,1.54,17.2,_escuro);
            for(var _i=0;_i<2;_i++) for(var _j=0;_j<2;_j++) {
                var _p=iso_ponto(_u+.38+_i*.65,_v+.42+_j*.8,17.5);
                draw_set_color(make_color_rgb(223,131,66)); draw_ellipse(_p.x-4,_p.y-2,_p.x+4,_p.y+2,true);
            }
            iso_caixa(_u+.12,_v+.1,.6,.65,5,_escuro,18);
            iso_caixa(_u-.12,_v-.12,1.65,1.95,4,_metal,42);
            iso_caixa(_u+.45,_v+.35,.4,.7,10,_escuro,46);
            break;
        case "fritadeira":
            iso_caixa(_u,_v,1.4,1.4,17,_metal);
            iso_laje(_u+.15,_v+.15,1.1,.95,17.2,_escuro,true);
            iso_laje(_u+.26,_v+.23,.88,.75,17.4,make_color_rgb(193,140,52));
            iso_caixa(_u+.4,_v+1,.5,.15,2,_escuro,19);
            break;
        case "forno":
            iso_caixa(_u,_v,1.4,1.5,29,_metal);
            var _a=iso_ponto(_u+.1,_v+1.51,25), _b=iso_ponto(_u+1.3,_v+1.51,25);
            var _c=iso_ponto(_u+1.3,_v+1.51,6), _d=iso_ponto(_u+.1,_v+1.51,6);
            iso_quad(_a,_b,_c,_d,_escuro,true);
            iso_linha(_u+.3,_v+1.53,21,_u+1.1,_v+1.53,21,_branco);
            iso_linha(_u+.3,_v+1.53,14,_u+1.1,_v+1.53,14,make_color_rgb(212,151,70));
            break;
        case "planta":
            iso_caixa(_u,_v,.6,.6,6,make_color_rgb(189,103,66));
            var _p=iso_ponto(_u+.3,_v+.3,6);
            draw_set_color(make_color_rgb(65,117,80)); draw_rectangle(_p.x-3,_p.y-11,_p.x+3,_p.y,false);
            draw_rectangle(_p.x-6,_p.y-7,_p.x+6,_p.y-3,false); break;
        default: iso_pessoa(_u,_v,_m.tipo); break;
    }
}
