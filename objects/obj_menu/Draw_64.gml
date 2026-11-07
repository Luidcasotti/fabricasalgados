var _v=global.visual;ui_fundo();tela_cenario=cenario_exibir(tela_cenario,cenario,"");
ui_titulo("MUNDO SENAI 2026 / GESTÃO NA PRÁTICA");
ui_cartao(24,138,398,444,_v.claro);
ui_texto(48,174,"SUA FÁBRICA,",3,_v.tinta);ui_texto(48,212,"SUAS DECISÕES.",3,_v.laranja);
ui_paragrafo(48,264,"5 pedidos para zerar. Acerte perguntas e ganhe tempo.",344,_v.suave);
ui_botao(botao_feira,"JOGAR / 5 MIN",_v.laranja);ui_botao(botao_novo,"MODO COMPLETO",_v.azul);ui_botao(botao_continuar,"CONTINUAR",_v.verde,exploracao_ativa(global.jogo));
ui_texto(48,558,"WASD/SETAS: ANDAR / E: INTERAGIR",1,_v.suave);
ui_texto(610,646,"COMERCIAL / ESTOQUE / PRODUÇÃO",2,_v.tinta);
ui_texto(24,698,"SIMULAÇÃO EDUCACIONAL / NÚMEROS E PORÇÕES FICTÍCIOS",1,_v.suave);
