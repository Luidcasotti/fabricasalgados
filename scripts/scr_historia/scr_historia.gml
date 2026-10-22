/// Conteúdo editável: falas e perguntas por ID. Fila e leitura ficam no estado persistente.
function historia_fala(_id,_p,_t,_fim="") {return {id:_id,tipo:"fala",personagem:_p,texto:_t,acao_final:_fim};}
function historia_pergunta(_id,_t,_op,_correta,_exp) {return {id:_id,tipo:"pergunta",personagem:"PARE E PENSE",texto:_t,opcoes:_op,correta:_correta,explicacoes:_exp,acao_final:""};}
function historia_conteudo(_j,_id) {
    var _m=_j.missoes,_p=catalogo_buscar(_j.pedidos,_m.primeiro_id),_f=[];
    switch(_id) {
        case "intro":return [
            historia_fala("intro_1","GERENTE / SABOR & GESTÃO","Bem-vindo à Sabor & Gestão! Nossa empresa produz salgados para atender encomendas de clientes."),
            historia_fala("intro_2","GERENTE / SABOR & GESTÃO","Para tudo funcionar, precisamos organizar as vendas, os ingredientes e a produção."),
            historia_fala("intro_3","GERENTE / SABOR & GESTÃO","Hoje você ficará responsável pelos primeiros pedidos. Vou ajudá-lo a conhecer a fábrica.","iniciar")];
        case "primeiro_pedido":return [
            historia_fala("pedido_1","MARTA / ATENDENTE","Bom dia! Recebemos uma encomenda de 10 coxinhas. Podemos atender esse cliente?"),
            historia_fala("pedido_2","GERENTE","Antes de decidir, compare a receita, os ingredientes e a capacidade. O lote usa "+string(produto_obter(_j.catalogo,"coxinha").capacidade_unidade*10)+" pontos; hoje cabem "+string(_j.parametros.capacidade_diaria)+". Ingrediente no Estoque ainda precisa chegar à cozinha. Use Ver informações da encomenda para conferir.")];
        case "informacoes":
            _p=catalogo_buscar(_j.pedidos,(_m.etapa>=EtapaMissao.DESAFIO)?_m.segundo_id:_m.primeiro_id);
            var _prod=produto_obter(_j.catalogo,_p.produto_id),_texto="Pedido #"+string(_p.id)+": "+string(_p.quantidade)+" "+_prod.nome+". Prazo dia "+string(_p.prazo_dia)+". Receita de venda "+financas_formatar(_p.total_centavos)+"; custo variável "+financas_formatar(_prod.custo_variavel_centavos*_p.quantidade)+". Capacidade necessária "+string(_prod.capacidade_unidade*_p.quantidade)+" / disponível "+string(_j.parametros.capacidade_diaria-_j.producao.capacidade_usada)+".";
            array_push(_f,historia_fala("info_geral","MARTA / INFORMAÇÕES",_texto));
            for(var _i=0;_i<array_length(_prod.receita);_i++) {
                var _a=_prod.receita[_i];if(_a.quantidade==0)continue;var _in=ingrediente_obter(_j.catalogo,_a.ingrediente_id);
                array_push(_f,historia_fala("info_"+_in.id,"RECEITA / "+string_upper(_in.nome),"Para o pedido: "+string(_a.quantidade*_p.quantidade)+". Cozinha: "+string(estoque_quantidade(_j.cozinha,_in.id))+"; mochila: "+string(estoque_quantidade(_j.carregados,_in.id))+"; depósito: "+string(estoque_quantidade(_j.estoque.materias_primas,_in.id))+"; em trânsito: "+string(compras_pendentes_quantidade(_j,_in.id))+". Prazo de reposição: "+string(_in.prazo_dias)+" dia(s)."));
            }
            return _f;
        case "aceite_primeiro":return [historia_fala("aceite_1","MARTA / ATENDENTE","Pedido aceito. Vá até a Produção e consulte a bancada de preparo. O pagamento só entra após a entrega.")];
        case "recusa_primeiro":return [historia_fala("recusa_1","GERENTE","Recusar evita assumir um compromisso, mas também deixa a venda passar. Para aprender o percurso, converse com Marta e escolha Novo pedido guiado. Sua recusa ficará no histórico.")];
        case "nova_oportunidade":return [historia_fala("nova_1","MARTA / ATENDENTE","Temos outra oferta de 10 coxinhas para praticar. Confira as informações e decida. O pedido recusado não foi apagado.")];
        case "falta_frango":return [
            historia_fala("frango_1","BIA / COZINHEIRA","Ainda não podemos começar! Está faltando frango aqui na cozinha."),
            historia_fala("frango_2","BIA / COZINHEIRA","Vamos verificar se existe frango disponível no nosso Estoque. A receita dos outros ingredientes já está separada. Busque o frango e traga à mesa de depósito.")];
        case "pronto_cozinhar":return [historia_fala("pronto_1","BIA / COZINHEIRA","Muito bem! Agora temos os ingredientes necessários. Podemos preparar as coxinhas. Selecione 10 na bancada e acompanhe a barra de preparo.")];
        case "lote_pronto":return [historia_fala("lote_1","BIA / COZINHEIRA","Lote pronto! Os ingredientes foram consumidos e os salgados entraram nos produtos acabados. Volte ao balcão do Comercial para entregar a encomenda.")];
        case "primeira_entrega":return [
            historia_fala("entrega_1","GERENTE","Parabéns! Você percebeu como o Estoque, a Produção e o Comercial precisam trabalhar juntos? O pagamento entrou no caixa: "+financas_formatar(_p.total_centavos)+" de receita. Saldo atual: "+financas_formatar(_j.financas.saldo_centavos)+"."),
            historia_fala("entrega_2","GERENTE","Imagine se tivéssemos aceitado várias encomendas sem verificar os ingredientes. Poderíamos atrasar entregas! Agora converse com Marta: há uma escolha mais difícil.")];
        case "segundo_pedido":return [
            historia_fala("segundo_1","MARTA / ATENDENTE","Chegou um pedido de 10 bolinhas de queijo para o dia "+string(catalogo_buscar(_j.pedidos,_m.segundo_id).prazo_dia)+". Falta queijo também no Estoque. Você pode aceitar e solicitar reposição, negociar um prazo viável ou recusar."),
            historia_fala("segundo_2","GERENTE","Lead time é o tempo entre pedir e receber. O queijo leva "+string(ingrediente_obter(_j.catalogo,"queijo").prazo_dias)+" dia(s). Comprar não resolve a falta na hora. Compare chegada, capacidade, caixa e compromisso; aceitar o prazo original pode gerar atraso.")];
        case "lead_time":return [historia_fala("lead_1","CAIO / ESTOQUE","O fornecedor entrega após o prazo informado, contado em dias da simulação. Encerrar dia faz a espera avançar; depois ainda é preciso retirar, transportar e produzir. Reposição não é entrega ao cliente.")];
        case "aceite_segundo":return [historia_fala("aceite_2","GERENTE","Você assumiu o pedido. Registre sua hipótese de prazo: quando o ingrediente chegará? Uma negociação ainda pode ser feita uma vez com Marta. Sem caixa, reavalie e use Reiniciar missão se precisar rever o capítulo.")];
        case "prazo_negociado":return [historia_fala("negociado_1","MARTA / ATENDENTE","Combinamos um prazo que considera a chegada prevista mais um dia para organizar a produção. A compra não foi feita por você: solicite a reposição no computador do Estoque.")];
        case "recusa_segundo":return [historia_fala("recusa_2","GERENTE","Você evitou assumir um prazo arriscado e abriu mão da receita desse pedido. Essa é uma decisão possível. Consulte os resultados e explique em quais condições aceitaria outra encomenda.")];
        case "segunda_entrega":return [historia_fala("entrega_3","GERENTE","Entrega registrada com o prazo e o pagamento reais. Consulte os resultados: compare sua escolha com as compras, o tempo de espera e os atrasos. Há mais de uma decisão defensável.")];
        case "pergunta_estoque":return [historia_pergunta("q_estoque","Por que devemos conferir o estoque antes de produzir?",["Para confirmar materiais e evitar um lote inviável.","Porque entrar na cozinha cria ingredientes.","Porque o dinheiro substitui qualquer ingrediente."],0,["A receita só pode ser executada com materiais disponíveis no local certo. A conferência evita compromissos impossíveis.","Trocar de sala preserva quantidades; não cria materiais. A transferência e a receita precisam ser conferidas.","Dinheiro permite comprar, mas a matéria-prima tem prazo e precisa chegar à cozinha."])];
        case "pergunta_risco":return [historia_pergunta("q_risco","Qual o risco de aceitar um pedido sem ingredientes suficientes?",["Nenhum: aceitar repõe tudo automaticamente.","Atrasar ou não conseguir atender o compromisso.","Receber o pagamento sem precisar entregar."],1,["Aceitar não compra nem produz. É preciso considerar chegada dos materiais e capacidade.","A falta pode impedir a produção dentro do prazo. Negociar ou recusar também são decisões de planejamento.","O pagamento só ocorre na entrega. Aceitar cria uma obrigação, não uma receita."])];
        case "pergunta_excesso":return [historia_pergunta("q_excesso","Comprar muito mais ingredientes do que precisamos pode causar qual problema?",["Aumenta automaticamente a procura dos clientes.","Garante lucro, mesmo sem vender os salgados.","Prende dinheiro em estoque e reduz o caixa disponível."],2,["Estoque não gera demanda automaticamente. Compare a compra com pedidos e hipóteses de venda.","Comprar gera pagamento; receita depende de entregas. Sobra em estoque não garante lucro.","Recursos gastos em sobras deixam de financiar outras necessidades. Uma reserva pode fazer sentido, mas precisa de justificativa."])];
    }
    return [];
}
function historia_aberta(_j) {return missoes_ativa(_j) && _j.missoes.indice_fala<array_length(_j.missoes.fila);}
function historia_enfileirar(_j,_id,_repetir=false) {
    if(!missoes_ativa(_j))return;
    var _m=_j.missoes;if(!_repetir && variable_struct_exists(_m.vistos,_id))return;
    _j.fala_visivel=false;
    var _f=historia_conteudo(_j,_id);if(array_length(_f)==0)return;
    variable_struct_set(_m.vistos,_id,true);
    if(_f[0].tipo!="pergunta")_m.ultima_explicacao=_id;
    for(var _i=0;_i<array_length(_f);_i++)array_push(_m.fila,_f[_i]);
}
function historia_continuar(_j) {
    if(!historia_aberta(_j))return false;var _m=_j.missoes,_f=_m.fila[_m.indice_fala];
    if(_f.tipo=="pergunta" && _m.resposta_atual<0)return false;
    _m.indice_fala++;_m.resposta_atual=-1;
    if(_f.acao_final=="iniciar" && _m.etapa==EtapaMissao.INTRO) {
        _m.etapa=EtapaMissao.COMERCIAL;missoes_registrar(_j,"CONHECER A FÁBRICA","Introdução lida; próximo passo é conversar no Comercial, não apenas entrar na sala.");
    }
    return true;
}
function historia_responder(_j,_indice) {
    if(!historia_aberta(_j))return false;var _m=_j.missoes,_f=_m.fila[_m.indice_fala];
    if(_f.tipo!="pergunta" || _m.resposta_atual>=0 || _indice<0 || _indice>=array_length(_f.opcoes))return false;
    _m.resposta_atual=_indice;
    array_push(_m.respostas,{id:_f.id,dia:_j.dia,escolha:_indice,correta:_indice==_f.correta,explicacao:_f.explicacoes[_indice]});
    diario_registrar(_j,"REFLETIR / "+_f.texto,_f.opcoes[_indice]+" / "+_f.explicacoes[_indice]);return true;
}
function historia_producao_iniciar(_c,_id,_q) {
    var _j=global.jogo,_b=exploracao_bloqueio_local(_j,"bancada");if(_b!="")return {ok:false,mensagem:_b};
    var _v=missoes_permitir(_j,"produzir",_id,_q);if(!_v.ok)return _v;
    _v=exploracao_receita_validar(_j,_id,_q);if(!_v.ok)return _v;
    _c.lote_em_curso={produto_id:_id,quantidade:_q};_c.lote_frames=0;return {ok:true,mensagem:"Preparando o lote. Materiais e pagamento serão confirmados ao terminar."};
}
function historia_passo(_c) {
    if(is_undefined(_c.lote_em_curso) || global.jogo.pausado)return;
    _c.lote_frames++;
    if(_c.lote_frames>=90) {
        var _l=_c.lote_em_curso;_c.lote_em_curso=undefined;
        exploracao_responder(_c,exploracao_produzir(global.jogo,_l.produto_id,_l.quantidade),"cozinhar");
    }
}
function historia_modal(_c) {return historia_aberta(global.jogo) || _c.reinicio_confirmar || !is_undefined(_c.lote_em_curso);}

