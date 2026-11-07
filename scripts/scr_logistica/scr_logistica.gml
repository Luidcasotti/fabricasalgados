/// A exploração usa as regras econômicas existentes, com estoques físicos separados.
function exploracao_ativa(_j) {return variable_struct_exists(_j,"exploracao");}
function exploracao_zerar_insumos(_j) {
    var _a=[];for(var _i=0;_i<array_length(_j.catalogo.ingredientes);_i++)array_push(_a,{id:_j.catalogo.ingredientes[_i].id,quantidade:0});return _a;
}
function exploracao_iniciar(_j) {
    if(exploracao_ativa(_j))return;
    maquinas_iniciar(_j);
    _j.cozinha=exploracao_zerar_insumos(_j);_j.carregados=exploracao_zerar_insumos(_j);
    _j.exploracao={setor:"corredor",posicoes:{},limite_transporte:80,transferencias:[],entregas_motoboy:0,aviso_entrega:"",aviso_entrega_segundos:0,saida_motoboy_segundos:0};
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
/// Caio separa o canhoto no balcão do Estoque; prateleiras continuam disponíveis.
function exploracao_separar_pedido(_j){
    var _b=exploracao_bloqueio_local(_j,"compras");if(_b!="")return {ok:false,mensagem:_b};
    var _c=canhoto_dados(_j);if(is_undefined(_c))return {ok:false,mensagem:"Aceite um pedido com Marta primeiro."};
    var _espaco=_j.exploracao.limite_transporte-exploracao_carregado_total(_j),_lotes=[],_total=0;
    for(var _i=0;_i<array_length(_c.linhas);_i++){
        var _d=_c.linhas[_i],_q=min(_d.retirar,_espaco);
        if(_q<=0)continue;
        if(estoque_quantidade(_j.carregados,_d.id)+_q>1000000)return {ok:false,mensagem:"Limite de transporte excedido."};
        array_push(_lotes,{id:_d.id,quantidade:_q});_espaco-=_q;_total+=_q;
    }
    if(_total==0)return {ok:false,mensagem:exploracao_carregado_total(_j)>0?"Leve a mochila à Mesa de depósito na Produção.":"Nada para retirar. Confira o próximo passo no canhoto."};
    for(var _i=0;_i<array_length(_lotes);_i++){
        var _a=_lotes[_i];estoque_ajustar(_j.estoque.materias_primas,_a.id,-_a.quantidade);estoque_ajustar(_j.carregados,_a.id,_a.quantidade);
        array_push(_j.exploracao.transferencias,{dia:_j.dia,id:_a.id,quantidade:_a.quantidade,origem:"estoque",destino:"mochila"});
    }
    diario_registrar(_j,"SEPARAR CANHOTO #"+string(_c.pedido.id),string(_total)+" porções separadas por Caio, sem compra ou consumo.");
    missoes_evento(_j,"retirada",{});
    return {ok:true,mensagem:"Ingredientes na mochila. Leve à Mesa de depósito na Produção."};
}
function exploracao_comprar_faltante(_j){
    var _b=exploracao_bloqueio_local(_j,"compras");if(_b!="")return {ok:false,mensagem:_b};
    var _c=canhoto_dados(_j);if(is_undefined(_c))return {ok:false,mensagem:"Aceite um pedido primeiro."};
    if(_c.comprar<=0)return {ok:false,mensagem:"Não precisa comprar: os ingredientes já existem ou estão a caminho."};
    var _custo=0;for(var _i=0;_i<array_length(_c.linhas);_i++){
        var _d=_c.linhas[_i];
        if(_d.almoxarifado+compras_pendentes_quantidade(_j,_d.id)+_d.comprar_quantidade>1000000)return {ok:false,mensagem:"Limite de estoque excedido; compra cancelada."};
        _custo+=_d.comprar_quantidade*ingrediente_obter(_j.catalogo,_d.id).custo_centavos;
    }
    if(_custo>financas_livre(_j))return {ok:false,mensagem:"Caixa insuficiente para a reposição do canhoto."};
    for(var _i=0;_i<array_length(_c.linhas);_i++){
        var _d=_c.linhas[_i];if(_d.comprar_quantidade<=0)continue;
        var _r=compra_realizar(_j,_d.id,_d.comprar_quantidade);if(!_r.ok)return _r;
    }
    return {ok:true,mensagem:"Faltantes encomendados! O motoboy chega em 12 segundos de jogo. Depois pegue os ingredientes com Caio. Não precisa encerrar o dia."};
}
function exploracao_retirar(_j,_id,_q) {
    var _missao=missoes_permitir(_j,"retirar",_id,_q);if(!_missao.ok)return _missao;
    var _b=exploracao_bloqueio_local(_j,"prateleira_"+_id);if(_b!="")return {ok:false,mensagem:_b};
    if(!quantidade_valida(_q) || is_undefined(ingrediente_obter(_j.catalogo,_id)))return {ok:false,mensagem:"Quantidade ou ingrediente inválido."};
    if(estoque_quantidade(_j.estoque.materias_primas,_id)<_q)return {ok:false,mensagem:"Falta "+ingrediente_obter(_j.catalogo,_id).nome+" na prateleira. Reduza a retirada ou peça reposição no computador do Estoque."};
    if(exploracao_carregado_total(_j)+_q>_j.exploracao.limite_transporte)return {ok:false,mensagem:"Mochila cheia. Leve ingredientes à cozinha antes de retirar mais."};
    estoque_ajustar(_j.estoque.materias_primas,_id,-_q);estoque_ajustar(_j.carregados,_id,_q);
    array_push(_j.exploracao.transferencias,{dia:_j.dia,id:_id,quantidade:_q,origem:"estoque",destino:"mochila"});
    diario_registrar(_j,"RETIRAR "+ingrediente_obter(_j.catalogo,_id).nome,string(_q)+" do estoque para a mochila. Nada foi produzido ou duplicado.");
    missoes_evento(_j,"retirada",{id:_id,quantidade:_q});
    return {ok:true,mensagem:"Ingredientes na mochila. Leve à mesa de depósito na Produção."};
}
function exploracao_depositar(_j) {
    var _missao=missoes_permitir(_j,"depositar","",0);if(!_missao.ok)return _missao;
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
    missoes_evento(_j,"deposito",{});
    return {ok:true,mensagem:"Cozinha abastecida. Vá à Mesa de preparo e cozinhe o pedido."};
}
/// Um diagnóstico único separa falta local de falta na empresa, usado pelo HUD e pela bancada.
function exploracao_insumo_diagnostico(_j,_id,_necessario) {
    var _nome=ingrediente_obter(_j.catalogo,_id).nome;
    var _cozinha=estoque_quantidade(_j.cozinha,_id),_almox=estoque_quantidade(_j.estoque.materias_primas,_id),_mochila=estoque_quantidade(_j.carregados,_id);
    var _total=_cozinha+_almox+_mochila,_falta=max(0,_necessario-_cozinha),_compra=max(0,_necessario-_total);
    var _pendente=compras_pendentes_quantidade(_j,_id);
    var _d={id:_id,nome:_nome,necessario:_necessario,cozinha:_cozinha,almoxarifado:_almox,mochila:_mochila,total:_total,falta_local:_falta,falta_empresa:_compra,em_transito:_pendente,comprar_quantidade:max(0,_compra-_pendente),acao:"pronto",mensagem:"Ingredientes disponíveis na cozinha."};
    if(_falta<=0)return _d;
    var _local="Cozinha: "+string(_cozinha)+" / precisa de "+string(_necessario)+". ";
    if(_compra>0) {
        if(_pendente>=_compra) {_d.acao="aguardar";_d.mensagem=_nome+": "+_local+"Reposição já em trânsito. Aguarde a chegada ao almoxarifado.";}
        else {_d.acao="comprar";_d.mensagem=_nome+": "+_local+"Solicite "+string(_d.comprar_quantidade)+" no Estoque; a reserva da empresa e as compras em trânsito não cobrem a receita.";}
    } else if(_mochila>0) {_d.acao="depositar";_d.mensagem=_nome+": "+_local+"Você já transporta "+string(_mochila)+". Deposite na mesa da Produção.";}
    else {_d.acao="retirar";_d.mensagem=_nome+": "+_local+"Há "+string(_almox)+" no almoxarifado. Retire "+string(_falta)+" e leve à Produção. Não precisa comprar.";}
    return _d;
}
function exploracao_necessidade_atual(_j,_id) {
    var _fila=pedidos_fila(_j);if(array_length(_fila)==0)return 0;
    var _pedido=_fila[0],_produto=produto_obter(_j.catalogo,_pedido.produto_id),_q=max(0,_pedido.quantidade-estoque_quantidade(_j.estoque.produtos,_pedido.produto_id));
    for(var _i=0;_i<array_length(_produto.receita);_i++)if(_produto.receita[_i].ingrediente_id==_id)return _produto.receita[_i].quantidade*_q;
    return 0;
}
function exploracao_receita_validar(_j,_id,_q) {
    var _p={capacidade_diaria:max(0,maquinas_limite_turno(_j)-_j.producao.capacidade_usada)};
    var _vista={catalogo:_j.catalogo,parametros:_p,producao:producao_criar(),financas:_j.financas,estoque:{materias_primas:_j.cozinha,produtos:_j.estoque.produtos}};
    var _v=producao_planejar(_vista,_id,_q);
    if(!_v.ok)_v.mensagem=string_replace_all(string_replace_all(_v.mensagem,"próximo dia","dia atual"),"Ingrediente livre insuficiente:","Falta na cozinha:");
    if(!_v.ok && string_pos("Falta na cozinha:",_v.mensagem)==1) {
        var _receita=produto_obter(_j.catalogo,_id).receita;
        for(var _i=0;_i<array_length(_receita);_i++) {
            var _r=_receita[_i],_d=exploracao_insumo_diagnostico(_j,_r.ingrediente_id,_r.quantidade*_q);
            if(_d.falta_local>0){_v.mensagem=_d.mensagem;_v.diagnostico=_d;break;}
        }
    }
    return _v;
}
function exploracao_produzir(_j,_id,_q) {
    var _missao=missoes_permitir(_j,"produzir",_id,_q);if(!_missao.ok)return _missao;
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
    missoes_evento(_j,"producao",{id:_id,quantidade:_q});
    return {ok:true,mensagem:string(_q)+" salgados prontos! Volte ao balcão do Comercial para entregar."};
}
/// Fecha o dia atual, preserva produção e entrega presenciais; abre o próximo dia.
function exploracao_avancar_dia(_j) {
    if(feira_ativa(_j))return {ok:false,mensagem:"Neste modo, o dia termina com a entrega ou ao terminar o tempo configurado."};
    var _missao=missoes_permitir(_j,"dia","",0);if(!_missao.ok)return _missao;
    var _b=simulacao_bloqueio(_j);if(_b!="")return {ok:false,mensagem:_b};
    if(_j.avancando)return {ok:false,mensagem:"Dia já em processamento."};
    _j.avancando=true;
    try {
        var _dia=_j.dia,_ev=["Dia "+string(_dia)+" encerrado. Produção e entrega ocorreram somente por interação presencial."];
        array_push(_ev,string(_j.producao.unidades_dia)+" salgados produzidos; "+string(_j.producao.capacidade_usada)+" pontos de capacidade usados.");
        _j.dias_processados++;
        var _r={dia:_dia,eventos:_ev,saldo_centavos:_j.financas.saldo_centavos,capacidade_usada:_j.producao.capacidade_usada,unidades:_j.producao.unidades_dia};
        array_push(_j.historico_dias,_r);
        if(_j.dias_processados>=_j.parametros.duracao_dias && !missoes_ativa(_j)) {
            _j.encerrado=true;array_push(_ev,"Período encerrado. Pedidos e compras pendentes preservados para análise.");
        } else {
            _j.dia++;if(missoes_ativa(_j))_j.parametros.duracao_dias=max(_j.parametros.duracao_dias,_j.dia+2);
            array_push(_ev,"1 / NOVO DIA "+string(_j.dia)+": RECEBER COMPRAS NO ESTOQUE");_ev=compras_receber(_j,_ev);
            array_push(_ev,"2 / ATUALIZAR PRAZOS SEM ENTREGAR AUTOMATICAMENTE");_ev=pedidos_atualizar_prazos(_j,_ev);if(missoes_ativa(_j))missoes_sincronizar(_j);
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
    if(missoes_ativa(_j))return missoes_guia(_j).acao;
    var _fila=pedidos_fila(_j);if(array_length(_fila)==0)return "Procure Marta no Comercial e analise as encomendas.";
    var _p=_fila[0];if(estoque_quantidade(_j.estoque.produtos,_p.produto_id)>=_p.quantidade)return "Leve os salgados ao balcão do Comercial e entregue o pedido.";
    if(exploracao_carregado_total(_j)>0)return "Transporte os ingredientes até a mesa de depósito na Produção.";
    var _v=exploracao_receita_validar(_j,_p.produto_id,_p.quantidade-estoque_quantidade(_j.estoque.produtos,_p.produto_id));
    if(_v.ok)return "Vá à bancada da Produção e cozinhe a quantidade do pedido.";
    return "Consulte a receita na Produção e retire os ingredientes no Estoque.";
}
