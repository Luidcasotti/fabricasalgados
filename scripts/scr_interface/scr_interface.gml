/// Texto antisserrilhado em atlas incorporado, com acentos e caixa original.
function visual_iniciar() {
    if (variable_global_exists("visual")) return;
    global.visual = {
        papel: make_color_rgb(14, 21, 30), claro: make_color_rgb(240, 240, 224),
        tinta: make_color_rgb(240, 245, 248), suave: make_color_rgb(185, 201, 213),
        linha: make_color_rgb(73, 91, 107), sombra: make_color_rgb(5, 10, 17),
        laranja: make_color_rgb(185, 82, 47), verde: make_color_rgb(43, 139, 76),
        azul: make_color_rgb(32, 123, 151), ouro: make_color_rgb(239, 189, 81),
        painel: make_color_rgb(19, 26, 38), borda: make_color_rgb(136, 158, 171),
        ciano: make_color_rgb(67, 213, 221), vermelho: make_color_rgb(235, 89, 84), fonte: {}
    };
    global.visual.fontes=[fnt_interface_1,fnt_interface_2,fnt_interface_3,fnt_interface_4];
}
function ui_fonte(_escala){return global.visual.fontes[clamp(round(_escala)-1,0,3)];}
function ui_cor_texto(_cor){
    if(_cor==global.visual.azul)return global.visual.ciano;
    if(_cor==global.visual.verde)return make_color_rgb(113,224,156);
    if(_cor==global.visual.laranja)return make_color_rgb(255,178,128);
    return _cor;
}
function ui_texto_largura(_texto,_escala){
    var _ant=draw_get_font();draw_set_font(ui_fonte(_escala));
    var _w=string_width(string(_texto));draw_set_font(_ant);return _w*(variable_global_exists("iso_mundo") && global.iso_mundo?.6:1);
}
function ui_texto(_x,_y,_texto,_escala,_cor){
    var _ant=draw_get_font(),_ha=draw_get_halign(),_va=draw_get_valign();
    var _filtro=gpu_get_texfilter();gpu_set_texfilter(true);
    draw_set_font(ui_fonte(_escala));draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(ui_cor_texto(_cor));
    var _s=variable_global_exists("iso_mundo") && global.iso_mundo?.6:1;
    draw_text_transformed(round(_x),round(_y)-floor(3*_escala*_s),string(_texto),_s,_s,0);
    draw_set_font(_ant);draw_set_halign(_ha);draw_set_valign(_va);gpu_set_texfilter(_filtro);
}
function ui_texto_ajustado(_x,_y,_texto,_escala,_largura,_cor){
    var _ant=draw_get_font(),_ha=draw_get_halign(),_va=draw_get_valign(),_filtro=gpu_get_texfilter();
    draw_set_font(ui_fonte(_escala));draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(ui_cor_texto(_cor));gpu_set_texfilter(true);
    var _s=min(1,_largura/max(1,string_width(string(_texto))));
    draw_text_transformed(round(_x),round(_y)-floor(3*_escala),string(_texto),_s,_s,0);
    draw_set_font(_ant);draw_set_halign(_ha);draw_set_valign(_va);gpu_set_texfilter(_filtro);
}

function ui_centro(_x, _y, _texto, _escala, _cor) {
    ui_texto(_x - ui_texto_largura(_texto, _escala) / 2, _y, _texto, _escala, _cor);
}

function ui_paragrafo(_x, _y, _texto, _largura, _cor) {
    var _palavras = string_split(_texto, " ");
    var _linha = "";
    for (var _i = 0; _i < array_length(_palavras); _i++) {
        var _nova = _linha == "" ? _palavras[_i] : _linha + " " + _palavras[_i];
        if (ui_texto_largura(_nova, 2) > _largura && _linha != "") {
            ui_texto(_x, _y, _linha, 2, _cor); _y += 28; _linha = _palavras[_i];
        } else _linha = _nova;
    }
    ui_texto(_x, _y, _linha, 2, _cor);
    return _y + 28;
}

