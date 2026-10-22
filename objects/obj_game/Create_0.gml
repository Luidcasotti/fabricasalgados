if (instance_number(obj_game) > 1) { instance_destroy(); exit; }
persistent = true;
if (!variable_global_exists("jogo")) global.jogo = jogo_criar();
visual_iniciar();
display_set_gui_size(1280, 720);
window_set_caption("Fábrica de Salgados • Gestão na prática");
window_set_size(1280, 720);
