global.jogo.fase=FaseJogo.PARAMETROS;
entrada_pronta=false;
configuracao=json_parse(json_stringify(global.jogo.parametros));
campos=parametros_campos(configuracao);pagina=0;campo_editando=-1;
layout=parametros_layout();
mensagem="Dia 1 é preparação. Cada avanço processa 1 dia de operação. Números fictícios.";
