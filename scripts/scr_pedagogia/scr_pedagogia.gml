/// Diário usa a data da simulação, não o relógio do computador.
function diario_registrar(_jogo,_acao,_consequencia) {
    array_push(_jogo.diario,{id:array_length(_jogo.diario)+1,dia:_jogo.dia,
        data:"Dia "+string(_jogo.dia),acao:_acao,consequencia:_consequencia});
}
function pedagogia_demanda_produto(_jogo,_id) {
    var _n=0;for(var _i=0;_i<array_length(_jogo.pedidos);_i++) {
        var _p=_jogo.pedidos[_i];if(_p.status=="aceito" && _p.produto_id==_id) _n+=_p.quantidade;
    }
    return _n;
}
function pedagogia_demanda_insumo(_jogo,_id) {
    var _n=0;
    for(var _i=0;_i<array_length(_jogo.catalogo.produtos);_i++) {
        var _p=_jogo.catalogo.produtos[_i];
        var _faltam=max(0,pedagogia_demanda_produto(_jogo,_p.id)-estoque_quantidade(_jogo.estoque.produtos,_p.id));
        for(var _k=0;_k<array_length(_p.receita);_k++) if(_p.receita[_k].ingrediente_id==_id) _n+=_faltam*_p.receita[_k].quantidade;
    }
    return _n;
}
function pedagogia_insumo_sem_reposicao(_jogo) {
    for(var _i=0;_i<array_length(_jogo.catalogo.ingredientes);_i++) {
        var _item=_jogo.catalogo.ingredientes[_i];
        var _livre=estoque_quantidade(_jogo.estoque.materias_primas,_item.id)-producao_reserva_ingrediente(_jogo,_item.id);
        if(_livre<_item.estoque_minimo && compras_pendentes_quantidade(_jogo,_item.id)==0) return _item;
    }
    return undefined;
}
/// Catálogo extensível: caso = evento + predicado + texto. Não altera regras econômicas.
function pedagogia_casos_criar() {
    return [
        {id:"aceite_sem_prontos",evento:"aceite",prioridade:50,personagem:"MARTA / GESTORA",positivo:false,
            verificar:function(_j,_c){return estoque_quantidade(_j.estoque.produtos,_c.pedido.produto_id)<_c.pedido.quantidade;},
            mensagem:function(_j,_c){return "O pedido #"+string(_c.pedido.id)+" ainda não tem todos os produtos prontos. Como o prazo combina com seus ingredientes e a capacidade disponível?";}},
        {id:"compra_excedente",evento:"compra",prioridade:50,personagem:"CAIO / ESTOQUE",positivo:false,
            verificar:function(_j,_c){
                var _id=_c.compra.ingrediente_id;
                return estoque_quantidade(_j.estoque.materias_primas,_id)+compras_pendentes_quantidade(_j,_id)>
                    max(ingrediente_obter(_j.catalogo,_id).estoque_minimo,pedagogia_demanda_insumo(_j,_id));
            },
            mensagem:function(_j,_c){return "A compra deixa mais "+ingrediente_obter(_j.catalogo,_c.compra.ingrediente_id).nome+" que a demanda aceita e o mínimo. Essa reserva faz sentido para seu caixa e seus próximos pedidos?";}},
        {id:"compra_apos_periodo",evento:"compra",prioridade:90,personagem:"CAIO / ESTOQUE",positivo:false,
            verificar:function(_j,_c){return _c.compra.dia_chegada>_j.parametros.duracao_dias+(exploracao_ativa(_j)?0:1);},
            mensagem:function(_j,_c){return "Essa compra só chega depois do período da atividade. O que acontece com o dinheiro pago e com o estoque mostrado no dashboard?";}},
        {id:"producao_sem_demanda",evento:"plano",prioridade:50,personagem:"BIA / PRODUÇÃO",positivo:false,
            verificar:function(_j,_c){
                var _id=_c.plano.produto_id,_q=estoque_quantidade(_j.estoque.produtos,_id);
                for(var _i=0;_i<array_length(_j.producao.planos);_i++) {
                    var _p=_j.producao.planos[_i];if(_p.status=="planejado" && _p.produto_id==_id) _q+=_p.quantidade;
                }
                return _q>pedagogia_demanda_produto(_j,_id);
            },
            mensagem:function(_j,_c){return "Estoque e planos superam os pedidos aceitos desse salgado. Qual é sua hipótese de venda para o excedente?";}},
        {id:"reposicao_nao_planejada",evento:"fim_dia",prioridade:70,personagem:"CAIO / ESTOQUE",positivo:false,
            verificar:function(_j,_c){return !is_undefined(pedagogia_insumo_sem_reposicao(_j));},
            mensagem:function(_j,_c){var _i=pedagogia_insumo_sem_reposicao(_j);return _i.nome+" ficou abaixo do mínimo livre, sem compra em trânsito. Como o prazo de reposição pode afetar a próxima produção?";}},
        {id:"entrega_atrasada",evento:"entrega",prioridade:80,personagem:"MARTA / GESTORA",positivo:false,
            verificar:function(_j,_c){return !_c.pedido.pontual;},
            mensagem:function(_j,_c){return "O pedido #"+string(_c.pedido.id)+" foi entregue com "+string(_c.pedido.atraso_dias)+" dia(s) de atraso. Em qual decisão o prazo começou a ficar apertado?";}},
        {id:"entrega_pontual",evento:"entrega",prioridade:40,personagem:"MARTA / GESTORA",positivo:true,
            verificar:function(_j,_c){return _c.pedido.pontual;},
            mensagem:function(_j,_c){return "Entrega dentro do prazo! Quais escolhas de estoque, capacidade e aceite ajudaram você a chegar a esse resultado?";}}
    ];
}
function pedagogia_disparar(_jogo,_evento,_contexto) {
    var _casos=pedagogia_casos_criar(),_melhor=undefined,_prioridade=-1;
    for(var _i=0;_i<array_length(_casos);_i++) {
        var _caso=_casos[_i];if(_caso.evento!=_evento) continue;
        if(!_caso.verificar(_jogo,_contexto)) continue;
        var _fala={dia:_jogo.dia,caso_id:_caso.id,personagem:_caso.personagem,
            texto:_caso.mensagem(_jogo,_contexto),positivo:_caso.positivo};
        array_push(_jogo.feedbacks,_fala);
        diario_registrar(_jogo,"REFLEXÃO / "+_caso.id,_fala.texto);
        if(_caso.prioridade>_prioridade) {_melhor=_fala;_prioridade=_caso.prioridade;}
    }
    if(!is_undefined(_melhor)) {_jogo.fala_atual=_melhor;_jogo.fala_visivel=true;}
}
function pedagogia_tentativa(_jogo,_acao,_mensagem) {
    diario_registrar(_jogo,"TENTATIVA / "+_acao,_mensagem+" Nenhum recurso foi consumido por essa tentativa.");
    _jogo.fala_atual={dia:_jogo.dia,caso_id:"acao_bloqueada",personagem:"MARTA / GESTORA",positivo:false,
        texto:_mensagem+" Que condição da simulação limita essa decisão?"};
    _jogo.fala_visivel=true;
}
function pedagogia_desenhar_fala(_jogo) {
    if(!_jogo.fala_visivel || is_undefined(_jogo.fala_atual)) return;
    var _v=global.visual,_f=_jogo.fala_atual;
    ui_cartao(300,110,282,494,_v.claro);
    ui_texto(316,136,_f.personagem,1,_v.tinta);
    ui_botao(ui_area(528,122,44,44),"X",_v.tinta);
    draw_set_color(_f.positivo?_v.verde:_v.laranja);draw_rectangle(316,166,566,170,false);
    ui_paragrafo(316,194,_f.texto,244,_v.tinta);
    ui_texto(316,566,"REFLETIR TAMBÉM É APRENDER.",1,_v.suave);
}
