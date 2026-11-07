global.jogo.fase=FaseJogo.PARAMETROS;
entrada_pronta=false;
configuracao=json_parse(json_stringify(global.jogo.parametros));
campos=parametros_campos(configuracao);pagina=0;campo_editando=-1;
layout=parametros_layout();
mensagem="O dia 1 já é jogável. Encerrar dia atualiza compras e prazos, sem produzir ou entregar. Valores fictícios.";

modo_guiado=!exploracao_ativa(global.jogo) || missoes_ativa(global.jogo);
if(!exploracao_ativa(global.jogo))configuracao=missoes_parametros();campos=parametros_campos(configuracao);
mensagem="História: 5 pedidos, 5 minutos e bônus das perguntas. Resultados pausa o jogo; VOLTAR AO JOGO retoma o mesmo cronômetro.";