function missoes_guia(_j) {
    var _g={titulo:"CONHECER A FÁBRICA",acao:"Converse com o gerente e continue a introdução.",setor:"corredor",alvo:"",motivo:"Conhecer como os setores dependem uns dos outros."};
    var _m=_j.missoes;
    switch(_m.etapa) {
        case EtapaMissao.COMERCIAL:_g={titulo:"1 / PRIMEIRO PEDIDO",acao:"Vá ao Comercial e converse com a atendente.",setor:"comercial",alvo:"vendas",motivo:"Uma encomenda começa no contato com o cliente."};break;
        case EtapaMissao.ANALISAR:_g={titulo:"1 / ANALISAR E DECIDIR",acao:"Confira a encomenda e decida com Marta.",setor:"comercial",alvo:"vendas",motivo:"Compare materiais, capacidade e prazo antes do compromisso."};break;
        case EtapaMissao.RECUPERAR:_g={titulo:"1 / NOVA OPORTUNIDADE",acao:"Converse com Marta e solicite Novo pedido guiado.",setor:"comercial",alvo:"vendas",motivo:"A recusa fica no histórico; outra oferta permite praticar."};break;
        case EtapaMissao.CONSULTAR_BANCADA:_g={titulo:"2 / CONFERIR PRODUÇÃO",acao:"Vá à Produção e consulte a bancada de preparo.",setor:"producao",alvo:"bancada",motivo:"Ter matéria-prima na empresa não significa tê-la na cozinha."};break;
        case EtapaMissao.BUSCAR_FRANGO:_g={titulo:"2 / FALTA LOCAL",acao:"Vá ao Estoque e retire o frango da prateleira.",setor:"estoque",alvo:"prateleira_frango",motivo:"A receita precisa ser abastecida no local de produção."};break;
        case EtapaMissao.DEPOSITAR_FRANGO:_g={titulo:"3 / ORGANIZAR A PRODUÇÃO",acao:"Leve o frango à mesa de depósito na Produção.",setor:"producao",alvo:"deposito",motivo:"A mochila transporta, mas a bancada consome da cozinha."};break;
        case EtapaMissao.COZINHAR:_g={titulo:"3 / PREPARAR O LOTE",acao:"Na bancada, prepare as 10 coxinhas do pedido.",setor:"producao",alvo:"bancada",motivo:"A produção usa receita, capacidade e custo variável reais."};break;
        case EtapaMissao.ENTREGAR:_g={titulo:"4 / ENTREGAR",acao:"Volte ao balcão do Comercial e entregue 10 coxinhas.",setor:"comercial",alvo:"entrega",motivo:"A receita financeira só entra após a entrega."};break;
        case EtapaMissao.DESAFIO:
            _g={titulo:"5 / UMA ESCOLHA MAIS DIFÍCIL",acao:"Converse com Marta: compre, negocie ou recuse.",setor:"comercial",alvo:"vendas",motivo:"Falta queijo na empresa. Compare lead time, prazo e dinheiro."};
            var _p=catalogo_buscar(_j.pedidos,_m.segundo_id);
            if(_p.status!="aceito")break;
            var _prod=produto_obter(_j.catalogo,_p.produto_id),_faltou=false;
            // Priorize falta geral e lead time antes de sugerir várias viagens de coleta.
            for(var _i=0;_i<array_length(_prod.receita);_i++) {
                var _a=_prod.receita[_i];if(_a.quantidade*_p.quantidade<=exploracao_total_insumo(_j,_a.ingrediente_id))continue;
                _g.setor="estoque";_g.alvo="compras";_faltou=true;
                _g.acao=compras_pendentes_quantidade(_j,_a.ingrediente_id)>0?"Compra em trânsito: encerre dias até a chegada prevista.":"Solicite reposição no computador do Estoque; confira custo e prazo.";break;
            }
            if(_faltou)break;
            if(exploracao_carregado_total(_j)>=_j.exploracao.limite_transporte) {_g.acao="Mochila cheia: leve os ingredientes à mesa de depósito.";_g.setor="producao";_g.alvo="deposito";break;}

            for(var _i=0;_i<array_length(_prod.receita);_i++) {
                var _a=_prod.receita[_i],_q=_a.quantidade*_p.quantidade-estoque_quantidade(_j.cozinha,_a.ingrediente_id)-estoque_quantidade(_j.carregados,_a.ingrediente_id);
                if(_q<=0)continue;_faltou=true;_g.setor="estoque";
                if(estoque_quantidade(_j.estoque.materias_primas,_a.ingrediente_id)>0) {_g.alvo="prateleira_"+_a.ingrediente_id;_g.acao="Retire "+ingrediente_obter(_j.catalogo,_a.ingrediente_id).nome+" no Estoque e leve à cozinha.";}
                else if(compras_pendentes_quantidade(_j,_a.ingrediente_id)>0) {_g.alvo="compras";_g.acao="Compra em trânsito: encerre dias até a chegada prevista.";}
                else {_g.alvo="compras";_g.acao="Solicite reposição no computador do Estoque; confira custo e prazo.";}
                break;
            }
            if(!_faltou) {
                _g.setor="producao";
                if(exploracao_carregado_total(_j)>0){_g.alvo="deposito";_g.acao="Leve os ingredientes à mesa de depósito na Produção.";}
                else {_g.alvo="bancada";_g.acao="Prepare o segundo pedido na bancada da Produção.";}
            }
            break;
        case EtapaMissao.DESAFIO_ENTREGAR:_g={titulo:"5 / CUMPRIR O COMPROMISSO",acao:"Entregue o segundo pedido no balcão do Comercial.",setor:"comercial",alvo:"entrega",motivo:"O prazo contratado determina pontualidade ou atraso."};break;
        case EtapaMissao.RESULTADOS:_g={titulo:"CONSULTAR RESULTADOS",acao:"Use Resultados para rever sua história e as decisões.",setor:_j.exploracao.setor,alvo:"",motivo:"Compare compras, receitas, problemas e o que você praticou."};break;
        case EtapaMissao.CONCLUIDA:_g={titulo:"HISTÓRIA CONCLUÍDA",acao:"Reveja os resultados ou reinicie para testar outra decisão.",setor:"comercial",alvo:"",motivo:"Os indicadores usam a simulação real, sem nota inventada."};break;
    }
    return _g;
}
function missoes_indicacao(_j,_mundo) {
    var _g=missoes_guia(_j),_id=_g.alvo;
    if(_id=="")return undefined;
    if(_g.setor!=_mundo.setor)_id=(_mundo.setor=="corredor")?"porta_"+_g.setor:"saida";
    return catalogo_buscar(_mundo.alvos,_id);
}
function missoes_indicador_desenhar(_c) {
    if(!missoes_ativa(global.jogo) || historia_modal(_c) || _c.ajuda || !is_undefined(_c.painel))return;
    var _al=missoes_indicacao(global.jogo,_c.mundo),_a=instance_find(obj_cozinheiro,0);if(is_undefined(_al) || !instance_exists(_a))return;
    var _p=mundo_projetar(_al.u,_al.v),_ang=point_direction(_a.x,_a.y,_p.x,_p.y);
    ui_cartao(306,110,670,68,global.visual.claro);
    draw_set_color(global.visual.laranja);draw_arrow(340,144,340+lengthdir_x(28,_ang),144+lengthdir_y(28,_ang),10);
    ui_texto(394,126,"SIGA A INDICAÇÃO",1,global.visual.suave);ui_texto(394,150,_al.nome,1,global.visual.azul);
}
function missoes_relatorio(_j) {
    var _m=_j.missoes,_r=dashboard_calcular(_j),_a=[];
    array_push(_a,{titulo:"HISTÓRIA / DADOS REAIS",texto:(_m.concluida?"Missões principais concluídas.":"História em andamento ou encerrada pelo período.")+" Pedidos recebidos: "+string(_r.recebidos)+"; entregues: "+string(_r.pedidos_atendidos)+"; recusados: "+string(_r.recusados)+". Compras: "+financas_formatar(_r.compras_centavos)+"; receitas: "+financas_formatar(_r.receitas_centavos)+"; resultado de caixa: "+financas_formatar(_r.resultado_caixa_centavos)+"."});
    for(var _i=0;_i<array_length(_m.problemas);_i++)array_push(_a,{titulo:"PROBLEMA ENFRENTADO",texto:_m.problemas[_i]});
    if(array_length(_m.evidencias)==0)array_push(_a,{titulo:"O QUE VOCÊ PRATICOU",texto:"Ainda não há ação concluída suficiente. Leia o objetivo e continue a história."});
    for(var _i=0;_i<array_length(_m.evidencias);_i++)array_push(_a,{titulo:"O QUE VOCÊ PRATICOU / EVIDÊNCIA",texto:_m.evidencias[_i]+" Como você explicaria essa decisão?"});
    for(var _i=0;_i<array_length(_m.respostas);_i++) {
        var _q=_m.respostas[_i];array_push(_a,{titulo:_q.correta?"PERGUNTA / CONCEITO IDENTIFICADO":"PERGUNTA / REVER O CONCEITO",texto:_q.explicacao});
    }
    if(array_length(_m.respostas)==0)array_push(_a,{titulo:"PERGUNTAS",texto:"Nenhuma resposta registrada. Não há pontuação ou percentual de aprendizagem para estimar."});
    return _a;
}
function historia_botoes(_c,_base) {
    if(!missoes_ativa(global.jogo))return _base;
    var _a=[];
    if(_c.reinicio_confirmar)return [
        {area:ui_area(352,446,360,56),texto:"CANCELAR",acao:"cancelar_reinicio"},
        {area:ui_area(736,446,454,56),texto:"RESTAURAR CAPÍTULO",acao:"confirmar_reinicio"}];
    if(!is_undefined(_c.lote_em_curso))return [
        {area:ui_area(356,480,350,56),texto:"CANCELAR PREPARO",acao:"cancelar_lote"},
        {area:ui_area(730,480,450,56),texto:global.jogo.pausado?"RETOMAR":"PAUSAR",acao:"pausar"}];
    if(historia_aberta(global.jogo)) {
        var _m=global.jogo.missoes,_f=_m.fila[_m.indice_fala];
        if(_f.tipo=="pergunta" && _m.resposta_atual<0)for(var _i=0;_i<array_length(_f.opcoes);_i++)array_push(_a,{area:ui_area(344,310+_i*70,872,54),texto:_f.opcoes[_i],acao:"resposta_"+string(_i)});
        else array_push(_a,{area:ui_area(970,546,246,48),texto:"CONTINUAR",acao:"continuar_fala"});
        array_push(_a,{area:ui_area(16,648,268,50),texto:"REINICIAR MISSÃO",acao:"reiniciar_missao"});return _a;
    }
    _a=_base;
    // O botão pedido pelo aluno fica sempre acessível durante a exploração.
    _a[0]={area:ui_area(890,24,366,46),texto:"O QUE PRECISO FAZER?",acao:"ajuda"};
    array_push(_a,{area:ui_area(858,648,398,50),texto:"REINICIAR MISSÃO",acao:"reiniciar_missao"});
    if(_c.ajuda)array_push(_a,{area:ui_area(344,540,550,48),texto:"REPETIR ÚLTIMA EXPLICAÇÃO",acao:"repetir_fala"});
    if(!is_undefined(_c.painel) && _c.painel.tipo=="vendas") {
        array_push(_a,{area:ui_area(626,548,568,44),texto:"VER INFORMAÇÕES DA ENCOMENDA",acao:"informacoes"});
        if(global.jogo.missoes.etapa==EtapaMissao.RECUPERAR)array_push(_a,{area:ui_area(626,420,568,52),texto:"NOVO PEDIDO GUIADO",acao:"reofertar"});
        if(global.jogo.missoes.etapa==EtapaMissao.DESAFIO && !global.jogo.missoes.negociou)array_push(_a,{area:ui_area(626,426,568,48),texto:"NEGOCIAR / DIA "+string(missoes_prazo_proposto(global.jogo))+" / ACEITAR",acao:"negociar"});
    }
    return _a;
}
function historia_acao(_c,_acao) {
    if(!missoes_ativa(global.jogo))return false;
    var _j=global.jogo;
    if(_acao=="reiniciar_missao") {_c.reinicio_confirmar=true;return true;}
    if(_acao=="cancelar_reinicio") {_c.reinicio_confirmar=false;return true;}
    if(_acao=="confirmar_reinicio") {if(!_c.reinicio_confirmar)return true;var _nova=missoes_reiniciar(_j);if(!is_undefined(_nova)){global.jogo=_nova;room_goto(mundo_sala(_nova.exploracao.setor));}return true;}
    if(_acao=="cancelar_lote") {_c.lote_em_curso=undefined;_c.mensagem="Preparo cancelado antes do consumo; estoque e dinheiro preservados.";return true;}
    if(_acao=="continuar_fala") {historia_continuar(_j);return true;}
    if(string_pos("resposta_",_acao)==1){historia_responder(_j,real(string_delete(_acao,1,9)));return true;}
    if(historia_modal(_c) && _acao!="pausar")return true;
    if(_acao=="repetir_fala") {_c.ajuda=false;historia_enfileirar(_j,_j.missoes.ultima_explicacao,true);return true;}
    if(_acao=="informacoes") {if(mundo_perto(_j,"vendas")){_j.missoes.informacoes=true;historia_enfileirar(_j,"informacoes",true);}return true;}
    if(_acao=="reofertar") {exploracao_responder(_c,missoes_reofertar(_j),"novo pedido");return true;}
    if(_acao=="negociar") {exploracao_responder(_c,missoes_negociar(_j),"negociar prazo");return true;}
    return false;
}
function historia_desenhar(_c) {
    if(!missoes_ativa(global.jogo))return;
    var _j=global.jogo,_v=global.visual;
    if(_c.ajuda && !historia_aberta(_j)) {
        var _g=missoes_guia(_j);ui_cartao(320,110,920,494,_v.claro);
        ui_texto(344,144,_g.titulo,2,_v.azul);
        ui_texto(344,200,"PRÓXIMA AÇÃO",1,_v.suave);ui_paragrafo(344,226,_g.acao,820,_v.tinta);
        ui_texto(344,298,"LOCAL: "+string_upper(_g.setor),2,_v.azul);
        ui_paragrafo(344,346,_g.motivo,820,_v.tinta);
        ui_paragrafo(344,426,"WASD/setas: andar. E: interagir perto do alvo. Esc: fechar painel ou pausar. As falas aguardam sua leitura; nada avança por tempo de leitura.",820,_v.suave);
    }
    if(_c.reinicio_confirmar) {
        ui_cartao(320,170,920,384,_v.claro);ui_texto(344,204,"REINICIAR O CAPÍTULO?",2,_v.laranja);
        ui_paragrafo(344,268,"O jogo voltará ao início do capítulo atual. Estoques, caixa, pedidos e decisões posteriores ao checkpoint serão restaurados juntos. Não há penalidade; confirme para tentar outra hipótese.",840,_v.tinta);return;
    }
    if(!is_undefined(_c.lote_em_curso)) {
        ui_cartao(320,170,920,414,_v.claro);ui_texto(344,206,"BIA / PREPARANDO O LOTE",2,_v.azul);
        ui_paragrafo(344,264,"Preparando "+string(_c.lote_em_curso.quantidade)+" salgados. Ao terminar, a receita será consumida e os produtos acabados serão registrados uma vez.",840,_v.tinta);
        draw_set_color(_v.linha);draw_rectangle(352,382,1192,418,false);draw_set_color(_v.verde);draw_rectangle(352,382,352+840*min(1,_c.lote_frames/90),418,false);
        ui_texto(356,440,_j.pausado?"PREPARO PAUSADO":"PREPARO EM ANDAMENTO",2,_v.tinta);return;
    }
    if(!historia_aberta(_j))return;
    var _m=_j.missoes,_f=_m.fila[_m.indice_fala];
    ui_cartao(16,218,268,196,_v.claro);ui_centro(150,238,"SABOR & GESTÃO",1,_v.azul);
    historia_retrato(76,376,false);historia_retrato(218,376,true);
    ui_centro(76,394,"GERENTE",1,_v.tinta);ui_centro(214,394,"VOCÊ",1,_v.tinta);
    ui_cartao(320,110,920,494,_v.claro);
    ui_texto(344,144,_f.personagem,2,_v.azul);ui_paragrafo(344,204,_f.texto,840,_v.tinta);
    if(_f.tipo=="pergunta" && _m.resposta_atual>=0) {
        ui_texto(344,310,_m.resposta_atual==_f.correta?"CONCEITO IDENTIFICADO":"VAMOS REVER ESSA IDEIA",2,_v.verde);
        ui_paragrafo(344,360,_f.explicacoes[_m.resposta_atual],840,_v.tinta);
    }
    ui_texto(344,574,"LEIA NO SEU TEMPO. E / ESC NÃO PULAM ESTA CONVERSA.",1,_v.suave);
}

