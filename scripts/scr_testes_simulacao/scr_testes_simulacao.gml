/// Testes opcionais. Nenhuma função aqui executa ao carregar o projeto.
function simulacao_auditar(_jogo) {
    var _erros=[];
    for(var _i=0;_i<array_length(_jogo.catalogo.ingredientes);_i++) {
        var _item=_jogo.catalogo.ingredientes[_i],_esperado=_item.estoque_inicial;
        for(var _k=0;_k<array_length(_jogo.compras);_k++) {
            var _c=_jogo.compras[_k];
            if(_c.status=="recebida" && _c.ingrediente_id==_item.id) _esperado+=_c.quantidade;
        }
        for(var _k=0;_k<array_length(_jogo.producao.lotes);_k++) {
            var _insumos=_jogo.producao.lotes[_k].insumos;
            for(var _n=0;_n<array_length(_insumos);_n++)
                if(_insumos[_n].ingrediente_id==_item.id) _esperado-=_insumos[_n].quantidade;
        }
        var _atual=estoque_quantidade(_jogo.estoque.materias_primas,_item.id);
        if(_atual!=_esperado || _atual<0 || _atual>1000000) array_push(_erros,"Conservação: "+_item.id);
    }
    for(var _i=0;_i<array_length(_jogo.catalogo.produtos);_i++) {
        var _produto=_jogo.catalogo.produtos[_i],_esperado=0;
        for(var _k=0;_k<array_length(_jogo.producao.lotes);_k++) {
            var _l=_jogo.producao.lotes[_k];if(_l.produto_id==_produto.id) _esperado+=_l.quantidade;
        }
        for(var _k=0;_k<array_length(_jogo.pedidos);_k++) {
            var _p=_jogo.pedidos[_k];if(_p.status=="entregue" && _p.produto_id==_produto.id) _esperado-=_p.quantidade;
        }
        var _atual=estoque_quantidade(_jogo.estoque.produtos,_produto.id);
        if(_atual!=_esperado || _atual<0 || _atual>1000000) array_push(_erros,"Conservação: "+_produto.id);
    }
    var _ids={},_chaves={};
    for(var _i=0;_i<array_length(_jogo.pedidos);_i++) {
        var _p=_jogo.pedidos[_i],_id=string(_p.id);
        if(variable_struct_exists(_ids,_id) || variable_struct_exists(_chaves,_p.chave)) array_push(_erros,"Pedido duplicado");
        variable_struct_set(_ids,_id,true);variable_struct_set(_chaves,_p.chave,true);
    }
    if(array_length(_jogo.pedidos)!=_jogo.proximo_pedido_id-1) array_push(_erros,"Histórico incompleto");
    var _saldo=_jogo.financas.saldo_inicial_centavos,_referencias={};
    for(var _i=0;_i<array_length(_jogo.financas.movimentos);_i++) {
        var _m=_jogo.financas.movimentos[_i];_saldo+=_m.valor_centavos;
        if(_m.referencia!="") {
            if(variable_struct_exists(_referencias,_m.referencia)) array_push(_erros,"Movimento duplicado");
            variable_struct_set(_referencias,_m.referencia,true);
        }
    }
    if(_saldo!=_jogo.financas.saldo_centavos || _saldo<0) array_push(_erros,"Conservação de caixa");
    if(indicadores_calcular(_jogo).resultado_caixa_centavos!=_saldo-_jogo.financas.saldo_inicial_centavos)
        array_push(_erros,"Resultado de caixa incoerente");
    if(_jogo.producao.capacidade_usada>_jogo.parametros.capacidade_diaria) array_push(_erros,"Capacidade excedida");
    return {ok:array_length(_erros)==0,erros:_erros};
}

