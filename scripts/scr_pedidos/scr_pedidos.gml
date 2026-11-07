function pedidos_contar_status(_pedidos,_status) {
    var _n=0;for(var _i=0;_i<array_length(_pedidos);_i++) if(_pedidos[_i].status==_status) _n++;return _n;
}
function pedidos_gerar_dia(_jogo) {
    if(_jogo.encerrado || missoes_ativa(_jogo)) return 0;
    if(_jogo.ultimo_dia_gerado>=_jogo.dia) return 0;
    var _criados=0,_p=_jogo.parametros;
    for(var _i=0;_i<array_length(_jogo.catalogo.produtos);_i++) {
        var _produto=_jogo.catalogo.produtos[_i];var _chave=string(_jogo.dia)+":"+_produto.id;
        var _existe=false;
        for(var _k=0;_k<array_length(_jogo.pedidos);_k++) if(_jogo.pedidos[_k].chave==_chave) _existe=true;
        if(_existe) continue;
        var _qtd=_p.pedido_quantidade_min+((_jogo.dia-1)*7+_i*5) mod (_p.pedido_quantidade_max-_p.pedido_quantidade_min+1);
        if(variable_struct_exists(_p,"pedidos_variados") && _p.pedidos_variados==1)_qtd=pedidos_quantidade_variada(_jogo);
        array_push(_jogo.pedidos,{id:_jogo.proximo_pedido_id++,chave:_chave,produto_id:_produto.id,
            quantidade:_qtd,preco_unitario_centavos:_produto.preco_centavos,total_centavos:_qtd*_produto.preco_centavos,
            dia_geracao:_jogo.dia,prazo_dia:_jogo.dia+_p.prazo_pedido_dias,
            aceitar_ate_dia:_jogo.dia+min(_p.oferta_validade_dias,_p.prazo_pedido_dias),
            status:"ofertado",sequencia_aceite:0,dia_aceite:0,dia_entrega:0,atraso_dias:0,pontual:false});
        _criados++;
    }
    _jogo.ultimo_dia_gerado=_jogo.dia;return _criados;
}
function pedido_decidir(_jogo,_id,_aceitar) {
    var _missao=missoes_permitir(_jogo,(_aceitar?"aceitar":"recusar"),_id,0);if(!_missao.ok)return _missao;
    if(exploracao_ativa(_jogo) && !mundo_perto(_jogo,"vendas"))return {ok:false,mensagem:"Aproxime-se do local de vendas e pressione E."};
    var _bloqueio=simulacao_bloqueio(_jogo);if(_bloqueio!="") return {ok:false,mensagem:_bloqueio};
    var _p=catalogo_buscar(_jogo.pedidos,_id);
    if(is_undefined(_p) || _p.status!="ofertado") return {ok:false,mensagem:"Oferta já decidida ou inexistente."};
    if(_jogo.dia>_p.aceitar_ate_dia) return {ok:false,mensagem:"Oferta fora do prazo de aceite."};
    _p.status=_aceitar ? "aceito" : "recusado";
    if(_aceitar) {_p.dia_aceite=_jogo.dia;_p.sequencia_aceite=_jogo.proximo_aceite_id++;}
    diario_registrar(_jogo,(_aceitar?"ACEITAR":"RECUSAR")+" PEDIDO #"+string(_id),string(_p.quantidade)+" "+produto_obter(_jogo.catalogo,_p.produto_id).nome+"; valor "+financas_formatar(_p.total_centavos)+"; prazo dia "+string(_p.prazo_dia)+(_aceitar?". Entrou na fila.":". Não entrou na fila; registro preservado."));
    if(_aceitar) pedagogia_disparar(_jogo,"aceite",{pedido:_p});
    missoes_evento(_jogo,"decisao",{id:_id,aceitar:_aceitar});
    if(_aceitar && missoes_ativa(_jogo))return {ok:true,mensagem:"Pedido aceito! Canhoto à esquerda. Peça os ingredientes a Caio no Estoque."};
    return {ok:true,mensagem:_aceitar ? (exploracao_ativa(_jogo)?"Pedido aceito. Produza e entregue no balcão do Comercial.":"Pedido aceito. Entrega ao avançar o dia.") : "Pedido recusado e mantido no histórico."};
}
function pedidos_fila(_jogo) {
    var _fila=[];
    for(var _i=0;_i<array_length(_jogo.pedidos);_i++) if(_jogo.pedidos[_i].status=="aceito") array_push(_fila,_jogo.pedidos[_i]);
    array_sort(_fila,function(_a,_b){return _a.sequencia_aceite-_b.sequencia_aceite;});
    return _fila;
}
function pedido_entregar(_jogo,_pedido) {
    if(feira_ativa(_jogo) && (_jogo.feira.concluida || _jogo.feira.segundos>=_jogo.feira.limite_segundos))return {ok:false,mensagem:"O tempo deste dia acabou. Aguarde o próximo colega."};
    var _missao=missoes_permitir(_jogo,"entregar",_pedido.id,0);if(!_missao.ok)return _missao;
    if(exploracao_ativa(_jogo) && !mundo_perto(_jogo,"entrega"))return {ok:false,mensagem:"Aproxime-se do local de entrega e pressione E."};
    var _bloqueio=simulacao_bloqueio(_jogo);if(_bloqueio!="") return {ok:false,mensagem:_bloqueio};
    if(_pedido.status!="aceito") return {ok:false,mensagem:"Pedido não está na fila."};
    if(estoque_quantidade(_jogo.estoque.produtos,_pedido.produto_id)<_pedido.quantidade)
        return {ok:false,mensagem:"Pedido #"+string(_pedido.id)+": sem produtos; permanece na fila."};
    if(!financas_registrar(_jogo.financas,_pedido.total_centavos,"Entrega #"+string(_pedido.id),
        "entrega",_jogo.dia,"pedido:"+string(_pedido.id))) return {ok:false,mensagem:"Recebimento recusado; pedido mantido."};
    estoque_ajustar(_jogo.estoque.produtos,_pedido.produto_id,-_pedido.quantidade);
    _pedido.status="entregue";_pedido.dia_entrega=_jogo.dia;
    _pedido.atraso_dias=max(0,_jogo.dia-_pedido.prazo_dia);_pedido.pontual=_pedido.atraso_dias==0;
    diario_registrar(_jogo,"ENTREGAR PEDIDO #"+string(_pedido.id),"Receita "+financas_formatar(_pedido.total_centavos)+"; baixa de "+string(_pedido.quantidade)+" produtos; atraso de "+string(_pedido.atraso_dias)+" dia(s).");
    pedagogia_disparar(_jogo,"entrega",{pedido:_pedido});
    missoes_evento(_jogo,"entrega",{id:_pedido.id});
    if(missoes_ativa(_jogo))return {ok:true,mensagem:missoes_zerou(_jogo)?"Parabéns! Você entregou os 5 pedidos e zerou o jogo! Confirme para ver o resultado final.":"Entrega concluída! "+string(array_length(_jogo.missoes.entregues))+" de "+string(_jogo.missoes.meta)+" pedidos entregues. O próximo já está disponível com Marta no Comercial. Confirme e aceite a próxima missão."};
    return {ok:true,mensagem:"Pedido #"+string(_pedido.id)+" entregue "+(_pedido.pontual ? "no prazo." : "com "+string(_pedido.atraso_dias)+" dia(s) de atraso.")};
}
function pedidos_entregar_fila(_jogo,_eventos) {
    var _fila=pedidos_fila(_jogo);
    for(var _i=0;_i<array_length(_fila);_i++) array_push(_eventos,pedido_entregar(_jogo,_fila[_i]).mensagem);
    return _eventos;
}
function pedidos_atualizar_prazos(_jogo,_eventos) {
    for(var _i=0;_i<array_length(_jogo.pedidos);_i++) {
        var _p=_jogo.pedidos[_i];
        if(_p.status=="ofertado" && _jogo.dia>_p.aceitar_ate_dia) {
            _p.status="expirado";array_push(_eventos,"Oferta #"+string(_p.id)+" expirou sem aceite.");
        }
        if(_p.status=="aceito") {
            _p.atraso_dias=max(0,_jogo.dia-_p.prazo_dia);
            if(_p.atraso_dias>0) array_push(_eventos,"Pedido #"+string(_p.id)+": "+string(_p.atraso_dias)+" dia(s) atrasado; mantido.");
        }
    }
    return _eventos;
}