/// Retratos provisórios próprios em GML: recepção visível mesmo com a conversa aberta.
function historia_retrato(_x,_y,_chef) {
    if(visuais_alunos_retrato(_x,_y,_chef))return;
    var _v=global.visual;
    draw_set_color(_v.tinta);draw_rectangle(_x-14,_y-20,_x-3,_y,false);draw_rectangle(_x+3,_y-20,_x+14,_y,false);
    draw_set_color(_chef?_v.claro:_v.azul);draw_rectangle(_x-20,_y-58,_x+20,_y-20,false);
    draw_set_color(make_color_rgb(180,119,76));draw_rectangle(_x-12,_y-84,_x+12,_y-60,false);
    draw_set_color(_v.tinta);draw_rectangle(_x-14,_y-90,_x+14,_y-80,false);draw_rectangle(_x+5,_y-75,_x+8,_y-72,false);
    if(_chef) {draw_set_color(_v.claro);draw_rectangle(_x-16,_y-94,_x+16,_y-84,false);draw_rectangle(_x-9,_y-102,_x+9,_y-94,false);draw_set_color(_v.verde);draw_rectangle(_x-9,_y-51,_x+9,_y-24,false);}
    else {draw_set_color(_v.ouro);draw_rectangle(_x-3,_y-55,_x+3,_y-33,false);}
    draw_set_color(c_white);
}
