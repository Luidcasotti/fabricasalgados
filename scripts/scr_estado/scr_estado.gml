/// Estado e transicoes da sessao. Nenhuma inicializacao ocorre ao carregar o script.
enum FaseJogo { MENU, PARAMETROS, FABRICA, RESULTADOS }

function parametros_padrao() {
    return { caixa_inicial_centavos: 100000, capacidade_diaria: 100 };
}

function jogo_criar() {
    var _parametros = parametros_padrao();
    var _catalogo = produtos_catalogo_criar();
    return {
        fase: FaseJogo.MENU,
        dia: 1,
        parametros: _parametros,
        catalogo: _catalogo,
        estoque: estoque_criar(_catalogo),
        pedidos: [],
        proximo_pedido_id: 1,
        producao: producao_criar(),
        financas: financas_criar(_parametros.caixa_inicial_centavos)
    };
}

function jogo_novo() {
    global.jogo = jogo_criar();
}

function jogo_ir_para(_fase) {
    var _destino;
    switch (_fase) {
        case FaseJogo.MENU:       _destino = rm_menu; break;
        case FaseJogo.PARAMETROS: _destino = rm_parametros; break;
        case FaseJogo.FABRICA:    _destino = rm_fabrica; break;
        case FaseJogo.RESULTADOS: _destino = rm_resultados; break;
        default: return false;
    }
    global.jogo.fase = _fase;
    room_goto(_destino);
    return true;
}
