function exploracao_lista_pedidos(_tipo) {
    if(missoes_ativa(global.jogo) && _tipo=="vendas") {
        var _m=global.jogo.missoes,_id=(_m.etapa>=EtapaMissao.DESAFIO)?_m.segundo_id:_m.primeiro_id;
        var _p=catalogo_buscar(global.jogo.pedidos,_id);
        if(!is_undefined(_p) && (_p.status=="ofertado" || _p.status=="aceito"))return [_p];
        return [];
    }
    var _a=[];for(var _i=0;_i<array_length(global.jogo.pedidos);_i++) {
        var _p=global.jogo.pedidos[_i];
        if((_tipo=="vendas" && _p.status=="ofertado") || (_tipo=="entrega" && _p.status=="aceito"))array_push(_a,_p);
    }
    return _a;
}
function exploracao_botoes(_c) {
    var _v=global.visual,_a=[{area:ui_area(1020,24,236,46),texto:"AJUDA / OBJETIVO",acao:"ajuda"},
        {area:ui_area(24,648,190,50),texto:global.jogo.pausado?"RETOMAR":"PAUSAR",acao:"pausar"},
        {area:ui_area(228,648,198,50),texto:"RESULTADOS",acao:"resultados"},
        {area:ui_area(440,648,210,50),texto:"ENCERRAR DIA",acao:"relogio"},
        {area:ui_area(664,648,180,50),texto:"MENU",acao:"menu"}];
    if(_c.ajuda) {array_push(_a,{area:ui_area(1040,128,180,44),texto:"FECHAR",acao:"ajuda"});return historia_botoes(_c,_a);}
    if(is_undefined(_c.painel))return historia_botoes(_c,_a);
    array_push(_a,{area:ui_area(1054,122,170,44),texto:"FECHAR / E",acao:"fechar"});
    var _t=_c.painel.tipo;
    if(_t=="relogio") {array_push(_a,{area:ui_area(626,468,568,52),texto:"CONFIRMAR / ENCERRAR DIA",acao:"avancar"});return historia_botoes(_c,_a);}
    if(_t=="deposito") {array_push(_a,{area:ui_area(626,486,568,52),texto:"DEPOSITAR TODA A MOCHILA",acao:"depositar"});return historia_botoes(_c,_a);}
    if(_t!="prateleira") {
        array_push(_a,{area:ui_area(626,190,170,44),texto:"ANTERIOR",acao:"anterior"});
        array_push(_a,{area:ui_area(1024,190,170,44),texto:"PRÓXIMO",acao:"proximo"});
    }
    if(_t=="vendas") {
        var _ofertas=exploracao_lista_pedidos("vendas");
        if(!missoes_ativa(global.jogo) || (array_length(_ofertas)>0 && _ofertas[0].status=="ofertado")) {
            array_push(_a,{area:ui_area(626,486,270,52),texto:"ACEITAR",acao:"aceitar"});
            array_push(_a,{area:ui_area(914,486,280,52),texto:"RECUSAR",acao:"recusar"});
        }
    } else if(_t=="entrega") array_push(_a,{area:ui_area(626,486,568,52),texto:"ENTREGAR PEDIDO SELECIONADO",acao:"entregar"});
    else {
        array_push(_a,{area:ui_area(626,422,82,46),texto:"-5",acao:"menos5"});
        array_push(_a,{area:ui_area(720,422,82,46),texto:"-1",acao:"menos"});
        array_push(_a,{area:ui_area(1006,422,82,46),texto:"+1",acao:"mais"});
        array_push(_a,{area:ui_area(1100,422,94,46),texto:"+5",acao:"mais5"});
        var _texto=_t=="bancada"?"COZINHAR AGORA":(_t=="compras"?"COMPRAR / CHEGADA COM PRAZO":"RETIRAR PARA MOCHILA");
        array_push(_a,{area:ui_area(626,486,568,52),texto:_texto,acao:_t=="bancada"?"produzir":(_t=="compras"?"comprar":"retirar")});
    }
    return historia_botoes(_c,_a);
}
function exploracao_responder(_c,_r,_acao) {
    _c.mensagem=_r.mensagem;
    if(!_r.ok) {
        pedagogia_tentativa(global.jogo,_acao,_r.mensagem);
        if(missoes_ativa(global.jogo))missoes_problema(global.jogo,_r.mensagem);
    }
}
function exploracao_acao(_c,_acao) {
    var _j=global.jogo;
    if(historia_acao(_c,_acao))return;
    switch(_acao) {
        case "ajuda":_c.ajuda=!_c.ajuda;return;
        case "fechar":_c.painel=undefined;return;
        case "menu":jogo_ir_para(FaseJogo.MENU);return;
        case "pausar":simulacao_pausar(_j);return;
        case "resultados":
            missoes_finalizar(_j);if(!_j.pausado)simulacao_pausar(_j);jogo_ir_para(FaseJogo.RESULTADOS);return;
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
    if(_acao=="depositar")_r=exploracao_depositar(_j);
    else if(_acao=="retirar")_r=exploracao_retirar(_j,_c.painel.ingrediente_id,_c.quantidade);
    else if(_acao=="produzir") {
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
}
function exploracao_controle_passo(_c) {
    var _a=instance_find(obj_cozinheiro,0),_j=global.jogo;if(!instance_exists(_a))return;
    mundo_guardar(_a);
    if(!mouse_check_button(mb_left))_c.entrada_pronta=true;
    historia_passo(_c);
    if(historia_modal(_c)) {
        if(_c.entrada_pronta && mouse_check_button_pressed(mb_left))exploracao_clicar(_c,device_mouse_x_to_gui(0),device_mouse_y_to_gui(0));
        return;
    }
    if(keyboard_check_pressed(vk_escape)) {
        if(_c.ajuda)_c.ajuda=false;
        else if(!is_undefined(_c.painel))_c.painel=undefined;
        else simulacao_pausar(_j);
    }
    if(keyboard_check_pressed(ord("E")) && !_c.ajuda) {
        if(!is_undefined(_c.painel))_c.painel=undefined;
        else mundo_interagir(_c,mundo_alvo_proximo(_a,_c.mundo));
    }
    if(!mouse_check_button(mb_left))_c.entrada_pronta=true;
    if(!_c.entrada_pronta || !mouse_check_button_pressed(mb_left))return;
    var _mx=device_mouse_x_to_gui(0),_my=device_mouse_y_to_gui(0);
    exploracao_clicar(_c,_mx,_my);
}
function exploracao_clicar(_c,_mx,_my) {
    var _j=global.jogo;
    if(_j.fala_visivel && ui_contem(ui_area(528,122,44,44),_mx,_my)){_j.fala_visivel=false;return;}
    var _bs=exploracao_botoes(_c);
    for(var _i=array_length(_bs)-1;_i>=0;_i--) if(ui_contem(_bs[_i].area,_mx,_my)){exploracao_acao(_c,_bs[_i].acao);return;}
}

function exploracao_painel_desenhar(_c) {
    var _j=global.jogo,_v=global.visual,_t=_c.painel.tipo;
    ui_cartao(600,110,640,494,_v.claro);ui_texto(626,144,_c.painel.nome,2,_v.tinta);
    if(_t=="relogio") {
        ui_paragrafo(626,216,"Encerrar o dia registra o que você já fez. Não produz nem entrega pedidos por você. Compras chegam ao Estoque no início do dia previsto.",568,_v.tinta);
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
        if(array_length(_l)==0 && missoes_ativa(_j)) {ui_paragrafo(626,272,_j.missoes.etapa==EtapaMissao.RECUPERAR?"Marta: sua recusa foi registrada. Use Novo pedido guiado para praticar com outra oferta, sem apagar a anterior.":"Marta: siga o objetivo da história. Não são geradas encomendas extras pelo relógio neste modo.",568,_v.tinta);return;}
        if(array_length(_l)==0) {ui_paragrafo(626,272,_t=="vendas"?"Marta: nenhuma oferta aguardando decisão. Ao abrir outro dia, novas encomendas poderão chegar.":"Nenhum pedido aceito aguardando entrega. Converse com Marta para analisar as ofertas.",568,_v.tinta);return;}
        _c.selecao=clamp(_c.selecao,0,array_length(_l)-1);var _p=_l[_c.selecao],_prod=produto_obter(_j.catalogo,_p.produto_id);
        ui_texto(626,258,"PEDIDO #"+string(_p.id)+" / "+string_upper(_p.status),2,_v.azul);
        ui_texto(626,294,_prod.nome+" / "+string(_p.quantidade)+" UN.",2,_v.tinta);
        ui_texto(626,330,"VALOR: "+financas_formatar(_p.total_centavos),2,_v.tinta);
        ui_texto(626,366,"PRAZO: DIA "+string(_p.prazo_dia)+" / PRONTOS: "+string(estoque_quantidade(_j.estoque.produtos,_p.produto_id)),2,_v.tinta);
        if(missoes_ativa(_j))ui_texto(626,406,"CONFIRA AS INFORMAÇÕES ANTES DE DECIDIR.",1,_v.suave);
        else ui_paragrafo(626,406,_t=="vendas"?"Marta: o que será necessário para cumprir esse prazo? Entregas são feitas neste setor, no balcão.":"Entregue quando houver toda a quantidade pronta. A receita só entra no caixa após confirmar a entrega.",568,_v.suave);return;
    }
    if(_t=="bancada") {
        _c.selecao=clamp(_c.selecao,0,array_length(_j.catalogo.produtos)-1);var _p=_j.catalogo.produtos[_c.selecao];
        ui_texto(626,252,_p.nome+" / RECEITA DO LOTE",2,_v.azul);
        for(var _i=0;_i<array_length(_p.receita);_i++) {
            var _ri=_p.receita[_i],_in=ingrediente_obter(_j.catalogo,_ri.ingrediente_id);
            ui_texto(626,286+_i*22,_in.nome+": "+string(_ri.quantidade*_c.quantidade)+" NECESSÁRIO / "+string(estoque_quantidade(_j.cozinha,_in.id))+" NA COZINHA",1,_v.tinta);
        }
        ui_texto(626,402,"CAPACIDADE USADA: "+string(_j.producao.capacidade_usada)+" / "+string(_j.parametros.capacidade_diaria)+"   VARIÁVEL: "+financas_formatar(_p.custo_variavel_centavos*_c.quantidade),1,_v.suave);
    } else {
        var _in;
        if(_t=="prateleira")_in=ingrediente_obter(_j.catalogo,_c.painel.ingrediente_id);
        else {_c.selecao=clamp(_c.selecao,0,array_length(_j.catalogo.ingredientes)-1);_in=_j.catalogo.ingredientes[_c.selecao];}
        ui_texto(626,252,_in.nome,2,_v.azul);
        ui_texto(626,290,"NO ESTOQUE: "+string(estoque_quantidade(_j.estoque.materias_primas,_in.id))+" / MÍNIMO: "+string(_in.estoque_minimo),2,_v.tinta);
        if(_t=="compras") {
            ui_texto(626,330,"COMPRA: "+financas_formatar(_in.custo_centavos*_c.quantidade),2,_v.tinta);
            ui_texto(626,366,"CHEGADA: DIA "+string(_j.dia+_in.prazo_dias)+" / TRÂNSITO: "+string(compras_pendentes_quantidade(_j,_in.id)),2,_v.tinta);
        } else ui_paragrafo(626,338,"Caio: retire o necessário e leve até a mesa de depósito na Produção. A bancada usa somente ingredientes que já estão na cozinha.",568,_v.suave);
    }
    ui_centro(902,438,"QTD: "+string(_c.quantidade),2,_v.tinta);
}
function exploracao_interface_desenhar(_c) {
    var _j=global.jogo,_v=global.visual;
    ui_cartao(16,16,1248,80,_v.claro);
    ui_texto(32,32,_c.mundo.nome+" / DIA "+string(_j.dia)+" DE "+string(_j.parametros.duracao_dias)+" / "+financas_formatar(_j.financas.saldo_centavos)+(_j.pausado?" / PAUSADO":""),2,_v.tinta);
    ui_texto(32,66,(missoes_ativa(_j)?missoes_guia(_j).titulo+" / ":"")+exploracao_objetivo(_j),1,_v.azul);
    missoes_indicador_desenhar(_c);
    ui_cartao(16,430,268,198,_v.claro);ui_texto(30,448,"MOCHILA "+string(exploracao_carregado_total(_j))+" / "+string(_j.exploracao.limite_transporte),2,_v.tinta);
    for(var _i=0;_i<array_length(_j.carregados);_i++) {
        var _in=_j.carregados[_i];ui_texto(30,482+_i*25,ingrediente_obter(_j.catalogo,_in.id).nome+": "+string(_in.quantidade),1,_v.tinta);
    }
    var _fila=pedidos_fila(_j);ui_cartao(16,110,268,94,_v.claro);
    ui_texto(30,126,"PEDIDO ATUAL",1,_v.suave);
    if(array_length(_fila)>0) {
        var _p=_fila[0];ui_texto(30,150,produto_obter(_j.catalogo,_p.produto_id).nome+" X"+string(_p.quantidade),1,_v.tinta);
        ui_texto(30,176,"#"+string(_p.id)+" / PRAZO DIA "+string(_p.prazo_dia),1,_v.azul);
    } else ui_texto(30,158,"CONVERSE COM MARTA.",1,_v.tinta);
    var _a=instance_find(obj_cozinheiro,0);
    if(instance_exists(_a) && is_undefined(_c.painel) && !_c.ajuda) {
        var _alvo=mundo_alvo_proximo(_a,_c.mundo);
        if(!is_undefined(_alvo)) {ui_cartao(340,548,872,44,_v.claro);ui_texto(356,562,"PRESSIONE E / "+_alvo.nome,2,_v.azul);}
    }
    if(!is_undefined(_c.painel))exploracao_painel_desenhar(_c);
    if(_c.ajuda && !missoes_ativa(_j)) {
        ui_cartao(320,110,920,494,_v.claro);ui_texto(344,144,"CONTROLES E OBJETIVO",2,_v.azul);
        ui_paragrafo(344,208,"WASD ou setas: caminhar. E: interagir perto de portas, funcionários ou equipamentos; E ou Esc fecha um painel. Esc também pausa quando não há painel aberto.",840,_v.tinta);
        ui_paragrafo(344,320,"1. Aceite uma encomenda com Marta. 2. Confira a receita na bancada. 3. Retire ingredientes nas prateleiras. 4. Leve e deposite na cozinha. 5. Cozinhe. 6. Entregue no balcão do Comercial.",840,_v.tinta);
        ui_paragrafo(344,466,"Encerrar dia recebe compras e atualiza prazos; não cozinha nem entrega. Resultados permite consultar o diário e retomar. Todos os valores são fictícios para aprendizagem.",840,_v.suave);
    } else pedagogia_desenhar_fala(_j);
    ui_cartao(16,608,1248,26,_v.claro);
    ui_texto(24,618,string_copy(_c.mensagem,1,102),1,_v.tinta);
    historia_desenhar(_c);
    var _bs=exploracao_botoes(_c);for(var _i=0;_i<array_length(_bs);_i++)ui_botao(_bs[_i].area,_bs[_i].texto,_v.azul);
}
