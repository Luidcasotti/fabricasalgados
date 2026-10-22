if (!ui_entrada_liberada()) exit;
if(mouse_check_button_pressed(mb_left)) {
    if(ui_contem(botao_voltar,ui_mouse_x(),ui_mouse_y())) jogo_ir_para(FaseJogo.FABRICA);
    else if(ui_contem(botao_menu,ui_mouse_x(),ui_mouse_y())) jogo_ir_para(FaseJogo.MENU);
}
if(keyboard_check_pressed(vk_enter)) jogo_ir_para(FaseJogo.FABRICA);
if(keyboard_check_pressed(vk_escape)) jogo_ir_para(FaseJogo.MENU);
