/// A exploração usa as regras econômicas existentes, com estoques físicos separados.
function exploracao_ativa(_j) {return variable_struct_exists(_j,"exploracao");}
function exploracao_zerar_insumos(_j) {
    var _a=[];for(var _i=0;_i<array_length(_j.catalogo.ingredientes);_i++)array_push(_a,{id:_j.catalogo.ingredientes[_i].id,quantidade:0});return _a;
}
function exploracao_iniciar(_j) {
    if(exploracao_ativa(_j))return;
    _j.cozinha=exploracao_zerar_insumos(_j);_j.carregados=exploracao_zerar_insumos(_j);
    _j.exploracao={setor:"corredor",posicoes:{},limite_transporte:80,transferencias:[]};
    _j.diario[0].consequencia=string(_j.parametros.duracao_dias)+" dias de operação, começando no dia 1. Valores fictícios. Produção e entregas são presenciais; encerrar dia não as executa.";
    diario_registrar(_j,"ENTRAR NA FÁBRICA","Procure Marta no Comercial. E interage; WASD e setas movimentam o cozinheiro.");
}
function exploracao_carregado_total(_j) {
    var _q=0;for(var _i=0;_i<array_length(_j.carregados);_i++)_q+=_j.carregados[_i].quantidade;return _q;
}
function exploracao_total_insumo(_j,_id) {
    var _q=estoque_quantidade(_j.estoque.materias_primas,_id);
    if(exploracao_ativa(_j))_q+=estoque_quantidade(_j.cozinha,_id)+estoque_quantidade(_j.carregados,_id);
    return _q;
}
function exploracao_bloqueio_local(_j,_alvo) {
    var _b=simulacao_bloqueio(_j);if(_b!="")return _b;
    if(!exploracao_ativa(_j) || !mundo_perto(_j,_alvo))return "Aproxime-se do local correto e pressione E.";
    return "";
}
function exploracao_retirar(_j,_id,_q) {
    var _b=exploracao_bloqueio_local(_j,"prateleira_"+_id);if(_b!="")return {ok:false,mensagem:_b};
    if(!quantidade_valida(_q) || is_undefined(ingrediente_obter(_j.catalogo,_id)))return {ok:false,mensagem:"Quantidade ou ingrediente inválido."};
    if(estoque_quantidade(_j.estoque.materias_primas,_id)<_q)return {ok:false,mensagem:"Não há essa quantidade na prateleira."};
    if(exploracao_carregado_total(_j)+_q>_j.exploracao.limite_transporte)return {ok:false,mensagem:"Mochila cheia. Leve ingredientes à cozinha antes de retirar mais."};
    estoque_ajustar(_j.estoque.materias_primas,_id,-_q);estoque_ajustar(_j.carregados,_id,_q);
    array_push(_j.exploracao.transferencias,{dia:_j.dia,id:_id,quantidade:_q,origem:"estoque",destino:"mochila"});
    diario_registrar(_j,"RETIRAR "+ingrediente_obter(_j.catalogo,_id).nome,string(_q)+" do estoque para a mochila. Nada foi produzido ou duplicado.");
    return {ok:true,mensagem:"Ingredientes na mochila. Leve à mesa de depósito na Produção."};
}
function exploracao_depositar(_j) {
    var _b=exploracao_bloqueio_local(_j,"deposito");if(_b!="")return {ok:false,mensagem:_b};
    var _total=exploracao_carregado_total(_j);if(_total==0)return {ok:false,mensagem:"Mochila vazia. Retire ingredientes no Estoque."};
    for(var _i=0;_i<array_length(_j.carregados);_i++) {
        var _a=_j.carregados[_i];if(estoque_quantidade(_j.cozinha,_a.id)+_a.quantidade>1000000)return {ok:false,mensagem:"Limite da cozinha excedido; transferência cancelada."};
    }
    for(var _i=0;_i<array_length(_j.carregados);_i++) {
        var _a=_j.carregados[_i],_q=_a.quantidade;if(_q==0)continue;
        estoque_ajustar(_j.carregados,_a.id,-_q);estoque_ajustar(_j.cozinha,_a.id,_q);
        array_push(_j.exploracao.transferencias,{dia:_j.dia,id:_a.id,quantidade:_q,origem:"mochila",destino:"cozinha"});
    }
    diario_registrar(_j,"ABASTECER A COZINHA",string(_total)+" unidades transferidas da mochila para a cozinha, sem duplicação.");
    return {ok:true,mensagem:"Cozinha abastecida. Consulte a receita na bancada."};
}
function exploracao_receita_validar(_j,_id,_q) {
    var _p={capacidade_diaria:max(0,_j.parametros.capacidade_diaria-_j.producao.capacidade_usada)};
    var _vista={catalogo:_j.catalogo,parametros:_p,producao:producao_criar(),financas:_j.financas,estoque:{materias_primas:_j.cozinha,produtos:_j.estoque.produtos}};
    var _v=producao_planejar(_vista,_id,_q);
    if(!_v.ok)_v.mensagem=string_replace_all(string_replace_all(_v.mensagem,"próximo dia","dia atual"),"Ingrediente livre insuficiente:","Falta na cozinha:");
    return _v;
}
function exploracao_produzir(_j,_id,_q) {
    var _b=exploracao_bloqueio_local(_j,"bancada");if(_b!="")return {ok:false,mensagem:_b};
    var _p=exploracao_receita_validar(_j,_id,_q);if(!_p.ok)return _p;
    _p.id=_j.producao.proximo_id;_p.dia_planejado=_j.dia;_p.dia_execucao=_j.dia;_p.produzido_dia=_j.dia;_p.status="produzido";
    if(_p.variavel_centavos>0 && !financas_registrar(_j.financas,-_p.variavel_centavos,"Cozinhar lote #"+string(_p.id),"variavel",_j.dia,"lote:"+string(_p.id)))return {ok:false,mensagem:"Pagamento recusado; ingredientes preservados."};
    for(var _i=0;_i<array_length(_p.insumos);_i++) {
        var _a=_p.insumos[_i];estoque_ajustar(_j.cozinha,_a.ingrediente_id,-_a.quantidade);
    }
    estoque_ajustar(_j.estoque.produtos,_id,_q);
    _j.producao.proximo_id++;_j.producao.capacidade_usada+=_p.capacidade;
    _j.producao.unidades_dia+=_q;_j.producao.unidades_produzidas+=_q;
    array_push(_j.producao.planos,_p);
    array_push(_j.producao.lotes,{id:_p.id,dia:_j.dia,produto_id:_id,quantidade:_q,capacidade:_p.capacidade,insumos:_p.insumos,custo_ingredientes_centavos:_p.custo_ingredientes_centavos,variavel_centavos:_p.variavel_centavos});
    diario_registrar(_j,"COZINHAR "+produto_obter(_j.catalogo,_id).nome,string(_q)+" prontos; ingredientes consumidos da cozinha; custo variável "+financas_formatar(_p.variavel_centavos)+". Entregue no balcão do Comercial.");
    pedagogia_disparar(_j,"plano",{plano:_p});
    return {ok:true,mensagem:string(_q)+" salgados prontos! Volte ao balcão do Comercial para entregar."};
}
/// Fecha o dia atual, preserva produção e entrega presenciais; abre o próximo dia.
function exploracao_avancar_dia(_j) {
    var _b=simulacao_bloqueio(_j);if(_b!="")return {ok:false,mensagem:_b};
    if(_j.avancando)return {ok:false,mensagem:"Dia já em processamento."};
    _j.avancando=true;
    try {
        var _dia=_j.dia,_ev=["Dia "+string(_dia)+" encerrado. Produção e entrega ocorreram somente por interação presencial."];
        array_push(_ev,string(_j.producao.unidades_dia)+" salgados produzidos; "+string(_j.producao.capacidade_usada)+" pontos de capacidade usados.");
        _j.dias_processados++;
        var _r={dia:_dia,eventos:_ev,saldo_centavos:_j.financas.saldo_centavos,capacidade_usada:_j.producao.capacidade_usada,unidades:_j.producao.unidades_dia};
        array_push(_j.historico_dias,_r);
        if(_j.dias_processados>=_j.parametros.duracao_dias) {
            _j.encerrado=true;array_push(_ev,"Período encerrado. Pedidos e compras pendentes preservados para análise.");
        } else {
            _j.dia++;
            array_push(_ev,"1 / NOVO DIA "+string(_j.dia)+": RECEBER COMPRAS NO ESTOQUE");_ev=compras_receber(_j,_ev);
            array_push(_ev,"2 / ATUALIZAR PRAZOS SEM ENTREGAR AUTOMATICAMENTE");_ev=pedidos_atualizar_prazos(_j,_ev);
            array_push(_ev,"3 / GERAR OFERTAS ÚNICAS: "+string(pedidos_gerar_dia(_j)));
            _j.producao.capacidade_usada=0;_j.producao.unidades_dia=0;
            array_push(_ev,"4 / RENOVAR CAPACIDADE. Procure os setores; nada foi produzido automaticamente.");
        }
        _r.eventos=_ev;_j.ultimo_resumo=_r;
        diario_registrar(_j,"ENCERRAR DIA "+string(_dia),string(_r.unidades)+" produzidos. Caixa "+financas_formatar(_r.saldo_centavos)+". Reveja os eventos no dashboard.");
        pedagogia_disparar(_j,"fim_dia",{});
        return {ok:true,mensagem:_j.encerrado?"Período encerrado. Reveja os resultados.":"Dia "+string(_j.dia)+" iniciado. Compras recebidas somente no Estoque; consulte os eventos."};
    } finally {_j.avancando=false;}
}
function exploracao_objetivo(_j) {
    var _fila=pedidos_fila(_j);if(array_length(_fila)==0)return "Procure Marta no Comercial e analise as encomendas.";
    var _p=_fila[0];if(estoque_quantidade(_j.estoque.produtos,_p.produto_id)>=_p.quantidade)return "Leve os salgados ao balcão do Comercial e entregue o pedido.";
    if(exploracao_carregado_total(_j)>0)return "Transporte os ingredientes até a mesa de depósito na Produção.";
    var _v=exploracao_receita_validar(_j,_p.produto_id,_p.quantidade-estoque_quantidade(_j.estoque.produtos,_p.produto_id));
    if(_v.ok)return "Vá à bancada da Produção e cozinhe a quantidade do pedido.";
    return "Consulte a receita na Produção e retire os ingredientes no Estoque.";
}
