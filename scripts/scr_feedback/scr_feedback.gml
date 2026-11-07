/// Sons curtos próprios, importados como recursos nativos (sem rede ou streaming).
function feedback_iniciar() {
    if(variable_global_exists("audio_feira"))return;
    global.audio_feira={volume:.35,mudo:false};
    audio_master_gain(global.audio_feira.volume);
}
function feedback_som(_tipo) {
    feedback_iniciar();if(global.audio_feira.mudo || global.audio_feira.volume<=0)return;
    var _snd=snd_feira_objetivo;
    switch(_tipo) {
        case "porta":_snd=snd_feira_porta;break;
        case "pedido":_snd=snd_feira_pedido;break;
        case "coleta":_snd=snd_feira_coleta;break;
        case "producao":_snd=snd_feira_producao;break;
        case "alerta":_snd=snd_feira_alerta;break;
    }
    audio_play_sound(_snd,0,false);
}
function feedback_acao(_acao) {
    feedback_iniciar();
    if(_acao=="som")global.audio_feira.mudo=!global.audio_feira.mudo;
    if(_acao=="volume_menos")global.audio_feira.volume=max(0,global.audio_feira.volume-.1);
    if(_acao=="volume_mais")global.audio_feira.volume=min(1,global.audio_feira.volume+.1);
    // Altera também um som que ainda estiver tocando, sem mexer em áudio de outros sistemas.
    audio_master_gain(global.audio_feira.mudo?0:global.audio_feira.volume);
}
