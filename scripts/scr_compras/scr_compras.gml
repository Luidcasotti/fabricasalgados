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
    var _missao=missoes_permitir(_jogo,"comprar",_id,_quantidade);if(!_missao.ok)return _missao;
    if(exploracao_ativa(_jogo) && !mundo_perto(_jogo,"compras"))return {ok:false,mensagem:"Aproxime-se do local de compras e pressione E."};
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
        dia_compra:_jogo.dia,dia_chegada:_jogo.dia+_item.prazo_dias,status:"em_transito",recebida_dia:0,via_motoboy:exploracao_ativa(_jogo),entrega_total:12,entrega_restante:12});
    _jogo.proximo_compra_id++;
    diario_registrar(_jogo,"COMPRAR "+_item.nome,string(_quantidade)+" unidade(s); pago "+financas_formatar(_total)+(exploracao_ativa(_jogo)?"; motoboy em 12 segundos de jogo.":"; chegada prevista no dia "+string(_jogo.dia+_item.prazo_dias)+".")+" O físico só muda na chegada.");
    pedagogia_disparar(_jogo,"compra",{compra:_jogo.compras[array_length(_jogo.compras)-1]});
    missoes_evento(_jogo,"compra",{compra:_jogo.compras[array_length(_jogo.compras)-1]});
    return {ok:true,mensagem:exploracao_ativa(_jogo)?"Encomenda paga. O motoboy chega em 12 segundos de jogo e deixa os ingredientes nas prateleiras do Estoque.":"Compra paga. Chegada no dia "+string(_jogo.dia+_item.prazo_dias)+"."};
}
function compras_receber(_jogo,_eventos) {
    if(simulacao_bloqueio(_jogo)!="") return _eventos;
    var _novas=[];
    for(var _i=0;_i<array_length(_jogo.compras);_i++) {
        var _c=_jogo.compras[_i];
        if(_c.status!="em_transito")continue;
        var _moto=variable_struct_exists(_c,"via_motoboy") && _c.via_motoboy;
        if(_moto?_c.entrega_restante>0:_c.dia_chegada>_jogo.dia)continue;
        if(estoque_ajustar(_jogo.estoque.materias_primas,_c.ingrediente_id,_c.quantidade)) {
            _c.status="recebida";_c.recebida_dia=_jogo.dia;
            if(_moto){array_push(_novas,_c);diario_registrar(_jogo,"MOTOBOY ENTREGOU",string(_c.quantidade)+" de "+ingrediente_obter(_jogo.catalogo,_c.ingrediente_id).nome+" recebidos no Estoque. Pagamento já registrado na encomenda.");}
            array_push(_eventos,"Compra #"+string(_c.id)+": chegaram "+string(_c.quantidade)+" de "+ingrediente_obter(_jogo.catalogo,_c.ingrediente_id).nome+".");
        } else array_push(_eventos,"Compra #"+string(_c.id)+": chegada bloqueada; compra preservada.");
    }
    if(array_length(_novas)>0){
        var _e=_jogo.exploracao;_e.entregas_motoboy+=array_length(_novas);_e.saida_motoboy_segundos=4;_e.aviso_entrega_segundos=7;
        _e.aviso_entrega=array_length(_novas)==1?"Motoboy entregou "+string(_novas[0].quantidade)+" de "+ingrediente_obter(_jogo.catalogo,_novas[0].ingrediente_id).nome+"!":"Motoboy entregou "+string(array_length(_novas))+" itens!";
        _e.aviso_entrega+=" Já estão nas prateleiras. Peça a lista do pedido a Caio.";
        if(missoes_ativa(_jogo))missoes_sincronizar(_jogo);
    }
    return _eventos;
}

/// Relógio logístico da exploração: não depende de virar dias nem da sala atual.
function compras_passo(_j,_dt){
    if(!exploracao_ativa(_j) || simulacao_bloqueio(_j)!="" || historia_introducao_aberta(_j) || historia_decisao_pendente(_j) || historia_quiz_aberto(_j) || maquinas_decisao_aberta(_j))return 0;
    _dt=max(0,_dt);var _e=_j.exploracao,_antes=_e.entregas_motoboy;
    _e.aviso_entrega_segundos=max(0,_e.aviso_entrega_segundos-_dt);_e.saida_motoboy_segundos=max(0,_e.saida_motoboy_segundos-_dt);
    for(var _i=0;_i<array_length(_j.compras);_i++){
        var _c=_j.compras[_i];
        if(_c.status=="em_transito" && variable_struct_exists(_c,"via_motoboy") && _c.via_motoboy)_c.entrega_restante=max(0,_c.entrega_restante-_dt);
    }
    compras_receber(_j,[]);return _e.entregas_motoboy-_antes;
}
function compras_motoboy_restante(_j,_id=""){
    var _menor=1000000;
    for(var _i=0;_i<array_length(_j.compras);_i++){
        var _c=_j.compras[_i];
        if(_c.status=="em_transito" && variable_struct_exists(_c,"via_motoboy") && _c.via_motoboy && (_id=="" || _c.ingrediente_id==_id))_menor=min(_menor,_c.entrega_restante);
    }
    return _menor==1000000?0:_menor;
}
function compras_status_motoboy(_j){
    if(!exploracao_ativa(_j))return "";
    if(_j.exploracao.aviso_entrega_segundos>0)return _j.exploracao.aviso_entrega;
    var _resto=compras_motoboy_restante(_j);
    return _resto>0?"Motoboy a caminho: "+string(ceil(_resto))+" s de jogo. A entrega vai para as prateleiras do Estoque.":"";
}
function compras_motoboy_visual(_j){
    var _resto=compras_motoboy_restante(_j),_saida=_j.exploracao.saida_motoboy_segundos;
    if(_resto<=0 && _saida<=0)return undefined;
    var _progresso=_resto>0?1-clamp(_resto/12,0,1):clamp(_saida/4,0,1);
    return {u:lerp(3.5,12.5,_progresso),v:11.4,restante:ceil(_resto),saindo:_resto<=0};
}