function ui_area(_x, _y, _w, _h) { return {x:_x, y:_y, w:_w, h:_h}; }
function ui_contem(_area, _mx, _my) {
    return _mx >= _area.x && _mx < _area.x + _area.w && _my >= _area.y && _my < _area.y + _area.h;
}
function ui_mouse_x() { return device_mouse_x_to_gui(0); }
function ui_mouse_y() { return device_mouse_y_to_gui(0); }

function ui_entrada_liberada() {
    // Um clique que mudou de sala precisa terminar antes de ativar outra ação.
    if (!entrada_pronta) {
        if (!mouse_check_button(mb_left)) entrada_pronta = true;
        return false;
    }
    return true;
}

function ui_cartao(_x, _y, _w, _h, _cor) {
    var _v=global.visual,_fundo=(_cor==_v.claro)?_v.painel:_cor;
    draw_set_color(_v.sombra);draw_roundrect_ext(_x+3,_y+5,_x+_w+3,_y+_h+5,8,8,false);
    draw_set_color(_v.borda);draw_roundrect_ext(_x,_y,_x+_w,_y+_h,8,8,false);
    draw_set_color(_fundo);draw_roundrect_ext(_x+3,_y+3,_x+_w-3,_y+_h-3,6,6,false);
    draw_set_color(merge_color(_v.borda,c_white,.25));draw_line(_x+12,_y+2,_x+_w-12,_y+2);
    draw_set_color(_v.linha);draw_line(_x+9,_y+_h-3,_x+_w-9,_y+_h-3);
}
function ui_barra_segmentada(_x,_y,_w,_h,_fracao,_cor) {
    draw_set_color(global.visual.borda);draw_rectangle(_x-2,_y-2,_x+_w+2,_y+_h+2,false);
    draw_set_color(make_color_rgb(24,31,43));draw_rectangle(_x,_y,_x+_w,_y+_h,false);
    var _n=12,_passo=_w/_n;
    for(var _i=0;_i<_n;_i++) {
        var _f=clamp(_fracao*_n-_i,0,1);if(_f<=0)continue;
        var _esq=round(_x+_i*_passo+1),_dir=round(_x+(_i+_f)*_passo-1);
        if(_dir<_esq)continue;
        draw_set_color(_cor);draw_rectangle(_esq,_y+1,_dir,_y+_h-1,false);
        draw_set_color(merge_color(_cor,c_white,.3));draw_line(_esq,_y+1,_dir,_y+1);
    }
}

function ui_botao(_area, _texto, _cor, _habilitado = true, _selecionado = false) {
    var _v = global.visual;
    var _hover = ui_contem(_area, ui_mouse_x(), ui_mouse_y());
    var _fundo = _habilitado ? (_cor==_v.claro?_v.azul:_cor) : _v.linha;
    if (_hover && _habilitado) _fundo = merge_color(_fundo, c_white, 0.15);
    ui_cartao(_area.x, _area.y, _area.w, _area.h, _fundo);
    if (_selecionado) {
        draw_set_color(_v.ouro); draw_rectangle(_area.x, _area.y, _area.x + _area.w, _area.y + 4, false);
    }
    var _esc=ui_texto_largura(_texto,2)>_area.w-24?1:2;
    var _lum=color_get_red(_fundo)*.2126+color_get_green(_fundo)*.7152+color_get_blue(_fundo)*.0722;
    ui_texto_ajustado(_area.x+12,_area.y+(_area.h-(_esc==1?16:22))/2,_texto,_esc,_area.w-24,_habilitado?(_lum>155?_v.painel:_v.claro):_v.suave);
}

function ui_fundo() {
    draw_clear(global.visual.papel);
    draw_set_color(make_color_rgb(29, 42, 54));
    for (var _x = 8; _x < 1280; _x += 24) for (var _y = 8; _y < 720; _y += 28) draw_point(_x, _y);
}

function ui_titulo(_subtitulo) {
    var _v = global.visual;
    draw_set_color(_v.painel); draw_rectangle(0, 0, 1279, 91, false);
    draw_set_color(_v.borda);draw_line(0,91,1279,91);
    draw_set_color(_v.ciano); draw_rectangle(24, 21, 30, 68, false);
    ui_texto(46, 27, "FÁBRICA DE SALGADOS", 3, _v.claro);
    ui_texto(46, 59, _subtitulo, 2, _v.ouro);
}
