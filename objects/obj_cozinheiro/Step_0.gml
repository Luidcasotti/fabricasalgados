var _c=instance_find(obj_exploracao,0);
if(!instance_exists(_c))exit;
if(simulacao_bloqueio(global.jogo)=="" && is_undefined(_c.painel) && !_c.ajuda && !historia_modal(_c)) {
    var _dx=keyboard_check(ord("D"))+keyboard_check(vk_right)-keyboard_check(ord("A"))-keyboard_check(vk_left);
    var _dy=keyboard_check(ord("S"))+keyboard_check(vk_down)-keyboard_check(ord("W"))-keyboard_check(vk_up);
    // Uma direção de tela por vez. Velocidade constante nos quatro eixos.
    if(_dx!=0)_dy=0;_dx=sign(_dx);_dy=sign(_dy);
    if(_dx!=0 || _dy!=0) {
        face=(_dx<0)?1:((_dx>0)?2:((_dy<0)?3:0));
        if(mundo_mover(id,_c.mundo,(_dx*2.6/18+_dy*2.6/9)/2,(_dy*2.6/9-_dx*2.6/18)/2))animacao++;
    } else animacao=0;
}
mundo_guardar(id);mundo_camera(_c.camera_mundo,id);
