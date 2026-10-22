/// Missões avançam por eventos de ações confirmadas, nunca pela simples entrada em sala.
enum EtapaMissao {INTRO,COMERCIAL,ANALISAR,RECUPERAR,CONSULTAR_BANCADA,BUSCAR_FRANGO,DEPOSITAR_FRANGO,COZINHAR,ENTREGAR,DESAFIO,DESAFIO_ENTREGAR,RESULTADOS,CONCLUIDA}
function missoes_ativa(_j) {return variable_struct_exists(_j,"missoes");}
function missoes_parametros() {
    var _p=parametros_padrao();ingrediente_obter(_p.catalogo,"queijo").estoque_inicial=0;
    ingrediente_obter(_p.catalogo,"queijo").prazo_dias=2;return _p;
}
function missoes_validar_config(_p) {
    var _v=parametros_validar(_p);if(!_v.ok)return _v;
    var _cox=produto_obter(_p.catalogo,"coxinha"),_bol=produto_obter(_p.catalogo,"bolinha_queijo"),_fr=0,_qe=0;
    if(is_undefined(_cox) || is_undefined(_bol) || is_undefined(ingrediente_obter(_p.catalogo,"frango")) || is_undefined(ingrediente_obter(_p.catalogo,"queijo")))return {ok:false,mensagem:"História requer coxinha, bolinha de queijo, frango e queijo no catálogo. Use LIVRE para outro caso."};
    for(var _i=0;_i<array_length(_cox.receita);_i++) {
        var _a=_cox.receita[_i],_in=ingrediente_obter(_p.catalogo,_a.ingrediente_id);
        if(_in.estoque_inicial<_a.quantidade*10)return {ok:false,mensagem:"História: o estoque inicial deve cobrir a receita das 10 coxinhas. Ajuste os valores ou escolha LIVRE."};
        if(_a.ingrediente_id=="frango")_fr=_a.quantidade;
    }
    for(var _i=0;_i<array_length(_bol.receita);_i++)if(_bol.receita[_i].ingrediente_id=="queijo")_qe=_bol.receita[_i].quantidade;
    if(_fr==0 || _qe==0 || ingrediente_obter(_p.catalogo,"queijo").estoque_inicial!=0)return {ok:false,mensagem:"História: coxinha precisa de frango, bolinha precisa de queijo e o queijo inicial deve ser zero. Ou use LIVRE."};
    if(_p.capacidade_diaria<_cox.capacidade_unidade*10 || _p.caixa_inicial_centavos<_cox.custo_variavel_centavos*10)
        return {ok:false,mensagem:"História: a capacidade e o caixa precisam cobrir o primeiro lote de 10 coxinhas. Ou escolha LIVRE."};
    if(_p.duracao_dias<ingrediente_obter(_p.catalogo,"queijo").prazo_dias+2)return {ok:false,mensagem:"História: duração mínima = prazo do queijo + 2 dias. Ajuste ou escolha LIVRE."};
    return {ok:true,mensagem:"História viável. O segundo desafio pode ser recusado se faltar caixa ou capacidade."};
}
function missoes_novo_pedido(_j,_produto,_quantidade,_prazo,_chave) {
    var _prod=produto_obter(_j.catalogo,_produto),_id=_j.proximo_pedido_id++;
    array_push(_j.pedidos,{id:_id,chave:_chave,produto_id:_produto,quantidade:_quantidade,
        preco_unitario_centavos:_prod.preco_centavos,total_centavos:_quantidade*_prod.preco_centavos,
        dia_geracao:_j.dia,prazo_dia:_prazo,aceitar_ate_dia:_j.parametros.duracao_dias,
        status:"ofertado",sequencia_aceite:0,dia_aceite:0,dia_entrega:0,atraso_dias:0,pontual:false});
    diario_registrar(_j,"NOVA ENCOMENDA GUIADA #"+string(_id),string(_quantidade)+" "+_prod.nome+"; prazo dia "+string(_prazo)+". Oferta única do caso pedagógico.");
    return _id;
}
function missoes_iniciar(_j) {
    if(missoes_ativa(_j))return;
    var _v=missoes_validar_config(_j.parametros);if(!_v.ok)throw _v.mensagem;
    exploracao_iniciar(_j);
    if(array_length(_j.compras)>0 || array_length(_j.producao.lotes)>0 || _j.dias_processados>0 || array_length(_j.exploracao.transferencias)>0)throw "Inicie a história apenas em uma sessão nova; os dados existentes foram preservados.";
    // Substitui somente as ofertas iniciais de uma sessão ainda nova; histórico de partida não é apagado.
    _j.pedidos=[];_j.proximo_pedido_id=1;_j.proximo_aceite_id=1;
    _j.missoes={etapa:EtapaMissao.INTRO,primeiro_id:0,segundo_id:0,concluida:false,
        fila:[],indice_fala:0,resposta_atual:-1,vistos:{},respostas:[],ultima_explicacao:"intro",
        problemas:[],evidencias:[],eventos:[],checkpoint:"",conversou:false,informacoes:false,negociou:false};
    var _m=_j.missoes;
    _m.primeiro_id=missoes_novo_pedido(_j,"coxinha",10,min(_j.parametros.duracao_dias,_j.dia+2),"historia:primeiro:1");
    var _receita=produto_obter(_j.catalogo,"coxinha").receita;
    // Preparação local explícita, tirada do depósito. Somente o frango fica faltando.
    for(var _i=0;_i<array_length(_receita);_i++) {
        var _a=_receita[_i],_q=_a.quantidade*10;if(_a.ingrediente_id=="frango" || _q==0)continue;
        estoque_ajustar(_j.estoque.materias_primas,_a.ingrediente_id,-_q);estoque_ajustar(_j.cozinha,_a.ingrediente_id,_q);
        array_push(_j.exploracao.transferencias,{dia:_j.dia,id:_a.ingrediente_id,quantidade:_q,origem:"estoque",destino:"cozinha",motivo:"preparação didática inicial"});
    }
    diario_registrar(_j,"PREPARAÇÃO DA COZINHA","Demais insumos do primeiro lote transferidos do depósito; frango permanece no almoxarifado. Total físico conservado.");
    historia_enfileirar(_j,"intro");missoes_checkpoint(_j);
}
function missoes_checkpoint(_j) {
    var _m=_j.missoes;_m.checkpoint="";_m.checkpoint=json_stringify(_j);
}
function missoes_reiniciar(_j) {
    var _texto=_j.missoes.checkpoint;if(_texto=="")return undefined;
    var _novo=json_parse(_texto);_novo.missoes.checkpoint=_texto;_novo.pausado=false;
    diario_registrar(_novo,"REINICIAR MISSÃO","Restaurado o início do capítulo; ações posteriores, materiais e dinheiro voltaram ao checkpoint confirmado pelo jogador.");
    return _novo;
}
function missoes_registrar(_j,_nome,_consequencia) {
    array_push(_j.missoes.eventos,{dia:_j.dia,etapa:_j.missoes.etapa,acao:_nome,consequencia:_consequencia});
    diario_registrar(_j,"MISSÃO / "+_nome,_consequencia);
}
function missoes_problema(_j,_texto) {
    var _m=_j.missoes;
    if(array_contains(_m.problemas,_texto))return;
    array_push(_m.problemas,_texto);
}
function missoes_permitir(_j,_acao,_id="",_q=0) {
    if(!missoes_ativa(_j))return {ok:true,mensagem:""};
    var _m=_j.missoes,_e=_m.etapa;
    if(historia_aberta(_j))return {ok:false,mensagem:"Leia a conversa e pressione CONTINUAR antes de agir."};
    if(_acao=="dia" && _e<EtapaMissao.DESAFIO)return {ok:false,mensagem:"Conclua a primeira entrega antes de encerrar o dia. A missão inicial cabe no dia 1."};
    if(_acao=="aceitar" || _acao=="recusar") {
        if(!_m.conversou)return {ok:false,mensagem:"Converse com a atendente primeiro; entrar no Comercial não conclui a tarefa."};
        if((_id==_m.primeiro_id && _e==EtapaMissao.ANALISAR) || (_id==_m.segundo_id && _e==EtapaMissao.DESAFIO))return {ok:true,mensagem:""};
        return {ok:false,mensagem:"Esta decisão não corresponde ao pedido da missão atual."};
    }
    if(_acao=="retirar") {
        if((_e==EtapaMissao.BUSCAR_FRANGO || _e==EtapaMissao.DEPOSITAR_FRANGO) && _id=="frango")return {ok:true,mensagem:""};
        if(_e==EtapaMissao.DESAFIO && catalogo_buscar(_j.pedidos,_m.segundo_id).status=="aceito")return {ok:true,mensagem:""};
        return {ok:false,mensagem:"Confira primeiro a bancada e a etapa atual. A prateleira continua disponível quando a tarefa pedir."};
    }
    if(_acao=="depositar") {
        if(_e==EtapaMissao.DEPOSITAR_FRANGO || _e==EtapaMissao.DESAFIO)return {ok:true,mensagem:""};
        return {ok:false,mensagem:"Ainda não há uma transferência prevista nesta etapa."};
    }
    if(_acao=="produzir") {
        var _p=catalogo_buscar(_j.pedidos,(_e==EtapaMissao.DESAFIO)?_m.segundo_id:_m.primeiro_id);
        if((_e==EtapaMissao.COZINHAR || _e==EtapaMissao.DESAFIO) && _p.status=="aceito" && _id==_p.produto_id && _q==_p.quantidade)
            return {ok:true,mensagem:""};
        return {ok:false,mensagem:"Nesta história, prepare exatamente o lote do pedido atual depois de conferir a bancada. Veja O que preciso fazer?."};
    }
    if(_acao=="comprar" && (_e!=EtapaMissao.DESAFIO || catalogo_buscar(_j.pedidos,_m.segundo_id).status!="aceito"))return {ok:false,mensagem:"A primeira falta é só na cozinha. Procure o frango no Estoque antes de comprar."};
    if(_acao=="entregar" && !((_e==EtapaMissao.ENTREGAR && _id==_m.primeiro_id) || (_e==EtapaMissao.DESAFIO_ENTREGAR && _id==_m.segundo_id)))
        return {ok:false,mensagem:"Produza o lote da missão antes de entregar no balcão."};
    return {ok:true,mensagem:""};
}
function missoes_evento(_j,_evento,_c) {
    if(!missoes_ativa(_j))return;
    var _m=_j.missoes,_e=_m.etapa;
    if(_evento=="interacao") {
        if(_c.id=="vendas" && _e==EtapaMissao.COMERCIAL) {
            _m.conversou=true;_m.etapa=EtapaMissao.ANALISAR;historia_enfileirar(_j,"primeiro_pedido");
            missoes_registrar(_j,"CONVERSAR NO COMERCIAL","Pedido e capacidade apresentados antes do aceite.");
        }
        if(_c.id=="bancada" && _e==EtapaMissao.CONSULTAR_BANCADA) {
            _m.etapa=EtapaMissao.BUSCAR_FRANGO;missoes_problema(_j,"Frango ausente na cozinha, embora disponível no depósito.");
            historia_enfileirar(_j,"falta_frango");historia_enfileirar(_j,"pergunta_estoque");
            missoes_registrar(_j,"CONFERIR BANCADA","Receita conferida; falta local identificada sem consumir recursos.");
        }
        if(_c.id=="vendas" && _e==EtapaMissao.DESAFIO) {_m.conversou=true;historia_enfileirar(_j,"segundo_pedido");}
        if(_c.id=="compras" && _e==EtapaMissao.DESAFIO)historia_enfileirar(_j,"lead_time");
        return;
    }
    if(_evento=="decisao") {
        if(_c.id==_m.primeiro_id) {
            _m.etapa=_c.aceitar?EtapaMissao.CONSULTAR_BANCADA:EtapaMissao.RECUPERAR;
            historia_enfileirar(_j,_c.aceitar?"aceite_primeiro":"recusa_primeiro");
        } else if(_c.id==_m.segundo_id) {
            if(!_c.aceitar) {_m.etapa=EtapaMissao.RESULTADOS;historia_enfileirar(_j,"recusa_segundo");}
            else {historia_enfileirar(_j,"aceite_segundo");historia_enfileirar(_j,"pergunta_risco");}
        }
        missoes_registrar(_j,_c.aceitar?"ACEITAR PEDIDO":"RECUSAR PEDIDO","Escolha registrada; estoque e caixa não foram alterados pelo aceite.");return;
    }
    if(_evento=="retirada" && (_e==EtapaMissao.BUSCAR_FRANGO || _e==EtapaMissao.DEPOSITAR_FRANGO))_m.etapa=EtapaMissao.DEPOSITAR_FRANGO;
    if(_evento=="deposito" && _e==EtapaMissao.DEPOSITAR_FRANGO) {
        var _p=catalogo_buscar(_j.pedidos,_m.primeiro_id),_v=exploracao_receita_validar(_j,_p.produto_id,_p.quantidade);
        _m.etapa=_v.ok?EtapaMissao.COZINHAR:EtapaMissao.BUSCAR_FRANGO;
        if(_v.ok) {array_push(_m.evidencias,"Transportou frango do depósito à cozinha sem duplicação.");historia_enfileirar(_j,"pronto_cozinhar");}
    }
    if(_evento=="producao") {
        _m.etapa=(_e==EtapaMissao.DESAFIO)?EtapaMissao.DESAFIO_ENTREGAR:EtapaMissao.ENTREGAR;
        array_push(_m.evidencias,"Produziu "+string(_c.quantidade)+" "+produto_obter(_j.catalogo,_c.id).nome+" consumindo a receita real.");
        historia_enfileirar(_j,"lote_pronto");
    }
    if(_evento=="entrega") {
        if(_c.id==_m.primeiro_id) {
            _m.etapa=EtapaMissao.DESAFIO;_m.conversou=false;
            _m.segundo_id=missoes_novo_pedido(_j,"bolinha_queijo",10,_j.dia+1,"historia:segundo");
            missoes_problema(_j,"Segundo pedido sem queijo no estoque geral; reposição exige espera e dinheiro.");
            array_push(_m.evidencias,"Concluiu a ligação Comercial → Estoque → Produção → entrega.");
            historia_enfileirar(_j,"primeira_entrega");missoes_checkpoint(_j);
        } else {_m.etapa=EtapaMissao.RESULTADOS;historia_enfileirar(_j,"segunda_entrega");}
    }
    if(_evento=="compra") {historia_enfileirar(_j,"pergunta_excesso");missoes_registrar(_j,"SOLICITAR REPOSIÇÃO","Compra paga; entrega da matéria-prima segue o prazo, sem chegada instantânea.");}
}
function missoes_reofertar(_j) {
    var _m=_j.missoes;
    if(_m.etapa!=EtapaMissao.RECUPERAR || !mundo_perto(_j,"vendas") || simulacao_bloqueio(_j)!="" || historia_aberta(_j))return {ok:false,mensagem:"Converse com Marta após ler a orientação de recuperação."};
    _m.primeiro_id=missoes_novo_pedido(_j,"coxinha",10,_j.dia+2,"historia:repeticao:"+string(_j.proximo_pedido_id));
    _m.etapa=EtapaMissao.ANALISAR;_m.conversou=true;historia_enfileirar(_j,"nova_oportunidade");
    return {ok:true,mensagem:"Nova oferta criada; a recusa anterior permanece no histórico."};
}
function missoes_negociar(_j) {
    var _m=_j.missoes,_p=catalogo_buscar(_j.pedidos,_m.segundo_id);
    if(_m.etapa!=EtapaMissao.DESAFIO || !_m.conversou || !mundo_perto(_j,"vendas") || simulacao_bloqueio(_j)!="" || historia_aberta(_j))return {ok:false,mensagem:"Negocie pessoalmente com a atendente após ler a encomenda."};
    if(is_undefined(_p) || _p.status!="ofertado" && _p.status!="aceito" || _m.negociou)return {ok:false,mensagem:"Esse prazo já foi negociado ou o pedido já foi decidido."};
    var _novo=missoes_prazo_proposto(_j);
    if(produto_obter(_j.catalogo,_p.produto_id).capacidade_unidade*_p.quantidade>_j.parametros.capacidade_diaria)return {ok:false,mensagem:"O lote excede a capacidade de um dia. Recuse ou reinicie o capítulo para rever a escolha."};
    if(_novo>_j.parametros.duracao_dias)return {ok:false,mensagem:"O prazo proposto ultrapassa a atividade. Reavalie ou recuse; você também pode reiniciar a missão."};
    _p.prazo_original_dia=_p.prazo_dia;_p.prazo_dia=_novo;_p.negociado=true;_p.dia_negociacao=_j.dia;_m.negociou=true;
    if(_p.status=="ofertado")pedido_decidir(_j,_p.id,true);
    missoes_registrar(_j,"NEGOCIAR PRAZO","Pedido #"+string(_p.id)+": prazo original "+string(_p.prazo_original_dia)+", combinado dia "+string(_novo)+". Reposição não foi comprada automaticamente.");
    array_push(_m.evidencias,"Negociou prazo com base na chegada prevista e tempo para produção.");historia_enfileirar(_j,"prazo_negociado");
    return {ok:true,mensagem:"Novo prazo combinado: dia "+string(_novo)+". Compre e transporte os ingredientes necessários."};
}
function missoes_finalizar(_j) {
    if(!missoes_ativa(_j) || _j.missoes.etapa!=EtapaMissao.RESULTADOS || historia_aberta(_j))return false;
    var _m=_j.missoes;_m.etapa=EtapaMissao.CONCLUIDA;_m.concluida=true;
    if(!_j.encerrado) {
    array_push(_j.historico_dias,{dia:_j.dia,eventos:["História concluída por decisões e entregas presenciais; resultados consultados."],saldo_centavos:_j.financas.saldo_centavos,capacidade_usada:_j.producao.capacidade_usada,unidades:_j.producao.unidades_dia});
    // Capacidade do dia aberto entra uma vez no fechamento pedagógico, sem avançar data.
    _j.dias_processados++;_j.encerrado=true;
    }
    missoes_registrar(_j,"CONSULTAR RESULTADOS","História concluída. Indicadores calculados dos dados reais; perguntas indicam prática, não certificação de aprendizagem.");return true;
}

