function exploracao_lista_pedidos(_tipo) {
    if(missoes_ativa(global.jogo) && _tipo=="vendas") {
        var _p=missoes_atual(global.jogo);
        if(!is_undefined(_p) && (_p.status=="ofertado" || _p.status=="aceito"))return [_p];
        return [];
    }
    var _a=[];for(var _i=0;_i<array_length(global.jogo.pedidos);_i++) {
        var _p=global.jogo.pedidos[_i];
        if((_tipo=="vendas" && _p.status=="ofertado") || (_tipo=="entrega" && _p.status=="aceito"))array_push(_a,_p);
    }
    return _a;
}
function exploracao_botoes_base(_c) {
    if(feira_ativa(global.jogo) && global.jogo.feira.concluida)return feira_botoes(_c);
    var _v=global.visual,_a=[{area:ui_area(1020,24,236,46),texto:"AJUDA / OBJETIVO",acao:"ajuda"},
        {area:ui_area(24,648,190,50),texto:global.jogo.pausado?"RETOMAR":"PAUSAR",acao:"pausar"},
        {area:ui_area(228,648,198,50),texto:"RESULTADOS",acao:"resultados"},
        {area:ui_area(440,648,210,50),texto:"ENCERRAR DIA",acao:"relogio"},
        {area:ui_area(664,648,180,50),texto:"ENCERRAR JOGO",acao:"encerrar_jogo"}];
    if(_c.ajuda) {array_push(_a,{area:ui_area(1040,128,180,44),texto:"FECHAR",acao:"ajuda"});return historia_botoes(_c,_a);}
    if(_c.mundo.setor=="producao" && variable_struct_exists(global.jogo,"maquinas") && maquinas_funcionando(global.jogo)<maquinas_config(global.jogo).total && !historia_modal(_c) && is_undefined(_c.painel))array_push(_a,{area:ui_area(990,386,264,42),texto:"Chamar técnico",acao:"maquina_manutencao"});
    if(is_undefined(_c.painel))return historia_botoes(_c,_a);
    array_push(_a,{area:ui_area(1054,122,170,44),texto:"FECHAR / E",acao:"fechar"});
    var _t=_c.painel.tipo;
    if(_t=="compras" && missoes_ativa(global.jogo)){
        var _can=canhoto_dados(global.jogo),_texto="Voltar ao Comercial",_acao="fechar";
        if(!is_undefined(_can)){
            if(_can.comprar>0){_texto="COMPRAR APENAS O FALTANTE";_acao="comprar_faltante";}
            else if(_can.em_transito>0){_texto="VER MOTOBOY / "+string(ceil(compras_motoboy_restante(global.jogo)))+" s";}
            else if(_can.retirar>0){_texto="PEGAR INGREDIENTES DO PEDIDO";_acao="separar_pedido";}
            else {_texto="FECHAR / SEGUIR O CANHOTO";}
        }
        array_push(_a,{area:ui_area(626,486,568,52),texto:_texto,acao:_acao});
        return historia_botoes(_c,_a);
    }
    if(_t=="prateleira" && missoes_ativa(global.jogo)){
        var _q=missoes_coleta_quantidade(global.jogo,_c.painel.ingrediente_id);
        array_push(_a,{area:ui_area(626,486,568,52),texto:_q>0?"PEGAR O NECESSÁRIO / "+string(_q):"FECHAR / VER PRÓXIMO PASSO",acao:_q>0?"retirar_necessario":"fechar"});
        return historia_botoes(_c,_a);
    }
    if(_t=="relogio") {array_push(_a,{area:ui_area(626,468,568,52),texto:"CONFIRMAR / ENCERRAR DIA",acao:"avancar"});return historia_botoes(_c,_a);}
    if(_t=="deposito") {array_push(_a,{area:ui_area(626,486,568,52),texto:"DEPOSITAR TODA A MOCHILA",acao:"depositar"});return historia_botoes(_c,_a);}
    var _pedido_guiado=_t=="bancada" && missoes_ativa(global.jogo);
    if(_t!="prateleira" && !_pedido_guiado) {
        array_push(_a,{area:ui_area(626,190,170,44),texto:"ANTERIOR",acao:"anterior"});
        array_push(_a,{area:ui_area(1024,190,170,44),texto:"PRÓXIMO",acao:"proximo"});
    }
    if(_t=="vendas") {
        var _ofertas=exploracao_lista_pedidos("vendas");
        if(!missoes_ativa(global.jogo) || (array_length(_ofertas)>0 && _ofertas[0].status=="ofertado")) {
            array_push(_a,{area:ui_area(626,486,270,52),texto:"ACEITAR",acao:"aceitar"});
            array_push(_a,{area:ui_area(914,486,280,52),texto:"RECUSAR",acao:"recusar"});
        }
    } else if(_t=="entrega") {
        var _tem_entrega=array_length(exploracao_lista_pedidos("entrega"))>0;
        array_push(_a,{area:ui_area(626,486,568,52),texto:_tem_entrega?"ENTREGAR PEDIDO SELECIONADO":"FECHAR / VER PRÓXIMA MISSÃO",acao:_tem_entrega?"entregar":"fechar"});
    }
    else {
        if(!_pedido_guiado){
        array_push(_a,{area:ui_area(626,422,82,46),texto:"-5",acao:"menos5"});
        array_push(_a,{area:ui_area(720,422,82,46),texto:"-1",acao:"menos"});
        array_push(_a,{area:ui_area(1006,422,82,46),texto:"+1",acao:"mais"});
        array_push(_a,{area:ui_area(1100,422,94,46),texto:"+5",acao:"mais5"});
        }
        var _texto=_t=="bancada"?"COZINHAR PEDIDO":(_t=="compras"?"ENCOMENDAR / MOTOBOY EM 12 s":"BUSCAR INGREDIENTE / MOCHILA");
        var _acao=_t=="bancada"?"produzir":(_t=="compras"?"comprar":"retirar");
        if(_pedido_guiado){var _pedido=missoes_atual(global.jogo);if(is_undefined(_pedido) || _pedido.status!="aceito"){_texto="VOLTAR / ACEITAR NO COMERCIAL";_acao="fechar";}else if(missoes_restante(global.jogo,_pedido)==0){_texto="FECHAR E LEVAR AO COMERCIAL";_acao="fechar";}}
        array_push(_a,{area:ui_area(626,486,568,52),texto:_texto,acao:_acao});
    }
    return historia_botoes(_c,_a);
}
function exploracao_botoes(_c) {
    if(confirmacao_aberta(global.jogo))return confirmacao_botoes(global.jogo);
    if(missoes_zerou(global.jogo) && !feira_ativa(global.jogo))return missoes_fim_botoes();
    if(feira_resgate_aberto(global.jogo))return feira_resgate_botoes(global.jogo);
    var _j=global.jogo,_a=exploracao_botoes_base(_c);
    if(feira_ativa(_j) && _j.feira.concluida)return _a;
    if(_j.pausado) {
        _a=[{area:ui_area(24,648,220,50),texto:"RETOMAR",acao:"pausar"},
            {area:ui_area(264,648,180,50),texto:"ENCERRAR JOGO",acao:"encerrar_jogo"}];
    } else if(feira_ativa(_j)) {
        // A consulta de resultados pausa a campanha e preserva o mesmo cronômetro.
        var _filtrados=[];
        for(var _i=0;_i<array_length(_a);_i++)if(_a[_i].acao!="relogio")array_push(_filtrados,_a[_i]);
        _a=_filtrados;
    }
    if(_c.ajuda || _j.pausado) {
        if(!_j.pausado) {
            var _limpos=[];
            for(var _k=0;_k<array_length(_a);_k++)if(_a[_k].acao!="menu" && _a[_k].acao!="encerrar_jogo" && _a[_k].acao!="relogio" && _a[_k].acao!="resultados")array_push(_limpos,_a[_k]);
            _a=_limpos;array_push(_a,{area:ui_area(240,648,200,50),texto:"ENCERRAR JOGO",acao:"encerrar_jogo"});
        }
        array_push(_a,{area:ui_area(470,648,210,50),texto:global.audio_feira.mudo?"SOM: MUDO":"SOM: "+string(round(global.audio_feira.volume*100))+"%",acao:"som"});
        array_push(_a,{area:ui_area(694,648,64,50),texto:"-",acao:"volume_menos"});
        array_push(_a,{area:ui_area(774,648,64,50),texto:"+",acao:"volume_mais"});
    }
    for(var _h=0;_h<array_length(_a);_h++)if(_a[_h].acao=="ajuda" && _a[_h].area.y<100) {
        _a[_h].area=ui_area(800,26,170,46);_a[_h].texto="Ajuda / H";
    }
    return _a;
}
function exploracao_responder(_c,_r,_acao) {
    _c.mensagem=_r.mensagem;_c.mensagem_tempo=5;
    if(_r.ok){global.jogo.fala_visivel=false;feedback_som(_acao=="cozinhar"?"producao":((_acao=="retirar" || _acao=="depositar")?"coleta":"pedido"));_c.interacao_tempo=.35;}
    confirmacao_apos_acao(_c,_r,_acao);
    if(!_r.ok) {
        pedagogia_tentativa(global.jogo,_acao,_r.mensagem);
        if(missoes_ativa(global.jogo))missoes_problema(global.jogo,_r.mensagem);
    }
}
function exploracao_acao(_c,_acao) {
    var _j=global.jogo;
    if(_acao=="cancelar_saida"){if(confirmacao_aberta(_j) && _j.confirmacao.acao=="saida")confirmacao_fechar(_j);return;}
    if(_acao=="confirmar_saida" || (_acao=="confirmar_ato" && confirmacao_aberta(_j) && _j.confirmacao.acao=="saida")){
        if(confirmacao_aberta(_j) && _j.confirmacao.acao=="saida"){confirmacao_fechar(_j);jogo_ir_para(FaseJogo.MENU);}return;
    }
    if(_acao=="confirmar_ato"){confirmacao_fechar(_j);_c.entrada_pronta=false;return;}
    if(confirmacao_aberta(_j))return;
    if(feira_resgate_aberto(_j)){
        if(_acao=="resgate_encerrar")feira_resgate_encerrar(_j);
        else if(string_pos("resgate_resposta_",_acao)==1)feira_resgate_responder(_j,real(string_delete(_acao,1,17)));
        _c.entrada_pronta=false;return;
    }
    if(_acao=="historia_rejogar"){historia_jogar(_j.parametros);return;}
    if(_acao=="encerrar_jogo"){_j.confirmacao={titulo:"Encerrar o jogo?",texto:"Você voltará ao menu. Seu progresso ficará disponível em CONTINUAR. Para ficar nesta partida, escolha CONTINUAR JOGANDO.",acao:"saida",botao:"ENCERRAR / IR AO MENU"};return;}
    if(_acao=="feira_jogar"){feira_jogar();return;}
    if(_acao=="feira_inicio"){feira_inicio();return;}
    if(_acao=="feira_continuar"){if(feira_continuar(global.jogo)){_c.painel=undefined;_c.lote_em_curso=undefined;}return;}
    if(_acao=="som" || _acao=="volume_menos" || _acao=="volume_mais"){feedback_acao(_acao);return;}
    if(_acao=="menu"){jogo_ir_para(FaseJogo.MENU);return;}
    if(missoes_zerou(_j))return;
    if(historia_acao(_c,_acao))return;
    switch(_acao) {
        case "ajuda":_c.ajuda=!_c.ajuda;return;
        case "fechar":_c.painel=undefined;return;
        case "menu":jogo_ir_para(FaseJogo.MENU);return;
        case "pausar":simulacao_pausar(_j);return;
        case "resultados":
            if(!_j.pausado)simulacao_pausar(_j);jogo_ir_para(FaseJogo.RESULTADOS);return;
        case "relogio":_c.painel={tipo:"relogio",nome:"ENCERRAR O DIA"};_c.ajuda=false;return;
        case "avancar":
            var _r=simulacao_avancar_dia(_j);_c.painel=undefined;exploracao_responder(_c,_r,"encerrar dia");
            if(_r.ok && _j.encerrado)jogo_ir_para(FaseJogo.RESULTADOS);return;
        case "anterior":_c.selecao=max(0,_c.selecao-1);return;
        case "proximo":_c.selecao++;return;
        case "menos":_c.quantidade=max(1,_c.quantidade-1);return;
        case "menos5":_c.quantidade=max(1,_c.quantidade-5);return;
        case "mais":_c.quantidade=min(10000,_c.quantidade+1);return;
        case "mais5":_c.quantidade=min(10000,_c.quantidade+5);return;
    }
    if(is_undefined(_c.painel))return;
    var _t=_c.painel.tipo;
    // Painel e API conferem proximidade; abrir uma janela não autoriza ação remota.
    if(!mundo_perto(_j,_c.painel.id)) {exploracao_responder(_c,{ok:false,mensagem:"Volte ao equipamento para interagir."},_acao);return;}
    var _r={ok:false,mensagem:"Nada selecionado."};
    if(_acao=="separar_pedido")_r=exploracao_separar_pedido(_j);
    else if(_acao=="comprar_faltante")_r=exploracao_comprar_faltante(_j);
    else if(_acao=="consultar_estoque")_r=missoes_consultar_estoque(_j);
    else if(_acao=="depositar")_r=exploracao_depositar(_j);
    else if(_acao=="retirar" || _acao=="retirar_necessario"){
        var _q=_acao=="retirar_necessario"?missoes_coleta_quantidade(_j,_c.painel.ingrediente_id):_c.quantidade;
        _r=_q>0?exploracao_retirar(_j,_c.painel.ingrediente_id,_q):{ok:false,mensagem:missoes_fluxo(_j).acao};
        if(_r.ok && _acao=="retirar_necessario")_r.mensagem="Ingredientes na mochila. "+missoes_fluxo(_j).acao;
    }
    else if(_acao=="produzir") {
        if(missoes_ativa(_j))historia_selecionar_pedido(_c);
        _c.selecao=clamp(_c.selecao,0,array_length(_j.catalogo.produtos)-1);
        _r=missoes_ativa(_j)?historia_producao_iniciar(_c,_j.catalogo.produtos[_c.selecao].id,_c.quantidade):exploracao_produzir(_j,_j.catalogo.produtos[_c.selecao].id,_c.quantidade);
    } else if(_acao=="comprar") {
        _c.selecao=clamp(_c.selecao,0,array_length(_j.catalogo.ingredientes)-1);
        _r=compra_realizar(_j,_j.catalogo.ingredientes[_c.selecao].id,_c.quantidade);
    } else {
        var _lista=exploracao_lista_pedidos(_t);
        if(array_length(_lista)>0) {
            _c.selecao=clamp(_c.selecao,0,array_length(_lista)-1);var _p=_lista[_c.selecao];
            if(_acao=="aceitar" || _acao=="recusar")_r=pedido_decidir(_j,_p.id,_acao=="aceitar");
            if(_acao=="entregar")_r=pedido_entregar(_j,_p);
        }
    }
    exploracao_responder(_c,_r,_acao);
    if(_r.ok && _acao=="comprar")_c.painel=undefined;
    if(_r.ok && missoes_ativa(_j) && array_contains(["aceitar","separar_pedido","depositar","retirar_necessario","entregar","comprar_faltante","comprar"],_acao))_c.painel=undefined;
}
function exploracao_controle_passo(_c) {
    var _a=instance_find(obj_cozinheiro,0),_j=global.jogo;if(!instance_exists(_a))return;
    mundo_guardar(_a);
    if(!mouse_check_button(mb_left))_c.entrada_pronta=true;
    if(confirmacao_aberta(_j)){
        if(_j.confirmacao.acao=="saida" && keyboard_check_pressed(vk_escape)){confirmacao_fechar(_j);return;}
        if(keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)){exploracao_acao(_c,"confirmar_ato");return;}
        if(_c.entrada_pronta && mouse_check_button_pressed(mb_left))exploracao_clicar(_c,ui_mouse_x(),ui_mouse_y());
        return;
    }
    if(feira_resgate_aberto(_j)){
        for(var _i=0;_i<3;_i++)if(keyboard_check_pressed(ord("1")+_i)){exploracao_acao(_c,"resgate_resposta_"+string(_i));return;}
        if(_c.entrada_pronta && mouse_check_button_pressed(mb_left))exploracao_clicar(_c,ui_mouse_x(),ui_mouse_y());
        return;
    }
    if(missoes_zerou(_j) && !feira_ativa(_j)){
        if(_c.entrada_pronta && mouse_check_button_pressed(mb_left))exploracao_clicar(_c,ui_mouse_x(),ui_mouse_y());return;
    }
    var _dt=min(delta_time/1000000,.05);
    pedagogia_aviso_passo(_j,max(0,delta_time/1000000));
    if(variable_instance_exists(_c,"mensagem_tempo")){
        _c.mensagem_tempo=max(0,_c.mensagem_tempo-max(0,delta_time/1000000));
        if(_c.mensagem_tempo<=0 && missoes_ativa(_j))_c.mensagem=missoes_fluxo(_j).acao;
    }
    if(feira_ativa(_j)){
        if(feira_passo(_j,max(0,delta_time/1000000))){feira_inicio();return;}
        if(feira_resgate_aberto(_j)){_c.entrada_pronta=false;return;}
        if(_j.feira.concluida){
            _c.lote_em_curso=undefined;_c.ajuda=false;_c.reinicio_confirmar=false;
            if(keyboard_check_pressed(vk_enter)){feira_inicio();return;}
            if(_c.entrada_pronta && mouse_check_button_pressed(mb_left))exploracao_clicar(_c,ui_mouse_x(),ui_mouse_y());
            return;
        }
    }
    if(compras_passo(_j,max(0,delta_time/1000000))>0){_c.mensagem=_j.exploracao.aviso_entrega;_c.mensagem_tempo=7;feedback_som("coleta");}
    maquinas_passo(_j,_dt);
    if(!_j.pausado)hud_estoque_passo(_c,_dt);
    if(_c.porta_destino!="") {
        if(!_j.pausado)_c.porta_tempo+=_dt;
        if(_c.porta_tempo>=.18)mundo_porta_transitar(_c);
        return;
    }
    if(keyboard_check_pressed(ord("M")))feedback_acao("som");
    if(keyboard_check_pressed(vk_escape) && historia_modal(_c)) {
        if(historia_aberta(_j))historia_fechar(_j);
        else if(_c.reinicio_confirmar)_c.reinicio_confirmar=false;
        else simulacao_pausar(_j);
        return;
    }
    if(keyboard_check_pressed(ord("H")) && !historia_modal(_c))_c.ajuda=!_c.ajuda;
    if(_j.pausado) {
        if(keyboard_check_pressed(vk_escape))simulacao_pausar(_j);
        if(_c.entrada_pronta && mouse_check_button_pressed(mb_left))exploracao_clicar(_c,ui_mouse_x(),ui_mouse_y());
        return;
    }
    historia_passo(_c);
    if(historia_modal(_c)) {
        if(historia_aberta(_j) && keyboard_check_pressed(ord("E"))){historia_fechar(_j);return;}
        if(keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {historia_continuar(_j);return;}
        if(_c.entrada_pronta && mouse_check_button_pressed(mb_left)) {
            if(ui_mouse_y()>=510){exploracao_clicar(_c,ui_mouse_x(),ui_mouse_y());return;}
            if(historia_aberta(_j) && ui_contem(ui_area(320,110,920,494),ui_mouse_x(),ui_mouse_y())) {
                var _f=_j.missoes.fila[_j.missoes.indice_fala];
                if(_f.tipo=="fala" || _j.missoes.resposta_atual>=0)historia_continuar(_j);
                else exploracao_clicar(_c,ui_mouse_x(),ui_mouse_y());
            } else exploracao_clicar(_c,ui_mouse_x(),ui_mouse_y());
        }
        return;
    }
    if(keyboard_check_pressed(vk_escape)) {
        if(_c.ajuda)_c.ajuda=false;
        else if(!is_undefined(_c.painel))_c.painel=undefined;
        else simulacao_pausar(_j);
        return;
    }
    if(keyboard_check_pressed(ord("E")) && !_c.ajuda) {
        if(!is_undefined(_c.painel))_c.painel=undefined;
        else if(mundo_interagir(_c,mundo_alvo_proximo(_a,_c.mundo)) && _c.porta_destino!="")return;
    }
    if(!mouse_check_button(mb_left))_c.entrada_pronta=true;
    if(!_c.entrada_pronta || !mouse_check_button_pressed(mb_left))return;
    var _mx=device_mouse_x_to_gui(0),_my=device_mouse_y_to_gui(0);
    exploracao_clicar(_c,_mx,_my);
}
function exploracao_clicar(_c,_mx,_my) {
    var _j=global.jogo;
    if(_j.fala_visivel && ui_contem(ui_area(1232,610,24,22),_mx,_my)){_j.fala_visivel=false;_c.mensagem=missoes_ativa(_j)?missoes_fluxo(_j).acao:"Continue a atividade.";return;}
    var _bs=exploracao_botoes(_c);
    for(var _i=array_length(_bs)-1;_i>=0;_i--) if(ui_contem(_bs[_i].area,_mx,_my)){exploracao_acao(_c,_bs[_i].acao);return;}
}

