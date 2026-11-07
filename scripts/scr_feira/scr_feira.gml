/// Feira: cinco minutos iniciais, perguntas com bônus e até dez resgates de tempo.
function feira_ativa(_j){return variable_struct_exists(_j,"feira");}
function feira_criar(_parametros=undefined){
    var _p=is_undefined(_parametros)?missoes_parametros():json_parse(json_stringify(_parametros));_p.duracao_dias=1;
    var _j=jogo_criar(_p);
    _j.feira={segundos:0,iniciada:false,limite_segundos:_p.demonstracao_segundos,lembrete_exibido:false,lembrete_segundos:0,
        bonus_tempo:0,bonus_chaves:[],resgate:undefined,resgates_usados:0,resgates_acertos:0,resgates_max:10,respostas_resgate:[],
        concluida:false,venceu:false,fim_segundos:0,reinicio_segundos:30,insumos:[],receita_centavos:0,quantidade:0};
    missoes_iniciar(_j);return _j;
}
function feira_jogar(){global.jogo=feira_criar();room_goto(rm_corredor);}
function feira_inicio(){global.jogo=jogo_criar();room_goto(rm_menu);}
function feira_conteudo(_j,_id){return undefined;}
/// Devolve true quando é hora de voltar ao início; não muda de sala nos testes de estado.
function feira_passo(_j,_dt){
    if(!feira_ativa(_j))return false;
    var _f=_j.feira;_dt=max(0,_dt);
    if(confirmacao_aberta(_j))return false;
    if(_f.concluida){
        if(_f.venceu)return false;
        _f.fim_segundos=min(_f.reinicio_segundos,_f.fim_segundos+_dt);
        return _f.fim_segundos>=_f.reinicio_segundos;
    }
    if(feira_resgate_aberto(_j))return false;
    if(historia_introducao_aberta(_j))return false;
    _f.iniciada=true;
    if(_j.pausado || historia_decisao_pendente(_j) || historia_quiz_aberto(_j) || maquinas_decisao_aberta(_j))return false;
    _f.lembrete_segundos=max(0,_f.lembrete_segundos-_dt);
    _f.segundos=min(_f.limite_segundos,_f.segundos+_dt);
    if(_f.segundos>=_f.limite_segundos){
        if(_f.resgates_usados<_f.resgates_max)feira_resgate_abrir(_j);else feira_finalizar(_j,false);
        return false;
    }
    if(!_f.lembrete_exibido && _f.segundos>=_f.limite_segundos/2){
        _f.lembrete_exibido=true;_f.lembrete_segundos=5;feedback_som("alerta");
    }
    return false;
}
function feira_resgate_aberto(_j){return feira_ativa(_j) && is_struct(_j.feira.resgate);}
function feira_bonus_tempo(_j,_segundos,_chave){
    if(!feira_ativa(_j) || _j.feira.concluida || _j.encerrado || _segundos<=0 || floor(_segundos)!=_segundos)return 0;
    var _f=_j.feira;if(array_contains(_f.bonus_chaves,_chave))return 0;
    array_push(_f.bonus_chaves,_chave);_f.limite_segundos+=_segundos;_f.bonus_tempo+=_segundos;_f.lembrete_segundos=0;
    diario_registrar(_j,"TEMPO EXTRA","Acerto: +"+feira_tempo(_segundos)+". O pedido continua de onde estava.");return _segundos;
}
function feira_banco_resgates(){return [
    {pergunta:"Falta ingrediente na cozinha, mas existe no Estoque. O que fazer?",opcoes:["Buscar no Estoque e depositar na cozinha.","Comprar tudo novamente.","Cozinhar sem esse ingrediente."],correta:0,explicacao:"Transporte o que já existe na empresa antes de comprar mais."},
    {pergunta:"Antes de produzir, o que é importante conferir?",opcoes:["Apenas a decoração da fábrica.","O canhoto, os ingredientes e a quantidade pedida.","Somente o nome do cliente."],correta:1,explicacao:"O canhoto orienta a receita e evita falta ou excesso de materiais."},
    {pergunta:"Uma máquina apresentou defeito. Qual atitude é segura?",opcoes:["Continuar usando a máquina com defeito.","Ignorar o problema.","Parar a defeituosa e avaliar técnico ou outra máquina."],correta:2,explicacao:"A máquina com defeito deve ficar parada. Avalie segurança, tempo e recursos."},
    {pergunta:"Quando a venda do pedido entra no caixa?",opcoes:["Assim que os ingredientes são retirados.","Quando os salgados são entregues ao cliente.","Ao abrir a porta do Comercial."],correta:1,explicacao:"A entrega registra a venda e o pagamento, uma única vez."},
    {pergunta:"Os ingredientes já estão na mochila. Qual é o próximo passo?",opcoes:["Depositar na Mesa de depósito da Produção.","Comprar a mesma lista novamente.","Entregar os ingredientes ao cliente."],correta:0,explicacao:"A mesa de preparo usa os ingredientes que estão na cozinha."},
    {pergunta:"O cliente pediu 20 unidades. Como evitar desperdício?",opcoes:["Produzir 50 sem necessidade.","Retirar todos os ingredientes disponíveis.","Preparar a quantidade do pedido e conferir o canhoto."],correta:2,explicacao:"Produzir conforme a demanda evita consumo desnecessário de recursos."},
    {pergunta:"Uma compra está a caminho. Ela já pode ser usada na cozinha?",opcoes:["Sim, basta pagar.","Não. É preciso receber no Estoque e transportar.","Sim, aparece automaticamente na mochila."],correta:1,explicacao:"Compra em trânsito ainda não é estoque físico disponível."},
    {pergunta:"A mochila encheu e ainda faltam ingredientes. O que fazer?",opcoes:["Depositar na Produção e voltar apenas pelo faltante.","Jogar fora os ingredientes transportados.","Retirar acima da capacidade da mochila."],correta:0,explicacao:"O canhoto desconta o que já foi levado; faça outra viagem só pelo faltante."},
    {pergunta:"Os salgados estão prontos e o prazo está acabando. O que priorizar?",opcoes:["Comprar mais ingredientes sem necessidade.","Deixar o pedido parado na cozinha.","Entregar no balcão do Comercial."],correta:2,explicacao:"O pedido só é concluído depois da entrega ao cliente."},
    {pergunta:"Conferir o canhoto e o estoque ajuda a quê?",opcoes:["Gastar ingredientes sem planejamento.","Evitar faltas, compras duplicadas e desperdícios.","Pular a entrega ao cliente."],correta:1,explicacao:"Planejamento organiza materiais, produção e prazo de entrega."}
];}
function feira_resgate_abrir(_j){
    if(!feira_ativa(_j) || _j.feira.concluida || feira_resgate_aberto(_j) || _j.feira.segundos<_j.feira.limite_segundos || _j.feira.resgates_usados>=_j.feira.resgates_max)return false;
    var _f=_j.feira,_b=feira_banco_resgates();_f.resgate=_b[_f.resgates_usados mod array_length(_b)];_f.resgates_usados++;
    _j.fala_visivel=false;feedback_som("alerta");return true;
}
function feira_resgate_responder(_j,_indice){
    if(!feira_resgate_aberto(_j) || _j.pausado || confirmacao_aberta(_j))return false;
    var _f=_j.feira,_q=_f.resgate;
    if(floor(_indice)!=_indice || _indice<0 || _indice>=array_length(_q.opcoes))return false;
    var _acertou=_indice==_q.correta;array_push(_f.respostas_resgate,{numero:_f.resgates_usados,escolha:_indice,acertou:_acertou});_f.resgate=undefined;
    if(_acertou){_f.resgates_acertos++;feira_bonus_tempo(_j,120,"resgate:"+string(_f.resgates_usados));}
    else feira_finalizar(_j,false);
    _j.confirmacao={titulo:_acertou?"Acertou! +2 minutos":"Boa tentativa!",texto:_q.explicacao+(_acertou?" Você ganhou mais 2 minutos. Continue o pedido de onde parou.":" A rodada terminou. Confira o resultado e tente novamente."),acao:"resgate",sucesso:_acertou,botao:_acertou?"CONTINUAR COM MAIS 2 MINUTOS":"VER RESULTADO / ENTER"};
    return true;
}
function feira_resgate_encerrar(_j){
    if(!feira_resgate_aberto(_j))return false;
    _j.feira.resgate=undefined;feira_finalizar(_j,false);
    _j.confirmacao={titulo:"Rodada encerrada",texto:"Você pode conferir o resultado ou começar uma nova rodada.",acao:"resgate_encerrar",sucesso:false,botao:"VER RESULTADO / ENTER"};return true;
}
function feira_resgate_botoes(_j){
    var _q=_j.feira.resgate,_a=[];
    for(var _i=0;_i<array_length(_q.opcoes);_i++)array_push(_a,{area:ui_area(376,308+_i*66,824,52),texto:string(_i+1)+". "+_q.opcoes[_i],acao:"resgate_resposta_"+string(_i)});
    array_push(_a,{area:ui_area(376,526,824,40),texto:"ENCERRAR A RODADA / VER RESULTADO",acao:"resgate_encerrar"});return _a;
}
function feira_resgate_desenhar(_j){
    var _v=global.visual,_f=_j.feira;
    draw_set_alpha(.82);draw_set_color(_v.papel);draw_rectangle(0,0,1280,720,false);draw_set_alpha(1);
    ui_cartao(352,140,888,460,_v.claro);
    ui_texto(376,166,"Tempo esgotado! Quer mais 2 minutos?",2,_v.ouro);
    ui_texto(376,204,"Resgate "+string(_f.resgates_usados)+" de "+string(_f.resgates_max)+" · Acerte para continuar de onde parou.",1,_v.ciano);
    ui_paragrafo(376,248,_f.resgate.pergunta,824,_v.tinta);
    var _a=feira_resgate_botoes(_j);for(var _i=0;_i<array_length(_a);_i++)ui_botao(_a[_i].area,_a[_i].texto,_i<3?_v.azul:_v.linha);
    ui_texto(376,576,"Jogo pausado. Clique na resposta ou use 1, 2 ou 3. Errar encerra a rodada.",1,_v.suave);
}
function feira_finalizar(_j,_venceu=true){
    var _f=_j.feira;if(_f.concluida)return;
    var _p=missoes_atual(_j);
    // O resultado só declara vitória se a entrega foi registrada dentro do dia.
    _f.venceu=_venceu && array_length(_j.missoes.entregues)>=_j.missoes.meta && _f.segundos<_f.limite_segundos;
    if(!is_undefined(_p) && _p.status=="aceito" && !_f.venceu)_p.prazo_esgotado=true;
    _f.quantidade=_j.producao.unidades_produzidas;
    _f.receita_centavos=_j.financas.receitas_centavos;
    for(var _i=0;_i<array_length(_j.producao.lotes);_i++){
        var _l=_j.producao.lotes[_i];for(var _k=0;_k<array_length(_l.insumos);_k++)array_push(_f.insumos,_l.insumos[_k]);
    }
    _f.concluida=true;_f.resgate=undefined;_f.fim_segundos=0;_f.lembrete_segundos=0;
    _j.pausado=false;_j.fala_visivel=false;historia_fechar(_j);
    _j.missoes.etapa=EtapaMissao.RESULTADOS;missoes_finalizar(_j);
    diario_registrar(_j,_f.venceu?"DIA SUPERADO":"TEMPO DO DIA ENCERRADO",_f.venceu?"Pedido entregue dentro do tempo da demonstração.":"Fim do tempo, sem entrega automática nem pagamento inventado.");
}
function feira_tempo(_s){return string(floor(_s/60))+":"+string_copy("0"+string(floor(_s) mod 60),max(1,string_length("0"+string(floor(_s) mod 60))-1),2);}
function feira_botoes(_c){return [{area:ui_area(104,578,520,58),texto:"VOLTAR AO MENU",acao:"feira_inicio"},
    {area:ui_area(650,578,526,58),texto:global.jogo.feira.venceu?"JOGAR NOVAMENTE":"TENTAR NOVAMENTE",acao:"feira_jogar"}];}
