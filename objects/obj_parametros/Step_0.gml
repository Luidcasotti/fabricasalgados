if (!ui_entrada_liberada()) exit;
var _delta=0;
if (mouse_check_button_pressed(mb_left)) {
    var _mx=ui_mouse_x(), _my=ui_mouse_y();
    if(ui_contem(botao_menos,_mx,_my)) _delta=-10;
    if(ui_contem(botao_mais,_mx,_my)) _delta=10;
    if(ui_contem(botao_abrir,_mx,_my)) jogo_ir_para(FaseJogo.FABRICA);
    if(ui_contem(botao_voltar,_mx,_my)) jogo_ir_para(FaseJogo.MENU);
}
if(keyboard_check_pressed(vk_up)) _delta=10;
if(keyboard_check_pressed(vk_down)) _delta=-10;
global.jogo.parametros.capacidade_diaria=clamp(global.jogo.parametros.capacidade_diaria+_delta,10,500);
if(keyboard_check_pressed(vk_enter)) jogo_ir_para(FaseJogo.FABRICA);
if(keyboard_check_pressed(vk_escape)) jogo_ir_para(FaseJogo.MENU);
