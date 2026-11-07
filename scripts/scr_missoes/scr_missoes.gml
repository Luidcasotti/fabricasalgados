/// Fluxo guiado pelos materiais reais, sem etapas escondidas.
enum EtapaMissao {INTRO,COMERCIAL,ANALISAR,RECUPERAR,CONSULTAR_BANCADA,BUSCAR_FRANGO,DEPOSITAR_FRANGO,COZINHAR,ENTREGAR,DESAFIO,DESAFIO_ENTREGAR,RESULTADOS,CONCLUIDA,ESTOQUE}
function missoes_ativa(_j) {return variable_struct_exists(_j,"missoes");}
function missoes_parametros() {
    var _p=parametros_padrao();_p.capacidade_diaria=300;
    _p.pedido_quantidade_min=20;_p.pedido_quantidade_max=50;
    return _p;
}
function missoes_validar_config(_p) {
    var _v=parametros_validar(_p);if(!_v.ok)return _v;
    var _prod=produto_obter(_p.catalogo,"bolinha_queijo");
    if(is_undefined(_prod) || is_undefined(produto_obter(_p.catalogo,"coxinha")))return {ok:false,mensagem:"A história usa bolinha de queijo e coxinha. Use Modo livre para outro catálogo."};
    if(min(_p.capacidade_diaria,_p.maquinas_total*_p.maquina_capacidade_hora)<_prod.capacidade_unidade*20 || _p.caixa_inicial_centavos<_prod.custo_variavel_centavos*20)return {ok:false,mensagem:"Separe capacidade e caixa para preparar 20 bolinhas de queijo."};
    for(var _i=0;_i<array_length(_prod.receita);_i++) {
        var _r=_prod.receita[_i];if(ingrediente_obter(_p.catalogo,_r.ingrediente_id).estoque_inicial<_r.quantidade*20)return {ok:false,mensagem:"O estoque inicial precisa cobrir 20 bolinhas de queijo. Ajuste os ingredientes ou use Modo livre."};
    }
    return {ok:true,mensagem:"Aceite, busque os ingredientes, deposite, cozinhe e entregue."};
}
function missoes_novo_pedido(_j,_produto,_quantidade,_prazo,_chave) {
    var _prod=produto_obter(_j.catalogo,_produto),_id=_j.proximo_pedido_id++;
    array_push(_j.pedidos,{id:_id,chave:_chave,produto_id:_produto,quantidade:_quantidade,
        preco_unitario_centavos:_prod.preco_centavos,total_centavos:_quantidade*_prod.preco_centavos,
        dia_geracao:_j.dia,prazo_dia:_prazo,aceitar_ate_dia:_j.parametros.duracao_dias,
        status:"ofertado",sequencia_aceite:0,dia_aceite:0,dia_entrega:0,atraso_dias:0,pontual:false});
    diario_registrar(_j,"NOVO PEDIDO #"+string(_id),string(_quantidade)+" "+_prod.nome+". Entregue até o dia "+string(_prazo)+".");return _id;
}
function missoes_preparar_cozinha(_j,_produto,_recheio) {
    var _r=produto_obter(_j.catalogo,_produto).receita;
    for(var _i=0;_i<array_length(_r);_i++) {
        var _a=_r[_i];if(_a.ingrediente_id==_recheio)continue;
        var _q=max(0,min(estoque_quantidade(_j.estoque.materias_primas,_a.ingrediente_id),_a.quantidade*20-estoque_quantidade(_j.cozinha,_a.ingrediente_id)));
        if(_q==0)continue;
        estoque_ajustar(_j.estoque.materias_primas,_a.ingrediente_id,-_q);estoque_ajustar(_j.cozinha,_a.ingrediente_id,_q);
        array_push(_j.exploracao.transferencias,{dia:_j.dia,id:_a.ingrediente_id,quantidade:_q,origem:"estoque",destino:"cozinha",motivo:"insumos separados pela equipe"});
    }
}
function missoes_iniciar(_j) {
    if(missoes_ativa(_j))return;
    var _v=missoes_validar_config(_j.parametros);if(!_v.ok)throw _v.mensagem;
    exploracao_iniciar(_j);
    if(array_length(_j.compras)>0 || array_length(_j.producao.lotes)>0 || _j.dias_processados>0 || array_length(_j.exploracao.transferencias)>0)throw "Comece a história em uma partida nova.";
    _j.exploracao.limite_transporte=120;
    _j.pedidos=[];_j.proximo_pedido_id=1;_j.proximo_aceite_id=1;
    _j.missoes={etapa:EtapaMissao.COMERCIAL,estoque_consultado:false,primeiro_id:0,segundo_id:0,concluida:false,
        fila:[],indice_fala:0,resposta_atual:-1,vistos:{},respostas:[],ultima_explicacao:"informacoes",
        problemas:[],evidencias:[],eventos:[],checkpoint:"",conversou:false,informacoes:false,negociou:false,
        conferidos:{},perguntas:[],decisoes:[],bonus_centavos:0,meta:5,entregues:[],atual_id:0,plano:missoes_plano()};
    _j.variacao_pedidos={ultima:20,bolsa:[30,40,50]};
    _j.missoes.primeiro_id=missoes_novo_pedido(_j,"bolinha_queijo",20,min(_j.parametros.duracao_dias,_j.dia+2),"historia:primeiro");
    _j.missoes.atual_id=_j.missoes.primeiro_id;
    historia_enfileirar(_j,"introducao");
    diario_registrar(_j,"INÍCIO DO TURNO","Aceite o pedido com Marta. O canhoto mostra os ingredientes; Caio separa tudo no Estoque.");
    missoes_checkpoint(_j);
}
function missoes_atual(_j) {
    var _fila=pedidos_fila(_j);if(array_length(_fila)>0)return _fila[0];
    var _m=_j.missoes,_p=catalogo_buscar(_j.pedidos,_m.atual_id);
    if(!is_undefined(_p) && _p.status=="ofertado")return _p;return undefined;
}
function missoes_restante(_j,_p) {return max(0,_p.quantidade-estoque_quantidade(_j.estoque.produtos,_p.produto_id));}
/// Quantidade que falta para o pedido, limitada ao espaço e ao saldo da prateleira.
function missoes_coleta_quantidade(_j,_id) {
    if(!missoes_ativa(_j))return 0;
    var _p=missoes_atual(_j);
    if(is_undefined(_p) || _p.status!="aceito")return 0;
    var _falta=exploracao_necessidade_atual(_j,_id)-estoque_quantidade(_j.cozinha,_id)-estoque_quantidade(_j.carregados,_id);
    return max(0,min(_falta,_j.exploracao.limite_transporte-exploracao_carregado_total(_j),estoque_quantidade(_j.estoque.materias_primas,_id)));
}
/// O canhoto é calculado do estado real, sem saldos paralelos.
function canhoto_dados(_j){
    var _fila=pedidos_fila(_j);if(array_length(_fila)==0)return undefined;
    var _p=_fila[0],_prod=produto_obter(_j.catalogo,_p.produto_id),_resto=max(0,_p.quantidade-estoque_quantidade(_j.estoque.produtos,_p.produto_id));
    var _c={pedido:_p,produto:_prod.nome,restante:_resto,linhas:[],retirar:0,comprar:0,em_transito:0};
    for(var _i=0;_i<array_length(_prod.receita);_i++){
        var _r=_prod.receita[_i];if(_r.quantidade<=0)continue;
        var _d=exploracao_insumo_diagnostico(_j,_r.ingrediente_id,_r.quantidade*_resto);
        _d.total_pedido=_r.quantidade*_p.quantidade;
        _d.retirar=max(0,min(_d.almoxarifado,_d.necessario-_d.cozinha-_d.mochila));
        _c.retirar+=_d.retirar;_c.comprar+=_d.comprar_quantidade;_c.em_transito+=min(_d.falta_empresa,_d.em_transito);
        array_push(_c.linhas,_d);
    }
    return _c;
}
function missoes_fluxo(_j) {
    var _m=_j.missoes,_p=missoes_atual(_j);
    var _g={passo:1,titulo:"Aceitar o pedido",acao:"Vá ao Comercial e aceite o pedido com Marta.",setor:"comercial",alvo:"vendas",motivo:"Acompanhe seu canhoto à esquerda."};
    if(_m.concluida){_g.passo=7;_g.titulo="Você zerou o jogo!";_g.acao="Parabéns! Você concluiu as cinco entregas da história.";_g.alvo="";return _g;}
    if(is_undefined(_p)){_g.acao="No Comercial, peça OUTRO PEDIDO à Marta.";return _g;}
    if(_p.status!="aceito")return _g;
    var _c=canhoto_dados(_j);
    if(_c.restante==0){_g.passo=6;_g.titulo="Entregar o pedido";_g.acao="Tudo pronto! Vá ao balcão ENTREGAR no Comercial.";_g.alvo="entrega";return _g;}
    var _carga=exploracao_carregado_total(_j);
    if(_carga>0 && (_c.retirar==0 || _carga>=_j.exploracao.limite_transporte)){
        _g.passo=4;_g.titulo="Depositar na cozinha";_g.acao="Leve a mochila à Mesa de depósito, na Produção.";_g.setor="producao";_g.alvo="deposito";return _g;
    }
    if(_c.retirar>0 || _c.comprar>0 || _c.em_transito>0){
        _g.passo=3;_g.setor="estoque";_g.alvo="compras";_g.titulo="Separar os ingredientes";
        _g.acao="No Estoque, use E em Caio e PEGAR INGREDIENTES DO PEDIDO.";
        if(_c.comprar>0){_g.titulo="Comprar o que falta";_g.acao="Faltam ingredientes na empresa. Peça apenas o faltante a Caio.";}
        if(_c.comprar==0 && _c.em_transito>0){_g.titulo="Esperar a reposição";_g.acao="O motoboy está a caminho. Aguarde a entrega e pegue os ingredientes com Caio no Estoque.";}
        return _g;
    }
    _g.passo=5;_g.titulo="Cozinhar o pedido";_g.acao="Ingredientes na cozinha. Use E na Mesa de preparo e COZINHAR PEDIDO.";_g.setor="producao";_g.alvo="bancada";return _g;
}
function missoes_sincronizar(_j) {
    if(!missoes_ativa(_j) || _j.missoes.concluida || _j.missoes.etapa==EtapaMissao.RESULTADOS)return;
    var _m=_j.missoes,_g=missoes_fluxo(_j),_p=missoes_atual(_j);
    if(_g.passo==0){_m.etapa=EtapaMissao.ESTOQUE;return;}
    if(is_undefined(_p)){_m.etapa=EtapaMissao.RECUPERAR;return;}
    if(_p.id==_m.segundo_id){_m.etapa=_g.passo==6?EtapaMissao.DESAFIO_ENTREGAR:EtapaMissao.DESAFIO;return;}
    var _etapas=[EtapaMissao.COMERCIAL,EtapaMissao.CONSULTAR_BANCADA,EtapaMissao.BUSCAR_FRANGO,EtapaMissao.DEPOSITAR_FRANGO,EtapaMissao.COZINHAR,EtapaMissao.ENTREGAR];
    _m.etapa=_etapas[clamp(_g.passo-1,0,5)];
}
function missoes_checkpoint(_j) {var _m=_j.missoes;_m.checkpoint="";_m.checkpoint=json_stringify(_j);}
function missoes_reiniciar(_j) {
    var _texto=_j.missoes.checkpoint;if(_texto=="")return undefined;
    var _novo=json_parse(_texto);_novo.missoes.checkpoint=_texto;_novo.pausado=false;return _novo;
}
function missoes_registrar(_j,_nome,_consequencia) {array_push(_j.missoes.eventos,{dia:_j.dia,etapa:_j.missoes.etapa,acao:_nome,consequencia:_consequencia});diario_registrar(_j,_nome,_consequencia);}
function missoes_problema(_j,_texto) {if(!array_contains(_j.missoes.problemas,_texto))array_push(_j.missoes.problemas,_texto);}
function missoes_permitir(_j,_acao,_id="",_q=0) {
    if(!missoes_ativa(_j))return {ok:true,mensagem:""};
    if(_acao=="retirar" || _acao=="produzir") {
        var _pedido=missoes_atual(_j);
        if(is_undefined(_pedido) || _pedido.status!="aceito")return {ok:false,mensagem:"Converse com Marta e aceite uma encomenda primeiro."};
    }
    if(_acao=="produzir") {
        var _p=missoes_atual(_j);
        if(is_undefined(_p) || _p.status!="aceito")return {ok:false,mensagem:"Primeiro aceite um pedido com Marta no Comercial."};
        if(_id!=_p.produto_id)return {ok:false,mensagem:"O pedido é de "+produto_obter(_j.catalogo,_p.produto_id).nome+". A mesa seleciona esse salgado automaticamente."};
        var _resto=missoes_restante(_j,_p);
        if(_resto==0)return {ok:false,mensagem:"O pedido já está pronto. Leve ao balcão ENTREGAR do Comercial."};
        if(_q>_resto)return {ok:false,mensagem:"Faltam preparar "+string(_resto)+" salgados. Use COZINHAR PEDIDO na mesa de preparo."};
    }
    return {ok:true,mensagem:""};
}
function missoes_oferecer_pergunta(_j,_id) {
    var _m=_j.missoes;for(var _i=0;_i<array_length(_m.respostas);_i++)if(_m.respostas[_i].id==_id)return;
    if(!array_contains(_m.perguntas,_id))array_push(_m.perguntas,_id);
}
function missoes_evento(_j,_evento,_c) {
    if(!missoes_ativa(_j))return;
    var _m=_j.missoes,_p=missoes_atual(_j);
    if(_evento=="interacao") {
        if(_c.id=="compras" && !_m.estoque_consultado)historia_enfileirar(_j,"dec_ingredientes");
        if(_c.id=="vendas")_m.conversou=true;
        if(_c.id=="bancada" && !is_undefined(_p) && _p.status=="aceito"){
            variable_struct_set(_m.conferidos,string(_p.id),true);missoes_oferecer_pergunta(_j,"q_estoque");
        }
    }
    // Só a consulta presencial da bancada registra a conferência da receita.
    if(_evento=="deposito")missoes_oferecer_pergunta(_j,"q_risco");
    if(_evento=="producao"){missoes_oferecer_pergunta(_j,"q_excesso");array_push(_m.evidencias,"Preparou "+string(_c.quantidade)+" salgados usando ingredientes da cozinha.");}
    if(_evento=="entrega") {
        var _entrega=catalogo_buscar(_j.pedidos,_c.id);
        if(is_undefined(_entrega) || _entrega.status!="entregue" || _c.id!=_m.atual_id || array_contains(_m.entregues,_c.id))return;
        array_push(_m.evidencias,"Entregou o pedido #"+string(_c.id)+" e recebeu o pagamento.");
        array_push(_m.entregues,_c.id);
        if(array_length(_m.entregues)>=_m.meta){
            _m.etapa=EtapaMissao.RESULTADOS;
            if(feira_ativa(_j))feira_finalizar(_j,true);else missoes_finalizar(_j);
            return;
        }
        missoes_abrir_proximo(_j);
    }
    if(_evento=="decisao" && !_c.aceitar){_m.etapa=EtapaMissao.RECUPERAR;return;}
    missoes_sincronizar(_j);
}
function missoes_reofertar(_j) {
    if(_j.missoes.etapa!=EtapaMissao.RECUPERAR || !mundo_perto(_j,"vendas"))return {ok:false,mensagem:"Peça outro pedido à Marta, no Comercial."};
    var _m=_j.missoes,_pl=_m.plano[array_length(_m.entregues) mod array_length(_m.plano)];
    _m.atual_id=missoes_novo_pedido(_j,_pl.produto_id,_pl.quantidade,min(_j.parametros.duracao_dias,_j.dia+2),"historia:reoferta:"+string(_j.proximo_pedido_id));
    if(array_length(_m.entregues)==0)_m.primeiro_id=_m.atual_id;else _m.segundo_id=_m.atual_id;
    _m.etapa=EtapaMissao.COMERCIAL;missoes_sincronizar(_j);return {ok:true,mensagem:"Pedido substituto disponível. Clique em ACEITAR para continuar a missão."};
}
function missoes_negociar(_j) {
    var _p=missoes_atual(_j);if(is_undefined(_p) || !mundo_perto(_j,"vendas") || _j.missoes.negociou)return {ok:false,mensagem:"Converse com Marta no Comercial para combinar o prazo."};
    _p.prazo_dia=min(_j.parametros.duracao_dias,_p.prazo_dia+1);_j.missoes.negociou=true;
    if(_p.status=="ofertado")pedido_decidir(_j,_p.id,true);
    return {ok:true,mensagem:"Entrega combinada para o dia "+string(_p.prazo_dia)+"."};
}
function missoes_prazo_proposto(_j) {var _p=missoes_atual(_j);return is_undefined(_p)?_j.dia:min(_j.parametros.duracao_dias,_p.prazo_dia+1);}
function missoes_finalizar(_j) {
    if(!missoes_ativa(_j) || _j.missoes.etapa!=EtapaMissao.RESULTADOS || _j.missoes.concluida)return false;
    if(array_length(_j.missoes.entregues)<_j.missoes.meta && !(feira_ativa(_j) && _j.feira.concluida))return false;
    _j.missoes.etapa=EtapaMissao.CONCLUIDA;_j.missoes.concluida=true;
    if(!_j.encerrado){array_push(_j.historico_dias,{dia:_j.dia,eventos:["Turno concluído."],saldo_centavos:_j.financas.saldo_centavos,capacidade_usada:_j.producao.capacidade_usada,unidades:_j.producao.unidades_dia});_j.dias_processados++;_j.encerrado=true;}
    return true;
}
function missoes_necessario(_j,_produto,_ingrediente) {
    var _r=produto_obter(_j.catalogo,_produto).receita;for(var _i=0;_i<array_length(_r);_i++)if(_r[_i].ingrediente_id==_ingrediente)return _r[_i].quantidade*20;return 0;
}

