function parametro_inteiro(_v,_min,_max) {return is_real(_v) && floor(_v)==_v && _v>=_min && _v<=_max;}
function parametros_validar(_p) {
    var _campos=parametros_campos(_p);
    for(var _i=0;_i<array_length(_campos);_i++) {
        var _c=_campos[_i];
        if(!parametro_inteiro(parametro_ler(_p,_c),_c.minimo,_c.maximo))
            return {ok:false,mensagem:"Valor fora dos limites: "+_c.nome};
    }
    if(_p.pedido_quantidade_min>_p.pedido_quantidade_max) return {ok:false,mensagem:"Quantidade mínima do pedido excede a máxima."};
    if(array_length(_p.catalogo.produtos)==0 || array_length(_p.catalogo.ingredientes)==0)
        return {ok:false,mensagem:"Catálogo vazio."};
    var _ids={};
    for(var _i=0;_i<array_length(_p.catalogo.ingredientes);_i++) {
        var _id=_p.catalogo.ingredientes[_i].id;
        if(variable_struct_exists(_ids,_id)) return {ok:false,mensagem:"Ingrediente duplicado."};
        variable_struct_set(_ids,_id,true);
    }
    var _produtos={};
    for(var _i=0;_i<array_length(_p.catalogo.produtos);_i++) {
        var _prod=_p.catalogo.produtos[_i],_vistos={},_total=0;
        if(variable_struct_exists(_produtos,_prod.id)) return {ok:false,mensagem:"Produto duplicado."};
        variable_struct_set(_produtos,_prod.id,true);
        for(var _k=0;_k<array_length(_prod.receita);_k++) {
            var _r=_prod.receita[_k];
            if(!variable_struct_exists(_ids,_r.ingrediente_id) || variable_struct_exists(_vistos,_r.ingrediente_id))
                return {ok:false,mensagem:"Receita com ingrediente inválido ou repetido."};
            variable_struct_set(_vistos,_r.ingrediente_id,true);_total+=_r.quantidade;
        }
        if(_total==0) return {ok:false,mensagem:"Receita precisa de pelo menos um ingrediente."};
    }
    return {ok:true,mensagem:"Parâmetros válidos."};
}
function parametro_campo(_nome,_tipo,_chave,_indice,_receita,_min,_max,_passo=1,_moeda=false) {
    return {nome:_nome,tipo:_tipo,chave:_chave,indice:_indice,receita:_receita,
        minimo:_min,maximo:_max,passo:_passo,moeda:_moeda};
}
function parametros_campos(_p) {
    var _lista=[
        parametro_campo("DURAÇÃO / DIAS DE OPERAÇÃO","geral","duracao_dias",0,0,1,60),
        parametro_campo("GERAL / CAIXA INICIAL","geral","caixa_inicial_centavos",0,0,0,10000000,10000,true),
        parametro_campo("GERAL / CAPACIDADE DIÁRIA","geral","capacidade_diaria",0,0,1,10000,10),
        parametro_campo("PEDIDOS / QUANTIDADE MÍNIMA","geral","pedido_quantidade_min",0,0,1,1000),
        parametro_campo("PEDIDOS / QUANTIDADE MÁXIMA","geral","pedido_quantidade_max",0,0,1,1000),
        parametro_campo("PEDIDOS / PRAZO EM DIAS","geral","prazo_pedido_dias",0,0,1,30),
        parametro_campo("OFERTAS / VALIDADE EM DIAS","geral","oferta_validade_dias",0,0,0,30)
    ];
    for(var _i=0;_i<array_length(_p.catalogo.ingredientes);_i++) {
        var _n=_p.catalogo.ingredientes[_i].nome+" / ";
        array_push(_lista,parametro_campo(_n+"ESTOQUE INICIAL","ingrediente","estoque_inicial",_i,0,0,1000000,5),
            parametro_campo(_n+"ESTOQUE MÍNIMO","ingrediente","estoque_minimo",_i,0,0,1000000),
            parametro_campo(_n+"CUSTO UNITÁRIO","ingrediente","custo_centavos",_i,0,1,10000,1,true),
            parametro_campo(_n+"REPOSIÇÃO EM DIAS","ingrediente","prazo_dias",_i,0,1,30));
    }
    for(var _i=0;_i<array_length(_p.catalogo.produtos);_i++) {
        var _produto=_p.catalogo.produtos[_i],_n=_produto.nome+" / ";
        array_push(_lista,parametro_campo(_n+"PREÇO UNITÁRIO","produto","preco_centavos",_i,0,1,100000,10,true),
            parametro_campo(_n+"CUSTO VARIÁVEL","produto","custo_variavel_centavos",_i,0,0,10000,1,true),
            parametro_campo(_n+"CAPACIDADE POR UN.","produto","capacidade_unidade",_i,0,1,100));
        for(var _k=0;_k<array_length(_produto.receita);_k++) {
            var _nome=ingrediente_obter(_p.catalogo,_produto.receita[_k].ingrediente_id);
            array_push(_lista,parametro_campo(_n+(is_undefined(_nome)?"ID INVÁLIDO":_nome.nome),"receita","quantidade",_i,_k,0,100));
        }
    }
    return _lista;
}
function parametro_alvo(_p,_campo) {
    switch(_campo.tipo) {
        case "geral":return _p;
        case "ingrediente":return _p.catalogo.ingredientes[_campo.indice];
        case "produto":return _p.catalogo.produtos[_campo.indice];
        default:return _p.catalogo.produtos[_campo.indice].receita[_campo.receita];
    }
}
function parametro_ler(_p,_campo) {return variable_struct_get(parametro_alvo(_p,_campo),_campo.chave);}
function parametro_escrever(_p,_campo,_valor) {
    if(!parametro_inteiro(_valor,_campo.minimo,_campo.maximo)) return false;
    variable_struct_set(parametro_alvo(_p,_campo),_campo.chave,_valor);return true;
}
function parametros_layout() {
    var _l={anterior:ui_area(24,618,180,56),proxima:ui_area(218,618,180,56),
        restaurar:ui_area(414,618,290,56),voltar:ui_area(722,618,190,56),iniciar:ui_area(930,618,326,56),
        confirmar:ui_area(680,446,330,56),cancelar:ui_area(270,446,330,56),linhas:[]};
    for(var _i=0;_i<6;_i++) array_push(_l.linhas,{menos:ui_area(820,172+_i*65,52,48),
        valor:ui_area(886,172+_i*65,270,48),mais:ui_area(1170,172+_i*65,52,48)});
    return _l;
}
function parametros_clique(_mx,_my) {
    if(campo_editando<0 && ui_contem(ui_area(930,102,326,46),_mx,_my)) {modo_guiado=!modo_guiado;configuracao=modo_guiado?missoes_parametros():parametros_padrao();campos=parametros_campos(configuracao);pagina=0;mensagem=modo_guiado?"História: receita inicial viável; queijo inicial zero e reposição com prazo.":"Livre: parâmetros e exploração sem sequência de missões.";return;}
    if(campo_editando>=0) {
        if(ui_contem(layout.cancelar,_mx,_my)) campo_editando=-1;
        else if(ui_contem(layout.confirmar,_mx,_my)) parametros_confirmar();
        return;
    }
    if(ui_contem(layout.anterior,_mx,_my)) pagina=max(0,pagina-1);
    else if(ui_contem(layout.proxima,_mx,_my)) pagina=min(ceil(array_length(campos)/6)-1,pagina+1);
    else if(ui_contem(layout.restaurar,_mx,_my)) {
        configuracao=modo_guiado?missoes_parametros():parametros_padrao();campos=parametros_campos(configuracao);pagina=0;
        mensagem="Padrões restaurados na configuração. A partida atual só muda ao iniciar.";
    }
    else if(ui_contem(layout.voltar,_mx,_my)) jogo_ir_para(FaseJogo.MENU);
    else if(ui_contem(layout.iniciar,_mx,_my)) {
        var _val=modo_guiado?missoes_validar_config(configuracao):parametros_validar(configuracao);mensagem=_val.mensagem;
        if(_val.ok) {global.jogo=jogo_criar(configuracao);exploracao_iniciar(global.jogo);if(modo_guiado)missoes_iniciar(global.jogo);jogo_ir_para(FaseJogo.FABRICA);}
    } else for(var _i=0;_i<6;_i++) {
        var _idx=pagina*6+_i;if(_idx>=array_length(campos)) break;
        var _c=campos[_idx],_l=layout.linhas[_i],_valor=parametro_ler(configuracao,_c);
        if(ui_contem(_l.menos,_mx,_my)) parametro_escrever(configuracao,_c,max(_c.minimo,_valor-_c.passo));
        if(ui_contem(_l.mais,_mx,_my)) parametro_escrever(configuracao,_c,min(_c.maximo,_valor+_c.passo));
        if(ui_contem(_l.valor,_mx,_my)) {campo_editando=_idx;keyboard_string="";mensagem="Digite um número inteiro; dinheiro em centavos.";}
    }
}
function parametros_confirmar() {
    var _texto=keyboard_string;
    var _valido=string_length(_texto)>0 && string_length(_texto)<=9;
    for(var _i=1;_i<=string_length(_texto);_i++) if(string_pos(string_char_at(_texto,_i),"0123456789")==0) _valido=false;
    if(!_valido) {mensagem="Use apenas dígitos, sem vírgula ou ponto.";return;}
    if(parametro_escrever(configuracao,campos[campo_editando],real(_texto))) {campo_editando=-1;mensagem="Valor atualizado.";}
    else mensagem="Valor fora dos limites exibidos.";
}
function parametros_desenhar() {
    var _v=global.visual;ui_fundo();ui_titulo("VALORES FICTÍCIOS PARA APRENDIZAGEM");
    ui_texto(24,116,"PARÂMETROS / CLIQUE NO VALOR OU USE + E -",2,_v.tinta);
    ui_botao(ui_area(930,102,326,46),modo_guiado?"HISTÓRIA GUIADA":"MODO LIVRE",_v.verde);
    for(var _i=0;_i<6;_i++) {
        var _idx=pagina*6+_i;if(_idx>=array_length(campos)) break;
        var _c=campos[_idx],_l=layout.linhas[_i],_yy=172+_i*65;
        ui_cartao(24,_yy,1232,48,_v.claro);
        // Nomes longos usam a escala pequena, sem cortar os dados do catálogo.
        var _esc=ui_texto_largura(_c.nome,2)>770?1:2;
        ui_texto(40,_yy+17,_c.nome,_esc,_v.tinta);
        ui_botao(_l.menos,"-",_v.tinta);ui_botao(_l.mais,"+",_v.tinta);
        var _valor=parametro_ler(configuracao,_c);
        ui_botao(_l.valor,_c.moeda?financas_formatar(_valor):string(_valor),_v.azul);
    }
    ui_texto(24,586,"PÁGINA "+string(pagina+1)+" / "+string(ceil(array_length(campos)/6)),2,_v.suave);
    ui_botao(layout.anterior,"ANTERIOR",_v.tinta,pagina>0);
    ui_botao(layout.proxima,"PRÓXIMA",_v.tinta,pagina<ceil(array_length(campos)/6)-1);
    ui_botao(layout.restaurar,"RESTAURAR PADRÕES",_v.verde);
    ui_botao(layout.voltar,"MENU",_v.tinta);ui_botao(layout.iniciar,"INICIAR SIMULAÇÃO",_v.laranja);
    ui_texto(24,698,mensagem,1,_v.tinta);
    if(campo_editando>=0) {
        draw_set_alpha(.65);draw_set_color(_v.tinta);draw_rectangle(0,92,1279,719,false);draw_set_alpha(1);
        ui_cartao(240,232,800,300,_v.claro);
        var _c=campos[campo_editando];
        ui_centro(640,264,"EDITAR PARÂMETRO",3,_v.tinta);
        ui_centro(640,310,_c.nome,1,_v.suave);
        ui_centro(640,344,"LIMITE: "+string(_c.minimo)+" A "+string(_c.maximo)+(_c.moeda?" CENTAVOS":""),2,_v.tinta);
        ui_centro(640,390,string_copy(keyboard_string,1,9)+"_",3,_v.azul);
        ui_botao(layout.cancelar,"CANCELAR",_v.tinta);ui_botao(layout.confirmar,"CONFIRMAR",_v.verde);
        ui_texto(260,516,mensagem,1,_v.laranja);
    }
}
