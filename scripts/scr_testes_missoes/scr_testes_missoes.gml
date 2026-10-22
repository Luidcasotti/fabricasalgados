/// Cenários opcionais: só executam no harness em cópia.
function teste_historia_ler(_j,_errar=false) {
    var _n=0;
    while(historia_aberta(_j)) {
        if(_n++>80)throw "Fila de história não concluiu";
        var _m=_j.missoes,_f=_m.fila[_m.indice_fala];
        if(_f.tipo=="pergunta" && _m.resposta_atual<0)historia_responder(_j,_errar?((_f.correta+1) mod 3):_f.correta);
        historia_continuar(_j);
    }
}
function teste_missao_interagir(_j,_setor,_id) {
    teste_exploracao_posicionar(_j,_setor,_id);missoes_evento(_j,"interacao",{id:_id});
}
function teste_missao_primeira_entrega(_j) {
    teste_historia_ler(_j);teste_missao_interagir(_j,"comercial","vendas");teste_historia_ler(_j);
    pedido_decidir(_j,_j.missoes.primeiro_id,true);teste_historia_ler(_j);
    teste_missao_interagir(_j,"producao","bancada");teste_historia_ler(_j);
    teste_exploracao_posicionar(_j,"estoque","prateleira_frango");exploracao_retirar(_j,"frango",10);
    teste_exploracao_posicionar(_j,"producao","deposito");exploracao_depositar(_j);teste_historia_ler(_j);
    teste_exploracao_posicionar(_j,"producao","bancada");exploracao_produzir(_j,"coxinha",10);teste_historia_ler(_j);
    teste_exploracao_posicionar(_j,"comercial","entrega");pedido_entregar(_j,catalogo_buscar(_j.pedidos,_j.missoes.primeiro_id));teste_historia_ler(_j);
}
function testes_missoes_executar() {
    var _t={total:0,falhas:[]},_exigir=method(_t,function(_c,_n){total++;if(!_c)array_push(falhas,_n);show_debug_message((_c?"OK MISSÃO: ":"FALHA: ")+_n);});
    var _cfg=missoes_parametros(),_j=jogo_criar(_cfg),_v,_antes;
    _exigir(missoes_validar_config(_cfg).ok,"preset guiado viavel");
    var _invalido=json_parse(json_stringify(_cfg));_invalido.capacidade_diaria=9;
    _exigir(!missoes_validar_config(_invalido).ok,"capacidade insuficiente na introducao e validada");
    _invalido=json_parse(json_stringify(_cfg));_invalido.caixa_inicial_centavos=0;
    _exigir(!missoes_validar_config(_invalido).ok,"caixa inicial insuficiente e validado");
    _invalido=json_parse(json_stringify(_cfg));_invalido.catalogo.ingredientes[1].estoque_inicial=9;
    _exigir(!missoes_validar_config(_invalido).ok,"frango inicial precisa cobrir primeiro lote");
    _invalido=json_parse(json_stringify(_cfg));_invalido.duracao_dias=2;
    _exigir(!missoes_validar_config(_invalido).ok,"horizonte insuficiente e validado");
    missoes_iniciar(_j);
    _exigir(_j.missoes.etapa==EtapaMissao.INTRO && historia_aberta(_j),"nova historia abre introducao");
    _exigir(array_length(_j.pedidos)==1 && _j.pedidos[0].quantidade==10 && _j.pedidos[0].produto_id=="coxinha","oferta inicial unica de dez coxinhas");
    _exigir(_j.cozinha[0].quantidade==10 && _j.cozinha[1].quantidade==0 && _j.estoque.materias_primas[1].quantidade>=10,"so frango falta no primeiro lote local");
    _exigir(simulacao_auditar(_j).ok,"preparacao inicial conserva materias primas");
    _antes=json_stringify(_j);missoes_iniciar(_j);_exigir(json_stringify(_j)==_antes,"inicializacao nao duplica missao");
    _exigir(!pedido_decidir(_j,1,true).ok,"nao decide durante introducao");
    _exigir(_j.missoes.fila[0].texto=="Bem-vindo à Sabor & Gestão! Nossa empresa produz salgados para atender encomendas de clientes.","fala inicial solicitada");
    historia_continuar(_j);_exigir(_j.missoes.etapa==EtapaMissao.INTRO,"uma fala nao pula introducao inteira");
    teste_historia_ler(_j);_exigir(_j.missoes.etapa==EtapaMissao.COMERCIAL,"fim da introducao pede comercial");
    teste_exploracao_posicionar(_j,"comercial","vendas");
    _exigir(_j.missoes.etapa==EtapaMissao.COMERCIAL && !pedido_decidir(_j,1,true).ok,"entrar e aproximar nao conclui conversa");
    teste_missao_interagir(_j,"producao","bancada");
    _exigir(_j.missoes.etapa==EtapaMissao.COMERCIAL && !exploracao_produzir(_j,"coxinha",10).ok,"interacao fora da ordem nao avanca");
    teste_missao_interagir(_j,"comercial","vendas");_exigir(_j.missoes.etapa==EtapaMissao.ANALISAR && historia_aberta(_j),"conversa real apresenta capacidade antes de decidir");
    teste_historia_ler(_j);_exigir(pedido_decidir(_j,1,false).ok && _j.missoes.etapa==EtapaMissao.RECUPERAR,"recusa inicial e possivel");
    teste_historia_ler(_j);_exigir(missoes_reofertar(_j).ok && array_length(_j.pedidos)==2 && _j.pedidos[0].status=="recusado","recupera recusa sem apagar registro");
    _exigir(!missoes_reofertar(_j).ok,"reoferta nao duplica por repeticao");
    teste_historia_ler(_j);_exigir(pedido_decidir(_j,_j.missoes.primeiro_id,true).ok,"aceita nova oportunidade");
    teste_historia_ler(_j);_exigir(_j.missoes.etapa==EtapaMissao.CONSULTAR_BANCADA,"aceite aponta producao");
    _antes=json_stringify(_j);_exigir(!exploracao_avancar_dia(_j).ok && json_stringify(_j)==_antes,"relógio nao invalida missao introdutoria");
    teste_missao_interagir(_j,"producao","bancada");
    _exigir(_j.missoes.etapa==EtapaMissao.BUSCAR_FRANGO && !exploracao_receita_validar(_j,"coxinha",10).ok,"conferir bancada identifica falta real");
    teste_historia_ler(_j,true);_exigir(array_length(_j.missoes.respostas)==1 && !_j.missoes.respostas[0].correta,"resposta incorreta explica sem penalidade");
    var _n=array_length(_j.missoes.fila);historia_enfileirar(_j,"pergunta_estoque");_exigir(array_length(_j.missoes.fila)==_n,"pergunta so dispara uma vez");
    teste_exploracao_posicionar(_j,"estoque","prateleira_frango");
    _exigir(!exploracao_retirar(_j,"frango",61).ok,"retirada alem do estoque falha");
    _exigir(exploracao_retirar(_j,"frango",10).ok && _j.missoes.etapa==EtapaMissao.DEPOSITAR_FRANGO,"retirada correta pede transporte");
    _exigir(!exploracao_produzir(_j,"coxinha",10).ok,"frango na mochila nao basta para produzir");
    teste_exploracao_posicionar(_j,"producao","deposito");_exigir(exploracao_depositar(_j).ok,"transfere frango real");
    teste_historia_ler(_j);_exigir(_j.missoes.etapa==EtapaMissao.COZINHAR && exploracao_receita_validar(_j,"coxinha",10).ok,"deposito completo libera receita");
    teste_exploracao_posicionar(_j,"producao","bancada");_antes=json_stringify(_j);
    _exigir(!exploracao_produzir(_j,"coxinha",9).ok && json_stringify(_j)==_antes,"lote fora do pedido nao conclui missao");
    var _original=global.jogo;global.jogo=_j;var _c={lote_em_curso:undefined,lote_frames:0,mensagem:""};
    _exigir(historia_producao_iniciar(_c,"coxinha",10).ok && estoque_quantidade(_j.estoque.produtos,"coxinha")==0,"barra comeca sem criar produtos");
    _j.pausado=true;historia_passo(_c);_exigir(_c.lote_frames==0,"pausa interrompe progresso do lote");_j.pausado=false;
    for(var _i=0;_i<89;_i++)historia_passo(_c);
    _exigir(estoque_quantidade(_j.estoque.produtos,"coxinha")==0,"preparo nao termina antes da barra");historia_passo(_c);
    _exigir(estoque_quantidade(_j.estoque.produtos,"coxinha")==10 && _j.missoes.etapa==EtapaMissao.ENTREGAR,"preparo conclui lote uma vez");
    historia_passo(_c);_exigir(_j.producao.unidades_produzidas==10,"passos extras nao duplicam produto");global.jogo=_original;
    teste_historia_ler(_j);teste_exploracao_posicionar(_j,"comercial","entrega");
    _exigir(pedido_entregar(_j,catalogo_buscar(_j.pedidos,_j.missoes.primeiro_id)).ok,"primeira entrega manual");
    _exigir(_j.financas.receitas_centavos==6000 && _j.financas.saldo_centavos==105750,"pagamento real das dez coxinhas");
    _exigir(_j.missoes.etapa==EtapaMissao.DESAFIO && array_length(_j.pedidos)==3,"entrega cria segundo desafio uma vez");
    teste_historia_ler(_j);_exigir(simulacao_auditar(_j).ok && _j.estoque.materias_primas[2].quantidade==0,"falta geral de queijo sem violar conservacao");
    teste_missao_interagir(_j,"comercial","vendas");teste_historia_ler(_j);
    var _ramo_recusa=json_parse(json_stringify(_j));
    _exigir(pedido_decidir(_ramo_recusa,_ramo_recusa.missoes.segundo_id,false).ok,"segunda recusa tem ramo valido");
    teste_historia_ler(_ramo_recusa);_exigir(missoes_finalizar(_ramo_recusa) && _ramo_recusa.missoes.concluida,"recusa segundo conclui historia com primeira entrega");
    var _r=dashboard_calcular(_ramo_recusa);_exigir(_r.recebidos==3 && _r.recusados==2 && _r.receitas_centavos==6000,"recusas e receitas reais no dashboard");
    _exigir(missoes_negociar(_j).ok && catalogo_buscar(_j.pedidos,_j.missoes.segundo_id).prazo_dia==4,"negociacao considera lead time e folga");
    teste_historia_ler(_j);_exigir(!missoes_negociar(_j).ok,"negociacao nao altera prazo repetidamente");
    teste_exploracao_posicionar(_j,"estoque","compras");var _saldo=_j.financas.saldo_centavos;_j.financas.saldo_centavos=0;
    _antes=json_stringify(_j);_exigir(!compra_realizar(_j,"queijo",20).ok && json_stringify(_j)==_antes,"falta de dinheiro nao paga nem cria compras");_j.financas.saldo_centavos=_saldo;
    var _reinicio=missoes_reiniciar(_j);_exigir(_reinicio.missoes.etapa==EtapaMissao.DESAFIO && _reinicio.financas.saldo_centavos==105750 && array_length(_reinicio.compras)==0,"reinicio restaura checkpoint financeiro e fisico do capitulo");
    _exigir(compra_realizar(_j,"queijo",20).ok && _j.estoque.materias_primas[2].quantidade==0,"compra paga nao e estoque instantaneo");
    teste_historia_ler(_j);_exigir(array_length(_j.missoes.respostas)==3,"tres perguntas contextuais registradas");
    _exigir(exploracao_avancar_dia(_j).ok && _j.dia==2 && _j.compras[0].status=="em_transito","lead time exige espera");
    _exigir(exploracao_avancar_dia(_j).ok && _j.dia==3 && _j.compras[0].status=="recebida","chegada somente apos dois dias");
    var _ids=["farinha","queijo","oleo","embalagens"],_qs=[10,20,10,10];
    for(var _i=0;_i<4;_i++){teste_exploracao_posicionar(_j,"estoque","prateleira_"+_ids[_i]);_exigir(exploracao_retirar(_j,_ids[_i],_qs[_i]).ok,"retirada do segundo lote / "+_ids[_i]);}
    teste_exploracao_posicionar(_j,"producao","deposito");exploracao_depositar(_j);
    teste_exploracao_posicionar(_j,"producao","bancada");_exigir(exploracao_produzir(_j,"bolinha_queijo",10).ok,"segundo lote consome receita");teste_historia_ler(_j);
    teste_exploracao_posicionar(_j,"comercial","entrega");_exigir(pedido_entregar(_j,catalogo_buscar(_j.pedidos,_j.missoes.segundo_id)).ok,"segunda entrega com prazo negociado");
    teste_historia_ler(_j);_exigir(_j.missoes.etapa==EtapaMissao.RESULTADOS && !_j.encerrado,"missao pede consulta antes de finalizar");
    _exigir(missoes_finalizar(_j) && !missoes_finalizar(_j),"consulta finaliza sem dupla contagem");
    _r=dashboard_calcular(_j);_exigir(_r.receitas_centavos==10000 && _r.compras_centavos==1400 && _r.variaveis_centavos==500 && _r.resultado_caixa_centavos==8100,"financeiro da historia vem dos movimentos");
    _exigir(_r.entregas_pontuais==2 && _r.capacidade_usada_total==20 && _r.dias_processados==3,"pontualidade e capacidade reais");
    _exigir(simulacao_auditar(_j).ok && array_length(missoes_relatorio(_j))>=6,"auditoria e evidencias pedagogicas finais");
    var _antes_final=json_stringify(_j);_exigir(!exploracao_avancar_dia(_j).ok && json_stringify(_j)==_antes_final,"fim bloqueia novos dias");
    // Aceitar prazo original gera atraso real, mas ainda permite cumprir e aprender.
    _j=jogo_criar(missoes_parametros());missoes_iniciar(_j);teste_missao_primeira_entrega(_j);teste_missao_interagir(_j,"comercial","vendas");teste_historia_ler(_j);
    pedido_decidir(_j,_j.missoes.segundo_id,true);teste_historia_ler(_j);
    teste_exploracao_posicionar(_j,"estoque","compras");compra_realizar(_j,"queijo",20);teste_historia_ler(_j);
    exploracao_avancar_dia(_j);exploracao_avancar_dia(_j);
    for(var _i=0;_i<4;_i++){teste_exploracao_posicionar(_j,"estoque","prateleira_"+_ids[_i]);exploracao_retirar(_j,_ids[_i],_qs[_i]);}
    teste_exploracao_posicionar(_j,"producao","deposito");exploracao_depositar(_j);teste_exploracao_posicionar(_j,"producao","bancada");exploracao_produzir(_j,"bolinha_queijo",10);teste_historia_ler(_j);
    teste_exploracao_posicionar(_j,"comercial","entrega");pedido_entregar(_j,catalogo_buscar(_j.pedidos,_j.missoes.segundo_id));teste_historia_ler(_j);
    _exigir(catalogo_buscar(_j.pedidos,_j.missoes.segundo_id).atraso_dias==1 && dashboard_calcular(_j).entregas_atrasadas==1,"prazo original resulta em atraso coerente");
    _exigir(missoes_finalizar(_j) && simulacao_auditar(_j).ok,"escolha inadequada permite terminar e refletir");
    _t.ok=array_length(_t.falhas)==0;show_debug_message("FDS_MISSOES_TESTES: "+string(_t.total)+" / FALHAS: "+string(array_length(_t.falhas)));return _t;
}