function testes_simulacao_executar() {
    var _t={total:0,falhas:[]};
    var _exigir=method(_t,function(_cond,_nome) {
        total++;if(!_cond) array_push(falhas,_nome);
        show_debug_message((_cond?"OK: ":"FALHA: ")+_nome);
    });
    var _j=jogo_criar(),_cfg=parametros_padrao(),_antes;
    _exigir(_j.dia==1 && _j.financas.saldo_centavos==100000,"estado inicial");
    _exigir(array_length(_j.catalogo.ingredientes)==5 && array_length(_j.catalogo.produtos)==3,"catalogo solicitado");
    _exigir(is_undefined(ingrediente_obter(_j.catalogo,"massa")),"farinha substitui massa");
    _exigir(array_length(_j.pedidos)==3 && _j.proximo_pedido_id==4,"ofertas iniciais unicas");
    _exigir(pedidos_gerar_dia(_j)==0 && array_length(_j.pedidos)==3,"geracao idempotente");
    _j.ultimo_dia_gerado=0;
    _exigir(pedidos_gerar_dia(_j)==0 && array_length(_j.pedidos)==3,"chave protege regeneracao");
    _exigir(simulacao_auditar(_j).ok,"auditoria inicial");
    _exigir(!quantidade_valida(0) && !quantidade_valida(-1) && !quantidade_valida(1.5),"quantidades invalidas");
    _exigir(!estoque_ajustar(_j.estoque.materias_primas,"farinha",-121),"bloquear saldo fisico negativo");
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"farinha")==120,"saida recusada conserva saldo");
    _antes=json_stringify(_j);
    _exigir(!compra_realizar(_j,"inexistente",10).ok && json_stringify(_j)==_antes,"compra invalida atomica");
    _exigir(compra_realizar(_j,"farinha",10).ok,"compra aceita");
    _exigir(_j.financas.saldo_centavos==99400 && _j.financas.compras_centavos==600,"compra paga no ato");
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"farinha")==120,"compra nao chega instantaneamente");
    _exigir(_j.compras[0].dia_chegada==2 && compras_pendentes_quantidade(_j,"farinha")==10,"prazo e transito");
    compras_receber(_j,[]);
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"farinha")==120,"recebimento antecipado bloqueado");
    simulacao_avancar_dia(_j);
    _exigir(_j.dia==2 && _j.compras[0].status=="recebida" && estoque_quantidade(_j.estoque.materias_primas,"farinha")==130,"compra chega no dia correto");
    compras_receber(_j,[]);
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"farinha")==130,"chegada nao duplica estoque");
    _exigir(simulacao_auditar(_j).ok,"conservacao apos compra");
    _j=jogo_criar();compra_realizar(_j,"frango",20);simulacao_avancar_dia(_j);
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"frango")==60,"prazo de dois dias respeitado");
    simulacao_avancar_dia(_j);
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"frango")==80 && simulacao_auditar(_j).ok,"compra longa conservada");
    _cfg=parametros_padrao();_cfg.caixa_inicial_centavos=100;_j=jogo_criar(_cfg);_antes=json_stringify(_j);
    _exigir(!compra_realizar(_j,"farinha",2).ok && json_stringify(_j)==_antes,"compra sem caixa atomica");
    _cfg=parametros_padrao();_cfg.catalogo.ingredientes[0].estoque_inicial=999990;_j=jogo_criar(_cfg);
    compra_realizar(_j,"farinha",10);_antes=json_stringify(_j);
    _exigir(!compra_realizar(_j,"farinha",1).ok && json_stringify(_j)==_antes,"limite inclui estoque em transito");
    simulacao_avancar_dia(_j);
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"farinha")==1000000 && simulacao_auditar(_j).ok,"limite fisico conservado");

    _cfg=parametros_padrao();_cfg.capacidade_diaria=10;_j=jogo_criar(_cfg);_antes=json_stringify(_j);
    var _pl=producao_planejar(_j,"coxinha",5);
    _exigir(_pl.ok && _pl.custo_ingredientes_centavos==875 && _pl.variavel_centavos==125,"custos separados por lote");
    _exigir(json_stringify(_j)==_antes,"consulta de plano pura");
    _exigir(producao_agendar(_j,"coxinha",5).ok,"agendar quantidade escolhida");
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"farinha")==120 && estoque_quantidade(_j.estoque.produtos,"coxinha")==0,"agendar nao produz");
    _exigir(producao_reserva_capacidade(_j)==5 && producao_reserva_ingrediente(_j,"embalagens")==5 && producao_reserva_caixa(_j)==125,"reservas de capacidade ingredientes e caixa");
    _antes=json_stringify(_j);
    _exigir(!producao_agendar(_j,"pastel",6).ok && json_stringify(_j)==_antes,"capacidade reservada impede excesso");
    simulacao_avancar_dia(_j);
    _exigir(estoque_quantidade(_j.estoque.produtos,"coxinha")==5 && _j.producao.unidades_dia==5,"producao no proximo dia");
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"farinha")==115 && estoque_quantidade(_j.estoque.materias_primas,"embalagens")==115,"consumo da receita e embalagem");
    _exigir(_j.financas.saldo_centavos==99875 && _j.financas.variaveis_centavos==125,"custo variavel pago uma vez");
    _exigir(producao_reserva_caixa(_j)==0 && producao_reserva_capacidade(_j)==0,"reservas liberadas na execucao");
    _antes=json_stringify(_j);
    _exigir(!producao_executar_lote(_j,_j.producao.planos[0]).ok && json_stringify(_j)==_antes,"lote nao executa duas vezes");
    simulacao_avancar_dia(_j);
    _exigir(_j.producao.capacidade_usada==0 && _j.producao.unidades_dia==0 && _j.producao.unidades_produzidas==5,"capacidade diaria reseta e total persiste");
    _exigir(simulacao_auditar(_j).ok,"conservacao apos producao");
    _cfg=parametros_padrao();_cfg.catalogo.ingredientes[4].estoque_inicial=0;_j=jogo_criar(_cfg);_antes=json_stringify(_j);
    _exigir(!producao_agendar(_j,"coxinha",1).ok && json_stringify(_j)==_antes,"sem embalagem nao produz");
    _j=jogo_criar();producao_agendar(_j,"coxinha",50);_antes=json_stringify(_j);
    _exigir(!producao_agendar(_j,"coxinha",20).ok && json_stringify(_j)==_antes,"frango nao reservado duas vezes");
    _exigir(producao_cancelar(_j,1).ok && producao_reserva_capacidade(_j)==0 && producao_reserva_caixa(_j)==0,"cancelamento libera reservas");
    _exigir(!producao_cancelar(_j,1).ok && _j.producao.planos[0].status=="cancelado","cancelamento preserva historico");
    _cfg=parametros_padrao();_cfg.caixa_inicial_centavos=1000;_j=jogo_criar(_cfg);producao_agendar(_j,"coxinha",5);_antes=json_stringify(_j);
    _exigir(!compra_realizar(_j,"farinha",15).ok && json_stringify(_j)==_antes,"compras respeitam caixa reservado");
    _cfg=parametros_padrao();_cfg.catalogo.produtos[0].receita[0].quantidade=2;_cfg.catalogo.produtos[0].capacidade_unidade=2;_j=jogo_criar(_cfg);
    producao_agendar(_j,"coxinha",3);simulacao_avancar_dia(_j);
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"farinha")==114 && _j.producao.capacidade_usada==6 && simulacao_auditar(_j).ok,"receita e capacidade configuraveis");
    _cfg=parametros_padrao();_cfg.catalogo.produtos[0].custo_variavel_centavos=0;_j=jogo_criar(_cfg);
    producao_agendar(_j,"coxinha",2);simulacao_avancar_dia(_j);
    _exigir(_j.financas.saldo_centavos==100000 && _j.producao.unidades_produzidas==2,"custo variavel zero valido");

    _j=jogo_criar();
    _exigir(pedido_decidir(_j,1,true).ok && _j.pedidos[0].status=="aceito","aceite entra na fila");
    _antes=json_stringify(_j);
    _exigir(!pedido_decidir(_j,1,true).ok && json_stringify(_j)==_antes,"aceite nao duplica pedido");
    _exigir(pedido_decidir(_j,2,false).ok && _j.pedidos[1].status=="recusado","recusa preservada");
    _antes=json_stringify(_j);
    _exigir(!pedido_entregar(_j,_j.pedidos[0]).ok && json_stringify(_j)==_antes,"entrega sem produtos atomica");
    compra_realizar(_j,"farinha",10);producao_agendar(_j,"coxinha",5);simulacao_avancar_dia(_j);
    _exigir(_j.pedidos[0].status=="entregue" && _j.pedidos[0].pontual && _j.pedidos[0].dia_entrega==2,"entrega pontual no mesmo processamento");
    _exigir(estoque_quantidade(_j.estoque.materias_primas,"farinha")==125 && estoque_quantidade(_j.estoque.produtos,"coxinha")==0,"ordem chegada producao entrega conserva estoque");
    _exigir(_j.financas.saldo_centavos==102275 && _j.financas.receitas_centavos==3000,"resultado numerico compra producao entrega");
    _exigir(indicadores_calcular(_j).resultado_caixa_centavos==2275,"receita diferente de resultado");
    _antes=json_stringify(_j);
    _exigir(!pedido_entregar(_j,_j.pedidos[0]).ok && json_stringify(_j)==_antes,"entrega nao paga duas vezes");
    _exigir(simulacao_auditar(_j).ok,"auditoria ciclo completo");
    _exigir(array_length(_j.historico_dias)==1 && array_length(_j.ultimo_resumo.eventos)>6,"resumo preservado");
    _cfg=parametros_padrao();_cfg.prazo_pedido_dias=1;_j=jogo_criar(_cfg);pedido_decidir(_j,1,true);simulacao_avancar_dia(_j);
    _exigir(_j.pedidos[0].status=="aceito" && _j.pedidos[0].atraso_dias==0,"pedido no vencimento preservado");
    simulacao_avancar_dia(_j);
    _exigir(_j.pedidos[0].status=="aceito" && _j.pedidos[0].atraso_dias==1,"pedido atrasado nao apagado");
    _exigir(_j.pedidos[1].status=="expirado" && !pedido_decidir(_j,2,true).ok,"oferta expirada nao aceita");
    producao_agendar(_j,"coxinha",5);simulacao_avancar_dia(_j);
    _exigir(_j.pedidos[0].status=="entregue" && !_j.pedidos[0].pontual && _j.pedidos[0].atraso_dias==2,"entrega tardia registrada");
    _exigir(indicadores_calcular(_j).entregas_atrasadas==1 && simulacao_auditar(_j).ok,"indicadores e conservacao atrasos");
    _cfg=parametros_padrao();_cfg.pedido_quantidade_min=5;_cfg.pedido_quantidade_max=5;_j=jogo_criar(_cfg);
    pedido_decidir(_j,2,true);pedido_decidir(_j,1,true);producao_agendar(_j,"coxinha",5);producao_agendar(_j,"pastel",5);
    var _fila=pedidos_fila(_j);_exigir(_fila[0].id==2,"fila ordenada pelo aceite");
    simulacao_avancar_dia(_j);var _refs=[];
    for(var _i=0;_i<array_length(_j.financas.movimentos);_i++) if(_j.financas.movimentos[_i].tipo=="entrega") array_push(_refs,_j.financas.movimentos[_i].referencia);
    _exigir(_refs[0]=="pedido:2" && _refs[1]=="pedido:1" && simulacao_auditar(_j).ok,"entregas respeitam fila e conservacao");
    _j=jogo_criar(_cfg);pedido_decidir(_j,1,true);simulacao_avancar_dia(_j);pedido_decidir(_j,4,true);producao_agendar(_j,"coxinha",5);simulacao_avancar_dia(_j);
    _exigir(_j.pedidos[0].status=="entregue" && _j.pedidos[3].status=="aceito" && simulacao_auditar(_j).ok,"mesmos produtos nao atendem dois pedidos");
    _j.avancando=true;var _dia=_j.dia;
    _exigir(!simulacao_avancar_dia(_j).ok && _j.dia==_dia,"reentrada do tempo bloqueada");_j.avancando=false;
    for(var _i=0;_i<12;_i++) simulacao_avancar_dia(_j);
    _exigir(simulacao_auditar(_j).ok && array_length(_j.pedidos)==_j.dia*3,"varios dias sem apagar ou duplicar pedidos");

    _cfg=parametros_padrao();_cfg.pedido_quantidade_min=20;
    _exigir(!parametros_validar(_cfg).ok,"parametros min maior que max rejeitados");
    _cfg=parametros_padrao();_cfg.catalogo.produtos[0].receita[0].quantidade=1.5;
    _exigir(!parametros_validar(_cfg).ok,"receita fracionaria rejeitada");
    _cfg=parametros_padrao();_cfg.catalogo.produtos[0].receita[0].ingrediente_id="desconhecido";
    _exigir(!parametros_validar(_cfg).ok,"ingrediente inexistente rejeitado");
    _cfg=parametros_padrao();_cfg.catalogo.produtos[0].receita[1].ingrediente_id="farinha";
    _exigir(!parametros_validar(_cfg).ok,"receita duplicada rejeitada");
    _cfg=parametros_padrao();for(var _i=0;_i<array_length(_cfg.catalogo.produtos[0].receita);_i++) _cfg.catalogo.produtos[0].receita[_i].quantidade=0;
    _exigir(!parametros_validar(_cfg).ok,"receita vazia rejeitada");
    _cfg=parametros_padrao();_j=jogo_criar(_cfg);_cfg.catalogo.ingredientes[0].estoque_inicial=0;
    _exigir(_j.catalogo.ingredientes[0].estoque_inicial==120,"parametros da sessao independentes");
    var _nova=jogo_criar();
    _exigir(_nova.financas.saldo_centavos==100000 && _nova.dia==1 && _nova.producao.unidades_produzidas==0,"nova sessao restaura padroes");
    _t.ok=array_length(_t.falhas)==0;
    show_debug_message("FDS_SIMULACAO_TESTES: "+string(_t.total)+" / FALHAS: "+string(array_length(_t.falhas)));
    return _t;
}