function exploracao_painel_desenhar(_c) {
    var _j=global.jogo,_v=global.visual,_t=_c.painel.tipo;
    ui_cartao(600,110,640,494,_v.claro);ui_texto(626,144,_c.painel.nome,2,_v.tinta);
    if(_t=="compras" && missoes_ativa(_j)){
        var _can=canhoto_dados(_j);
        if(is_undefined(_can)){ui_paragrafo(626,228,"Primeiro aceite o pedido com Marta no Comercial. Depois traga seu canhoto para eu separar os ingredientes.",568,_v.tinta);return;}
        ui_texto(626,196,"Lista do pedido #"+string(_can.pedido.id),2,_v.ciano);
        ui_texto(626,230,_can.comprar>0?"Há faltantes. Compre só o que não existe na empresa.":(_can.em_transito>0?"Motoboy a caminho / "+string(ceil(compras_motoboy_restante(_j)))+" s. Aguarde a chegada.":"Os ingredientes já estão aqui. Não precisa comprar."),1,_v.tinta);
        ui_texto(626,268,"Ingrediente",1,_v.suave);ui_texto(854,268,"Pedido",1,_v.suave);ui_texto(964,268,"Aqui",1,_v.suave);ui_texto(1070,268,"Retirar",1,_v.suave);
        for(var _i=0;_i<array_length(_can.linhas);_i++){
            var _d=_can.linhas[_i],_y=304+_i*32;
            ui_texto(626,_y,_d.nome,2,_v.tinta);ui_texto(854,_y,string(_d.total_pedido),2,_v.tinta);
            ui_texto(964,_y,string(_d.almoxarifado),2,_v.suave);ui_texto(1070,_y,string(_d.retirar),2,_d.retirar>0?_v.ciano:_v.verde);
        }
        ui_texto_ajustado(626,454,"Mochila "+string(exploracao_carregado_total(_j))+"/"+string(_j.exploracao.limite_transporte)+" · A lista desconta o que você já levou.",1,568,_v.suave);return;
    }
    if(_t=="relogio") {
        ui_paragrafo(626,216,"Encerrar o dia registra o que você já fez. Não produz nem entrega pedidos por você. Na exploração, o motoboy entrega compras em segundos de jogo, sem precisar virar o dia.",568,_v.tinta);
        ui_paragrafo(626,350,"Os pedidos pendentes continuam na fila. Ao fechar o último dia, o período termina e os resultados ficam disponíveis.",568,_v.suave);return;
    }
    if(_t=="deposito") {
        for(var _i=0;_i<array_length(_j.catalogo.ingredientes);_i++) {
            var _in=_j.catalogo.ingredientes[_i];
            ui_texto(626,208+_i*42,_in.nome,2,_v.tinta);
            ui_texto(850,208+_i*42,string(estoque_quantidade(_j.carregados,_in.id))+" MOCHILA / "+string(estoque_quantidade(_j.cozinha,_in.id))+" COZINHA",1,_v.suave);
        }
        ui_texto(626,444,"TRANSFERÊNCIA SEM CONSUMO E SEM DUPLICAÇÃO.",1,_v.suave);return;
    }
    if(_t=="vendas" || _t=="entrega") {
        var _l=exploracao_lista_pedidos(_t);
        if(array_length(_l)==0 && missoes_ativa(_j)) {ui_paragrafo(626,272,_j.missoes.etapa==EtapaMissao.RECUPERAR?"Marta: sua recusa foi registrada. Use OUTRO PEDIDO para continuar esta missão.":"Nenhum pedido aguardando entrega aqui. Feche este painel e vá ao balcão de vendas da Marta para aceitar a próxima missão.",568,_v.tinta);return;}
        if(array_length(_l)==0) {ui_paragrafo(626,272,_t=="vendas"?"Marta: nenhuma oferta aguardando decisão. Ao abrir outro dia, novas encomendas poderão chegar.":"Nenhum pedido aceito aguardando entrega. Converse com Marta para analisar as ofertas.",568,_v.tinta);return;}
        _c.selecao=clamp(_c.selecao,0,array_length(_l)-1);var _p=_l[_c.selecao],_prod=produto_obter(_j.catalogo,_p.produto_id);
        ui_texto(626,258,"PEDIDO #"+string(_p.id)+" / "+string_upper(_p.status),2,_v.azul);
        ui_texto(626,294,_prod.nome+" / "+string(_p.quantidade)+" UN.",2,_v.tinta);
        ui_texto(626,330,"VALOR: "+financas_formatar(_p.total_centavos),2,_v.tinta);
        ui_texto(626,366,"PRAZO: DIA "+string(_p.prazo_dia)+" / PRONTOS: "+string(estoque_quantidade(_j.estoque.produtos,_p.produto_id)),2,_v.tinta);
        if(missoes_ativa(_j)) {
            ui_paragrafo(626,406,_t=="vendas"?pedido_diagnostico(_j,_p).mensagem:"A entrega recebe o pagamento do cliente.",568,_v.suave);
        }
        else ui_paragrafo(626,406,_t=="vendas"?pedido_diagnostico(_j,_p).mensagem:"Entregue quando houver toda a quantidade pronta. A receita só entra no caixa após confirmar a entrega.",568,_v.suave);return;
    }
    if(_t=="bancada") {
        if(missoes_ativa(_j))historia_selecionar_pedido(_c);
        if(missoes_ativa(_j)){
            var _pedido=missoes_atual(_j);
            if(is_undefined(_pedido) || _pedido.status!="aceito"){ui_paragrafo(626,258,"Primeiro aceite um pedido com Marta no Comercial. Depois volte a esta mesa para preparar.",568,_v.tinta);return;}
            if(missoes_restante(_j,_pedido)==0){ui_texto(626,258,"PEDIDO PRONTO!",2,_v.verde);ui_paragrafo(626,320,"Leve os salgados ao balcão ENTREGAR do Comercial. Use E e confirme a entrega para receber o pagamento.",568,_v.tinta);return;}
        }
        _c.selecao=clamp(_c.selecao,0,array_length(_j.catalogo.produtos)-1);var _p=_j.catalogo.produtos[_c.selecao];
        if(missoes_ativa(_j))ui_texto(626,202,string_upper(_p.nome)+" / "+string(_c.quantidade)+" UN.",2,_v.ciano);
        var _validacao=exploracao_receita_validar(_j,_p.id,_c.quantidade);
        var _titulo=_validacao.ok?"COZINHA ABASTECIDA":(variable_struct_exists(_validacao,"diagnostico")?"FALTA ABASTECER A COZINHA":"CONFIRA CAPACIDADE E CAIXA");
        ui_texto(626,252,_titulo,2,_validacao.ok?_v.ciano:_v.ouro);
        var _linha=0;
        for(var _i=0;_i<array_length(_p.receita);_i++) {
            var _ri=_p.receita[_i],_in=ingrediente_obter(_j.catalogo,_ri.ingrediente_id);
            if(_ri.quantidade<=0)continue;
            var _d=exploracao_insumo_diagnostico(_j,_in.id,_ri.quantidade*_c.quantidade),_y=282+_linha*27;
            var _cor=(_d.falta_local<=0)?_v.verde:(_d.falta_empresa>0?_v.vermelho:_v.ouro);
            ui_texto(626,_y,_in.nome,1,_v.tinta);ui_barra_segmentada(758,_y,192,10,min(1,_d.cozinha/max(1,_d.necessario)),_cor);
            ui_texto(968,_y,string(_d.cozinha)+"/"+string(_d.necessario)+" NA COZINHA",1,_cor);
            ui_texto(758,_y+16,"ALMOXARIFADO "+string(_d.almoxarifado)+" / MOCHILA "+string(_d.mochila)+" / EMPRESA "+string(_d.total),1,_v.suave);_linha++;
        }
        ui_texto(626,402,"PREPARO: "+financas_formatar(_p.custo_variavel_centavos*_c.quantidade)+(missoes_ativa(_j)?" / PRODUTO E QUANTIDADE DO PEDIDO":""),1,_v.suave);
        if(missoes_ativa(_j))ui_paragrafo(626,548,missoes_fluxo(_j).acao,568,_v.ciano);
    } else {
        var _in;
        if(_t=="prateleira")_in=ingrediente_obter(_j.catalogo,_c.painel.ingrediente_id);
        else {_c.selecao=clamp(_c.selecao,0,array_length(_j.catalogo.ingredientes)-1);_in=_j.catalogo.ingredientes[_c.selecao];}
        ui_texto(626,252,_in.nome,2,_v.azul);
        ui_texto(626,290,"NO ESTOQUE: "+string(estoque_quantidade(_j.estoque.materias_primas,_in.id))+" / MÍNIMO: "+string(_in.estoque_minimo),2,_v.tinta);
        if(_t=="compras") {
            ui_texto(626,330,"COMPRA: "+financas_formatar(_in.custo_centavos*_c.quantidade),2,_v.tinta);
            ui_texto(626,366,"MOTOBOY: "+string(ceil(compras_motoboy_restante(_j,_in.id)>0?compras_motoboy_restante(_j,_in.id):12))+" s / A CAMINHO: "+string(compras_pendentes_quantidade(_j,_in.id)),2,_v.tinta);
        } else if(missoes_ativa(_j)){
            var _q=missoes_coleta_quantidade(_j,_in.id);
            ui_paragrafo(626,338,_q>0?"PEGAR O NECESSÁRIO leva "+string(_q)+" para a mochila. A quantidade já considera o pedido e o espaço disponível.":missoes_fluxo(_j).acao,568,_v.suave);
            ui_texto(626,438,"MOCHILA: "+string(exploracao_carregado_total(_j))+" / "+string(_j.exploracao.limite_transporte)+". USE E PARA FECHAR.",1,_v.ciano);
            return;
        } else ui_paragrafo(626,338,"Retire "+string(_c.quantidade)+" e leve à MESA DE DEPÓSITO na Produção. Não precisa comprar: este ingrediente já está na prateleira.",568,_v.suave);
    }
    ui_centro(902,438,(missoes_ativa(_j) && _t=="bancada"?"LOTE DO PEDIDO: ":"QTD: ")+string(_c.quantidade),2,_v.tinta);
}
function exploracao_interface_desenhar(_c) {
    var _j=global.jogo,_v=global.visual;
    if(feira_resgate_aberto(_j)){
        hud_estoque_desenhar(_c);canhoto_desenhar(_j);feira_resgate_desenhar(_j);return;
    }
    if(confirmacao_aberta(_j)){
        if(feira_ativa(_j) && _j.feira.concluida)feira_resultado_desenhar(_c);
        else {hud_estoque_desenhar(_c);canhoto_desenhar(_j);if(feira_ativa(_j))feira_relogio_desenhar(_j,_c);}
        confirmacao_desenhar(_j);return;
    }
    if(feira_ativa(_j) && _j.feira.concluida) {
        feira_resultado_desenhar(_c);var _fim=feira_botoes(_c);for(var _i=0;_i<array_length(_fim);_i++)ui_botao(_fim[_i].area,_fim[_i].texto,_v.verde);return;
    }
    if(missoes_zerou(_j) && !feira_ativa(_j)){
        missoes_fim_desenhar(_j);var _fim=missoes_fim_botoes();for(var _i=0;_i<array_length(_fim);_i++)ui_botao(_fim[_i].area,_fim[_i].texto,_v.verde);return;
    }
    ui_cartao(16,110,1248,74,_v.claro);
    var _g=missoes_ativa(_j)?missoes_fluxo(_j):{titulo:"Próximo passo",acao:exploracao_objetivo(_j)};
    ui_texto(32,120,(missoes_ativa(_j)?"Missão "+string(min(_j.missoes.meta,array_length(_j.missoes.entregues)+1))+"/"+string(_j.missoes.meta)+" · ":"Próximo: ")+_g.titulo,2,_v.ciano);
    ui_texto_ajustado(32,154,_g.acao,1,1216,_v.tinta);
    missoes_indicador_desenhar(_c);
    canhoto_desenhar(_j);
    var _a=instance_find(obj_cozinheiro,0);
    if(instance_exists(_a) && is_undefined(_c.painel) && !_c.ajuda) {
        var _alvo=mundo_alvo_proximo(_a,_c.mundo);
        var _destino=missoes_ativa(_j)?missoes_indicacao(_j,_c.mundo):_alvo;
        if(!is_undefined(_alvo) && !is_undefined(_destino) && _alvo.id==_destino.id) {ui_cartao(340,548,872,44,_v.claro);ui_texto(356,562,(_alvo.tipo=="porta"?"PRESSIONE E PARA ENTRAR NO ":"PRESSIONE E / ")+_alvo.nome,2,_v.azul);}
    }
    if(!is_undefined(_c.painel))exploracao_painel_desenhar(_c);
    if(_c.ajuda && !missoes_ativa(_j)) {
        ui_cartao(320,110,920,494,_v.claro);ui_texto(344,144,"CONTROLES E OBJETIVO",2,_v.azul);
        ui_paragrafo(344,208,"VOCÊ ESTÁ EM: "+_c.mundo.nome+". "+exploracao_objetivo(_j)+" WASD/setas: andar. E: interagir perto do alvo. H: ajuda. M: som. Esc: fechar painel ou pausar.",840,_v.tinta);
        ui_paragrafo(344,320,"1. Aceite uma encomenda com Marta. 2. Confira a receita na bancada. 3. Retire ingredientes nas prateleiras. 4. Leve e deposite na cozinha. 5. Cozinhe. 6. Entregue no balcão do Comercial.",840,_v.tinta);
        ui_paragrafo(344,466,"Encerrar dia recebe compras e atualiza prazos; não cozinha nem entrega. Resultados permite consultar o diário e retomar. Todos os valores são fictícios para aprendizagem.",840,_v.suave);
    }
    ui_cartao(16,608,1248,26,_v.claro);
    var _status_moto=compras_status_motoboy(_j);
    ui_texto_ajustado(24,614,_status_moto!=""?_status_moto:_c.mensagem,1,1216,_status_moto!=""?_v.ciano:_v.tinta);
    pedagogia_desenhar_fala(_j);
    maquinas_desenhar(_c);
    historia_desenhar(_c);
    hud_estoque_desenhar(_c);
    if(feira_ativa(_j))feira_relogio_desenhar(_j,_c);
    if(_j.pausado) {
        draw_set_alpha(.92);draw_set_color(_v.painel);draw_rectangle(0,106,1280,638,false);draw_set_alpha(1);
        ui_centro(640,280,"PAUSADO",4,_v.claro);ui_centro(640,340,"ESC OU RETOMAR PARA CONTINUAR",2,_v.ouro);
    }
    var _bs=exploracao_botoes(_c);for(var _i=0;_i<array_length(_bs);_i++)ui_botao(_bs[_i].area,_bs[_i].texto,_v.azul);
    ui_texto(24,702,"WASD / setas: andar     E: abrir e fechar     H: ajuda     Esc: voltar ou pausar",1,_v.suave);
}