function teste_historia_click(_c,_acao) {
    var _bs=exploracao_botoes(_c);
    for(var _i=0;_i<array_length(_bs);_i++)if(_bs[_i].acao==_acao) {
        var _a=_bs[_i].area;exploracao_clicar(_c,_a.x+_a.w/2,_a.y+_a.h/2);return true;
    }
    throw "FDS_HISTORIA_FALHOU: botao ausente / "+_acao;
}
function teste_historia_cmd(_s,_a,_acao="porta",_q=10) {return {setor:_s,alvo:_a,acao:_acao,quantidade:_q};}
function teste_historia_percurso() {
    var _a=[
        teste_historia_cmd("corredor","porta_producao"),teste_historia_cmd("producao","bancada","fora_ordem"),
        teste_historia_cmd("producao","saida"),teste_historia_cmd("corredor","porta_comercial"),
        teste_historia_cmd("comercial","vendas","informacoes"),teste_historia_cmd("comercial","vendas","ajuda"),
        teste_historia_cmd("comercial","vendas","aceitar"),teste_historia_cmd("comercial","saida"),
        teste_historia_cmd("corredor","porta_producao"),teste_historia_cmd("producao","bancada","consultar"),
        teste_historia_cmd("producao","saida"),teste_historia_cmd("corredor","porta_estoque"),
        teste_historia_cmd("estoque","prateleira_frango","retirar"),teste_historia_cmd("estoque","saida"),
        teste_historia_cmd("corredor","porta_producao"),teste_historia_cmd("producao","deposito","depositar"),
        teste_historia_cmd("producao","bancada","produzir"),teste_historia_cmd("producao","saida"),
        teste_historia_cmd("corredor","porta_comercial"),teste_historia_cmd("comercial","entrega","entregar"),
        teste_historia_cmd("comercial","vendas",global.teste_ramo=="negociar"?"negociar":(global.teste_ramo=="recusar"?"recusar":"aceitar"))];
    if(global.teste_ramo=="recusar")return _a;
    var _resto=[
        teste_historia_cmd("comercial","saida"),teste_historia_cmd("corredor","porta_estoque"),
        teste_historia_cmd("estoque","compras","comprar",20),
        teste_historia_cmd("estoque","compras","esperar"),
        teste_historia_cmd("estoque","prateleira_farinha","retirar"),
        teste_historia_cmd("estoque","prateleira_queijo","retirar",20),
        teste_historia_cmd("estoque","prateleira_oleo","retirar"),
        teste_historia_cmd("estoque","prateleira_embalagens","retirar"),
        teste_historia_cmd("estoque","saida"),teste_historia_cmd("corredor","porta_producao"),
        teste_historia_cmd("producao","deposito","depositar"),teste_historia_cmd("producao","bancada","produzir"),
        teste_historia_cmd("producao","saida"),teste_historia_cmd("corredor","porta_comercial"),
        teste_historia_cmd("comercial","entrega","entregar")];
    for(var _i=0;_i<array_length(_resto);_i++)array_push(_a,_resto[_i]);return _a;
}
/// Driver em cópia: Step de entrada original roda antes deste controlador de teste.
function teste_historia_partida() {
    global.teste_ticks++;if(global.teste_ticks>4000)throw "FDS_HISTORIA_FALHOU: tempo excedido";
    var _j=global.jogo;
    if(room==rm_menu) {
        if(global.teste_etapa==0){jogo_novo();global.teste_etapa=1;jogo_ir_para(FaseJogo.PARAMETROS);}
        else if(global.teste_etapa==7) {global.teste_etapa=8;jogo_ir_para(FaseJogo.FABRICA);}
        return;
    }
    if(room==rm_parametros) {
        if(global.teste_etapa==1) {
            teste_partida_exigir(modo_guiado && configuracao.catalogo.ingredientes[2].estoque_inicial==0,"parametros oferecem preset guiado valido");
            global.teste_cmds=teste_historia_percurso();global.teste_cmd=0;global.teste_rota=[];global.teste_ri=0;global.teste_fase_cmd=0;
            global.teste_soltar_e=false;global.teste_leitura_id="";global.teste_leitura_ticks=0;
            global.teste_etapa=2;parametros_clique(1090,644);
        } else if(global.teste_etapa==5) {
            teste_partida_exigir(modo_guiado,"reinicio mantem historia selecionada");global.teste_etapa=6;parametros_clique(1090,644);
        }
        return;
    }
    if(room==rm_dashboard) {
        if(global.teste_etapa==3) {
            teste_partida_exigir(_j.missoes.concluida && _j.encerrado,"consulta conclui historia e abre dashboard");
            var _recusar=global.teste_ramo=="recusar";
            teste_partida_exigir(resumo.recebidos==2 && resumo.pedidos_atendidos==(_recusar?1:2) && resumo.recusados==(_recusar?1:0),"pedidos recebidos entregues e recusados reais");
            teste_partida_exigir(resumo.receitas_centavos==(_recusar?6000:10000) && resumo.resultado_caixa_centavos==(_recusar?5750:8100),"receitas custos e resultado reais da historia");
            if(!_recusar)teste_partida_exigir(resumo.entregas_atrasadas==(global.teste_ramo=="comprar"?1:0),"prazo original e negociado tem consequencias distintas");
            teste_partida_exigir(array_length(layout.tabs)==7 && array_length(missoes_relatorio(_j))>3,"dashboard inclui aprendizagem e problemas reais");
            teste_partida_exigir(simulacao_auditar(_j).ok && instance_number(obj_game)==1,"conservacao e controlador unico no final");
            global.teste_etapa=4;global.teste_tab=0;global.teste_tab_tick=0;aba_dashboard=0;pagina_dashboard=0;
        } else if(global.teste_etapa==4) {
            global.teste_tab_tick++;if(global.teste_tab_tick mod 3!=0)return;
            screen_save("fds-historia-"+global.teste_ramo+"-dashboard-"+string(global.teste_tab)+".png");
            teste_partida_exigir(aba_dashboard==global.teste_tab,"aba real da historia / "+string(global.teste_tab));
            global.teste_tab++;
            if(global.teste_tab<7){var _a=layout.tabs[global.teste_tab];dashboard_clicar(_a.x+20,_a.y+20);}
            else {global.teste_etapa=5;dashboard_clicar(500,670);}
        } else if(global.teste_etapa==7) {
            teste_partida_exigir(!_j.missoes.concluida && !_j.encerrado,"continuar historia reiniciada abre parcial sem concluir indevidamente");
            show_debug_message("FDS_CAPTURAS_DIR: "+working_directory);
            show_debug_message("FDS_PARTIDA_APROVADA: "+string(global.teste_checks)+" / HISTORIA "+global.teste_ramo);game_end();
        }
        return;
    }
    if(!instance_exists(obj_exploracao))return;
    var _c=instance_find(obj_exploracao,0),_a=instance_find(obj_cozinheiro,0);if(!instance_exists(_a))return;
    if(global.teste_soltar_e){keyboard_key_release(ord("E"));global.teste_soltar_e=false;}
    if(global.teste_etapa==6) {
        teste_partida_exigir(_j.missoes.etapa==EtapaMissao.INTRO && _j.financas.receitas_centavos==0,"reiniciar abre introducao com estado novo");
        global.teste_etapa=7;jogo_ir_para(FaseJogo.MENU);return;
    }
    if(global.teste_etapa==8) {
        teste_partida_exigir(_j.missoes.etapa==EtapaMissao.INTRO && !_j.encerrado && _j.financas.receitas_centavos==0,"menu continuar preserva historia reiniciada");
        show_debug_message("FDS_CAPTURAS_DIR: "+working_directory);
        show_debug_message("FDS_PARTIDA_APROVADA: "+string(global.teste_checks)+" / HISTORIA "+global.teste_ramo);game_end();return;
    }
    if(historia_aberta(_j)) {
        var _m=_j.missoes,_f=_m.fila[_m.indice_fala];
        if(global.teste_leitura_id!=_f.id){global.teste_leitura_id=_f.id;global.teste_leitura_ticks=0;}
        global.teste_leitura_ticks++;
        var _espera=(_f.id=="intro_1")?12:3;if(global.teste_leitura_ticks<_espera)return;
        screen_save("fds-historia-"+global.teste_ramo+"-fala-"+_f.id+".png");
        if(_f.tipo=="pergunta" && _m.resposta_atual<0) {
            screen_save("fds-historia-"+global.teste_ramo+"-pergunta-"+_f.id+".png");
            var _resposta=(_f.id=="q_estoque")?1:_f.correta;
            teste_partida_exigir(teste_historia_click(_c,"resposta_"+string(_resposta)),"alternativa contextual / "+_f.id);
            global.teste_leitura_ticks=0;return;
        }
        teste_partida_exigir(teste_historia_click(_c,"continuar_fala"),"leitura confirmada / "+_f.id);return;
    }
    if(global.teste_cmd>=array_length(global.teste_cmds)) {
        teste_partida_exigir(_j.missoes.etapa==EtapaMissao.RESULTADOS,"acoes corretas deixam consulta como ultimo objetivo");
        global.teste_etapa=3;teste_historia_click(_c,"resultados");return;
    }
    if(!is_undefined(_c.lote_em_curso)) {
        if(_c.lote_frames==45)screen_save("fds-historia-"+global.teste_ramo+"-preparo.png");return;
    }
    var _cmd=global.teste_cmds[global.teste_cmd];
    if(global.teste_fase_cmd==0) {
        if(array_length(global.teste_rota)==0) {
            teste_partida_exigir(_c.mundo.setor==_cmd.setor,"setor real / "+_cmd.setor);
            var _al=catalogo_buscar(_c.mundo.alvos,_cmd.alvo);
            global.teste_rota=teste_mundo_rota(_c.mundo,_a.u,_a.v,_al.u,_al.v);global.teste_ri=0;
            teste_partida_exigir(array_length(global.teste_rota)>0,"caminho / "+_cmd.alvo);
            _c.painel=undefined;_j.fala_visivel=false;
        }
        for(var _i=0;_i<30;_i++) {
            if(global.teste_ri>=array_length(global.teste_rota))break;
            var _p=global.teste_rota[global.teste_ri];mundo_mover(_a,_c.mundo,clamp(_p.u-_a.u,-.1,.1),clamp(_p.v-_a.v,-.1,.1));_a.animacao++;
            if(point_distance(_a.u,_a.v,_p.u,_p.v)<.02)global.teste_ri++;
        }
        mundo_guardar(_a);mundo_camera(_c.camera_mundo,_a);
        if(global.teste_ri<array_length(global.teste_rota))return;
        teste_partida_exigir(mundo_perto(_j,_cmd.alvo),"proximidade / "+_cmd.alvo);
        keyboard_key_press(ord("E"));global.teste_soltar_e=true;global.teste_fase_cmd=1;return;
    }
    if(global.teste_fase_cmd==1) {
        if(_cmd.acao=="porta") {
            global.teste_cmd++;global.teste_rota=[];global.teste_fase_cmd=0;return;
        }
        teste_partida_exigir(!is_undefined(_c.painel) && _c.painel.id==_cmd.alvo,"E abre alvo correto / "+_cmd.alvo);
        _c.quantidade=_cmd.quantidade;
        if(_cmd.alvo=="compras")_c.selecao=2;
        if(_cmd.alvo=="bancada")_c.selecao=(_j.missoes.etapa>=EtapaMissao.DESAFIO)?2:0;
        if(_cmd.acao=="consultar")teste_partida_exigir(_j.missoes.etapa==EtapaMissao.BUSCAR_FRANGO,"conferencia real identifica falta de frango");
        else if(_cmd.acao=="fora_ordem") {
            var _antes=json_stringify(_j.estoque);teste_historia_click(_c,"produzir");
            teste_partida_exigir(_j.missoes.etapa==EtapaMissao.COMERCIAL && json_stringify(_j.estoque)==_antes,"fora da ordem nao consome nem conclui");
        } else if(_cmd.acao=="esperar") {
            teste_historia_click(_c,"fechar");teste_historia_click(_c,"relogio");teste_historia_click(_c,"avancar");
            teste_partida_exigir(_j.dia==2 && _j.compras[0].status=="em_transito","primeira espera nao recebe cedo");
            teste_historia_click(_c,"relogio");teste_historia_click(_c,"avancar");
            teste_partida_exigir(_j.dia==3 && _j.compras[0].status=="recebida","segunda espera recebe compra real");
        } else if(_cmd.acao=="ajuda") {
            teste_historia_click(_c,"ajuda");teste_partida_exigir(_c.ajuda,"O que preciso fazer abre orientacao");
            teste_historia_click(_c,"repetir_fala");teste_partida_exigir(historia_aberta(_j),"explicacao importante pode ser repetida");
        } else teste_historia_click(_c,_cmd.acao);
        global.teste_fase_cmd=2;global.teste_acao_tick=0;return;
    }
    if(global.teste_fase_cmd==2) {
        global.teste_acao_tick++;if(global.teste_acao_tick<3)return;
        if(_cmd.acao=="produzir")teste_partida_exigir(is_undefined(_c.lote_em_curso) && _j.producao.unidades_produzidas>=10,"barra termina e registra lote");
        screen_save("fds-historia-"+global.teste_ramo+"-acao-"+string(global.teste_cmd)+".png");
        teste_partida_exigir(simulacao_auditar(_j).ok,"conservacao apos acao / "+_cmd.acao);
        global.teste_cmd++;global.teste_rota=[];global.teste_fase_cmd=0;_c.painel=undefined;
    }
}