/// Mesmo despachante de cliques usado pelo Step. Executar somente em cópia de teste.
function testes_interface_simulacao_executar() {
    var _t={total:0,falhas:[]};
    var _exigir=method(_t,function(_cond,_nome){
        total++;if(!_cond) array_push(falhas,_nome);
        show_debug_message((_cond?"OK UI: ":"FALHA UI: ")+_nome);
    });
    var _original=global.jogo;
    global.jogo=jogo_criar();
    var _f=instance_create_depth(0,0,-1000,obj_fabrica);
    try {
        with(_f) {
            fabrica_clicar(450,650);
            _exigir(painel=="comercial","abrir comercial");
            fabrica_clicar(780,516);
            _exigir(global.jogo.pedidos[0].status=="aceito","aceitar oferta");
            fabrica_clicar(1090,650);
            _exigir(painel=="producao","abrir producao");
            fabrica_clicar(1195,420);fabrica_clicar(652,420);
            _exigir(producao_quantidade==5,"quantidade de producao selecionavel");
            fabrica_clicar(924,520);
            _exigir(producao_reserva_capacidade(global.jogo)==5,"botao planeja lote");
            _exigir(estoque_quantidade(global.jogo.estoque.produtos,"coxinha")==0,"plano nao produz instantaneamente");
            fabrica_clicar(920,206);fabrica_clicar(924,520);
            _exigir(producao_reserva_capacidade(global.jogo)==0,"cancelar plano pela interface");
            fabrica_clicar(710,206);fabrica_clicar(924,520);
            fabrica_clicar(760,650);
            _exigir(painel=="estoque","abrir estoque");
            fabrica_clicar(1195,420);fabrica_clicar(652,420);
            _exigir(compra_quantidade==20,"quantidade da compra selecionavel");
            fabrica_clicar(924,520);
            _exigir(global.jogo.compras[0].quantidade==20 && global.jogo.compras[0].status=="em_transito","botao faz compra com prazo");
            _exigir(estoque_quantidade(global.jogo.estoque.materias_primas,"farinha")==120,"compra nao chega no clique");
            fabrica_clicar(150,562);
            _exigir(global.jogo.dia==2 && painel=="resumo","avancar mostra resumo");
            _exigir(global.jogo.pedidos[0].status=="entregue" && global.jogo.financas.saldo_centavos==101675,"ciclo financeiro pela interface");
            _exigir(simulacao_auditar(global.jogo).ok,"conservacao do ciclo de cliques");
            fabrica_clicar(150,562);
            _exigir(global.jogo.dia==2,"resumo bloqueia segundo avanco acidental");
            fabrica_clicar(1130,566);
            _exigir(resumo_pagina==1,"paginacao do resumo");
            fabrica_clicar(1216,146);
            _exigir(painel=="","fechar sem acionar cenario");
            fabrica_clicar(450,650);fabrica_clicar(920,206);
            _exigir(comercial_aba=="fila" && array_length(fabrica_pedidos_visiveis(global.jogo,"fila"))==0,"fila atualizada apos entrega");
        }
        var _param=instance_create_depth(0,0,-1000,obj_parametros);
        with(_param) {
            parametros_clique(1196,260);
            _exigir(configuracao.capacidade_diaria==110,"editar capacidade pelos botoes");
            parametros_clique(1000,196);keyboard_string="200000";parametros_clique(840,470);
            _exigir(campo_editando==-1 && configuracao.caixa_inicial_centavos==200000,"editar dinheiro em centavos");
            parametros_clique(300,644);
            _exigir(pagina==1 && array_length(campos)==50,"paginacao dos cinquenta parametros");
            _exigir(global.jogo.financas.saldo_centavos==101675,"editar configuracao nao altera sessao existente");
            instance_destroy();
        }
    } finally {
        if(instance_exists(_f)) with(_f) instance_destroy();
        global.jogo=_original;
    }
    _t.ok=array_length(_t.falhas)==0;
    show_debug_message("FDS_INTERFACE_TESTES: "+string(_t.total)+" / FALHAS: "+string(array_length(_t.falhas)));
    return _t;
}
