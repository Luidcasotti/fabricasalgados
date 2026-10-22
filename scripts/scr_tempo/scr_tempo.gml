/// Cada avanço processa um dia de operação; dia 1 é preparação.
function simulacao_avancar_dia(_jogo) {
    if(exploracao_ativa(_jogo))return exploracao_avancar_dia(_jogo);
    var _bloqueio=simulacao_bloqueio(_jogo);if(_bloqueio!="") return {ok:false,mensagem:_bloqueio};
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
        array_push(_eventos,"4 / PRAZOS E OFERTAS");
        _eventos=pedidos_atualizar_prazos(_jogo,_eventos);
        _jogo.dias_processados++;
        var _fim=_jogo.dias_processados>=_jogo.parametros.duracao_dias;
        var _novos=_fim?0:pedidos_gerar_dia(_jogo);
        array_push(_eventos,_fim?"Período encerrado. Analise o dashboard.":string(_novos)+" novas ofertas. Confira o Comercial.");
        var _resumo={dia:_jogo.dia,eventos:_eventos,saldo_centavos:_jogo.financas.saldo_centavos,
            capacidade_usada:_jogo.producao.capacidade_usada,unidades:_jogo.producao.unidades_dia};
        _jogo.ultimo_resumo=_resumo;array_push(_jogo.historico_dias,_resumo);
        diario_registrar(_jogo,"AVANÇAR DIA","Dia de operação "+string(_jogo.dias_processados)+" de "+string(_jogo.parametros.duracao_dias)+"; produção: "+string(_jogo.producao.unidades_dia)+"; caixa: "+financas_formatar(_jogo.financas.saldo_centavos)+". Eventos detalhados no dashboard.");
        pedagogia_disparar(_jogo,"fim_dia",{});
        if(_fim) {
            _jogo.encerrado=true;
            diario_registrar(_jogo,"FIM DO PERÍODO","Partida encerrada pelo tempo configurado, sem Game Over por resultado. Estoques, compras e pedidos preservados para análise.");
        }
        return {ok:true,mensagem:_fim?"Período concluído. Reveja suas decisões.":"Dia "+string(_jogo.dia)+" processado. Confira o resumo."};
    } finally {_jogo.avancando=false;}
}
