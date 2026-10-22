if (!ui_entrada_liberada()) exit;
if (mouse_check_button_pressed(mb_left)) {
    if (ui_contem(botao_novo,ui_mouse_x(),ui_mouse_y())) {jogo_novo();jogo_ir_para(FaseJogo.PARAMETROS);}
    else if (ui_contem(botao_continuar,ui_mouse_x(),ui_mouse_y())) jogo_ir_para(FaseJogo.FABRICA);
}
if (keyboard_check_pressed(vk_enter)) {jogo_novo();jogo_ir_para(FaseJogo.PARAMETROS);}