/// Bolsa de quantidades: usa todas as opções antes de repetir e evita vizinhos iguais.
function pedidos_quantidade_variada(_j,_preferida=0){
    if(!variable_struct_exists(_j,"variacao_pedidos"))_j.variacao_pedidos={ultima:0,bolsa:[]};
    var _v=_j.variacao_pedidos;
    if(array_length(_v.bolsa)==0){
        var _op=[20,30,40,50];
        for(var _i=0;_i<4;_i++)if(_op[_i]>=_j.parametros.pedido_quantidade_min && _op[_i]<=_j.parametros.pedido_quantidade_max)array_push(_v.bolsa,_op[_i]);
        if(array_length(_v.bolsa)==0){_v.ultima=_j.parametros.pedido_quantidade_min;return _v.ultima;}
        array_shuffle(_v.bolsa);
    }
    var _idx=0;
    for(var _i=0;_i<array_length(_v.bolsa);_i++)if((_preferida>0 && _v.bolsa[_i]==_preferida) || (_preferida==0 && _v.bolsa[_i]!=_v.ultima)){_idx=_i;break;}
    var _q=_v.bolsa[_idx];array_delete(_v.bolsa,_idx,1);_v.ultima=_q;return _q;
}
/// Avaliação não reserva nem movimenta materiais. Aceitar um risco continua sendo uma decisão.
function pedido_diagnostico(_j,_p){
    var _prod=produto_obter(_j.catalogo,_p.produto_id),_faltas=[];
    var _cap=_p.quantidade*_prod.capacidade_unidade,_comprometida=0;
    var _fila=pedidos_fila(_j);
    for(var _i=0;_i<array_length(_fila);_i++){
        var _ab=_fila[_i];if(_ab.id!=_p.id)_comprometida+=_ab.quantidade*produto_obter(_j.catalogo,_ab.produto_id).capacidade_unidade;
    }
    for(var _i=0;_i<array_length(_prod.receita);_i++){
        var _r=_prod.receita[_i],_reservado=0;
        for(var _k=0;_k<array_length(_fila);_k++){
            var _ab=_fila[_k];if(_ab.id==_p.id)continue;
            var _rec=produto_obter(_j.catalogo,_ab.produto_id).receita;
            for(var _n=0;_n<array_length(_rec);_n++)if(_rec[_n].ingrediente_id==_r.ingrediente_id)_reservado+=_rec[_n].quantidade*_ab.quantidade;
        }
        if(_r.quantidade*_p.quantidade>exploracao_total_insumo(_j,_r.ingrediente_id)-_reservado)array_push(_faltas,ingrediente_obter(_j.catalogo,_r.ingrediente_id).nome);
    }
    var _disp=maquinas_limite_turno(_j)-_j.producao.capacidade_usada-_comprometida;
    var _seg=_cap*maquinas_config(_j).segundos_hora/max(1,maquinas_capacidade(_j));
    var _tempo=feira_ativa(_j)?max(0,_j.feira.limite_segundos-_j.feira.segundos):(_p.prazo_dia-_j.dia+1)*maquinas_config(_j).segundos_hora;
    var _ok=array_length(_faltas)==0 && _cap<=_disp && _seg<=_tempo;
    return {ok:_ok,segundos:_seg,mensagem:array_length(_faltas)>0?"Faltam ingredientes na empresa. Planeje a reposição.":(_cap>_disp?"Pedido acima da capacidade livre. Reorganize ou recuse.":(_seg>_tempo?"Tempo insuficiente para o preparo. Considere recusar.":"Ingredientes e capacidade suficientes. Reserve tempo para buscar e entregar."))};
}
