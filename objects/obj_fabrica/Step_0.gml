mensagem_tempo = max(0, mensagem_tempo - 1);
if (!ui_entrada_liberada()) exit;
if (mouse_check_button_pressed(mb_left)) fabrica_clicar(ui_mouse_x(), ui_mouse_y());
if (keyboard_check_pressed(vk_escape)) {
    if (painel != "") painel = "";
    else jogo_ir_para(FaseJogo.MENU);
}
