/// Falas e perguntas são opcionais. Erros usam o rodapé e não cobrem a fábrica.
function confirmacao_aberta(_j){return variable_struct_exists(_j,"confirmacao") && is_struct(_j.confirmacao);}
function confirmacao_fechar(_j){if(!confirmacao_aberta(_j))return false;_j.confirmacao=undefined;return true;}
function confirmacao_apos_acao(_c,_r,_acao){
    if(!_r.ok)return;
    var _titulo="";
    switch(_acao){
        case "aceitar":_titulo="Pedido aceito!";break;
        case "recusar":_titulo="Pedido recusado";break;
        case "separar_pedido":case "retirar":case "retirar_necessario":_titulo="Ingredientes separados!";break;
        case "depositar":_titulo="Ingredientes depositados!";break;
        case "produzir":_titulo=is_undefined(_c.lote_em_curso)?"Pedido pronto!":"Preparo iniciado!";break;
        case "cozinhar":_titulo="Pedido pronto!";break;
        case "entregar":_titulo=missoes_zerou(global.jogo)?"Você zerou o jogo!":"Pedido entregue!";break;
        case "encerrar dia":_titulo="Dia encerrado";break;
        case "comprar":case "comprar_faltante":_titulo="Compra registrada!";break;
        case "consultar_estoque":_titulo="Estoque conferido!";break;
        case "novo pedido":case "outro pedido":_titulo="Novo pedido disponível";break;
    }
    if(_titulo=="")return;
    var _j=global.jogo;
    _j.confirmacao={titulo:_titulo,texto:_r.mensagem,acao:_acao,
        botao:feira_ativa(_j) && _j.feira.concluida?"VER RESULTADO / ENTER":"CONFIRMAR / CONTINUAR"};
    _c.entrada_pronta=false;
}
function confirmacao_botoes(_j){
    if(_j.confirmacao.acao=="saida")return [{area:ui_area(380,470,390,60),texto:"CONTINUAR JOGANDO",acao:"cancelar_saida"},{area:ui_area(790,470,414,60),texto:"ENCERRAR / IR AO MENU",acao:"confirmar_saida"}];
    return [{area:ui_area(380,470,824,60),texto:_j.confirmacao.botao,acao:"confirmar_ato"}];}
