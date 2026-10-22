if(!ui_entrada_liberada()) exit;
if(mouse_check_button_pressed(mb_left)) dashboard_clicar(ui_mouse_x(),ui_mouse_y());
if(keyboard_check_pressed(vk_escape)) jogo_ir_para(FaseJogo.MENU);
