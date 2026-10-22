/// Base de pedidos de um produto. Criar pedido nao movimenta estoque nem caixa.
function pedido_adicionar(_jogo, _produto_id, _quantidade) {
    var _produto = produto_obter(_jogo.catalogo, _produto_id);
    if (is_undefined(_produto) || !quantidade_valida(_quantidade)) {
        return { ok: false, mensagem: "Produto ou quantidade invalida.", pedido: undefined };
    }
    var _pedido = {
        id: _jogo.proximo_pedido_id,
        dia: _jogo.dia,
        status: "pendente",
        produto_id: _produto_id,
        quantidade: _quantidade,
        preco_unitario_centavos: _produto.preco_centavos,
        total_centavos: _produto.preco_centavos * _quantidade
    };
    array_push(_jogo.pedidos, _pedido);
    _jogo.proximo_pedido_id += 1;
    return { ok: true, mensagem: "Pedido registrado.", pedido: _pedido };
}

function pedidos_contar_status(_pedidos, _status) {
    var _total = 0;
    for (var _i = 0; _i < array_length(_pedidos); _i++) {
        if (_pedidos[_i].status == _status) _total += 1;
    }
    return _total;
}
