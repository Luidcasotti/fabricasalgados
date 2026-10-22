var _c=instance_find(obj_exploracao,0),_e=global.jogo.exploracao;
var _p=variable_struct_exists(_e.posicoes,_e.setor)?variable_struct_get(_e.posicoes,_e.setor):_c.mundo.entrada;
u=_p.u;v=_p.v;face=_p.face;animacao=0;image_speed=0;
if(!mundo_livre(_c.mundo,u,v)){u=_c.mundo.entrada.u;v=_c.mundo.entrada.v;}
mundo_mover(id,_c.mundo,0,0);mundo_guardar(id);mundo_camera(_c.camera_mundo,id);
