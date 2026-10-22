/// Testes adicionais de fim, indicadores, pausa e aprendizagem.
function teste_feedback_tem(_j,_id) {
    for(var _i=0;_i<array_length(_j.feedbacks);_i++) if(_j.feedbacks[_i].caso_id==_id) return true;
    return false;
}
function testes_v01_executar() {
    var _t={total:0,falhas:[]};
    var _exigir=method(_t,function(_cond,_nome){total++;if(!_cond) array_push(falhas,_nome);show_debug_message((_cond?"OK V01: ":"FALHA V01: ")+_nome);});
    var _cfg=parametros_padrao(),_j=jogo_criar(),_r=dashboard_calcular(_j),_antes;
    _exigir(_cfg.duracao_dias==5 && parametros_validar(_cfg).ok,"duracao padrao valida");
    _cfg.duracao_dias=0;_exigir(!parametros_validar(_cfg).ok,"duracao zero rejeitada");
    _cfg.duracao_dias=61;_exigir(!parametros_validar(_cfg).ok,"duracao acima do limite rejeitada");
    _exigir(is_undefined(_r.taxa_pontualidade) && is_undefined(_r.utilizacao_capacidade),"sem denominadores metricas nao aplicaveis");
    _exigir(indicador_percentual_texto(undefined)=="NÃO APLICÁVEL","rotulo nao aplicavel");
    _exigir(_r.recebidos==3 && _r.aceitos==0 && _r.producao_por_produto[0].produzida==0,"dashboard inicial sem inventar dados");
    _antes=json_stringify(_j);dashboard_calcular(_j);dashboard_reflexoes(_j,_r);
    _exigir(json_stringify(_j)==_antes,"consultas do dashboard puras");
    _exigir(_j.diario[0].data=="Dia 1" && array_length(_j.diario)==1,"diario inicia com data simulada");
    simulacao_pausar(_j);_antes=json_stringify(_j);
    _exigir(_j.pausado && !simulacao_avancar_dia(_j).ok && json_stringify(_j)==_antes,"pausa bloqueia tempo");
    _exigir(!compra_realizar(_j,"farinha",1).ok && !producao_agendar(_j,"coxinha",1).ok && !pedido_decidir(_j,1,true).ok,"pausa bloqueia decisoes economicas");
    simulacao_pausar(_j);
    _exigir(!_j.pausado && _j.dias_processados==0 && _j.financas.saldo_centavos==100000,"retomar preserva recursos e periodo");
    pedido_decidir(_j,1,true);
    _exigir(teste_feedback_tem(_j,"aceite_sem_prontos"),"reflexao ao aceitar sem prontos");
    compra_realizar(_j,"farinha",10);
    _exigir(teste_feedback_tem(_j,"compra_excedente"),"reflexao compra acima da demanda");
    producao_agendar(_j,"pastel",3);
    _exigir(teste_feedback_tem(_j,"producao_sem_demanda"),"reflexao producao acima de pedidos aceitos");
    _exigir(array_length(_j.diario)>4 && _j.fala_visivel,"feedback e consequencias registrados");

    _cfg=parametros_padrao();_cfg.duracao_dias=1;_j=jogo_criar(_cfg);
    pedido_decidir(_j,1,true);pedido_decidir(_j,2,false);compra_realizar(_j,"farinha",10);producao_agendar(_j,"coxinha",5);
    _exigir(!_j.encerrado && _j.dias_processados==0,"nao encerra durante preparacao");
    simulacao_avancar_dia(_j);_r=dashboard_calcular(_j);
    _exigir(_j.encerrado && _j.dias_processados==1 && _j.dia==2,"um ciclo encerra periodo configurado de um dia");
    _exigir(_r.recebidos==3 && _r.aceitos==1 && _r.recusados==1,"fim nao gera novas ofertas e aceitos acumulam entregues");
    _exigir(_r.entregas_pontuais==1 && _r.entregas_atrasadas==0 && _r.taxa_pontualidade==100,"pontualidade calculada por entregas");
    _exigir(_r.producao_por_produto[0].produzida==5 && _r.producao_por_produto[0].prontos==0 && _r.producao_por_produto[1].produzida==0,"producao separada por salgado");
    _exigir(_r.receitas_centavos==3000 && _r.custos_pagos_centavos==725 && _r.resultado_caixa_centavos==2275 && _r.saldo_centavos==102275,"financeiro final baseado nos movimentos reais");
    _exigir(_r.estoque_final[0].fisico==125 && _r.estoque_final[4].fisico==115,"saldos finais reais de insumos");
    _exigir(_r.capacidade_usada_total==5 && _r.capacidade_disponivel_total==100 && _r.utilizacao_capacidade==5,"capacidade por dias realmente processados");
    _exigir(teste_feedback_tem(_j,"entrega_pontual") && simulacao_auditar(_j).ok,"feedback positivo com conservacao no fim");
    _antes=json_stringify(_j);
    _exigir(!simulacao_avancar_dia(_j).ok && json_stringify(_j)==_antes,"fim bloqueia novos dias sem alterar historico");
    _exigir(!compra_realizar(_j,"farinha",1).ok && !producao_agendar(_j,"coxinha",1).ok && !pedido_decidir(_j,3,true).ok && !simulacao_pausar(_j),"fim bloqueia novas decisoes");
    _exigir(pedidos_gerar_dia(_j)==0 && array_length(_j.pedidos)==3,"fim nao duplica pedidos");
    _exigir(array_length(dashboard_reflexoes(_j,_r))>=1 && array_length(dashboard_eventos(_j))>0,"reflexoes e eventos acessiveis no fim");
    var _nova=jogo_criar(_j.parametros);
    _exigir(!_nova.encerrado && _nova.parametros.duracao_dias==1 && _nova.financas.saldo_centavos==100000 && array_length(_nova.diario)==1,"reinicio com mesmos parametros e dados novos");

    _cfg=parametros_padrao();_cfg.duracao_dias=2;_cfg.prazo_pedido_dias=1;_j=jogo_criar(_cfg);
    pedido_decidir(_j,1,true);simulacao_avancar_dia(_j);simulacao_avancar_dia(_j);_r=dashboard_calcular(_j);
    _exigir(_j.encerrado && _r.pedidos_pendentes==1 && _r.abertos_atrasados==1 && _r.entregas_atrasadas==0,"distingue pedido aberto atrasado de entrega atrasada");
    _exigir(is_undefined(_r.taxa_pontualidade) && _j.pedidos[0].status=="aceito","sem entrega taxa nao aplicavel e pedido preservado");
    _cfg=parametros_padrao();_cfg.duracao_dias=3;_cfg.prazo_pedido_dias=1;_j=jogo_criar(_cfg);
    pedido_decidir(_j,1,true);simulacao_avancar_dia(_j);simulacao_avancar_dia(_j);producao_agendar(_j,"coxinha",5);simulacao_avancar_dia(_j);
    _exigir(teste_feedback_tem(_j,"entrega_atrasada") && dashboard_calcular(_j).entregas_atrasadas==1,"reflexao de atraso com dias reais");
    _cfg=parametros_padrao();_cfg.catalogo.ingredientes[1].estoque_inicial=10;_cfg.catalogo.ingredientes[1].estoque_minimo=15;_j=jogo_criar(_cfg);
    simulacao_avancar_dia(_j);_exigir(teste_feedback_tem(_j,"reposicao_nao_planejada"),"feedback falta de planejamento de reposicao");
    _cfg=parametros_padrao();_cfg.duracao_dias=1;_j=jogo_criar(_cfg);compra_realizar(_j,"frango",20);
    _exigir(teste_feedback_tem(_j,"compra_apos_periodo"),"compra que chega apos periodo vira reflexao");
    simulacao_avancar_dia(_j);_r=dashboard_calcular(_j);
    _exigir(_r.estoque_final[1].fisico==60 && _r.estoque_final[1].transito==20 && _r.compras_em_transito==1,"transito final nao inventa estoque fisico");
    _exigir(_r.resultado_caixa_centavos==-1600 && simulacao_auditar(_j).ok,"resultado negativo valido no periodo final");
    _cfg=parametros_padrao();_cfg.duracao_dias=2;_j=jogo_criar(_cfg);compra_realizar(_j,"farinha",10);simulacao_avancar_dia(_j);
    _exigir(!_j.encerrado && dashboard_calcular(_j).resultado_caixa_centavos<0,"resultado negativo nao causa game over");
    _j=jogo_criar(_cfg);producao_agendar(_j,"coxinha",5);simulacao_avancar_dia(_j);producao_agendar(_j,"coxinha",10);simulacao_avancar_dia(_j);_r=dashboard_calcular(_j);
    _exigir(_r.capacidade_usada_total==15 && _r.capacidade_disponivel_total==200 && _r.utilizacao_capacidade==7.5,"utilizacao acumulada sem percentual inventado");
    _exigir(_r.producao_por_produto[0].produzida==15 && _r.producao_por_produto[0].prontos==15,"soma lotes por produto mesmo sem entregas");
    _exigir(simulacao_auditar(_j).ok,"conservacao partida finita completa");
    var _diario_valido=true;
    for(var _i=0;_i<array_length(_j.diario);_i++) {
        var _d=_j.diario[_i];if(_d.id!=_i+1 || _d.data!="Dia "+string(_d.dia) || _d.acao=="" || _d.consequencia=="") _diario_valido=false;
    }
    _exigir(_diario_valido,"diario tem ordem data acao e consequencia");

    // Contexto real dos controladores: restauração, bolão, pausa, dashboard e navegação.
    var _original=global.jogo;global.jogo=jogo_criar();
    var _param=instance_create_depth(0,0,-1000,obj_parametros);
    with(_param) {
        configuracao.duracao_dias=9;configuracao.catalogo.produtos[0].receita[0].quantidade=3;
        parametros_clique(560,644);
        _exigir(configuracao.duracao_dias==5 && configuracao.catalogo.produtos[0].receita[0].quantidade==1 && pagina==0,"restaurar padroes inclui duracao e receitas");
        _exigir(global.jogo.dias_processados==0,"restaurar configuracao nao inicia partida");instance_destroy();
    }
    var _f=instance_create_depth(0,0,-1000,obj_fabrica);
    with(_f) {
        fabrica_clicar(150,438);_exigir(global.jogo.pausado,"botao pausar funcional");
        fabrica_clicar(150,562);_exigir(global.jogo.dias_processados==0,"botao de dia nao processa enquanto pausado");
        fabrica_clicar(150,438);_exigir(!global.jogo.pausado,"botao retomar funcional");
        fabrica_clicar(150,490);_exigir(painel=="diario","diario acessivel durante partida");
        fabrica_clicar(1216,146);fabrica_clicar(450,650);fabrica_clicar(780,516);
        _exigir(global.jogo.fala_visivel,"balao aparece na decisao");
        fabrica_clicar(550,146);_exigir(!global.jogo.fala_visivel && painel=="comercial","fechar balao nao atravessa para painel");instance_destroy();
    }
    _cfg=parametros_padrao();_cfg.duracao_dias=1;global.jogo=jogo_criar(_cfg);simulacao_avancar_dia(global.jogo);
    var _dash=instance_create_depth(0,0,-1000,obj_resultados);
    with(_dash) {
        dashboard_clicar(330,132);_exigir(aba_dashboard==1,"navegar aba producao do dashboard");
        dashboard_clicar(1220,132);_exigir(aba_dashboard==5 && dashboard_paginas()>0,"aba eventos final");
        dashboard_clicar(980,132);_exigir(aba_dashboard==4 && dashboard_paginas()==array_length(global.jogo.diario),"diario completo no dashboard");
        dashboard_clicar(150,670);_exigir(aba_dashboard==5 && global.jogo.encerrado,"fim nao retoma partida encerrada");
        dashboard_clicar(500,670);_exigir(global.jogo.fase==FaseJogo.PARAMETROS,"reiniciar abre parametros para nova partida");
        instance_destroy();
    }
    global.jogo=_original;
    _t.ok=array_length(_t.falhas)==0;
    show_debug_message("FDS_V01_TESTES: "+string(_t.total)+" / FALHAS: "+string(array_length(_t.falhas)));
    return _t;
}

