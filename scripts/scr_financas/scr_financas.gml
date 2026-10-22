/// Caixa inicial e movimentos sao separados: capital inicial nao e receita de venda.
function financas_criar(_caixa_inicial_centavos) {
    return {
        saldo_inicial_centavos: _caixa_inicial_centavos,
        saldo_centavos: _caixa_inicial_centavos,
        entradas_centavos: 0, saidas_centavos: 0, movimentos: []
    };
}

function financas_registrar(_financas, _valor_centavos, _descricao) {
    if (!is_real(_valor_centavos)) return false;
    if (_valor_centavos == 0 || abs(_valor_centavos) > 100000000
        || floor(_valor_centavos) != _valor_centavos) return false;
    if (_financas.saldo_centavos + _valor_centavos < 0) return false;
    _financas.saldo_centavos += _valor_centavos;
    if (_valor_centavos > 0) _financas.entradas_centavos += _valor_centavos;
    else _financas.saidas_centavos -= _valor_centavos;
    array_push(_financas.movimentos, { valor_centavos: _valor_centavos, descricao: _descricao });
    return true;
}

function financas_formatar(_centavos) {
    return "R$ " + string_replace_all(string_format(_centavos / 100, 0, 2), ".", ",");
}
