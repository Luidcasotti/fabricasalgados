/// Testes de integração em cópia: ações presenciais, materiais e decisões reais.
function teste_historia_ler(_j,_errar=false){
    var _n=0;while(historia_aberta(_j)){if(_n++>80)throw "Conversa não fechou";
        var _m=_j.missoes,_f=_m.fila[_m.indice_fala];if(_f.tipo=="pergunta" && _m.resposta_atual<0)historia_responder(_j,_errar?((_f.correta+1) mod 3):_f.correta);historia_continuar(_j);}
}
function teste_missao_interagir(_j,_setor,_id){teste_exploracao_posicionar(_j,_setor,_id);missoes_evento(_j,"interacao",{id:_id});}
function teste_missao_consultar(_j){historia_fechar(_j);teste_exploracao_posicionar(_j,"estoque","compras");missoes_consultar_estoque(_j);}
function teste_missao_abastecer(_j,_p){
    var _r=produto_obter(_j.catalogo,_p.produto_id).receita;
    teste_missao_interagir(_j,"producao","bancada");
    for(var _i=0;_i<array_length(_r);_i++){
        var _a=_r[_i],_q=max(0,_a.quantidade*missoes_restante(_j,_p)-estoque_quantidade(_j.cozinha,_a.ingrediente_id)-estoque_quantidade(_j.carregados,_a.ingrediente_id));
        while(_q>0){
            var _ret=min(_q,_j.exploracao.limite_transporte-exploracao_carregado_total(_j));
            if(_ret<=0){teste_exploracao_posicionar(_j,"producao","deposito");exploracao_depositar(_j);continue;}
            teste_exploracao_posicionar(_j,"estoque","prateleira_"+_a.ingrediente_id);
            var _v=exploracao_retirar(_j,_a.ingrediente_id,_ret);if(!_v.ok)throw "Abastecimento de teste: "+_v.mensagem;
            _q-=_ret;
        }
    }
    teste_exploracao_posicionar(_j,"producao","deposito");exploracao_depositar(_j);
}
function teste_missao_primeira_entrega(_j){
    teste_missao_consultar(_j);teste_missao_interagir(_j,"comercial","vendas");pedido_decidir(_j,_j.missoes.primeiro_id,true);
    var _p=catalogo_buscar(_j.pedidos,_j.missoes.primeiro_id);teste_missao_abastecer(_j,_p);
    teste_exploracao_posicionar(_j,"producao","bancada");exploracao_produzir(_j,_p.produto_id,_p.quantidade);
    teste_exploracao_posicionar(_j,"comercial","entrega");pedido_entregar(_j,_p);
}
function testes_missoes_executar(){
    var _t={total:0,falhas:[]},_exigir=method(_t,function(_ok,_n){total++;if(!_ok)array_push(falhas,_n);show_debug_message((_ok?"OK MISSÃO: ":"FALHA: ")+_n);});
    var _j=jogo_criar(missoes_parametros());missoes_iniciar(_j);
    _exigir(historia_aberta(_j) && array_length(_j.missoes.fila)==5,"introdução curta com cinco falas");
    historia_continuar(_j);_exigir(_j.missoes.indice_fala==1 && historia_aberta(_j),"avançar não pula todas as falas");
    historia_fechar(_j);_exigir(!historia_aberta(_j) && missoes_fluxo(_j).passo==1,"pular introdução mantém objetivo aceitar pedido");
    var _cfg=missoes_parametros();_cfg.capacidade_diaria=19;_exigir(!missoes_validar_config(_cfg).ok,"capacidade insuficiente impede início guiado");
    _cfg=missoes_parametros();_cfg.catalogo.ingredientes[2].estoque_inicial=39;_exigir(!missoes_validar_config(_cfg).ok,"primeiro pedido viável validado");
    _exigir(_j.pedidos[0].quantidade==20 && _j.pedidos[0].produto_id=="bolinha_queijo","primeiro pedido simples de 20");
    _exigir(estoque_quantidade(_j.cozinha,"farinha")==0 && exploracao_total_insumo(_j,"farinha")==120,"cozinha vazia sem perder estoque");
    teste_exploracao_posicionar(_j,"producao","bancada");var _antes=json_stringify(_j);
    _exigir(!pedido_decidir(_j,1,true).ok && json_stringify(_j)==_antes,"aceite exige presença com Marta e não altera dados à distância");
    _exigir(!missoes_consultar_estoque(_j).ok,"consulta exige proximidade no Estoque");
    teste_exploracao_posicionar(_j,"estoque","compras");
    _exigir(missoes_fluxo(_j).passo==1,"visitar Estoque antes do pedido mantém orientação Comercial");
    _exigir(missoes_consultar_estoque(_j).ok && missoes_fluxo(_j).passo==1,"confirmação presencial conclui consulta");
    var _eventos=array_length(_j.diario);missoes_consultar_estoque(_j);_exigir(array_length(_j.diario)==_eventos,"consulta repetida não repete mensagens");
    teste_exploracao_posicionar(_j,"comercial","vendas");_exigir(pedido_diagnostico(_j,_j.pedidos[0]).ok,"primeira oferta possui recursos e capacidade");
    _exigir(pedido_decidir(_j,1,true).ok && !pedido_decidir(_j,1,true).ok,"aceite único");
    _exigir(missoes_fluxo(_j).passo==3 && missoes_fluxo(_j).alvo=="compras","aceite dá canhoto e orienta diretamente a Caio");
    teste_exploracao_posicionar(_j,"estoque","prateleira_queijo");_antes=json_stringify(_j);
    _exigir(exploracao_retirar(_j,"queijo",1).ok && estoque_quantidade(_j.carregados,"queijo")==1,"canhoto permite retirar sem visita extra à bancada");
    teste_missao_interagir(_j,"producao","bancada");_exigir(missoes_fluxo(_j).passo==3,"conferência aponta busca de materiais");
    var _v=exploracao_receita_validar(_j,"bolinha_queijo",20);
    _exigir(!_v.ok && _v.diagnostico.acao=="retirar","falta local explica transporte em vez de compra");
    teste_missao_abastecer(_j,_j.pedidos[0]);
    _exigir(missoes_fluxo(_j).passo==5 && exploracao_carregado_total(_j)==0,"duas viagens respeitam mochila e abastecem cozinha");
    _exigir(simulacao_auditar(_j).ok && exploracao_total_insumo(_j,"queijo")==100,"transferências não consomem nem duplicam");
    var _saldo=_j.financas.saldo_centavos;historia_enfileirar(_j,"q_estoque",true);historia_responder(_j,0);
    _exigir(_j.financas.bonus_centavos==1000 && _j.financas.saldo_centavos==_saldo+1000,"pergunta correta paga bônus separado de receita");
    _exigir(!historia_responder(_j,0) && _j.financas.bonus_centavos==1000,"prêmio idempotente");historia_fechar(_j);
    teste_exploracao_posicionar(_j,"producao","bancada");_exigir(exploracao_produzir(_j,"bolinha_queijo",4).ok,"lote parcial permitido após conferência");
    _exigir(missoes_restante(_j,_j.pedidos[0])==16,"restante usa produtos prontos reais");
    _exigir(exploracao_produzir(_j,"bolinha_queijo",16).ok && missoes_fluxo(_j).passo==6,"produção completa libera entrega");
    _exigir(exploracao_total_insumo(_j,"queijo")==60 && _j.producao.unidades_produzidas==20,"receita consumida exatamente uma vez");
    teste_exploracao_posicionar(_j,"comercial","entrega");_exigir(pedido_entregar(_j,_j.pedidos[0]).ok && !pedido_entregar(_j,_j.pedidos[0]).ok,"entrega e pagamento únicos");
    _exigir(_j.missoes.segundo_id>0 && missoes_atual(_j).quantidade==30,"dificuldade cresce para 30 no segundo pedido");
    teste_exploracao_posicionar(_j,"comercial","vendas");var _p=missoes_atual(_j);pedido_decidir(_j,_p.id,true);teste_missao_abastecer(_j,_p);
    teste_exploracao_posicionar(_j,"producao","bancada");_exigir(exploracao_produzir(_j,_p.produto_id,_p.quantidade).ok,"segundo pedido usa mesmos transportes reais");
    teste_exploracao_posicionar(_j,"comercial","entrega");pedido_entregar(_j,_p);
    _exigir(!_j.encerrado && !_j.missoes.concluida && array_length(_j.missoes.entregues)==2 && missoes_atual(_j).produto_id=="pastel","segunda entrega libera terceira missão sem encerrar");
    for(var _n=2;_n<5;_n++){
        var _p=missoes_atual(_j);teste_exploracao_posicionar(_j,"comercial","vendas");pedido_decidir(_j,_p.id,true);teste_missao_abastecer(_j,_p);
        teste_exploracao_posicionar(_j,"producao","bancada");_exigir(exploracao_produzir(_j,_p.produto_id,_p.quantidade).ok,"preparo das missões finais / "+string(_n+1));
        teste_exploracao_posicionar(_j,"comercial","entrega");_exigir(pedido_entregar(_j,_p).ok,"entrega das missões finais / "+string(_n+1));
    }
    _exigir(missoes_zerou(_j) && _j.encerrado,"quinta entrega zera a história e encerra");
    _exigir(!missoes_finalizar(_j) && simulacao_auditar(_j).ok,"finalização idempotente e auditada");
    var _r=dashboard_calcular(_j);_exigir(_r.recebidos==5 && _r.aceitos==5 && _r.pedidos_atendidos==5 && _r.unidades_produzidas==120,"dashboard conta ações reais");
    _exigir(_r.receitas_centavos==62000 && _r.custos_pagos_centavos==3000 && _r.resultado_caixa_centavos==60000,"receita, bônus e custos reais separados");
    _exigir(_r.consumo_total==520 && _r.ingredientes_consumidos[2].quantidade==100,"consumo agregado dos lotes por ingrediente");
    _j=jogo_criar(missoes_parametros());missoes_iniciar(_j);teste_missao_consultar(_j);teste_exploracao_posicionar(_j,"comercial","vendas");
    _exigir(pedido_decidir(_j,1,false).ok && _j.pedidos[0].status=="recusado","recusa preservada no histórico");
    _saldo=_j.financas.saldo_centavos;_exigir(missoes_reofertar(_j).ok && _j.pedidos[1].quantidade==20 && _j.financas.saldo_centavos==_saldo,"reoferta preserva a missão e não mexe no caixa");
    var _anterior=0,_vistos={};
    for(var _i=0;_i<16;_i++){var _q=pedidos_quantidade_variada(_j);_exigir(array_contains([20,30,40,50],_q) && _q!=_anterior,"quantidade válida sem repetição vizinha "+string(_i));_anterior=_q;variable_struct_set(_vistos,string(_q),true);}
    _exigir(array_length(variable_struct_get_names(_vistos))==4,"todas as quatro quantidades aparecem");
    _j=jogo_criar(missoes_parametros());missoes_iniciar(_j);teste_missao_consultar(_j);teste_exploracao_posicionar(_j,"comercial","vendas");pedido_decidir(_j,1,true);teste_missao_interagir(_j,"producao","bancada");
    estoque_ajustar(_j.estoque.materias_primas,"queijo",-100);ingrediente_obter(_j.catalogo,"queijo").estoque_inicial=0;
    // Completa os demais materiais para que o guia destaque a falta geral de queijo.
    estoque_ajustar(_j.estoque.materias_primas,"farinha",-20);estoque_ajustar(_j.cozinha,"farinha",20);
    _exigir(missoes_fluxo(_j).alvo=="compras","falta na empresa aponta reposição");
    teste_exploracao_posicionar(_j,"estoque","compras");_exigir(compra_realizar(_j,"queijo",40).ok,"compra é paga e entra em trânsito");
    _exigir(canhoto_dados(_j).em_transito==40 && canhoto_dados(_j).comprar==0,"canhoto reconhece compra em trânsito sem pedir novamente");
    compras_passo(_j,12);_exigir(estoque_quantidade(_j.estoque.materias_primas,"queijo")==40 && simulacao_auditar(_j).ok,"recebimento único e conservação");
    _t.ok=array_length(_t.falhas)==0;show_debug_message("FDS_MISSOES_TESTES: "+string(_t.total)+" / FALHAS: "+string(array_length(_t.falhas)));return _t;
}
function teste_historia_click(_c,_acao){
    var _bs=exploracao_botoes(_c);for(var _i=0;_i<array_length(_bs);_i++)if(_bs[_i].acao==_acao){var _a=_bs[_i].area;exploracao_clicar(_c,_a.x+_a.w/2,_a.y+_a.h/2);return true;}
    throw "Botão ausente: "+_acao;
}

