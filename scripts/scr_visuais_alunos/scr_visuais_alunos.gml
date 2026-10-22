/// Apenas apresentação: editar imagens não altera receita, dinheiro, colisão ou interação.
function visuais_alunos_sprite(_obj,_x,_y,_escala=1,_quadro=-1) {
    var _spr=object_get_sprite(_obj);if(_spr<0 || !sprite_exists(_spr))return false;
    if(_quadro<0)_quadro=(current_time div 250) mod max(1,sprite_get_number(_spr));
    draw_sprite_ext(_spr,_quadro,round(_x),round(_y),_escala,_escala,0,c_white,1);return true;
}
function visuais_alunos_movel(_m,_setor) {
    var _obj=noone;
    switch(_m.tipo) {
        case "balcao":_obj=obj_aula_com_balcao;break;
        case "mesa":_obj=(_setor=="estoque")?obj_aula_est_computador:obj_aula_com_computador;break;
        case "bancada":_obj=obj_aula_prod_bancada;break;
        case "fogao":_obj=obj_aula_prod_fogao;break;
        case "prateleira":_obj=obj_aula_est_prateleira;break;
        case "caixas":_obj=obj_aula_est_caixas;break;
        case "npc":
            switch(_m.papel) {
                case "atendente":_obj=obj_aula_atendente;break;
                case "estoquista":_obj=obj_aula_estoquista;break;
                case "gestor":_obj=obj_aula_gerente;break;
                case "cozinheiro":_obj=obj_aula_cozinheira_bia;break;
            }break;
    }
    if(_obj==noone)return false;
    var _p=mundo_projetar(_m.u,_m.v);return visuais_alunos_sprite(_obj,_p.x,_p.y);
}
function visuais_alunos_em(_obj,_u,_v,_z=0) {
    var _p=mundo_projetar(_u,_v);visuais_alunos_sprite(_obj,_p.x,_p.y-_z);
}
function visuais_alunos_ambiente(_setor) {
    // Decoração de parede: sem sólidos, sem alvos E e sem alterar corredores.
    switch(_setor) {
        case "comercial":
            visuais_alunos_em(obj_aula_com_placa,10,0.3,20);
            visuais_alunos_em(obj_aula_com_decoracao,20,0.2,0);
            break;
        case "producao":
            visuais_alunos_em(obj_aula_prod_utensilios,4,0.2,16);
            visuais_alunos_em(obj_aula_prod_placa,10,0.3,20);
            visuais_alunos_em(obj_aula_prod_decoracao,21,0.2,12);
            break;
        case "estoque":
            visuais_alunos_em(obj_aula_est_placa,10,0.3,20);
            visuais_alunos_em(obj_aula_est_decoracao,22,0.2,12);
            break;
    }
}
function visuais_alunos_rotulo(_alvo) {
    var _obj=noone;
    switch(_alvo.id) {
        case "prateleira_farinha":_obj=obj_aula_est_placa_farinha;break;
        case "prateleira_frango":_obj=obj_aula_est_placa_frango;break;
        case "prateleira_queijo":_obj=obj_aula_est_placa_queijo;break;
        case "prateleira_oleo":_obj=obj_aula_est_placa_oleo;break;
        case "prateleira_embalagens":_obj=obj_aula_est_placa_embalagens;break;
    }
    if(_obj==noone)return false;
    var _p=mundo_projetar(_alvo.u,_alvo.v);return visuais_alunos_sprite(_obj,_p.x,_p.y-45);
}
function visuais_alunos_retrato(_x,_y,_chef) {
    // O retrato acompanha o sprite real que o grupo personalizou.
    return visuais_alunos_sprite(_chef?obj_cozinheiro:obj_aula_gerente,_x,_y,2,0);
}
