missoes_finalizar(global.jogo);
global.jogo.fase=FaseJogo.RESULTADOS;entrada_pronta=false;
resumo=dashboard_calcular(global.jogo);reflexoes=dashboard_reflexoes(global.jogo,resumo);
eventos=dashboard_eventos(global.jogo);layout=dashboard_layout();aba_dashboard=0;pagina_dashboard=0;

if(missoes_ativa(global.jogo) && global.jogo.missoes.concluida)aba_dashboard=6;
