if(!ui_entrada_liberada()) exit;
if(mouse_check_button_pressed(mb_left)) parametros_clique(ui_mouse_x(),ui_mouse_y());
if(keyboard_check_pressed(vk_enter) && campo_editando>=0) parametros_confirmar();
if(keyboard_check_pressed(vk_escape)) {
    if(campo_editando>=0) campo_editando=-1;else jogo_ir_para(FaseJogo.MENU);
}
