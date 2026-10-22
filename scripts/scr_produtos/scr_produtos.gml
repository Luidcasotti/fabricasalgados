/// Catalogo didatico. Custos em centavos por porcao, sem precos reais de mercado.
function produtos_catalogo_criar() {
    return {
        ingredientes: [
            { id: "massa", nome: "Massa", unidade: "porcao", custo_centavos: 60, estoque_inicial: 120 },
            { id: "frango", nome: "Frango", unidade: "porcao", custo_centavos: 80, estoque_inicial: 60 },
            { id: "queijo", nome: "Queijo", unidade: "porcao", custo_centavos: 70, estoque_inicial: 100 },
            { id: "oleo", nome: "Oleo", unidade: "porcao", custo_centavos: 20, estoque_inicial: 200 }
        ],
        produtos: [
            { id: "coxinha", nome: "Coxinha", preco_centavos: 600, receita: [
                { ingrediente_id: "massa", quantidade: 1 },
                { ingrediente_id: "frango", quantidade: 1 },
                { ingrediente_id: "oleo", quantidade: 1 }
            ] },
            { id: "pastel", nome: "Pastel", preco_centavos: 500, receita: [
                { ingrediente_id: "massa", quantidade: 1 },
                { ingrediente_id: "queijo", quantidade: 1 },
                { ingrediente_id: "oleo", quantidade: 1 }
            ] },
            { id: "bolinha_queijo", nome: "Bolinha de queijo", preco_centavos: 400, receita: [
                { ingrediente_id: "massa", quantidade: 1 },
                { ingrediente_id: "queijo", quantidade: 2 },
                { ingrediente_id: "oleo", quantidade: 1 }
            ] }
        ]
    };
}

function catalogo_buscar(_itens, _id) {
    for (var _i = 0; _i < array_length(_itens); _i++) {
        if (_itens[_i].id == _id) return _itens[_i];
    }
    return undefined;
}

function produto_obter(_catalogo, _id) {
    return catalogo_buscar(_catalogo.produtos, _id);
}

function ingrediente_obter(_catalogo, _id) {
    return catalogo_buscar(_catalogo.ingredientes, _id);
}
