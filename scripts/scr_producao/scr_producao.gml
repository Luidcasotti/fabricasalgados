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
    if(exploracao_ativa(_jogo))return {ok:false,mensagem:"Cozinhe presencialmente na bancada da Produção."};
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
    if(exploracao_ativa(_jogo))return {ok:false,mensagem:"Cozinhe presencialmente na bancada da Produção."};
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

/// Equipamentos persistem no estado da partida, nunca nos objetos das salas.
function maquinas_config(_j){
    var _p=_j.parametros;
    return {total:variable_struct_exists(_p,"maquinas_total")?_p.maquinas_total:3,
        por_hora:variable_struct_exists(_p,"maquina_capacidade_hora")?_p.maquina_capacidade_hora:100,
        segundos_hora:variable_struct_exists(_p,"simulacao_segundos_hora")?_p.simulacao_segundos_hora:180};
}
function maquinas_iniciar(_j){
    if(variable_struct_exists(_j,"maquinas"))return;
    var _c=maquinas_config(_j),_itens=[];
    for(var _i=0;_i<_c.total;_i++)array_push(_itens,{id:_i+1,status:"funcionando",restante:0});
    _j.maquinas={itens:_itens,falhas:0,tempo_manutencao:0,decisao:false,aguardar_tecnico:false,evento_disparado:false,escolhas:[],mensagem:""};
}
function maquinas_funcionando(_j){
    if(!variable_struct_exists(_j,"maquinas"))return maquinas_config(_j).total;
    var _n=0;for(var _i=0;_i<array_length(_j.maquinas.itens);_i++)if(_j.maquinas.itens[_i].status=="funcionando")_n++;return _n;
}
function maquinas_capacidade(_j){return maquinas_funcionando(_j)*maquinas_config(_j).por_hora;}
function maquinas_limite_turno(_j){
    if(!variable_struct_exists(_j,"maquinas"))return _j.parametros.capacidade_diaria;
    // A quebra reduz a cota real do turno, além de reduzir a velocidade da animação.
    return min(_j.parametros.capacidade_diaria,maquinas_capacidade(_j));
}
function maquinas_falhar(_j){
    if(!variable_struct_exists(_j,"maquinas") || _j.encerrado || _j.pausado || _j.parametros.falhas_ativas==0)return false;
    var _m=_j.maquinas;if(_m.evento_disparado)return false;
    for(var _i=0;_i<array_length(_m.itens);_i++){
        var _a=_m.itens[_i];if(_a.status!="funcionando")continue;
        _a.status="parada";_m.falhas++;_m.evento_disparado=true;_m.decisao=true;
        _m.mensagem="Uma máquina apresentou defeito. A capacidade caiu para "+string(maquinas_capacidade(_j))+" salgados/hora.";
        diario_registrar(_j,"ALERTA: MÁQUINA PARADA",_m.mensagem);feedback_som("alerta");return true;
    }
    return false;
}
function maquinas_decidir(_j,_acao){
    var _b=simulacao_bloqueio(_j);if(_b!="")return {ok:false,mensagem:_b};
    if(!variable_struct_exists(_j,"maquinas"))return {ok:false,mensagem:"Nenhuma máquina disponível."};
    var _m=_j.maquinas,_a=undefined,_primeira=_m.decisao;
    for(var _i=0;_i<array_length(_m.itens);_i++)if(_m.itens[_i].status=="parada"){_a=_m.itens[_i];break;}
    if(is_undefined(_a))return {ok:false,mensagem:"Não há máquina parada aguardando decisão."};
    if(_acao=="manutencao" || _acao=="reorganizar"){
        var _custo=_acao=="manutencao"?_j.parametros.manutencao_centavos:0;
        if(_custo>financas_livre(_j))return {ok:false,mensagem:"Caixa insuficiente. Reorganizar usa a equipe e não cobra dinheiro."};
        if(_custo>0 && !financas_registrar(_j.financas,-_custo,"Reparo da máquina #"+string(_a.id),"manutencao",_j.dia,"reparo:"+string(_m.falhas)+":"+string(_a.id)))return {ok:false,mensagem:"Reparo já registrado ou pagamento recusado."};
        _a.status="manutencao";_a.restante=_j.parametros.manutencao_segundos*(_acao=="reorganizar"?2:1);
        _m.aguardar_tecnico=_acao=="manutencao";
        _m.mensagem=_acao=="manutencao"?"Técnico chamado: "+financas_formatar(_custo)+". O lote aguarda "+string(_a.restante)+" s pelo conserto seguro; depois a capacidade é recuperada.":"Equipe reorganizada: reparo gratuito em "+string(_a.restante)+" s. As outras máquinas continuam trabalhando.";
    }else if(_acao=="continuar"){
        if(maquinas_funcionando(_j)==0)return {ok:false,mensagem:"Todas estão paradas. Solicite manutenção ou reorganize a equipe."};
        _m.mensagem="Você usa as máquinas que estão funcionando e continua sem esperar o técnico, a "+string(maquinas_capacidade(_j))+" salgados/hora. A máquina com defeito permanece parada; a capacidade total fica reduzida.";
    }else return {ok:false,mensagem:"Escolha manutenção, continuar ou reorganizar."};
    _m.decisao=false;array_push(_m.escolhas,{acao:_acao,dia:_j.dia,custo_centavos:_acao=="manutencao"?_j.parametros.manutencao_centavos:0});
    if(_primeira)historia_decisao_registrar(_j,"dec_defeito",_acao=="manutencao"?"A. Chamar o técnico":(_acao=="continuar"?"B. Usar outra máquina disponível":"Reorganizar a equipe"),_m.mensagem,"É importante avaliar tempo, segurança e recursos disponíveis.");
    diario_registrar(_j,"DECISÃO DE EQUIPAMENTO",_m.mensagem);return {ok:true,mensagem:_m.mensagem};
}
function maquinas_passo(_j,_dt){
    if(!variable_struct_exists(_j,"maquinas") || _j.pausado || _j.encerrado || historia_decisao_pendente(_j) || historia_quiz_aberto(_j) || feira_resgate_aberto(_j) || confirmacao_aberta(_j))return;
    _dt=max(0,_dt);var _m=_j.maquinas;
    for(var _i=0;_i<array_length(_m.itens);_i++){
        var _a=_m.itens[_i];if(_a.status!="manutencao")continue;
        var _uso=min(_dt,_a.restante);_a.restante=max(0,_a.restante-_uso);_m.tempo_manutencao+=_uso;
        if(_a.restante<=0){_a.status="funcionando";_m.aguardar_tecnico=false;_m.mensagem="Reparo concluído! Capacidade recuperada: "+string(maquinas_capacidade(_j))+" salgados/hora.";diario_registrar(_j,"MANUTENÇÃO CONCLUÍDA",_m.mensagem);}
    }
}
function maquinas_decisao_aberta(_j){return variable_struct_exists(_j,"maquinas") && _j.maquinas.decisao;}
function maquinas_botoes(_j){
    return [{area:ui_area(344,310,872,56),texto:"A. Chamar o técnico / "+financas_formatar(_j.parametros.manutencao_centavos)+" / "+string(_j.parametros.manutencao_segundos)+" s",acao:"maquina_manutencao"},
        {area:ui_area(344,380,872,56),texto:maquinas_funcionando(_j)>0?"B. Usar outra máquina disponível":"B. Sem outra máquina disponível / solicite reparo",acao:"maquina_continuar"},
        {area:ui_area(344,450,872,56),texto:"C. Reorganizar a equipe / grátis / "+string(_j.parametros.manutencao_segundos*2)+" s",acao:"maquina_reorganizar"}];
}
function maquinas_desenhar(_c){
    var _j=global.jogo,_v=global.visual;if(!variable_struct_exists(_j,"maquinas"))return;
    var _m=_j.maquinas,_cfg=maquinas_config(_j),_n=maquinas_funcionando(_j);
    if(maquinas_decisao_aberta(_j)){
        ui_cartao(320,110,920,494,_v.claro);
        ui_texto(344,174,"DECISÃO 1 / COMO RESOLVER O DEFEITO?",2,_v.ciano);
        ui_paragrafo(344,224,"Uma máquina parou. Avalie o tempo, a segurança e os recursos disponíveis.",840,_v.tinta);
        ui_texto(344,554,"Escolha uma alternativa. A consequência aparece depois da escolha.",1,_v.suave);
        ui_texto(344,578,"RELÓGIO E PREPARO PAUSADOS ENQUANTO VOCÊ ESCOLHE",1,_v.ciano);return;
    }
    if(_c.mundo.setor!="producao" || !is_undefined(_c.painel) || historia_modal(_c) || _c.ajuda)return;
    ui_cartao(990,294,264,80,_v.claro);
    ui_texto(1004,308,"Máquinas: "+string(_n)+" / "+string(_cfg.total),2,_v.ciano);
    ui_texto(1004,346,string(maquinas_capacidade(_j))+" salgados por hora",1,_n<_cfg.total?_v.ouro:_v.verde);
}
