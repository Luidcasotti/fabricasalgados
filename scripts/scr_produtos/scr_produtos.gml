/// Porções e preços fictícios para aprendizagem, sem equivalência culinária.
function produtos_catalogo_criar() {
    var _ingredientes=[
        {id:"farinha",nome:"Farinha",unidade:"porção",estoque_inicial:120,estoque_minimo:30,custo_centavos:60,prazo_dias:1},
        {id:"frango",nome:"Frango",unidade:"porção",estoque_inicial:60,estoque_minimo:15,custo_centavos:80,prazo_dias:2},
        {id:"queijo",nome:"Queijo",unidade:"porção",estoque_inicial:100,estoque_minimo:25,custo_centavos:70,prazo_dias:1},
        {id:"oleo",nome:"Óleo",unidade:"porção",estoque_inicial:200,estoque_minimo:40,custo_centavos:20,prazo_dias:1},
        {id:"embalagens",nome:"Embalagens",unidade:"unidade",estoque_inicial:120,estoque_minimo:30,custo_centavos:15,prazo_dias:2}
    ];
    var _produtos=[];
    var _ids=["coxinha","pastel","bolinha_queijo"];
    var _nomes=["Coxinha","Pastel","Bolinha de queijo"];
    var _precos=[600,500,400];
    var _receitas=[[1,1,0,1,1],[1,0,1,1,1],[1,0,2,1,1]];
    for(var _i=0;_i<3;_i++) {
        var _receita=[];
        for(var _j=0;_j<array_length(_ingredientes);_j++)
            array_push(_receita,{ingrediente_id:_ingredientes[_j].id,quantidade:_receitas[_i][_j]});
        array_push(_produtos,{id:_ids[_i],nome:_nomes[_i],preco_centavos:_precos[_i],
            custo_variavel_centavos:25,capacidade_unidade:1,receita:_receita});
    }
    return {ingredientes:_ingredientes,produtos:_produtos};
}
function catalogo_buscar(_itens,_id) {
    for(var _i=0;_i<array_length(_itens);_i++) if(_itens[_i].id==_id) return _itens[_i];
    return undefined;
}
function produto_obter(_catalogo,_id) {return catalogo_buscar(_catalogo.produtos,_id);}
function ingrediente_obter(_catalogo,_id) {return catalogo_buscar(_catalogo.ingredientes,_id);}