/// Driver usado somente pelo modo --partida da ferramenta em uma cópia.
function teste_partida_exigir(_cond,_nome) {
    global.teste_checks++;
    show_debug_message((_cond?"OK PARTIDA: ":"FALHA PARTIDA: ")+_nome);
    if(!_cond) throw "FDS_PARTIDA_FALHOU: "+_nome;
}
function teste_v01_navegar() {
    global.teste_ticks++;
    if(global.teste_ticks>3000) throw "FDS_PARTIDA_FALHOU: navegação sem conclusão";
    if(global.teste_ticks mod 12!=0) return;
    var _etapa=global.teste_etapa;
    if(room==rm_menu) {
        if(_etapa==0) {
            teste_partida_exigir(instance_number(obj_game)==1,"controlador persistente unico");
            jogo_novo();global.teste_etapa=1;jogo_ir_para(FaseJogo.PARAMETROS);
        } else if(_etapa==17) {global.teste_etapa=18;jogo_ir_para(FaseJogo.FABRICA);}
        return;
    }
    if(room==rm_parametros) {
        if(_etapa==1) {
            screen_save("fds-v01-parametros.png");
            teste_partida_exigir(array_length(campos)==51,"tela real dos parametros");
            configuracao.duracao_dias=9;parametros_clique(560,644);
            teste_partida_exigir(configuracao.duracao_dias==5,"restauracao na tela real");
            parametros_clique(1000,196);keyboard_string="2";parametros_confirmar();
            teste_partida_exigir(configuracao.duracao_dias==2,"duracao digitada na tela");
            global.teste_etapa=2;parametros_clique(1090,644);
        } else if(_etapa==14) {
            teste_partida_exigir(configuracao.duracao_dias==2,"reinicio preserva configuracao anterior para editar");
            parametros_clique(1000,196);keyboard_string="1";parametros_confirmar();
            global.teste_etapa=15;parametros_clique(1090,644);
        }
        return;
    }
    if(room==rm_fabrica) {
        if(_etapa==2) {
            teste_partida_exigir(global.jogo.parametros.duracao_dias==2 && !global.jogo.encerrado,"entrada na fabrica real");
            screen_save("fds-v01-fabrica.png");
            fabrica_clicar(450,650);fabrica_clicar(780,516);
            global.teste_etapa=19;
        } else if(_etapa==19) {
            screen_save("fds-v01-balao.png");
            fabrica_clicar(760,650);
            for(var _i=0;_i<10;_i++) fabrica_clicar(652,420);
            fabrica_clicar(924,520);
            fabrica_clicar(1090,650);fabrica_clicar(924,520);
            teste_partida_exigir(estoque_quantidade(global.jogo.estoque.produtos,"coxinha")==0,"plano aguarda processamento");
            global.teste_etapa=3;fabrica_clicar(150,562);
        } else if(_etapa==3) {
            screen_save("fds-v01-resumo.png");
            teste_partida_exigir(global.jogo.dias_processados==1 && !global.jogo.encerrado,"primeiro dia sem fim antecipado");
            teste_partida_exigir(global.jogo.financas.saldo_centavos==102275 && global.jogo.pedidos[0].status=="entregue","ciclo com receita e custo real");
            fabrica_clicar(1216,146);fabrica_clicar(150,438);fabrica_clicar(150,562);
            teste_partida_exigir(global.jogo.pausado && global.jogo.dias_processados==1,"pausa durante partida real");
            fabrica_clicar(150,438);global.teste_etapa=4;fabrica_clicar(150,650);
        } else if(_etapa==5) {global.teste_etapa=6;fabrica_clicar(150,562);}
        else if(_etapa==15) {
            teste_partida_exigir(global.jogo.dias_processados==0 && global.jogo.financas.receitas_centavos==0,"reinicio limpa dados da partida");
            global.teste_etapa=16;fabrica_clicar(150,562);
        }
        return;
    }
    if(room==rm_resultados) {
        if(_etapa==4) {
            teste_partida_exigir(!global.jogo.encerrado && resumo.receitas_centavos==3000,"rever resultados antes do fim");
            global.teste_etapa=5;dashboard_clicar(150,670);
        } else if(_etapa==6) {
            teste_partida_exigir(global.jogo.encerrado && resumo.dias_processados==2,"fim automatico na sala real do dashboard");
            teste_partida_exigir(resumo.recebidos==6 && resumo.aceitos==1 && resumo.entregas_pontuais==1,"indicadores finais da partida");
            teste_partida_exigir(resumo.utilizacao_capacidade==2.5 && resumo.resultado_caixa_centavos==2275,"percentuais e resultado calculados");
            teste_partida_exigir(simulacao_auditar(global.jogo).ok,"auditoria da partida completa");
            show_debug_message("FDS_CAPTURAS_DIR: "+working_directory);
            aba_dashboard=0;pagina_dashboard=0;global.teste_etapa=7;
        } else if(_etapa>=7 && _etapa<=12) {
            var _indice=_etapa-7;
            teste_partida_exigir(aba_dashboard==_indice,"aba real "+string(_indice));
            screen_save("fds-v01-dashboard-"+string(_indice)+".png");
            if(_indice<5) {dashboard_clicar(120+(_indice+1)*208,132);global.teste_etapa++;}
            else global.teste_etapa=13;
        } else if(_etapa==13) {global.teste_etapa=14;dashboard_clicar(500,670);}
        else if(_etapa==16) {
            teste_partida_exigir(global.jogo.encerrado && resumo.dias_processados==1,"segunda partida pode terminar");
            global.teste_etapa=17;dashboard_clicar(1050,670);
        } else if(_etapa==18) {
            teste_partida_exigir(global.jogo.encerrado && resumo.dias_processados==1,"continuar pelo menu reabre dashboard encerrado");
            show_debug_message("FDS_PARTIDA_APROVADA: "+string(global.teste_checks)+" verificações");game_end();
        }
    }
}