function confirmacao_desenhar(_j){
    var _v=global.visual,_c=_j.confirmacao;
    draw_set_alpha(.78);draw_set_color(_v.papel);draw_rectangle(0,0,1280,720,false);draw_set_alpha(1);
    ui_cartao(352,184,888,400,_v.claro);
    ui_texto(380,220,_c.titulo,3,variable_struct_exists(_c,"sucesso") && !_c.sucesso?_v.ouro:_v.verde);
    ui_paragrafo(380,292,_c.texto,824,_v.tinta);
    var _b=confirmacao_botoes(_j);for(var _i=0;_i<array_length(_b);_i++)ui_botao(_b[_i].area,_b[_i].texto,_v.azul);
    ui_texto(380,552,"Tempo pausado enquanto você lê. Enter ou Espaço também confirmam.",1,_v.suave);
}
function historia_introducao_aberta(_j){
    if(!historia_aberta(_j))return false;
    return string_pos("intro_",_j.missoes.fila[_j.missoes.indice_fala].id)==1;
}
function historia_fala(_id,_p,_t,_fim=""){return {id:_id,tipo:"fala",personagem:_p,texto:_t,acao_final:_fim};}
function historia_pergunta(_id,_t,_op,_correta,_exp){return {id:_id,tipo:"pergunta",personagem:"PERGUNTA RÁPIDA / ACERTO VALE R$ 10",texto:_t,opcoes:_op,correta:_correta,explicacoes:_exp,acao_final:""};}
function historia_decisao_pendente(_j){
    if(!historia_aberta(_j))return false;
    var _f=_j.missoes.fila[_j.missoes.indice_fala];
    return _f.tipo=="decisao" || _f.tipo=="consequencia";
}
function historia_decisao_registrar(_j,_id,_escolha,_consequencia,_aprendizado){
    if(!missoes_ativa(_j))return;
    var _m=_j.missoes;
    for(var _i=0;_i<array_length(_m.decisoes);_i++)if(_m.decisoes[_i].id==_id)return;
    array_push(_m.decisoes,{id:_id,escolha:_escolha,consequencia:_consequencia,aprendizado:_aprendizado});
    diario_registrar(_j,"DECISÃO / "+_escolha,_consequencia+" Aprendizado: "+_aprendizado);
}
function historia_decisao_responder(_j,_indice){
    if(!historia_decisao_pendente(_j) || _j.pausado || _j.encerrado)return false;
    var _m=_j.missoes,_f=_m.fila[_m.indice_fala];
    if(_f.tipo!="decisao" || _m.resposta_atual>=0 || floor(_indice)!=_indice || _indice<0 || _indice>=array_length(_f.opcoes))return false;
    if(_f.id=="dec_ingredientes" && _indice==0){
        var _r=missoes_consultar_estoque(_j);if(!_r.ok)return false;
    }
    _m.resposta_atual=_indice;
    historia_decisao_registrar(_j,_f.id,_f.opcoes[_indice],_f.explicacoes[_indice],_f.aprendizado);return true;
}
function historia_consequencia_maquina(_j,_acao,_texto){
    var _a=historia_fala("consequencia_defeito","DECISÃO 1 / CONSEQUÊNCIA",_texto);
    _a.tipo="consequencia";_a.aprendizado="É importante avaliar tempo, segurança e recursos disponíveis.";
    _a.escolha=_acao=="manutencao"?"A. CHAMAR O TÉCNICO":(_acao=="continuar"?"B. USAR OUTRA MÁQUINA":"REORGANIZAR A EQUIPE");
    array_push(_j.missoes.fila,_a);
}
function historia_conteudo(_j,_id){
    switch(_id){
        case "dec_ingredientes":return [{id:_id,tipo:"decisao",personagem:"DECISÃO 2 / INGREDIENTES",texto:"Como organizar os ingredientes?",
            opcoes:["A. Conferir o estoque antes de produzir.","B. Começar sem conferir."],
            explicacoes:["Você conferiu a lista do pedido e os ingredientes disponíveis. Agora use PEGAR INGREDIENTES DO PEDIDO com Caio para separar tudo.","Sem conferir, pode faltar ingrediente e atrasar o pedido. Seu canhoto continua visível: acompanhe as quantidades antes de cozinhar."],
            aprendizado:"O controle do estoque ajuda a evitar problemas na produção.",acao_final:""}];
        case "introducao":return [
            historia_fala("intro_1","FUNCIONÁRIO DA FÁBRICA","Olá! Seja bem-vindo à nossa Fábrica de Salgados!"),
            historia_fala("intro_2","FUNCIONÁRIO DA FÁBRICA",feira_ativa(_j)?"Você terá "+feira_tempo(_j.feira.limite_segundos)+" para cumprir 5 pedidos, começando com 20 bolinhas. O relógio só começa depois desta introdução. Acertar perguntas dá +2 minutos. No zero, haverá até 10 resgates.":"Sua história tem 5 pedidos. Entregue um, aceite o próximo com Marta e continue até zerar o jogo."),
            historia_fala("intro_3","FUNCIONÁRIO DA FÁBRICA","Use WASD ou as setas para andar. Chegue perto de uma porta, mesa ou prateleira e pressione E. Use E outra vez para fechar."),
            historia_fala("intro_4","FUNCIONÁRIO DA FÁBRICA","Siga o passo atual e a seta. Busque os ingredientes no Estoque, deposite na Produção, cozinhe e entregue no Comercial."),
            historia_fala("intro_5","FUNCIONÁRIO DA FÁBRICA","Primeiro aceite o pedido com Marta no Comercial. Você receberá um canhoto. No Estoque, Caio separa os ingredientes da lista em um clique.")];
        case "pergunta_estoque":case "q_estoque":return [historia_pergunta("q_estoque","Falta queijo na cozinha, mas tem queijo no Estoque. O que fazer?",["Buscar o queijo e levar à Produção.","Comprar mais sem olhar a prateleira.","Cozinhar sem queijo."],0,["Isso! Busque na prateleira e deposite na Produção.","Já existe queijo na empresa. Basta buscar na prateleira.","A receita precisa do queijo. Busque no Estoque."])];
        case "pergunta_risco":case "q_risco":return [historia_pergunta("q_risco","Você trouxe os ingredientes na mochila. Qual é o próximo passo?",["Entregar a mochila ao cliente.","Depositar os ingredientes na cozinha.","Comprar tudo de novo."],1,["O cliente recebe os salgados prontos. Deposite e cozinhe primeiro.","Isso! A mesa de preparo usa os ingredientes depositados na cozinha.","Não precisa comprar de novo. Deposite o que já trouxe."])];
        case "pergunta_excesso":case "q_excesso":return [historia_pergunta("q_excesso","Os salgados estão prontos. Como receber o pagamento do pedido?",["Deixar os salgados na cozinha.","Comprar mais ingredientes.","Entregar no balcão do Comercial."],2,["Falta entregar ao cliente. Vá ao balcão do Comercial.","A compra é outra tarefa. Entregue os salgados prontos.","Isso! A entrega registra a venda e o pagamento."])];
        case "informacoes":
            var _p=missoes_atual(_j);if(is_undefined(_p))return [];
            return [historia_fala("informacoes","PEDIDO #"+string(_p.id),string(_p.quantidade)+" "+produto_obter(_j.catalogo,_p.produto_id).nome+". Valor: "+financas_formatar(_p.total_centavos)+". Entrega até o dia "+string(_p.prazo_dia)+". "+missoes_fluxo(_j).acao)];
    }
    return [];
}
function historia_aberta(_j){return missoes_ativa(_j) && _j.missoes.indice_fala<array_length(_j.missoes.fila);}
function historia_quiz_aberto(_j){return historia_aberta(_j) && _j.missoes.fila[_j.missoes.indice_fala].tipo=="pergunta";}
function historia_enfileirar(_j,_id,_repetir=false){
    if(!missoes_ativa(_j))return;
    var _m=_j.missoes,_f=historia_conteudo(_j,_id);if(array_length(_f)==0)return;
    if(_f[0].tipo=="pergunta" && feira_ativa(_j))_f[0].personagem="PERGUNTA / ACERTO VALE +2 MINUTOS";
    if(_f[0].tipo=="pergunta")for(var _i=0;_i<array_length(_m.respostas);_i++)if(_m.respostas[_i].id==_f[0].id)return;
    if(!_repetir && variable_struct_exists(_m.vistos,_id))return;
    variable_struct_set(_m.vistos,_id,true);_j.fala_visivel=false;
    for(var _i=0;_i<array_length(_f);_i++)array_push(_m.fila,_f[_i]);
}
function historia_fechar(_j){
    if(!missoes_ativa(_j))return;
    _j.missoes.indice_fala=array_length(_j.missoes.fila);_j.missoes.resposta_atual=-1;
}
function historia_continuar(_j){
    if(!historia_aberta(_j))return false;
    _j.missoes.indice_fala++;_j.missoes.resposta_atual=-1;return true;
}
function historia_responder(_j,_indice){
    if(!historia_aberta(_j) || _j.pausado || _j.encerrado || confirmacao_aberta(_j) || feira_resgate_aberto(_j))return false;
    if(feira_ativa(_j) && _j.feira.segundos>=_j.feira.limite_segundos)return false;
    var _m=_j.missoes,_f=_m.fila[_m.indice_fala];
    if(_f.tipo!="pergunta" || _m.resposta_atual>=0 || floor(_indice)!=_indice || _indice<0 || _indice>=array_length(_f.opcoes))return false;
    for(var _i=0;_i<array_length(_m.respostas);_i++)if(_m.respostas[_i].id==_f.id)return false;
    var _acertou=_indice==_f.correta,_bonus=0,_tempo=0;
    if(_acertou && feira_ativa(_j))_tempo=feira_bonus_tempo(_j,120,"quiz:"+_f.id);
    else if(_acertou && financas_registrar(_j.financas,1000,"Bônus da pergunta: "+_f.id,"bonus",_j.dia,"quiz:"+_f.id)){_bonus=1000;_m.bonus_centavos+=1000;}
    _m.resposta_atual=_indice;
    array_push(_m.respostas,{id:_f.id,dia:_j.dia,escolha:_indice,correta:_acertou,bonus_centavos:_bonus,bonus_segundos:_tempo,explicacao:_f.explicacoes[_indice]});
    var _pendentes=[];for(var _i=0;_i<array_length(_m.perguntas);_i++)if(_m.perguntas[_i]!=_f.id)array_push(_pendentes,_m.perguntas[_i]);_m.perguntas=_pendentes;
    diario_registrar(_j,"PERGUNTA / "+_f.id,_f.explicacoes[_indice]+(_tempo>0?" Mais 2 minutos no relógio.":(_bonus>0?" Bônus de R$ 10 no caixa.":" Sem bônus nesta resposta.")));return true;
}
function historia_selecionar_pedido(_c){
    var _j=global.jogo,_p=missoes_atual(_j);if(is_undefined(_p))return;
    for(var _i=0;_i<array_length(_j.catalogo.produtos);_i++)if(_j.catalogo.produtos[_i].id==_p.produto_id)_c.selecao=_i;
    _c.quantidade=missoes_restante(_j,_p);
}
function historia_producao_iniciar(_c,_id,_q) {
    var _j=global.jogo,_b=exploracao_bloqueio_local(_j,"bancada");if(_b!="")return {ok:false,mensagem:_b};
    var _v=missoes_permitir(_j,"produzir",_id,_q);if(!_v.ok)return _v;
    _v=exploracao_receita_validar(_j,_id,_q);if(!_v.ok)return _v;
    if(!is_undefined(_c.lote_em_curso))return {ok:false,mensagem:"O preparo já está em andamento."};
    _c.lote_em_curso={produto_id:_id,quantidade:_q,unidades_preparadas:0};_c.lote_frames=0;return {ok:true,mensagem:"Preparando o lote. Materiais e pagamento serão confirmados ao terminar."};
}
function historia_passo(_c,_dt=undefined) {
    if(global.jogo.encerrado){_c.lote_em_curso=undefined;return;}
    if(is_undefined(_c.lote_em_curso) || global.jogo.pausado || historia_decisao_pendente(global.jogo) || historia_quiz_aberto(global.jogo) || feira_resgate_aberto(global.jogo) || confirmacao_aberta(global.jogo))return;
    if(is_undefined(_dt))_dt=delta_time/1000000;
    var _j=global.jogo,_l=_c.lote_em_curso;
    if(maquinas_decisao_aberta(_j))return;
    if(_j.maquinas.aguardar_tecnico)return;
    var _produto=produto_obter(_j.catalogo,_l.produto_id),_vel=maquinas_capacidade(_j)/maquinas_config(_j).segundos_hora/_produto.capacidade_unidade;
    _l.unidades_preparadas+=min(_dt,.05)*_vel;
    _c.lote_frames=90*min(1,_l.unidades_preparadas/_l.quantidade);
    if(_c.lote_frames>=27 && !_j.maquinas.evento_disparado && (feira_ativa(_j) || _j.missoes.segundo_id>0)){
        if(maquinas_falhar(_j))return;
    }
    if(_c.lote_frames>=90) {
        var _l=_c.lote_em_curso;_c.lote_em_curso=undefined;
        exploracao_responder(_c,exploracao_produzir(global.jogo,_l.produto_id,_l.quantidade),"cozinhar");
    }
}
function historia_modal(_c) {return feira_resgate_aberto(global.jogo) || confirmacao_aberta(global.jogo) || maquinas_decisao_aberta(global.jogo) || historia_aberta(global.jogo) || _c.reinicio_confirmar || !is_undefined(_c.lote_em_curso);}


