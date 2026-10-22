enum FaseJogo {MENU, PARAMETROS, FABRICA, RESULTADOS}
function parametros_padrao() {
    return {caixa_inicial_centavos:100000,capacidade_diaria:100,
        pedido_quantidade_min:5,pedido_quantidade_max:15,prazo_pedido_dias:2,
        oferta_validade_dias:1,catalogo:produtos_catalogo_criar()};
}
function jogo_criar(_parametros=undefined) {
    if(is_undefined(_parametros)) _parametros=parametros_padrao();
    var _validacao=parametros_validar(_parametros);
    if(!_validacao.ok) throw "Parâmetros inválidos: "+_validacao.mensagem;
    var _p=json_parse(json_stringify(_parametros));
    var _j={fase:FaseJogo.MENU,dia:1,parametros:_p,catalogo:_p.catalogo,
        estoque:estoque_criar(_p.catalogo),compras:[],proximo_compra_id:1,
        pedidos:[],proximo_pedido_id:1,proximo_aceite_id:1,ultimo_dia_gerado:0,
        producao:producao_criar(),financas:financas_criar(_p.caixa_inicial_centavos),
        avancando:false,historico_dias:[],ultimo_resumo:{dia:1,eventos:["Planeje e avance o dia para executar as ações."]}};
    pedidos_gerar_dia(_j);
    return _j;
}
function jogo_novo() {global.jogo=jogo_criar();}
function jogo_ir_para(_fase) {
    var _destino;
    switch(_fase) {
        case FaseJogo.MENU:_destino=rm_menu;break;
        case FaseJogo.PARAMETROS:_destino=rm_parametros;break;
        case FaseJogo.FABRICA:_destino=rm_fabrica;break;
        case FaseJogo.RESULTADOS:_destino=rm_resultados;break;
        default:return false;
    }
    global.jogo.fase=_fase;room_goto(_destino);return true;
}