function feira_continuar(_j){
    if(!feira_ativa(_j) || _j.feira.concluida || confirmacao_aberta(_j))return false;
    _j.pausado=false;return true;
}
function feira_relogio_desenhar(_j,_c,_x=1000,_consulta=false){
    var _f=_j.feira,_v=global.visual,_resto=max(0,_f.limite_segundos-_f.segundos);
    var _cor=_resto<=20?_v.vermelho:(_resto<=60?_v.ouro:_v.ciano);
    ui_texto(_x,22,feira_tempo(ceil(_resto)),3,_cor);
    ui_texto(_x+100,36,historia_introducao_aberta(_j)?"Após a introdução":(_consulta || _j.pausado || confirmacao_aberta(_j) || historia_quiz_aberto(_j) || historia_decisao_pendente(_j) || maquinas_decisao_aberta(_j)?"Tempo pausado":"Tempo restante"),1,_v.suave);
    ui_texto_ajustado(_x,60,"Resgates: "+string(_f.resgates_usados)+"/"+string(_f.resgates_max)+" · Extra: "+feira_tempo(_f.bonus_tempo),1,248,_v.suave);
    ui_barra_segmentada(_x,80,248,6,_resto/_f.limite_segundos,_cor);
    if(!_consulta && _f.lembrete_segundos>0 && is_undefined(_c.painel) && !_c.ajuda && !historia_aberta(_j) && !maquinas_decisao_aberta(_j)){
        ui_cartao(360,200,600,68,_v.painel);
        ui_centro(660,214,"Metade do tempo! Faltam "+feira_tempo(ceil(_resto)),2,_v.ouro);
        ui_centro(660,246,"Siga o próximo passo para concluir a entrega.",1,_v.tinta);
    }
}

