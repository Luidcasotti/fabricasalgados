if(global.jogo.encerrado) {jogo_ir_para(FaseJogo.RESULTADOS);exit;}
global.jogo.fase=FaseJogo.FABRICA;entrada_pronta=false;
cenario=cenario_criar();tela_cenario=-1;layout=fabrica_layout();painel="";
produto_indice=0;ingrediente_indice=0;pedido_indice=0;plano_indice=0;resumo_pagina=0;
compra_quantidade=20;producao_quantidade=5;comercial_aba="ofertas";producao_aba="novo";
diario_aba="decisoes";diario_pagina=0;
mensagem="Aceite pedidos, compre ingredientes e planeje lotes. Depois avance o dia.";
mensagem_ok=true;mensagem_tempo=room_speed*10;