/// Estimativa conservadora: chegada dos insumos faltantes mais um dia de organização.
function missoes_prazo_proposto(_j) {
    var _p=catalogo_buscar(_j.pedidos,_j.missoes.segundo_id);if(is_undefined(_p))return _j.dia;
    var _receita=produto_obter(_j.catalogo,_p.produto_id).receita,_chegada=_j.dia;
    for(var _i=0;_i<array_length(_receita);_i++) {
        var _a=_receita[_i],_necessario=_a.quantidade*_p.quantidade-exploracao_total_insumo(_j,_a.ingrediente_id);
        if(_necessario<=0)continue;var _pendente=0;
        for(var _k=0;_k<array_length(_j.compras);_k++) {
            var _c=_j.compras[_k];if(_c.ingrediente_id==_a.ingrediente_id && _c.status=="em_transito") {_pendente+=_c.quantidade;_chegada=max(_chegada,_c.dia_chegada);}
        }
        if(_pendente<_necessario)_chegada=max(_chegada,_j.dia+ingrediente_obter(_j.catalogo,_a.ingrediente_id).prazo_dias);
    }
    return max(_p.prazo_dia+1,_chegada+1);
}
function missoes_necessario(_j,_produto,_ingrediente) {
    var _receita=produto_obter(_j.catalogo,_produto).receita;
    for(var _i=0;_i<array_length(_receita);_i++)if(_receita[_i].ingrediente_id==_ingrediente)return _receita[_i].quantidade*10;
    return 0;
}