function missoes_guia(_j){return missoes_fluxo(_j);}
function missoes_indicacao(_j,_mundo) {
    var _g=missoes_guia(_j),_id=_g.alvo;
    if(_id=="")return undefined;
    if(_g.setor!=_mundo.setor)_id=(_mundo.setor=="corredor")?"porta_"+_g.setor:"saida";
    return catalogo_buscar(_mundo.alvos,_id);
}
function missoes_indicador_desenhar(_c) {
    if(!missoes_ativa(global.jogo) || historia_modal(_c) || _c.ajuda || !is_undefined(_c.painel))return;
    var _al=missoes_indicacao(global.jogo,_c.mundo),_a=instance_find(obj_cozinheiro,0);if(is_undefined(_al) || !instance_exists(_a))return;
    var _perto=mundo_alvo_proximo(_a,_c.mundo);
    var _p=mundo_projetar(_al.u,_al.v),_ang=point_direction(_a.x,_a.y,_p.x,_p.y);
    // Bússola pequena junto à borda inferior; preserva o centro da fábrica.
    var _x=1220,_y=580;
    ui_cartao(984,202,272,64,global.visual.claro);
    ui_texto(998,218,"SIGA PARA: "+string_upper(missoes_guia(global.jogo).setor),1,global.visual.ciano);
    ui_texto(998,244,_al.nome,1,global.visual.tinta);
    if(!is_undefined(_perto) && _perto.id==_al.id){
        ui_centro(_x,_y-10,"E",3,global.visual.ciano);return;
    }
    draw_set_alpha(.9);draw_set_color(global.visual.painel);draw_circle(_x,_y,25,false);draw_set_alpha(1);
    draw_set_color(global.visual.borda);draw_circle(_x,_y,25,true);draw_circle(_x,_y,22,true);
    draw_set_color(global.visual.ciano);draw_arrow(_x-lengthdir_x(9,_ang),_y-lengthdir_y(9,_ang),_x+lengthdir_x(15,_ang),_y+lengthdir_y(15,_ang),7);
    ui_centro(_x,613,"ROTA",1,global.visual.ciano);
}

