/// Planejamento puro: calcular um lote nao consome ingredientes nem produz unidades.
function producao_criar() {
    return { lotes: [], unidades_produzidas: 0 };
}

function producao_planejar(_jogo, _produto_id, _quantidade) {
    var _falha = { ok: false, mensagem: "Produto ou quantidade invalida.", insumos: [], custo_centavos: 0 };
    var _produto = produto_obter(_jogo.catalogo, _produto_id);
    if (is_undefined(_produto) || !quantidade_valida(_quantidade)) return _falha;
    if (_jogo.producao.unidades_produzidas + _quantidade > _jogo.parametros.capacidade_diaria) {
        _falha.mensagem = "Capacidade diaria insuficiente.";
        return _falha;
    }
    var _insumos = [];
    var _custo = 0;
    for (var _i = 0; _i < array_length(_produto.receita); _i++) {
        var _item = _produto.receita[_i];
        var _ingrediente = ingrediente_obter(_jogo.catalogo, _item.ingrediente_id);
        if (is_undefined(_ingrediente) || !quantidade_valida(_item.quantidade)) {
            _falha.mensagem = "Receita invalida no catalogo.";
            return _falha;
        }
        var _necessario = _item.quantidade * _quantidade;
        if (estoque_quantidade(_jogo.estoque.materias_primas, _ingrediente.id) < _necessario) {
            _falha.mensagem = "Estoque insuficiente: " + _ingrediente.nome;
            return _falha;
        }
        array_push(_insumos, { ingrediente_id: _ingrediente.id, quantidade: _necessario });
        _custo += _necessario * _ingrediente.custo_centavos;
    }
    return {
        ok: true, mensagem: "Planejamento valido.", produto_id: _produto_id,
        quantidade: _quantidade, insumos: _insumos, custo_centavos: _custo
    };
}
