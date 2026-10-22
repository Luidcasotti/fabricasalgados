/// Testes opcionais, executados somente em cópia pelo harness Python.
function teste_exploracao_posicionar(_j,_setor,_alvo) {
    _j.exploracao.setor=_setor;var _m=mundo_criar(_setor);
    for(var _i=0;_i<array_length(_m.alvos);_i++) {
        var _a=_m.alvos[_i];if(_a.id==_alvo) {variable_struct_set(_j.exploracao.posicoes,_setor,{u:_a.u,v:_a.v,face:0});return;}
    }
    throw "Alvo de teste inexistente: "+_alvo;
}
function testes_exploracao_executar() {
    var _t={total:0,falhas:[]},_exigir=method(_t,function(_c,_n){total++;if(!_c)array_push(falhas,_n);show_debug_message((_c?"OK EXPLORAÇÃO: ":"FALHA: ")+_n);});
    var _j=jogo_criar();exploracao_iniciar(_j);
    _exigir(exploracao_ativa(_j) && _j.dia==1 && exploracao_carregado_total(_j)==0,"inicio com mochila e cozinha vazias");
    _exigir(_j.estoque.materias_primas[0].quantidade==120 && _j.cozinha[0].quantidade==0,"ingredientes inicialmente no deposito");
    var _antes=json_stringify(_j);exploracao_iniciar(_j);_exigir(json_stringify(_j)==_antes,"inicializacao idempotente preserva progresso");
    _exigir(!exploracao_retirar(_j,"farinha",5).ok,"nao retira a distancia");
    _exigir(!compra_realizar(_j,"farinha",5).ok && !pedido_decidir(_j,1,true).ok,"compra e aceite exigem presenca");
    teste_exploracao_posicionar(_j,"comercial","vendas");_exigir(pedido_decidir(_j,1,true).ok,"aceita com Marta");
    _exigir(!pedido_decidir(_j,1,true).ok,"nao aceita duas vezes");
    teste_exploracao_posicionar(_j,"estoque","prateleira_farinha");
    _exigir(!exploracao_retirar(_j,"farinha",0).ok && !exploracao_retirar(_j,"farinha",1.5).ok,"retirada valida quantidade");
    _exigir(!exploracao_retirar(_j,"farinha",121).ok,"nao retira mais que estoque");
    _exigir(!exploracao_retirar(_j,"farinha",81).ok,"limite de transporte");
    _exigir(!exploracao_retirar(_j,"frango",5).ok,"cada prateleira tem ingrediente proprio");
    _exigir(exploracao_retirar(_j,"farinha",5).ok && _j.carregados[0].quantidade==5 && _j.estoque.materias_primas[0].quantidade==115,"retirada conserva quantidade");
    _exigir(simulacao_auditar(_j).ok,"auditoria soma tres locais");
    _exigir(!exploracao_depositar(_j).ok,"deposito exige mesa na cozinha");
    teste_exploracao_posicionar(_j,"producao","bancada");
    _exigir(!exploracao_produzir(_j,"coxinha",5).ok,"mochila e deposito nao abastecem bancada automaticamente");
    teste_exploracao_posicionar(_j,"producao","deposito");
    _exigir(exploracao_depositar(_j).ok && _j.cozinha[0].quantidade==5 && _j.carregados[0].quantidade==0,"deposito atomico da mochila para cozinha");
    _exigir(!exploracao_depositar(_j).ok,"repetir deposito nao duplica");
    var _ids=["frango","oleo","embalagens"];
    for(var _i=0;_i<3;_i++) {teste_exploracao_posicionar(_j,"estoque","prateleira_"+_ids[_i]);_exigir(exploracao_retirar(_j,_ids[_i],5).ok,"retira "+_ids[_i]);}
    teste_exploracao_posicionar(_j,"producao","deposito");exploracao_depositar(_j);
    _exigir(!exploracao_produzir(_j,"coxinha",5).ok,"mesa de deposito nao e bancada");
    teste_exploracao_posicionar(_j,"producao","bancada");
    _antes=json_stringify(_j);_exigir(!exploracao_produzir(_j,"coxinha",6).ok && json_stringify(_j)==_antes,"receita insuficiente nao consome recursos");
    _exigir(exploracao_produzir(_j,"coxinha",5).ok,"cozinha lote disponivel");
    _exigir(_j.cozinha[0].quantidade==0 && estoque_quantidade(_j.estoque.produtos,"coxinha")==5,"baixa cozinha e aumenta prontos");
    _exigir(_j.producao.capacidade_usada==5 && _j.financas.variaveis_centavos==125,"custo e capacidade registrados");
    _exigir(simulacao_auditar(_j).ok,"conservacao apos cozinhar");
    _exigir(!pedido_entregar(_j,_j.pedidos[0]).ok,"nao entrega a distancia");
    _exigir(!producao_agendar(_j,"coxinha",1).ok,"fila remota antiga bloqueada na exploracao");
    simulacao_avancar_dia(_j);
    _exigir(_j.pedidos[0].status=="aceito" && estoque_quantidade(_j.estoque.produtos,"coxinha")==5,"encerrar dia nao entrega automaticamente");
    _exigir(_j.producao.capacidade_usada==0 && _j.producao.unidades_produzidas==5,"capacidade renovada sem produzir");
    teste_exploracao_posicionar(_j,"comercial","entrega");
    _exigir(pedido_entregar(_j,_j.pedidos[0]).ok && _j.pedidos[0].pontual,"entrega presencial pontual");
    _exigir(!pedido_entregar(_j,_j.pedidos[0]).ok && _j.financas.receitas_centavos==3000,"nao duplica receita");
    teste_exploracao_posicionar(_j,"estoque","compras");
    _exigir(compra_realizar(_j,"farinha",10).ok && _j.estoque.materias_primas[0].quantidade==115,"compra paga e nao chega instantaneamente");
    simulacao_avancar_dia(_j);
    _exigir(_j.estoque.materias_primas[0].quantidade==125 && _j.compras[0].status=="recebida","compra chega ao deposito apos prazo");
    compras_receber(_j,[]);_exigir(_j.estoque.materias_primas[0].quantidade==125,"recebimento idempotente");
    _exigir(pedidos_gerar_dia(_j)==0 && array_length(_j.pedidos)==9,"ofertas unicas por dia");
    var _d=dashboard_calcular(_j);_exigir(_d.capacidade_usada_total==5 && _d.capacidade_disponivel_total==300,"dashboard inclui dia atual sem duplicar uso");
    _exigir(_d.resultado_caixa_centavos==2275 && _d.estoque_final[0].fisico==125,"dashboard e financeiro reais");
    teste_exploracao_posicionar(_j,"estoque","prateleira_queijo");simulacao_pausar(_j);_antes=json_stringify(_j);
    _exigir(!exploracao_retirar(_j,"queijo",1).ok && !simulacao_avancar_dia(_j).ok && json_stringify(_j)==_antes,"pausa bloqueia operacoes e tempo");simulacao_pausar(_j);
    _exigir(exploracao_retirar(_j,"queijo",80).ok && exploracao_carregado_total(_j)==80,"capacidade exata da mochila");
    _exigir(!exploracao_retirar(_j,"queijo",1).ok,"mochila cheia nao transborda");
    _d=dashboard_calcular(_j);_exigir(_d.estoque_final[2].fisico==100 && _d.estoque_final[2].mochila==80,"dashboard distingue transferencia de consumo");
    _exigir(simulacao_auditar(_j).ok,"conservacao com mochila cheia");
    while(!_j.encerrado)simulacao_avancar_dia(_j);
    _d=dashboard_calcular(_j);_exigir(_j.dia==5 && _j.dias_processados==5 && _d.utilizacao_capacidade==1,"fim no ultimo dia configurado e uso real");
    _antes=json_stringify(_j);_exigir(!simulacao_avancar_dia(_j).ok && !exploracao_retirar(_j,"queijo",1).ok && json_stringify(_j)==_antes,"fim preserva dados");
    var _cfg=parametros_padrao();_cfg.duracao_dias=3;_cfg.prazo_pedido_dias=1;_cfg.capacidade_diaria=4;
    _j=jogo_criar(_cfg);exploracao_iniciar(_j);teste_exploracao_posicionar(_j,"comercial","vendas");pedido_decidir(_j,1,true);
    teste_exploracao_posicionar(_j,"producao","bancada");
    _exigir(!exploracao_produzir(_j,"coxinha",5).ok,"capacidade diaria insuficiente bloqueia");
    simulacao_avancar_dia(_j);simulacao_avancar_dia(_j);
    _exigir(_j.pedidos[0].status=="aceito" && _j.pedidos[0].atraso_dias==1,"pedido atrasado nao apagado");
    teste_exploracao_posicionar(_j,"estoque","compras");compra_realizar(_j,"frango",1);simulacao_avancar_dia(_j);
    _exigir(_j.encerrado && _j.compras[0].status=="em_transito" && _j.financas.compras_centavos==80,"fim preserva compra paga em transito");
    _exigir(is_undefined(dashboard_calcular(_j).taxa_pontualidade),"sem entrega taxa nao aplicavel");

    // Os três produtos usam receitas configuráveis e o mesmo fluxo físico.
    for(var _pi=0;_pi<3;_pi++) {
        _cfg=parametros_padrao();if(_pi==0)_cfg.catalogo.produtos[0].receita[2].quantidade=1;
        _j=jogo_criar(_cfg);exploracao_iniciar(_j);var _prod=_j.catalogo.produtos[_pi];
        for(var _ri=0;_ri<array_length(_prod.receita);_ri++) {
            var _rec=_prod.receita[_ri];if(_rec.quantidade==0)continue;
            teste_exploracao_posicionar(_j,"estoque","prateleira_"+_rec.ingrediente_id);
            exploracao_retirar(_j,_rec.ingrediente_id,_rec.quantidade*2);
        }
        teste_exploracao_posicionar(_j,"producao","deposito");exploracao_depositar(_j);
        teste_exploracao_posicionar(_j,"producao","bancada");
        _exigir(exploracao_produzir(_j,_prod.id,2).ok && estoque_quantidade(_j.estoque.produtos,_prod.id)==2,"receita fisica configuravel / "+_prod.id);
        _exigir(simulacao_auditar(_j).ok,"conservacao por receita / "+_prod.id);
        _j.financas.saldo_centavos=0;var _pre=json_stringify(_j);
        _exigir(!exploracao_produzir(_j,_prod.id,1).ok && json_stringify(_j)==_pre,"falha nao altera saldos / "+_prod.id);
    }
    _cfg=parametros_padrao();_cfg.prazo_pedido_dias=1;_j=jogo_criar(_cfg);exploracao_iniciar(_j);
    teste_exploracao_posicionar(_j,"comercial","vendas");pedido_decidir(_j,1,true);
    var _recs=_j.catalogo.produtos[0].receita;
    for(var _ri=0;_ri<array_length(_recs);_ri++)if(_recs[_ri].quantidade>0){
        teste_exploracao_posicionar(_j,"estoque","prateleira_"+_recs[_ri].ingrediente_id);exploracao_retirar(_j,_recs[_ri].ingrediente_id,_recs[_ri].quantidade*5);
    }
    teste_exploracao_posicionar(_j,"producao","deposito");exploracao_depositar(_j);
    teste_exploracao_posicionar(_j,"producao","bancada");exploracao_produzir(_j,"coxinha",5);
    simulacao_avancar_dia(_j);simulacao_avancar_dia(_j);
    teste_exploracao_posicionar(_j,"comercial","entrega");
    _exigir(pedido_entregar(_j,_j.pedidos[0]).ok && _j.pedidos[0].atraso_dias==1,"entrega presencial atrasada continua possivel");
    _exigir(teste_feedback_tem(_j,"entrega_atrasada") && dashboard_calcular(_j).entregas_atrasadas==1,"atraso alimenta indicador e reflexao");
    _exigir(simulacao_auditar(_j).ok,"conservacao apos entrega atrasada");
    // Geometria e trajetos reais: todos os pontos de interação são alcançáveis.
    var _setores=["corredor","comercial","producao","estoque"];
    for(var _i=0;_i<4;_i++) {
        var _m=mundo_criar(_setores[_i]);
        _exigir(!mundo_livre(_m,-1,5) && !mundo_livre(_m,5,_m.h),"paredes / "+_m.setor);
        for(var _k=0;_k<array_length(_m.alvos);_k++) {
            var _al=_m.alvos[_k],_rota=teste_mundo_rota(_m,_m.entrada.u,_m.entrada.v,_al.u,_al.v);
            _exigir(array_length(_rota)>0,"rota livre / "+_m.setor+" / "+_al.id);
        }
    }
    var _m=mundo_criar("producao"),_a={u:9,v:5.8,x:0,y:0};
    mundo_mover(_a,_m,6,0);_exigir(_a.u<9.76,"colisao bloqueia bancada mesmo em passo grande");
    _a={u:1,v:8,x:0,y:0};mundo_mover(_a,_m,-10,0);_exigir(_a.u>=.6,"parede nao atravessada");
    _t.ok=array_length(_t.falhas)==0;show_debug_message("FDS_EXPLORACAO_TESTES: "+string(_t.total)+" / FALHAS: "+string(array_length(_t.falhas)));return _t;
}
/// BFS de teste: caminhos em meia unidade, usa o mesmo mapa de colisão do jogo.
function teste_mundo_rota(_m,_u,_v,_tu,_tv) {
    var _w=_m.w*2+1,_h=_m.h*2+1,_n=_w*_h,_pais=array_create(_n,-2),_fila=[],_head=0;
    var _sx=round(_u*2),_sy=round(_v*2),_inicio=_sy*_w+_sx,_fim=-1;
    _pais[_inicio]=-1;array_push(_fila,_inicio);
    while(_head<array_length(_fila)) {
        var _at=_fila[_head++],_xx=_at mod _w,_yy=_at div _w;
        if(point_distance(_xx*.5,_yy*.5,_tu,_tv)<.45){_fim=_at;break;}
        var _dx=[1,-1,0,0],_dy=[0,0,1,-1];
        for(var _i=0;_i<4;_i++) {
            var _nx=_xx+_dx[_i],_ny=_yy+_dy[_i];if(_nx<0 || _ny<0 || _nx>=_w || _ny>=_h)continue;
            var _idx=_ny*_w+_nx;
            if(_pais[_idx]!=-2 || !mundo_livre(_m,_nx*.5,_ny*.5))continue;
            _pais[_idx]=_at;array_push(_fila,_idx);
        }
    }
    if(_fim<0)return [];
    var _inversa=[];while(_fim!=-1){array_push(_inversa,{u:(_fim mod _w)*.5,v:(_fim div _w)*.5});_fim=_pais[_fim];}
    var _rota=[];for(var _i=array_length(_inversa)-1;_i>=0;_i--)array_push(_rota,_inversa[_i]);return _rota;
}

