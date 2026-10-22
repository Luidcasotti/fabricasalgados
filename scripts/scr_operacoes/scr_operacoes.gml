/// Consultas para a interface; não existem mais reposição/produção instantâneas.
function fabrica_aviso(_jogo) {
    for(var _i=0;_i<array_length(_jogo.catalogo.ingredientes);_i++) {
        var _item=_jogo.catalogo.ingredientes[_i];
        if(estoque_quantidade(_jogo.estoque.materias_primas,_item.id)-producao_reserva_ingrediente(_jogo,_item.id)<_item.estoque_minimo)
            return "Estoque livre abaixo do mínimo: "+_item.nome+". Compras têm prazo de chegada.";
    }
    return "Planeje, aceite pedidos e avance o dia. Valores fictícios para aprendizagem.";
}
function fabrica_pedidos_visiveis(_jogo,_aba) {
    if(_aba=="fila") return pedidos_fila(_jogo);
    var _lista=[];
    for(var _i=0;_i<array_length(_jogo.pedidos);_i++) {
        var _p=_jogo.pedidos[_i];
        if((_aba=="ofertas" && _p.status=="ofertado") ||
            (_aba=="historico" && _p.status!="ofertado" && _p.status!="aceito")) array_push(_lista,_p);
    }
    return _lista;
}
function fabrica_planos_pendentes(_jogo) {
    var _planos=[];
    for(var _i=0;_i<array_length(_jogo.producao.planos);_i++)
        if(_jogo.producao.planos[_i].status=="planejado") array_push(_planos,_jogo.producao.planos[_i]);
    return _planos;
}
