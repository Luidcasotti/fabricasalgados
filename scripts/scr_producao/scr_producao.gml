function producao_criar() {return {planos:[],lotes:[],proximo_id:1,capacidade_usada:0,unidades_dia:0,unidades_produzidas:0};}
function producao_reserva_caixa(_jogo) {
    var _total=0;
    for(var _i=0;_i<array_length(_jogo.producao.planos);_i++)
        if(_jogo.producao.planos[_i].status=="planejado") _total+=_jogo.producao.planos[_i].variavel_centavos;
    return _total;
}
function producao_reserva_capacidade(_jogo) {
    var _total=0;
    for(var _i=0;_i<array_length(_jogo.producao.planos);_i++)
        if(_jogo.producao.planos[_i].status=="planejado") _total+=_jogo.producao.planos[_i].capacidade;
    return _total;
}
function producao_reserva_ingrediente(_jogo,_id) {
    var _total=0;
    for(var _i=0;_i<array_length(_jogo.producao.planos);_i++) {
        var _plano=_jogo.producao.planos[_i];if(_plano.status!="planejado") continue;
        for(var _k=0;_k<array_length(_plano.insumos);_k++)
            if(_plano.insumos[_k].ingrediente_id==_id) _total+=_plano.insumos[_k].quantidade;
    }
    return _total;
}
function producao_planejar(_jogo,_id,_quantidade) {
    var _p=produto_obter(_jogo.catalogo,_id);
    var _falha={ok:false,mensagem:"Produto ou quantidade inválida."};
    if(is_undefined(_p) || !quantidade_valida(_quantidade)) return _falha;
    var _cap=_p.capacidade_unidade*_quantidade;
    if(_cap+producao_reserva_capacidade(_jogo)>_jogo.parametros.capacidade_diaria)
        return {ok:false,mensagem:"Capacidade do próximo dia insuficiente."};
    var _insumos=[],_custo=0;
    for(var _i=0;_i<array_length(_p.receita);_i++) {
        var _r=_p.receita[_i];var _qtd=_r.quantidade*_quantidade;
        if(_qtd==0) continue;
        var _item=ingrediente_obter(_jogo.catalogo,_r.ingrediente_id);
        if(is_undefined(_item) || !quantidade_valida(_qtd)) return _falha;
        var _livre=estoque_quantidade(_jogo.estoque.materias_primas,_item.id)-producao_reserva_ingrediente(_jogo,_item.id);
        if(_qtd>_livre) return {ok:false,mensagem:"Ingrediente livre insuficiente: "+_item.nome+"."};
        array_push(_insumos,{ingrediente_id:_item.id,quantidade:_qtd});_custo+=_qtd*_item.custo_centavos;
    }
    var _variavel=_quantidade*_p.custo_variavel_centavos;
    if(_variavel>financas_livre(_jogo)) return {ok:false,mensagem:"Dinheiro livre insuficiente para o custo variável."};
    var _prontos=estoque_quantidade(_jogo.estoque.produtos,_id);
    for(var _i=0;_i<array_length(_jogo.producao.planos);_i++) {
        var _pl=_jogo.producao.planos[_i];
        if(_pl.status=="planejado" && _pl.produto_id==_id) _prontos+=_pl.quantidade;
    }
    if(_prontos+_quantidade>1000000) return {ok:false,mensagem:"Limite de produtos acabados excedido."};
    return {ok:true,mensagem:"Plano válido.",produto_id:_id,quantidade:_quantidade,
        insumos:_insumos,custo_ingredientes_centavos:_custo,variavel_centavos:_variavel,capacidade:_cap};
}
function producao_agendar(_jogo,_id,_quantidade) {
    var _bloqueio=simulacao_bloqueio(_jogo);if(_bloqueio!="") return {ok:false,mensagem:_bloqueio};
    var _plano=producao_planejar(_jogo,_id,_quantidade);
    if(!_plano.ok) return _plano;
    _plano.id=_jogo.producao.proximo_id++;_plano.status="planejado";
    _plano.dia_planejado=_jogo.dia;_plano.dia_execucao=_jogo.dia+1;
    array_push(_jogo.producao.planos,_plano);
    diario_registrar(_jogo,"PLANEJAR "+produto_obter(_jogo.catalogo,_id).nome,string(_quantidade)+" unidade(s); reservados "+string(_plano.capacidade)+" pontos e "+financas_formatar(_plano.variavel_centavos)+" de custo variável para o dia "+string(_plano.dia_execucao)+".");
    pedagogia_disparar(_jogo,"plano",{plano:_plano});
    return {ok:true,mensagem:"Lote reservado para o próximo dia."};
}
function producao_cancelar(_jogo,_id) {
    var _bloqueio=simulacao_bloqueio(_jogo);if(_bloqueio!="") return {ok:false,mensagem:_bloqueio};
    var _plano=catalogo_buscar(_jogo.producao.planos,_id);
    if(is_undefined(_plano) || _plano.status!="planejado") return {ok:false,mensagem:"Plano não pode ser cancelado."};
    _plano.status="cancelado";
    diario_registrar(_jogo,"CANCELAR PLANO #"+string(_id),"Reservas liberadas, sem consumo ou pagamento. O plano continua no histórico.");
    return {ok:true,mensagem:"Plano cancelado; reservas liberadas."};
}
function producao_executar_lote(_jogo,_plano) {
    var _bloqueio=simulacao_bloqueio(_jogo);if(_bloqueio!="") return {ok:false,mensagem:_bloqueio};
    if(_plano.status!="planejado" || _plano.dia_execucao>_jogo.dia) return {ok:false,mensagem:"Lote não está previsto para hoje."};
    if(_jogo.producao.capacidade_usada+_plano.capacidade>_jogo.parametros.capacidade_diaria)
        return {ok:false,mensagem:"Faltou capacidade; plano mantido."};
    if(estoque_quantidade(_jogo.estoque.produtos,_plano.produto_id)+_plano.quantidade>1000000)
        return {ok:false,mensagem:"Estoque de produtos cheio; plano mantido."};
    for(var _i=0;_i<array_length(_plano.insumos);_i++) {
        var _r=_plano.insumos[_i];
        if(estoque_quantidade(_jogo.estoque.materias_primas,_r.ingrediente_id)<_r.quantidade)
            return {ok:false,mensagem:"Faltou ingrediente; plano mantido."};
    }
    if(_plano.variavel_centavos>0 && !financas_registrar(_jogo.financas,-_plano.variavel_centavos,
        "Custo variável do lote #"+string(_plano.id),"variavel",_jogo.dia,"lote:"+string(_plano.id)))
        return {ok:false,mensagem:"Custo variável recusado; plano mantido."};
    for(var _i=0;_i<array_length(_plano.insumos);_i++) {
        var _r=_plano.insumos[_i];estoque_ajustar(_jogo.estoque.materias_primas,_r.ingrediente_id,-_r.quantidade);
    }
    estoque_ajustar(_jogo.estoque.produtos,_plano.produto_id,_plano.quantidade);
    _plano.status="produzido";_plano.produzido_dia=_jogo.dia;
    _jogo.producao.capacidade_usada+=_plano.capacidade;
    _jogo.producao.unidades_dia+=_plano.quantidade;
    _jogo.producao.unidades_produzidas+=_plano.quantidade;
    array_push(_jogo.producao.lotes,{id:_plano.id,dia:_jogo.dia,produto_id:_plano.produto_id,
        quantidade:_plano.quantidade,capacidade:_plano.capacidade,insumos:_plano.insumos,
        custo_ingredientes_centavos:_plano.custo_ingredientes_centavos,variavel_centavos:_plano.variavel_centavos});
    return {ok:true,mensagem:"Lote #"+string(_plano.id)+": "+string(_plano.quantidade)+" "+produto_obter(_jogo.catalogo,_plano.produto_id).nome+" produzidos."};
}
function producao_processar(_jogo,_eventos) {
    if(simulacao_bloqueio(_jogo)!="") return _eventos;
    _jogo.producao.capacidade_usada=0;_jogo.producao.unidades_dia=0;
    for(var _i=0;_i<array_length(_jogo.producao.planos);_i++) {
        var _pl=_jogo.producao.planos[_i];
        if(_pl.status=="planejado" && _pl.dia_execucao<=_jogo.dia)
            array_push(_eventos,producao_executar_lote(_jogo,_pl).mensagem);
    }
    return _eventos;
}
