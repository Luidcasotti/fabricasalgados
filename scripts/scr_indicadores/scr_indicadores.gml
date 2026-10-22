/// Consulta pura. Nao salva totais derivados no estado da sessao.
function indicadores_calcular(_jogo) {
    var _unidades_em_estoque = 0;
    for (var _i = 0; _i < array_length(_jogo.estoque.produtos); _i++) {
        _unidades_em_estoque += _jogo.estoque.produtos[_i].quantidade;
    }
    return {
        dia: _jogo.dia,
        pedidos_total: array_length(_jogo.pedidos),
        pedidos_pendentes: pedidos_contar_status(_jogo.pedidos, "pendente"),
        pedidos_atendidos: pedidos_contar_status(_jogo.pedidos, "atendido"),
        unidades_produzidas: _jogo.producao.unidades_produzidas,
        unidades_em_estoque: _unidades_em_estoque,
        entradas_centavos: _jogo.financas.entradas_centavos,
        saidas_centavos: _jogo.financas.saidas_centavos,
        variacao_caixa_centavos: _jogo.financas.entradas_centavos - _jogo.financas.saidas_centavos,
        saldo_centavos: _jogo.financas.saldo_centavos
    };
}
