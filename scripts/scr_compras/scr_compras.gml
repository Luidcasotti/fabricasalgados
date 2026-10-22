function compras_pendentes_quantidade(_jogo,_id) {
    var _total=0;
    for(var _i=0;_i<array_length(_jogo.compras);_i++) {
        var _c=_jogo.compras[_i];
        if(_c.status=="em_transito" && _c.ingrediente_id==_id) _total+=_c.quantidade;
    }
    return _total;
}
function compras_proxima_chegada(_jogo,_id) {
    var _dia=0;
    for(var _i=0;_i<array_length(_jogo.compras);_i++) {
        var _c=_jogo.compras[_i];
        if(_c.status=="em_transito" && _c.ingrediente_id==_id && (_dia==0 || _c.dia_chegada<_dia)) _dia=_c.dia_chegada;
    }
    return _dia;
}
function compra_realizar(_jogo,_id,_quantidade) {
    var _bloqueio=simulacao_bloqueio(_jogo);if(_bloqueio!="") return {ok:false,mensagem:_bloqueio};
    var _item=ingrediente_obter(_jogo.catalogo,_id);
    if(is_undefined(_item) || !quantidade_valida(_quantidade)) return {ok:false,mensagem:"Compra inválida."};
    if(estoque_quantidade(_jogo.estoque.materias_primas,_id)+compras_pendentes_quantidade(_jogo,_id)+_quantidade>1000000)
        return {ok:false,mensagem:"Limite do estoque inclui compras em trânsito."};
    var _total=_item.custo_centavos*_quantidade;
    if(_total>financas_livre(_jogo)) return {ok:false,mensagem:"Dinheiro livre insuficiente. Há reservas de produção."};
    var _numero=_jogo.proximo_compra_id;
    if(!financas_registrar(_jogo.financas,-_total,"Compra de "+_item.nome,"compra",_jogo.dia,"compra:"+string(_numero)))
        return {ok:false,mensagem:"Pagamento da compra recusado."};
    array_push(_jogo.compras,{id:_numero,ingrediente_id:_id,quantidade:_quantidade,
        custo_unitario_centavos:_item.custo_centavos,total_centavos:_total,
        dia_compra:_jogo.dia,dia_chegada:_jogo.dia+_item.prazo_dias,status:"em_transito",recebida_dia:0});
    _jogo.proximo_compra_id++;
    diario_registrar(_jogo,"COMPRAR "+_item.nome,string(_quantidade)+" unidade(s); pago "+financas_formatar(_total)+"; chegada prevista no dia "+string(_jogo.dia+_item.prazo_dias)+". O físico não mudou.");
    pedagogia_disparar(_jogo,"compra",{compra:_jogo.compras[array_length(_jogo.compras)-1]});
    return {ok:true,mensagem:"Compra paga. Chegada no dia "+string(_jogo.dia+_item.prazo_dias)+"."};
}
function compras_receber(_jogo,_eventos) {
    if(simulacao_bloqueio(_jogo)!="") return _eventos;
    for(var _i=0;_i<array_length(_jogo.compras);_i++) {
        var _c=_jogo.compras[_i];
        if(_c.status!="em_transito" || _c.dia_chegada>_jogo.dia) continue;
        if(estoque_ajustar(_jogo.estoque.materias_primas,_c.ingrediente_id,_c.quantidade)) {
            _c.status="recebida";_c.recebida_dia=_jogo.dia;
            array_push(_eventos,"Compra #"+string(_c.id)+": chegaram "+string(_c.quantidade)+" de "+ingrediente_obter(_jogo.catalogo,_c.ingrediente_id).nome+".");
        } else array_push(_eventos,"Compra #"+string(_c.id)+": chegada bloqueada; compra preservada.");
    }
    return _eventos;
}
