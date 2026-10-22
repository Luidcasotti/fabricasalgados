function pedidos_contar_status(_pedidos,_status) {
    var _n=0;for(var _i=0;_i<array_length(_pedidos);_i++) if(_pedidos[_i].status==_status) _n++;return _n;
}
function pedidos_gerar_dia(_jogo) {
    if(_jogo.ultimo_dia_gerado>=_jogo.dia) return 0;
    var _criados=0,_p=_jogo.parametros;
    for(var _i=0;_i<array_length(_jogo.catalogo.produtos);_i++) {
        var _produto=_jogo.catalogo.produtos[_i];var _chave=string(_jogo.dia)+":"+_produto.id;
        var _existe=false;
        for(var _k=0;_k<array_length(_jogo.pedidos);_k++) if(_jogo.pedidos[_k].chave==_chave) _existe=true;
        if(_existe) continue;
        var _qtd=_p.pedido_quantidade_min+((_jogo.dia-1)*7+_i*5) mod (_p.pedido_quantidade_max-_p.pedido_quantidade_min+1);
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
    var _p=catalogo_buscar(_jogo.pedidos,_id);
    if(is_undefined(_p) || _p.status!="ofertado") return {ok:false,mensagem:"Oferta já decidida ou inexistente."};
    if(_jogo.dia>_p.aceitar_ate_dia) return {ok:false,mensagem:"Oferta fora do prazo de aceite."};
    _p.status=_aceitar ? "aceito" : "recusado";
    if(_aceitar) {_p.dia_aceite=_jogo.dia;_p.sequencia_aceite=_jogo.proximo_aceite_id++;}
    return {ok:true,mensagem:_aceitar ? "Pedido aceito. Entrega ao avançar o dia." : "Pedido recusado e mantido no histórico."};
}
function pedidos_fila(_jogo) {
    var _fila=[];
    for(var _i=0;_i<array_length(_jogo.pedidos);_i++) if(_jogo.pedidos[_i].status=="aceito") array_push(_fila,_jogo.pedidos[_i]);
    array_sort(_fila,function(_a,_b){return _a.sequencia_aceite-_b.sequencia_aceite;});
    return _fila;
}
function pedido_entregar(_jogo,_pedido) {
    if(_pedido.status!="aceito") return {ok:false,mensagem:"Pedido não está na fila."};
    if(estoque_quantidade(_jogo.estoque.produtos,_pedido.produto_id)<_pedido.quantidade)
        return {ok:false,mensagem:"Pedido #"+string(_pedido.id)+": sem produtos; permanece na fila."};
    if(!financas_registrar(_jogo.financas,_pedido.total_centavos,"Entrega #"+string(_pedido.id),
        "entrega",_jogo.dia,"pedido:"+string(_pedido.id))) return {ok:false,mensagem:"Recebimento recusado; pedido mantido."};
    estoque_ajustar(_jogo.estoque.produtos,_pedido.produto_id,-_pedido.quantidade);
    _pedido.status="entregue";_pedido.dia_entrega=_jogo.dia;
    _pedido.atraso_dias=max(0,_jogo.dia-_pedido.prazo_dia);_pedido.pontual=_pedido.atraso_dias==0;
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