/// Partida no Runner: percorre a malha real, abre os painéis e usa os botões do jogo.
function teste_historia_partida(){
    global.teste_ticks++;if(global.teste_ticks>9000)throw "FDS_HISTORIA_FALHOU: tempo";
    var _j=global.jogo;
    if(room==rm_menu){
        global.teste_etapa=1;global.teste_rota=[];global.teste_ri=0;global.teste_alvo="";global.teste_intro=false;global.teste_falha=false;global.teste_recusou=false;
        jogo_novo();jogo_ir_para(FaseJogo.PARAMETROS);return;
    }
    if(room==rm_parametros){teste_partida_exigir(modo_guiado,"história selecionada");global.teste_etapa=2;parametros_clique(1090,global.teste_ramo=="feira"?590:125);return;}
    if(room==rm_dashboard){
        if(global.teste_etapa==3){
            teste_partida_exigir(_j.missoes.concluida && _j.encerrado && simulacao_auditar(_j).ok,"fim auditado");
            teste_partida_exigir(resumo.pedidos_atendidos==(global.teste_ramo=="recusar"?1:2),"pedidos entregues");
            teste_partida_exigir(resumo.receitas_centavos==(global.teste_ramo=="recusar"?8000:26000),"vendas reais");
            global.teste_etapa=4;global.teste_tab=0;global.teste_tab_tick=0;aba_dashboard=0;
        }else{
            global.teste_tab_tick++;if(global.teste_tab_tick mod 3!=0)return;
            screen_save("fds-historia-"+global.teste_ramo+"-dashboard-"+string(global.teste_tab)+".png");
            teste_partida_exigir(aba_dashboard==global.teste_tab,"aba de resultados");global.teste_tab++;
            if(global.teste_tab<7){var _t=layout.tabs[global.teste_tab];dashboard_clicar(_t.x+20,_t.y+20);}else{
                show_debug_message("FDS_CAPTURAS_DIR: "+working_directory);show_debug_message("FDS_PARTIDA_APROVADA: "+string(global.teste_checks)+" / HISTORIA "+global.teste_ramo);game_end();
            }
        }return;
    }
    if(!instance_exists(obj_exploracao) || !instance_exists(obj_cozinheiro))return;
    var _c=instance_find(obj_exploracao,0),_a=instance_find(obj_cozinheiro,0);
    if(confirmacao_aberta(_j)){
        screen_save("fds-historia-"+global.teste_ramo+"-confirmacao-"+_j.confirmacao.acao+".png");
        teste_partida_exigir(confirmacao_aberta(_j),"mensagem exige confirmação / "+_j.confirmacao.acao);
        teste_historia_click(_c,"confirmar_ato");return;
    }
    if(missoes_zerou(_j)){
        screen_save("fds-historia-"+global.teste_ramo+"-final-cinco-pedidos.png");
        teste_partida_exigir(_j.encerrado && array_length(_j.missoes.entregues)==5 && _j.producao.unidades_produzidas==120 && simulacao_auditar(_j).ok,"história concluída com cinco pedidos e recursos auditados");
        if(feira_ativa(_j))teste_partida_exigir(_j.feira.venceu,"vitória cronometrada após quinta entrega");
        show_debug_message("FDS_CAPTURAS_DIR: "+working_directory);show_debug_message("FDS_PARTIDA_APROVADA: "+string(global.teste_checks)+" / HISTORIA "+global.teste_ramo);game_end();return;
    }
    if(feira_ativa(_j) && _j.feira.concluida){
        if(global.teste_etapa==2){global.teste_etapa=3;return;}
        screen_save("fds-historia-feira-dashboard-0.png");
        teste_partida_exigir(_j.feira.venceu && _j.maquinas.falhas==1 && _j.maquinas.tempo_manutencao>0,"feira completa com entrega e manutenção");
        teste_partida_exigir(simulacao_auditar(_j).ok && _j.producao.unidades_produzidas==20,"feira conserva materiais e caixa");
        show_debug_message("FDS_CAPTURAS_DIR: "+working_directory);show_debug_message("FDS_PARTIDA_APROVADA: "+string(global.teste_checks)+" / HISTORIA feira");game_end();return;
    }
    if(historia_aberta(_j)){
        var _f=_j.missoes.fila[_j.missoes.indice_fala];
        if(_f.tipo=="decisao"){
            if(_j.missoes.resposta_atual<0){screen_save("fds-historia-"+global.teste_ramo+"-decisao-ingredientes.png");teste_historia_click(_c,"decisao_0");}
            else {screen_save("fds-historia-"+global.teste_ramo+"-consequencia-ingredientes.png");teste_historia_click(_c,"fechar_conversa");}return;
        }
        if(_f.tipo=="consequencia"){
            screen_save("fds-historia-"+global.teste_ramo+"-consequencia-defeito.png");teste_historia_click(_c,"fechar_conversa");return;
        }
        if(!global.teste_intro){global.teste_intro=1;return;}
        if(global.teste_intro<30){global.teste_intro++;return;}
        if(_j.missoes.indice_fala==0)screen_save("fds-historia-"+global.teste_ramo+"-introducao.png");
        teste_historia_click(_c,"continuar_fala");return;
    }
    if(maquinas_decisao_aberta(_j)){
        screen_save("fds-historia-"+global.teste_ramo+"-falha.png");
        teste_partida_exigir(maquinas_capacidade(_j)==200,"painel e capacidade reduzidos");
        teste_historia_click(_c,"maquina_manutencao");global.teste_falha=true;return;
    }
    if(!is_undefined(_c.lote_em_curso)){
        // Acelera somente a espera do teste; usa os mesmos passos de equipamento e preparo.
        for(var _k=0;_k<12;_k++){maquinas_passo(_j,.05);historia_passo(_c,.05);if(maquinas_decisao_aberta(_j) || is_undefined(_c.lote_em_curso))break;}
        return;
    }
    if(_c.porta_destino!="")return;
    if(_j.missoes.etapa==EtapaMissao.RESULTADOS){global.teste_etapa=3;teste_historia_click(_c,"resultados");return;}
    var _g=missoes_fluxo(_j),_alvo=_g.alvo;
    if(_g.setor!=_c.mundo.setor)_alvo=_c.mundo.setor=="corredor"?"porta_"+_g.setor:"saida";
    if(global.teste_alvo!=_c.mundo.setor+":"+_alvo){
        _c.painel=undefined;global.teste_alvo=_c.mundo.setor+":"+_alvo;
        var _al=catalogo_buscar(_c.mundo.alvos,_alvo);global.teste_rota=teste_mundo_rota(_c.mundo,_a.u,_a.v,_al.u,_al.v);global.teste_ri=0;
        teste_partida_exigir(array_length(global.teste_rota)>0,"rota / "+global.teste_alvo);
    }
    for(var _i=0;_i<30;_i++){
        if(global.teste_ri>=array_length(global.teste_rota))break;
        var _p=global.teste_rota[global.teste_ri];mundo_mover(_a,_c.mundo,clamp(_p.u-_a.u,-.1,.1),clamp(_p.v-_a.v,-.1,.1));
        if(point_distance(_a.u,_a.v,_p.u,_p.v)<.02)global.teste_ri++;
    }
    mundo_guardar(_a);mundo_camera(_c.camera_mundo,_a);if(global.teste_ri<array_length(global.teste_rota))return;
    if(is_undefined(_c.painel)){
        screen_save("fds-historia-"+global.teste_ramo+"-rota.png");
        teste_partida_exigir(mundo_interagir(_c,mundo_alvo_proximo(_a,_c.mundo)),"interação / "+global.teste_alvo);return;
    }
    if(_alvo=="compras"){
        screen_save("fds-historia-"+global.teste_ramo+"-estoque.png");teste_historia_click(_c,"separar_pedido");
    }else if(_alvo=="vendas"){
        if(_j.missoes.etapa==EtapaMissao.RECUPERAR)teste_historia_click(_c,"reofertar");
        else if(global.teste_ramo=="recusar" && !global.teste_recusou && array_length(_j.missoes.entregues)==1){teste_historia_click(_c,"recusar");global.teste_recusou=true;}
        else teste_historia_click(_c,"aceitar");
    }else if(_alvo=="bancada"){
        if(_g.passo==5)teste_historia_click(_c,"produzir");
    }else if(_alvo=="deposito")teste_historia_click(_c,"depositar");
    else if(string_pos("prateleira_",_alvo)==1){
        screen_save("fds-historia-"+global.teste_ramo+"-"+_alvo+".png");
        teste_historia_click(_c,"retirar_necessario");
    }
    else if(_alvo=="entrega")teste_historia_click(_c,"entregar");
    teste_partida_exigir(simulacao_auditar(_j).ok,"ação conserva recursos / "+_alvo);
    _c.painel=undefined;global.teste_alvo="";
}
