/// Interface original por primitivas: fonte bitmap 5x7, sem arquivos externos.
function visual_iniciar() {
    if (variable_global_exists("visual")) return;
    global.visual = {
        papel: make_color_rgb(244, 239, 222), claro: make_color_rgb(255, 252, 239),
        tinta: make_color_rgb(32, 53, 63), suave: make_color_rgb(92, 110, 107),
        linha: make_color_rgb(201, 205, 185), sombra: make_color_rgb(216, 215, 195),
        laranja: make_color_rgb(214, 96, 54), verde: make_color_rgb(66, 116, 91),
        azul: make_color_rgb(60, 113, 132), ouro: make_color_rgb(224, 175, 77), fonte: {}
    };
    variable_struct_set(global.visual.fonte,"&",[12,18,20,8,21,18,13]);
    var _letras = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;!?-+/()$%#=>";
    var _linhas = [
        [14,17,17,31,17,17,17], [30,17,17,30,17,17,30], [14,17,16,16,16,17,14],
        [30,17,17,17,17,17,30], [31,16,16,30,16,16,31], [31,16,16,30,16,16,16],
        [14,17,16,23,17,17,15], [17,17,17,31,17,17,17], [14,4,4,4,4,4,14],
        [7,2,2,2,18,18,12], [17,18,20,24,20,18,17], [16,16,16,16,16,16,31],
        [17,27,21,21,17,17,17], [17,25,25,21,19,19,17], [14,17,17,17,17,17,14],
        [30,17,17,30,16,16,16], [14,17,17,17,21,18,13], [30,17,17,30,20,18,17],
        [15,16,16,14,1,1,30], [31,4,4,4,4,4,4], [17,17,17,17,17,17,14],
        [17,17,17,17,17,10,4], [17,17,17,21,21,21,10], [17,17,10,4,10,17,17],
        [17,17,10,4,4,4,4], [31,1,2,4,8,16,31],
        [14,17,19,21,25,17,14], [4,12,4,4,4,4,14], [14,17,1,2,4,8,31],
        [30,1,1,14,1,1,30], [2,6,10,18,31,2,2], [31,16,16,30,1,1,30],
        [14,16,16,30,17,17,14], [31,1,2,4,8,8,8], [14,17,17,14,17,17,14],
        [14,17,17,15,1,1,14],
        [0,0,0,0,0,6,6], [0,0,0,0,6,4,8], [0,6,6,0,6,6,0],
        [0,6,6,0,6,4,8], [4,4,4,4,4,0,4], [14,17,1,2,4,0,4],
        [0,0,0,31,0,0,0], [0,4,4,31,4,4,0], [1,2,2,4,8,8,16],
        [2,4,8,8,8,4,2], [8,4,2,2,2,4,8], [4,15,20,14,5,30,4],
        [25,25,2,4,8,19,19], [10,31,10,10,31,10,0], [0,0,31,0,31,0,0],
        [16,8,4,2,4,8,16]
    ];
    for (var _i = 1; _i <= string_length(_letras); _i++) {
        variable_struct_set(global.visual.fonte, string_char_at(_letras, _i), _linhas[_i - 1]);
    }
}

function ui_texto_largura(_texto, _escala) { return max(0, string_length(string(_texto)) * 6 - 1) * _escala; }

function ui_texto(_x, _y, _texto, _escala, _cor) {
    var _origem = round(_x);
    _x = _origem; _y = round(_y);
    _texto = string_upper(string(_texto));
    draw_set_color(_cor);
    for (var _i = 1; _i <= string_length(_texto); _i++) {
        var _ch = string_char_at(_texto, _i);
        if (_ch == "\n") { _x = _origem; _y += 11 * _escala; continue; }
        var _base = _ch;
        var _acento = 0;
        if (string_pos(_ch, "ÁÉÍÓÚ") > 0) { _base = string_char_at("AEIOU", string_pos(_ch, "ÁÉÍÓÚ")); _acento = 1; }
        if (string_pos(_ch, "ÃÕ") > 0) { _base = string_char_at("AO", string_pos(_ch, "ÃÕ")); _acento = 2; }
        if (string_pos(_ch, "ÂÊÔ") > 0) { _base = string_char_at("AEO", string_pos(_ch, "ÂÊÔ")); _acento = 3; }
        if (_ch == "À") { _base = "A"; _acento = 4; }
        if (_ch == "Ü") { _base = "U"; _acento = 5; }
        if (_ch == "Ç") { _base = "C"; _acento = 6; }
        if (variable_struct_exists(global.visual.fonte, _base)) {
            var _rows = variable_struct_get(global.visual.fonte, _base);
            for (var _r = 0; _r < 7; _r++) {
                for (var _c = 0; _c < 5; _c++) {
                    if ((_rows[_r] & (1 << (4 - _c))) != 0) {
                        draw_rectangle(_x + _c * _escala, _y + _r * _escala,
                            _x + (_c + 1) * _escala, _y + (_r + 1) * _escala, false);
                    }
                }
            }
            if (_acento > 0 && _acento < 6) {
                var _mascara = [0, 6, 10, 4, 12, 10][_acento];
                for (var _c = 0; _c < 5; _c++) {
                    if ((_mascara & (1 << (4 - _c))) != 0) draw_rectangle(
                        _x + _c * _escala, _y - 2 * _escala,
                        _x + (_c + 1) * _escala, _y - _escala, false);
                }
            }
            if (_acento == 6) draw_rectangle(_x + 2 * _escala, _y + 7 * _escala,
                _x + 3 * _escala, _y + 8 * _escala, false);
        }
        _x += 6 * _escala;
    }
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
            ui_texto(_x, _y, _linha, 2, _cor); _y += 24; _linha = _palavras[_i];
        } else _linha = _nova;
    }
    ui_texto(_x, _y, _linha, 2, _cor);
    return _y + 24;
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
    draw_set_color(global.visual.sombra); draw_rectangle(_x + 3, _y + 4, _x + _w + 3, _y + _h + 4, false);
    draw_set_color(_cor); draw_rectangle(_x, _y, _x + _w, _y + _h, false);
}

function ui_botao(_area, _texto, _cor, _habilitado = true, _selecionado = false) {
    var _v = global.visual;
    var _hover = ui_contem(_area, ui_mouse_x(), ui_mouse_y());
    var _fundo = _habilitado ? _cor : _v.linha;
    if (_hover && _habilitado) _fundo = merge_color(_fundo, c_white, 0.15);
    ui_cartao(_area.x, _area.y, _area.w, _area.h, _fundo);
    if (_selecionado) {
        draw_set_color(_v.ouro); draw_rectangle(_area.x, _area.y, _area.x + _area.w, _area.y + 4, false);
    }
    ui_centro(_area.x + _area.w / 2, _area.y + (_area.h - 14) / 2, _texto, 2,
        _habilitado ? _v.claro : _v.suave);
}

function ui_fundo() {
    draw_clear(global.visual.papel);
    draw_set_color(make_color_rgb(233, 230, 210));
    for (var _x = 8; _x < 1280; _x += 24) for (var _y = 8; _y < 720; _y += 24) draw_point(_x, _y);
}

function ui_titulo(_subtitulo) {
    var _v = global.visual;
    draw_set_color(_v.tinta); draw_rectangle(0, 0, 1279, 91, false);
    draw_set_color(_v.laranja); draw_rectangle(24, 21, 30, 68, false);
    ui_texto(46, 27, "FÁBRICA DE SALGADOS", 3, _v.claro);
    ui_texto(46, 59, _subtitulo, 2, _v.ouro);
}