function feira_avaliacao(_j,_r){
    if(_r.pedidos_atendidos==0)return "Faltou concluir a entrega. Confira o objetivo, planeje o transporte e reserve tempo para o Comercial.";
    if(_r.entregas_atrasadas+_r.abertos_atrasados>0)return "Sua equipe produziu, mas precisa organizar melhor os prazos.";
    var _baixo=false;for(var _i=0;_i<array_length(_r.estoque_final);_i++)if(_r.estoque_final[_i].fisico<_r.estoque_final[_i].minimo)_baixo=true;
    if(_baixo)return "Sua equipe atendeu o pedido, mas precisa planejar a reposição do estoque.";
    return "Boa gestão! Sua equipe organizou a produção e entregou no prazo.";
}
function feira_resultado_desenhar(_c){
    var _j=global.jogo,_f=_j.feira,_v=global.visual,_r=dashboard_calcular(_j);
    draw_set_color(_v.painel);draw_rectangle(0,0,1280,720,false);
    ui_centro(640,22,"MUNDO SENAI / GESTÃO NA PRÁTICA",3,_v.ciano);
    ui_centro(640,76,_f.venceu?"VOCÊ ZEROU O JOGO! / 5 PEDIDOS ENTREGUES":"TEMPO DA DEMONSTRAÇÃO ENCERRADO",2,_f.venceu?_v.verde:_v.ouro);
    ui_cartao(104,116,1072,430,_v.claro);
    var _esq=["RECEBIDOS: "+string(_r.recebidos),"ACEITOS: "+string(_r.aceitos),"RECUSADOS: "+string(_r.recusados),"ENTREGUES: "+string(_r.pedidos_atendidos),"ATRASADOS: "+string(_r.entregas_atrasadas+_r.abertos_atrasados),"PRODUZIDOS: "+string(_r.unidades_produzidas)];
    var _dir=["VENDAS: "+financas_formatar(_r.receitas_centavos),"CUSTOS PAGOS: "+financas_formatar(_r.custos_pagos_centavos),"RESULTADO DE CAIXA: "+financas_formatar(_r.resultado_caixa_centavos),"FALHAS: "+string(_r.falhas_maquinas),"MANUTENÇÃO: "+string_format(_r.tempo_manutencao,0,1)+" S","TEMPO EXTRA: "+feira_tempo(_f.bonus_tempo)];
    for(var _i=0;_i<6;_i++){ui_texto(128,138+_i*32,_esq[_i],2,_v.tinta);ui_texto(650,138+_i*32,_dir[_i],2,_v.tinta);}
    var _consumo="CONSUMO REAL: ";for(var _i=0;_i<array_length(_r.ingredientes_consumidos);_i++){var _a=_r.ingredientes_consumidos[_i];_consumo+=_a.nome+" "+string(_a.quantidade)+" / ";}
    ui_paragrafo(128,352,_consumo,1010,_v.suave);
    ui_paragrafo(128,412,feira_avaliacao(_j,_r),1010,_v.tinta);
    ui_texto(128,508,"CAIXA = VENDAS + BÔNUS - COMPRAS - PREPARO - MANUTENÇÃO",1,_v.suave);
    ui_centro(640,552,"CADA ENTREGA CONTA: COMPLETE AS CINCO MISSÕES DA FÁBRICA.",1,_v.claro);
    ui_centro(640,682,_f.venceu?"PARABÉNS! VOCÊ CONCLUIU TODAS AS MISSÕES.":"VOLTANDO AO INÍCIO EM "+string(ceil(max(0,_f.reinicio_segundos-_f.fim_segundos)))+" S / VALORES DIDÁTICOS",1,_v.suave);
}