function missoes_relatorio(_j){
    var _m=_j.missoes,_a=[{titulo:"TURNO / RESULTADO",texto:"Entregas: "+string(pedidos_contar_status(_j.pedidos,"entregue"))+". Bônus das perguntas: "+financas_formatar(_m.bonus_centavos)+"."}];
    for(var _i=0;_i<array_length(_m.evidencias);_i++)array_push(_a,{titulo:"O QUE VOCÊ FEZ",texto:_m.evidencias[_i]});
    for(var _i=0;_i<array_length(_m.respostas);_i++){
        var _r=_m.respostas[_i],_tempo=variable_struct_exists(_r,"bonus_segundos")?_r.bonus_segundos:0;
        array_push(_a,{titulo:_r.correta?(_tempo>0?"ACERTO / +2 MINUTOS":"ACERTO / +R$ 10"):"RESPOSTA / SEM BÔNUS",texto:_r.explicacao});
    }
    for(var _i=0;_i<array_length(_m.decisoes);_i++){var _d=_m.decisoes[_i];array_push(_a,{titulo:"DECISÃO / "+_d.escolha,texto:_d.consequencia+" Aprendizado: "+_d.aprendizado});}
    return _a;
}
function historia_botoes(_c,_base){
    if(!missoes_ativa(global.jogo))return _base;
    var _j=global.jogo,_a=[];
    if(_c.reinicio_confirmar)return [{area:ui_area(352,446,360,56),texto:"CANCELAR",acao:"cancelar_reinicio"},{area:ui_area(736,446,454,56),texto:"RECOMEÇAR",acao:"confirmar_reinicio"}];
    if(maquinas_decisao_aberta(_j))return maquinas_botoes(_j);
    if(!is_undefined(_c.lote_em_curso) && !historia_decisao_pendente(_j))return [{area:ui_area(356,480,350,56),texto:"CANCELAR PREPARO",acao:"cancelar_lote"},{area:ui_area(730,480,450,56),texto:_j.pausado?"RETOMAR":"PAUSAR",acao:"pausar"}];
    if(historia_aberta(_j)){
        var _m=_j.missoes,_f=_m.fila[_m.indice_fala];
        if(_f.tipo=="decisao" && _m.resposta_atual<0)for(var _i=0;_i<array_length(_f.opcoes);_i++)array_push(_a,{area:ui_area(344,310+_i*70,872,56),texto:_f.opcoes[_i],acao:"decisao_"+string(_i)});
        if(_f.tipo=="pergunta" && _m.resposta_atual<0)for(var _i=0;_i<array_length(_f.opcoes);_i++)array_push(_a,{area:ui_area(344,310+_i*70,872,54),texto:_f.opcoes[_i],acao:"resposta_"+string(_i)});
        var _intro=string_pos("intro_",_f.id)==1;
        array_push(_a,{area:ui_area(344,520,330,48),texto:_intro?"CONTINUAR / ENTER":"VOLTAR AO JOGO",acao:_intro?"continuar_fala":"fechar_conversa"});
        if(_intro)array_push(_a,{area:ui_area(780,520,436,48),texto:"PULAR INTRODUÇÃO",acao:"fechar_conversa"});
        array_push(_a,{area:ui_area(1180,122,36,36),texto:"X",acao:"fechar_conversa"});return _a;
    }
    _a=_base;
    if(_j.missoes.etapa==EtapaMissao.RESULTADOS && !is_undefined(_c.painel) && _c.painel.tipo=="vendas")array_push(_a,{area:ui_area(626,420,568,52),texto:"NOVO PEDIDO",acao:"mais_pedidos"});
    array_push(_a,{area:ui_area(858,648,398,50),texto:"RECOMEÇAR TURNO",acao:"reiniciar_missao"});
    if(!_c.ajuda && array_length(_j.missoes.perguntas)>0)array_push(_a,{area:ui_area(520,26,260,46),texto:feira_ativa(_j)?"Quiz / +2 minutos":"Quiz opcional / +R$ 10",acao:"pergunta"});
    if(!is_undefined(_c.painel) && _c.painel.tipo=="vendas" && _j.missoes.etapa==EtapaMissao.RECUPERAR)array_push(_a,{area:ui_area(626,420,568,52),texto:"OUTRO PEDIDO",acao:"reofertar"});
    return _a;
}
function historia_acao(_c,_acao){
    if(!missoes_ativa(global.jogo))return false;
    var _j=global.jogo;
    if(string_pos("maquina_",_acao)==1){
        if(historia_decisao_pendente(_j))return true;
        var _aberta=maquinas_decisao_aberta(_j),_escolha=string_delete(_acao,1,8),_r=maquinas_decidir(_j,_escolha);
        exploracao_responder(_c,_r,"equipamento");
        if(_r.ok && _aberta)historia_consequencia_maquina(_j,_escolha,_r.mensagem);return true;
    }
    if(string_pos("decisao_",_acao)==1){historia_decisao_responder(_j,real(string_delete(_acao,1,8)));return true;}
    if(_acao=="fechar_conversa"){historia_fechar(_j);return true;}
    if(_acao=="continuar_fala"){historia_continuar(_j);return true;}
    if(string_pos("resposta_",_acao)==1){historia_responder(_j,real(string_delete(_acao,1,9)));return true;}
    if(_acao=="cancelar_reinicio"){_c.reinicio_confirmar=false;return true;}
    if(_acao=="confirmar_reinicio"){
        if(!_c.reinicio_confirmar)return true;var _nova=missoes_reiniciar(_j);
        if(!is_undefined(_nova)){global.jogo=_nova;room_goto(mundo_sala(_nova.exploracao.setor));}return true;
    }
    if(_acao=="cancelar_lote"){_c.lote_em_curso=undefined;_c.mensagem="Preparo cancelado. Os ingredientes continuam na cozinha.";return true;}
    if(historia_modal(_c) && _acao!="pausar")return true;
    if(_acao=="reiniciar_missao"){_c.reinicio_confirmar=true;return true;}
    if(_acao=="pergunta"){if(array_length(_j.missoes.perguntas)>0)historia_enfileirar(_j,_j.missoes.perguntas[0],true);return true;}
    if(_acao=="informacoes" || _acao=="repetir_fala"){historia_enfileirar(_j,"informacoes",true);return true;}
    if(_acao=="mais_pedidos"){exploracao_responder(_c,missoes_mais_pedidos(_j),"novo pedido");return true;}
    if(_acao=="reofertar"){exploracao_responder(_c,missoes_reofertar(_j),"outro pedido");return true;}
    if(_acao=="negociar"){exploracao_responder(_c,missoes_negociar(_j),"combinar prazo");return true;}
    return false;
}
function historia_desenhar(_c){
    if(!missoes_ativa(global.jogo))return;
    var _j=global.jogo,_v=global.visual;
    if(_c.ajuda && !historia_aberta(_j)){
        var _g=missoes_fluxo(_j);ui_cartao(320,110,920,494,_v.claro);
        ui_texto(344,144,"PRÓXIMO PASSO: "+_g.titulo,2,_v.ciano);ui_paragrafo(344,214,_g.acao,830,_v.tinta);
        ui_paragrafo(344,330,"1. Aceite o pedido com Marta. 2. No Estoque, Caio separa o canhoto. 3. Deposite na Produção. 4. Cozinhe na Mesa de preparo. 5. Entregue no Comercial.",830,_v.tinta);
        ui_paragrafo(344,440,"E abre e fecha. H mostra ajuda. O canhoto diz o que falta retirar e o que já está na mochila ou na cozinha.",830,_v.suave);
        if(feira_ativa(_j))ui_paragrafo(344,510,"Acerto no quiz: +2 minutos. No zero, responda para continuar: até 10 resgates de +2 minutos. Errar o resgate encerra a rodada.",830,_v.ciano);
    }
    if(_c.reinicio_confirmar){
        ui_cartao(320,170,920,384,_v.claro);ui_texto(344,204,"RECOMEÇAR O TURNO?",2,_v.ouro);
        ui_paragrafo(344,276,"Isso volta ao início deste pedido. Estoque, dinheiro e bônus voltam juntos. Use CANCELAR para continuar de onde está.",840,_v.tinta);return;
    }
    if(maquinas_decisao_aberta(_j)){maquinas_desenhar(_c);return;}
    if(!is_undefined(_c.lote_em_curso) && !historia_decisao_pendente(_j)){
        ui_cartao(320,170,920,414,_v.claro);ui_texto(344,206,_j.maquinas.aguardar_tecnico?"AGUARDANDO O TÉCNICO":"PREPARANDO O PEDIDO",2,_v.ciano);
        ui_paragrafo(344,270,string(_c.lote_em_curso.quantidade)+" "+produto_obter(_j.catalogo,_c.lote_em_curso.produto_id).nome+". Quando terminar, leve os salgados ao Comercial.",840,_v.tinta);
        ui_barra_segmentada(352,382,840,36,min(1,_c.lote_frames/90),_v.verde);
        ui_texto(352,432,"CAPACIDADE ATUAL: "+string(maquinas_capacidade(_j))+" SALGADOS/HORA",2,_v.ciano);
        ui_paragrafo(352,554,_j.maquinas.mensagem,820,_v.suave);return;
    }
    if(!historia_aberta(_j))return;
    var _m=_j.missoes,_f=_m.fila[_m.indice_fala];
    ui_cartao(320,110,920,494,_v.claro);ui_texto(344,174,_f.personagem,2,_v.ciano);ui_paragrafo(344,224,_f.texto,840,_v.tinta);
    if(_f.tipo=="decisao"){
        if(_m.resposta_atual>=0){
            ui_texto(344,294,"CONSEQUÊNCIA DA SUA ESCOLHA",2,_v.ouro);
            ui_paragrafo(344,328,_f.explicacoes[_m.resposta_atual],840,_v.tinta);
            ui_texto(344,438,"APRENDIZADO",2,_v.ciano);ui_paragrafo(344,466,_f.aprendizado,840,_v.tinta);
        }
        ui_texto(344,578,_m.resposta_atual<0?"ESCOLHA UMA ALTERNATIVA / A CONSEQUÊNCIA APARECE DEPOIS":"RELÓGIO PARADO DURANTE A LEITURA / ESC PARA VOLTAR",1,_v.suave);return;
    }
    if(_f.tipo=="consequencia"){
        ui_texto(344,330,_f.escolha,2,_v.ouro);
        ui_texto(344,406,"APRENDIZADO",2,_v.ciano);ui_paragrafo(344,444,_f.aprendizado,840,_v.tinta);
        ui_texto(344,578,"RELÓGIO E PREPARO PARADOS / VOLTAR AO JOGO PARA CONTINUAR",1,_v.suave);return;
    }
    if(_f.tipo=="pergunta" && _m.resposta_atual>=0){
        ui_texto(344,310,_m.resposta_atual==_f.correta?(feira_ativa(_j)?"ACERTOU! +2 MINUTOS NO RELÓGIO":"ACERTOU! +R$ 10 NO CAIXA"):"SEM PROBLEMA! VEJA A DICA:",2,_v.verde);
        ui_paragrafo(344,364,_f.explicacoes[_m.resposta_atual],840,_v.tinta);
    }
    if(string_pos("intro_",_f.id)==1){
        draw_sprite_ext(object_get_sprite(obj_aula_gerente),0,1130,310,3,3,0,c_white,1);
        ui_texto(344,578,"ENTER, ESPAÇO OU CLIQUE PARA AVANÇAR / ESC PARA PULAR",1,_v.suave);
    }else ui_texto(344,578,_f.tipo=="pergunta" && _m.resposta_atual<0?"ESCOLHA UMA ALTERNATIVA / A EXPLICAÇÃO APARECE DEPOIS":"OPCIONAL / ESC OU X PARA VOLTAR AO JOGO",1,_v.suave);
}
