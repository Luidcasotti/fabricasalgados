function indicadores_calcular(_jogo) {
    var _prontos=0,_pontuais=0,_atrasadas=0,_abertos_atrasados=0;
    for(var _i=0;_i<array_length(_jogo.estoque.produtos);_i++) _prontos+=_jogo.estoque.produtos[_i].quantidade;
    for(var _i=0;_i<array_length(_jogo.pedidos);_i++) {
        var _p=_jogo.pedidos[_i];
        if(_p.status=="entregue") {if(_p.pontual) _pontuais++;else _atrasadas++;}
        if(_p.status=="aceito" && _jogo.dia>_p.prazo_dia) _abertos_atrasados++;
    }
    var _f=_jogo.financas;
    return {dia:_jogo.dia,pedidos_total:array_length(_jogo.pedidos),
        pedidos_pendentes:pedidos_contar_status(_jogo.pedidos,"aceito"),
        pedidos_atendidos:_pontuais+_atrasadas,entregas_pontuais:_pontuais,entregas_atrasadas:_atrasadas,
        abertos_atrasados:_abertos_atrasados,unidades_em_estoque:_prontos,
        unidades_produzidas:_jogo.producao.unidades_produzidas,unidades_dia:_jogo.producao.unidades_dia,
        receitas_centavos:_f.receitas_centavos,compras_centavos:_f.compras_centavos,variaveis_centavos:_f.variaveis_centavos,
        resultado_caixa_centavos:_f.receitas_centavos-_f.compras_centavos-_f.variaveis_centavos,
        variacao_caixa_centavos:_f.entradas_centavos-_f.saidas_centavos,saldo_centavos:_f.saldo_centavos};
}
