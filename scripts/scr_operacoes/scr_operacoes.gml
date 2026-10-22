/// Ciclo didático mínimo. Validações precedem qualquer mutação.
function fabrica_pedido_pendente(_jogo) {
    for(var _i=0;_i<array_length(_jogo.pedidos);_i++) {
        if(_jogo.pedidos[_i].status=="pendente") return _jogo.pedidos[_i];
    }
    return undefined;
}
function fabrica_receber(_jogo) {
    if(pedidos_contar_status(_jogo.pedidos,"pendente")>=3) return {ok:false,mensagem:"Atenda as encomendas: limite de 3 pendentes."};
    var _indice=(_jogo.proximo_pedido_id-1) mod array_length(_jogo.catalogo.produtos);
    return pedido_adicionar(_jogo,_jogo.catalogo.produtos[_indice].id,5);
}
function fabrica_produzir(_jogo,_produto_id) {
    var _plano=producao_planejar(_jogo,_produto_id,5);
    if(!_plano.ok) return _plano;
    if(estoque_quantidade(_jogo.estoque.produtos,_produto_id)+5>1000000)
        return {ok:false,mensagem:"Estoque de produtos no limite."};
    for(var _i=0;_i<array_length(_plano.insumos);_i++) {
        var _insumo=_plano.insumos[_i];
        estoque_ajustar(_jogo.estoque.materias_primas,_insumo.ingrediente_id,-_insumo.quantidade);
    }
    estoque_ajustar(_jogo.estoque.produtos,_produto_id,5);
    _jogo.producao.unidades_produzidas+=5;
    array_push(_jogo.producao.lotes,{dia:_jogo.dia,produto_id:_produto_id,quantidade:5,custo_centavos:_plano.custo_centavos});
    // O custo do lote é informativo: ingredientes são pagos na compra, uma só vez.
    return {ok:true,mensagem:"Lote pronto! Entregue a encomenda no Comercial."};
}
function fabrica_entregar(_jogo) {
    var _pedido=fabrica_pedido_pendente(_jogo);
    if(is_undefined(_pedido)) return {ok:false,mensagem:"Receba uma encomenda no Comercial."};
    if(estoque_quantidade(_jogo.estoque.produtos,_pedido.produto_id)<_pedido.quantidade)
        return {ok:false,mensagem:"Produza o lote solicitado antes de entregar."};
    if(!financas_registrar(_jogo.financas,_pedido.total_centavos,"Entrega #"+string(_pedido.id)))
        return {ok:false,mensagem:"Não foi possível registrar o recebimento."};
    estoque_ajustar(_jogo.estoque.produtos,_pedido.produto_id,-_pedido.quantidade);
    _pedido.status="atendido";
    return {ok:true,mensagem:"Encomenda entregue! Recebido "+financas_formatar(_pedido.total_centavos)+"."};
}
function fabrica_custo_reposicao(_jogo) {
    var _total=0;
    for(var _i=0;_i<array_length(_jogo.catalogo.ingredientes);_i++) _total+=_jogo.catalogo.ingredientes[_i].custo_centavos*20;
    return _total;
}
function fabrica_repor(_jogo) {
    var _custo=fabrica_custo_reposicao(_jogo);
    for(var _i=0;_i<array_length(_jogo.catalogo.ingredientes);_i++) {
        var _id=_jogo.catalogo.ingredientes[_i].id;
        if(estoque_quantidade(_jogo.estoque.materias_primas,_id)+20>1000000)
            return {ok:false,mensagem:"Não há espaço para repor ingredientes."};
    }
    if(!financas_registrar(_jogo.financas,-_custo,"Reposição de ingredientes"))
        return {ok:false,mensagem:"Dinheiro insuficiente para a reposição."};
    for(var _i=0;_i<array_length(_jogo.catalogo.ingredientes);_i++)
        estoque_ajustar(_jogo.estoque.materias_primas,_jogo.catalogo.ingredientes[_i].id,20);
    return {ok:true,mensagem:"Estoque reposto: +20 porções de cada ingrediente."};
}
function fabrica_aviso(_jogo) {
    for(var _i=0;_i<array_length(_jogo.estoque.materias_primas);_i++) {
        var _item=_jogo.estoque.materias_primas[_i];
        if(_item.quantidade<20) return "Estoque baixo: "+ingrediente_obter(_jogo.catalogo,_item.id).nome+". Planeje a reposição.";
    }
    return "Dica: clique nos setores ou use os botões abaixo da fábrica.";
}