/// A missão só avança depois da confirmação no computador do Estoque.
function missoes_consultar_estoque(_j){
    var _b=exploracao_bloqueio_local(_j,"compras");if(_b!="")return {ok:false,mensagem:_b};
    if(!missoes_ativa(_j))return {ok:true,mensagem:"Quantidades reais do almoxarifado consultadas."};
    if(_j.missoes.estoque_consultado)return {ok:true,mensagem:"Estoque já conferido. "+missoes_fluxo(_j).acao};
    _j.missoes.estoque_consultado=true;
    missoes_registrar(_j,"CONSULTAR ESTOQUE","Conferiu os ingredientes disponíveis antes de analisar a encomenda.");
    missoes_sincronizar(_j);
    return {ok:true,mensagem:"Estoque conferido. Use o canhoto para separar apenas os ingredientes do pedido."};
}

function missoes_mais_pedidos(_j){
    if(!missoes_ativa(_j) || _j.encerrado || _j.pausado || !is_undefined(missoes_atual(_j)))return {ok:false,mensagem:"Conclua o pedido atual antes de receber outro."};
    if(array_length(_j.missoes.entregues)>=_j.missoes.meta)return {ok:false,mensagem:"Você já concluiu todas as missões!"};
    missoes_abrir_proximo(_j);return {ok:true,mensagem:"Próxima missão disponível com Marta. Aceite o pedido para continuar."};
}
function missoes_plano(){return [{produto_id:"bolinha_queijo",quantidade:20},{produto_id:"coxinha",quantidade:30},{produto_id:"pastel",quantidade:20},{produto_id:"coxinha",quantidade:30},{produto_id:"bolinha_queijo",quantidade:20}];}
function missoes_abrir_proximo(_j){
    var _m=_j.missoes,_n=array_length(_m.entregues);
    if(_n>=_m.meta || !is_undefined(missoes_atual(_j)))return false;
    var _p=_m.plano[_n mod array_length(_m.plano)];
    _m.atual_id=missoes_novo_pedido(_j,_p.produto_id,_p.quantidade,min(_j.parametros.duracao_dias,_j.dia+2),"historia:missao:"+string(_n+1));
    _m.segundo_id=_m.atual_id;_m.etapa=EtapaMissao.COMERCIAL;
    missoes_sincronizar(_j);missoes_checkpoint(_j);return true;
}
function missoes_zerou(_j){return missoes_ativa(_j) && _j.missoes.concluida && array_length(_j.missoes.entregues)>=_j.missoes.meta;}
function historia_jogar(_parametros=undefined){
    global.jogo=feira_criar(_parametros);room_goto(rm_corredor);
}
function missoes_fim_botoes(){return [{area:ui_area(104,578,520,58),texto:"VOLTAR AO MENU",acao:"feira_inicio"},{area:ui_area(650,578,526,58),texto:"JOGAR NOVAMENTE",acao:"historia_rejogar"}];}
function missoes_fim_desenhar(_j){
    var _v=global.visual,_r=dashboard_calcular(_j);
    draw_set_color(_v.painel);draw_rectangle(0,0,1280,720,false);
    ui_centro(640,96,"VOCÊ ZEROU O JOGO!",4,_v.verde);
    ui_centro(640,166,"Parabéns! Você concluiu todas as 5 missões da fábrica.",2,_v.claro);
    ui_cartao(232,232,816,278,_v.claro);
    ui_texto(264,266,"PEDIDOS ENTREGUES: "+string(_r.pedidos_atendidos)+" / 5",3,_v.ciano);
    ui_texto(264,334,"SALGADOS PRODUZIDOS: "+string(_r.unidades_produzidas),2,_v.tinta);
    ui_texto(264,388,"VENDAS: "+financas_formatar(_r.receitas_centavos),2,_v.tinta);
    ui_paragrafo(264,440,"Você organizou os ingredientes, tomou decisões e entregou cada encomenda. Missão cumprida!",752,_v.suave);
}