function teste_exploracao_comandos() {
    return [
        {setor:"corredor",alvo:"porta_comercial",acao:"porta"},
        {setor:"comercial",alvo:"vendas",acao:"aceitar"},
        {setor:"comercial",alvo:"saida",acao:"porta"},
        {setor:"corredor",alvo:"porta_estoque",acao:"porta"},
        {setor:"estoque",alvo:"prateleira_farinha",acao:"retirar"},
        {setor:"estoque",alvo:"prateleira_frango",acao:"retirar"},
        {setor:"estoque",alvo:"prateleira_oleo",acao:"retirar"},
        {setor:"estoque",alvo:"prateleira_embalagens",acao:"retirar"},
        {setor:"estoque",alvo:"compras",acao:"comprar"},
        {setor:"estoque",alvo:"saida",acao:"porta"},
        {setor:"corredor",alvo:"porta_producao",acao:"porta"},
        {setor:"producao",alvo:"deposito",acao:"depositar"},
        {setor:"producao",alvo:"bancada",acao:"produzir"},
        {setor:"producao",alvo:"saida",acao:"porta"},
        {setor:"corredor",alvo:"porta_comercial",acao:"porta"},
        {setor:"comercial",alvo:"entrega",acao:"entregar"}
    ];
}
/// Navega no Runner. Não usa teletransporte: percorre caminhos com mundo_mover.
function teste_exploracao_partida() {
    global.teste_ticks++;
    if(global.teste_ticks>1600)throw "FDS_PARTIDA_FALHOU: percurso excedeu limite";
    var _j=global.jogo,_et=global.teste_etapa;
    if(room==rm_menu) {
        if(_et==0) {teste_partida_exigir(instance_number(obj_game)==1,"singleton no menu");jogo_novo();global.teste_etapa=1;jogo_ir_para(FaseJogo.PARAMETROS);}
        else if(_et==12) {global.teste_etapa=13;jogo_ir_para(FaseJogo.FABRICA);}
        return;
    }
    if(room==rm_parametros) {
        if(_et==1) {
            screen_save("fds-exploracao-parametros.png");configuracao.duracao_dias=2;
            global.teste_etapa=2;parametros_clique(1090,644);
        } else if(_et==10) {
            teste_partida_exigir(configuracao.duracao_dias==2,"reinicio preserva parametros editaveis");
            configuracao.duracao_dias=1;global.teste_etapa=11;parametros_clique(1090,644);
        }
        return;
    }
    if(room==rm_dashboard) {
        if(_et==5) {
            teste_partida_exigir(!_j.encerrado && _j.pausado && resumo.receitas_centavos==3000,"dashboard parcial pausa sem perder progresso");
            global.teste_etapa=6;dashboard_clicar(150,670);
        } else if(_et==7) {
            teste_partida_exigir(_j.encerrado && _j.dia==2 && _j.dias_processados==2,"fim na sala real rm_dashboard");
            teste_partida_exigir(resumo.recebidos==6 && resumo.aceitos==1 && resumo.entregas_pontuais==1,"indicadores de pedidos reais");
            teste_partida_exigir(resumo.resultado_caixa_centavos==2275 && resumo.utilizacao_capacidade==2.5,"resultado e capacidade reais");
            teste_partida_exigir(resumo.estoque_final[0].fisico==125 && simulacao_auditar(_j).ok,"estoque final e auditoria");
            aba_dashboard=0;pagina_dashboard=0;global.teste_etapa=8;global.teste_aba_ticks=0;
        } else if(_et==8) {
            global.teste_aba_ticks++;
            if(global.teste_aba_ticks mod 3!=0)return;
            screen_save("fds-exploracao-dashboard-"+string(aba_dashboard)+".png");
            teste_partida_exigir(aba_dashboard>=0 && aba_dashboard<6,"aba real do dashboard "+string(aba_dashboard));
            if(aba_dashboard<5)dashboard_clicar(120+(aba_dashboard+1)*208,132);
            else {global.teste_etapa=10;dashboard_clicar(500,670);}
        } else if(_et==11) {
            teste_partida_exigir(_j.encerrado && resumo.dias_processados==1,"segunda partida pode terminar");
            global.teste_etapa=12;dashboard_clicar(1050,670);
        } else if(_et==13) {
            teste_partida_exigir(_j.encerrado,"menu continuar reabre fim preservado");
            show_debug_message("FDS_CAPTURAS_DIR: "+working_directory);
            show_debug_message("FDS_PARTIDA_APROVADA: "+string(global.teste_checks)+" verificações");game_end();
        }
        return;
    }
    if(!instance_exists(obj_exploracao))return;
    var _c=instance_find(obj_exploracao,0),_a=instance_find(obj_cozinheiro,0);
    if(!instance_exists(_a))return;
    if(_et==2) {
        teste_partida_exigir(room==rm_corredor && instance_number(obj_cozinheiro)==1 && instance_number(obj_game)==1,"entrada na sala real com ator e singleton");
        teste_partida_exigir(sprite_get_number(spr_cozinheiro_temp)==8,"sprite proprio com oito quadros");
        global.teste_x_inicial=_a.x;global.teste_y_inicial=_a.y;global.teste_teclas=[vk_right,vk_left,vk_up,vk_down,ord("D"),ord("A"),ord("W"),ord("S")];global.teste_tecla=0;keyboard_key_press(vk_right);global.teste_mov_ticks=0;global.teste_etapa=3;return;
    }
    if(_et==3) {
        global.teste_mov_ticks++;
        if(global.teste_mov_ticks<6)return;
        keyboard_key_release(global.teste_teclas[global.teste_tecla]);
        var _k=global.teste_tecla,_dx=_a.x-global.teste_x_inicial,_dy=_a.y-global.teste_y_inicial;
        var _sentido=_k mod 4;
        teste_partida_exigir((_sentido==0 && _dx>10) || (_sentido==1 && _dx< -10) || (_sentido==2 && _dy< -10) || (_sentido==3 && _dy>10),"tecla real de movimento "+string(_k));
        global.teste_tecla++;
        if(global.teste_tecla<8) {
            global.teste_x_inicial=_a.x;global.teste_y_inicial=_a.y;global.teste_mov_ticks=0;
            keyboard_key_press(global.teste_teclas[global.teste_tecla]);return;
        }
        teste_partida_exigir(camera_get_view_x(_c.camera_mundo)>0,"camera acompanha ator");
        global.teste_comandos=teste_exploracao_comandos();global.teste_comando=0;global.teste_rota=[];global.teste_rota_idx=0;global.teste_etapa=4;return;
    }
    if(_et==4) {
        if(global.teste_comando>=array_length(global.teste_comandos)) {
            teste_partida_exigir(_j.pedidos[0].status=="entregue" && _j.financas.receitas_centavos==3000,"ciclo presencial completo");
            teste_partida_exigir(simulacao_auditar(_j).ok && exploracao_carregado_total(_j)==0,"conservacao apos transporte e entrega");
            exploracao_acao(_c,"pausar");var _d=_j.dia;
            exploracao_acao(_c,"avancar");teste_partida_exigir(_j.dia==_d && _j.pausado,"pausa bloqueia relogio pela interface");
            exploracao_acao(_c,"pausar");global.teste_etapa=5;exploracao_acao(_c,"resultados");return;
        }
        var _cmd=global.teste_comandos[global.teste_comando];
        if(global.teste_rota_idx==0 && array_length(global.teste_rota)==0) {
            teste_partida_exigir(_c.mundo.setor==_cmd.setor,"entrada e retorno / "+_cmd.setor);
            var _al=catalogo_buscar(_c.mundo.alvos,_cmd.alvo);
            if(is_undefined(_al))throw "Alvo inexistente: "+_cmd.alvo;
            global.teste_alvo=_al;
            global.teste_rota=teste_mundo_rota(_c.mundo,_a.u,_a.v,_al.u,_al.v);
            teste_partida_exigir(array_length(global.teste_rota)>0,"caminho alcançavel / "+_cmd.alvo);
            _c.painel=undefined;_j.fala_visivel=false;
        }
        // Percorre o mesmo deslocamento com colisão em passos curtos, acelerando só o teste.
        for(var _passo=0;_passo<30;_passo++) {
            if(global.teste_rota_idx>=array_length(global.teste_rota))break;
            var _p=global.teste_rota[global.teste_rota_idx];
            var _du=clamp(_p.u-_a.u,-.1,.1),_dv=clamp(_p.v-_a.v,-.1,.1);
            var _px=_a.x,_py=_a.y;
            mundo_mover(_a,_c.mundo,_du,_dv);_a.animacao++;
            _a.face=abs(_a.x-_px)>abs(_a.y-_py)?(_a.x>_px?2:1):(_a.y>_py?0:3);
            if(point_distance(_a.u,_a.v,_p.u,_p.v)<.02)global.teste_rota_idx++;
        }
        mundo_guardar(_a);mundo_camera(_c.camera_mundo,_a);
        if(global.teste_rota_idx<array_length(global.teste_rota))return;
        if(!variable_global_exists("teste_interacao_espera"))global.teste_interacao_espera=0;
        global.teste_interacao_espera++;
        if(global.teste_interacao_espera==1) {
            teste_partida_exigir(mundo_perto(_j,_cmd.alvo),"proximidade real / "+_cmd.alvo);
            if(_cmd.acao!="porta") {
                keyboard_key_press(ord("E"));
            }
            return;
        }
        if(global.teste_interacao_espera==2 && _cmd.acao!="porta") {
            keyboard_key_release(ord("E"));
            teste_partida_exigir(!is_undefined(_c.painel) && _c.painel.id==_cmd.alvo,"tecla E abre painel real / "+_cmd.alvo);
            _c.quantidade=(_cmd.acao=="comprar")?10:5;
        }
        if(global.teste_interacao_espera==3) {
            screen_save("fds-exploracao-"+string(global.teste_comando)+"-"+_cmd.setor+".png");
            if(_cmd.acao=="porta") {
                global.teste_comando++;global.teste_rota=[];global.teste_rota_idx=0;global.teste_interacao_espera=0;
                teste_partida_exigir(mundo_interagir(_c,global.teste_alvo),"E atravessa porta / "+_cmd.alvo);return;
            }
            var _bs=exploracao_botoes(_c),_clicou=false;
            for(var _bi=0;_bi<array_length(_bs);_bi++)if(_bs[_bi].acao==_cmd.acao) {
                var _ar=_bs[_bi].area;exploracao_clicar(_c,_ar.x+_ar.w/2,_ar.y+_ar.h/2);_clicou=true;break;
            }
            teste_partida_exigir(_clicou,"hit test do botao / "+_cmd.acao);
            if(_cmd.acao=="aceitar")teste_partida_exigir(_j.pedidos[0].status=="aceito" && _j.fala_visivel,"aceite presencial e balao");
            if(_cmd.acao=="retirar")teste_partida_exigir(estoque_quantidade(_j.carregados,_c.painel.ingrediente_id)==5,"retirada presencial / "+_c.painel.ingrediente_id);
            if(_cmd.acao=="depositar")teste_partida_exigir(exploracao_carregado_total(_j)==0 && _j.cozinha[0].quantidade==5,"deposito presencial conserva mochila");
            if(_cmd.acao=="produzir")teste_partida_exigir(estoque_quantidade(_j.estoque.produtos,"coxinha")==5 && _j.cozinha[0].quantidade==0,"producao presencial consome cozinha");
            if(_cmd.acao=="comprar")teste_partida_exigir(array_length(_j.compras)==1 && _j.compras[0].status=="em_transito","compra presencial com prazo");
            if(_cmd.acao=="entregar")teste_partida_exigir(_j.pedidos[0].status=="entregue","entrega presencial sem duplicar");
        }
        if(global.teste_interacao_espera>=5) {
            screen_save("fds-exploracao-"+string(global.teste_comando)+"-acao.png");
            teste_partida_exigir(instance_number(obj_game)==1 && simulacao_auditar(_j).ok,"persistencia e conservacao apos acao");
            _c.painel=undefined;global.teste_comando++;global.teste_rota=[];global.teste_rota_idx=0;global.teste_interacao_espera=0;
        }
        return;
    }
    if(_et==6) {
        teste_partida_exigir(!_j.pausado && _j.exploracao.setor=="comercial","retomar restaura sala e estado");
        exploracao_acao(_c,"avancar");
        teste_partida_exigir(_j.dia==2 && _j.compras[0].status=="recebida","dia recebe compra paga no deposito");
        global.teste_etapa=7;exploracao_acao(_c,"avancar");return;
    }
    if(_et==11) {
        teste_partida_exigir(_j.dia==1 && _j.financas.receitas_centavos==0 && exploracao_carregado_total(_j)==0,"reinicio limpa estado e conserva arquitetura");
        exploracao_acao(_c,"avancar");return;
    }
}
