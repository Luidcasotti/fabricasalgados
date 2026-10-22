if(!exploracao_ativa(global.jogo))exploracao_iniciar(global.jogo);
global.jogo.fase=FaseJogo.FABRICA;global.jogo.exploracao.setor=mundo_setor();
mundo=mundo_criar(mundo_setor());painel=undefined;selecao=0;quantidade=5;ajuda=false;
mensagem="WASD ou setas para andar. Aproxime-se e pressione E.";entrada_pronta=false;
camera_mundo=camera_create_view(0,0,640,360,0,noone,-1,-1,0,0);
view_enabled=true;view_visible[0]=true;view_camera[0]=camera_mundo;
view_xport[0]=0;view_yport[0]=0;view_wport[0]=1280;view_hport[0]=720;
gpu_set_texfilter(false);
