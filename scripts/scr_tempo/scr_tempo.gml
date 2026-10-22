/// Única entrada do processamento diário. Um botão pressionado dispara uma transição.
function simulacao_avancar_dia(_jogo) {
    if(_jogo.avancando) return {ok:false,mensagem:"Dia já está em processamento."};
    _jogo.avancando=true;
    try {
        _jogo.dia++;
        var _eventos=["Dia "+string(_jogo.dia)+" iniciado. Valores fictícios.","1 / CHEGADA DAS COMPRAS"];
        _eventos=compras_receber(_jogo,_eventos);
        array_push(_eventos,"2 / EXECUÇÃO DA PRODUÇÃO PLANEJADA");
        _eventos=producao_processar(_jogo,_eventos);
        array_push(_eventos,"3 / ENTREGAS DOS PEDIDOS ACEITOS");
        _eventos=pedidos_entregar_fila(_jogo,_eventos);
        array_push(_eventos,"4 / PRAZOS E NOVAS OFERTAS");
        _eventos=pedidos_atualizar_prazos(_jogo,_eventos);
        var _novos=pedidos_gerar_dia(_jogo);
        array_push(_eventos,string(_novos)+" novas ofertas. Confira o Comercial.");
        var _resumo={dia:_jogo.dia,eventos:_eventos,saldo_centavos:_jogo.financas.saldo_centavos,
            capacidade_usada:_jogo.producao.capacidade_usada};
        _jogo.ultimo_resumo=_resumo;array_push(_jogo.historico_dias,_resumo);
        return {ok:true,mensagem:"Dia "+string(_jogo.dia)+" processado. Confira o resumo."};
    } finally {_jogo.avancando=false;}
}
