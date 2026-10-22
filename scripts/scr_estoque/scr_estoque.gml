/// Quantidades inteiras: uma unidade de ingrediente representa uma porcao didatica.
function quantidade_valida(_quantidade) {
    if (!is_real(_quantidade)) return false;
    return _quantidade >= 1 && _quantidade <= 1000000
        && floor(_quantidade) == _quantidade;
}

function estoque_criar(_catalogo) {
    var _materias_primas = [];
    var _produtos = [];
    for (var _i = 0; _i < array_length(_catalogo.ingredientes); _i++) {
        var _ingrediente = _catalogo.ingredientes[_i];
        array_push(_materias_primas, { id: _ingrediente.id, quantidade: _ingrediente.estoque_inicial });
    }
    for (var _p = 0; _p < array_length(_catalogo.produtos); _p++) {
        array_push(_produtos, { id: _catalogo.produtos[_p].id, quantidade: 0 });
    }
    return { materias_primas: _materias_primas, produtos: _produtos };
}

function estoque_quantidade(_itens, _id) {
    var _item = catalogo_buscar(_itens, _id);
    return is_undefined(_item) ? 0 : _item.quantidade;
}

function estoque_ajustar(_itens, _id, _delta) {
    if (!is_real(_delta)) return false;
    if (abs(_delta) > 1000000 || floor(_delta) != _delta) return false;
    var _item = catalogo_buscar(_itens, _id);
    if (is_undefined(_item)) return false;
    var _nova_quantidade = _item.quantidade + _delta;
    if (_nova_quantidade < 0 || _nova_quantidade > 1000000) return false;
    _item.quantidade = _nova_quantidade;
    return true;
}
