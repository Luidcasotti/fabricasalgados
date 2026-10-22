function financas_criar(_inicial) {
    return {saldo_inicial_centavos:_inicial,saldo_centavos:_inicial,
        entradas_centavos:0,saidas_centavos:0,receitas_centavos:0,
        compras_centavos:0,variaveis_centavos:0,movimentos:[]};
}
function financas_registrar(_financas,_valor,_descricao,_tipo="outros",_dia=0,_referencia="") {
    if(!is_real(_valor) || floor(_valor)!=_valor || _valor==0 || abs(_valor)>1000000000) return false;
    if(_financas.saldo_centavos+_valor<0) return false;
    // Identidade por operação, não pelo dia: execuções repetidas não cobram duas vezes.
    if(_referencia!="") for(var _i=0;_i<array_length(_financas.movimentos);_i++)
        if(_financas.movimentos[_i].referencia==_referencia) return false;
    _financas.saldo_centavos+=_valor;
    if(_valor>0) _financas.entradas_centavos+=_valor; else _financas.saidas_centavos-=_valor;
    if(_tipo=="entrega") _financas.receitas_centavos+=_valor;
    if(_tipo=="compra") _financas.compras_centavos-=_valor;
    if(_tipo=="variavel") _financas.variaveis_centavos-=_valor;
    array_push(_financas.movimentos,{dia:_dia,tipo:_tipo,referencia:_referencia,valor_centavos:_valor,descricao:_descricao});
    return true;
}
function financas_livre(_jogo) {return _jogo.financas.saldo_centavos-producao_reserva_caixa(_jogo);}
function financas_formatar(_centavos) {
    return "R$ "+string_replace_all(string_format(_centavos/100,0,2),".",",");
}
