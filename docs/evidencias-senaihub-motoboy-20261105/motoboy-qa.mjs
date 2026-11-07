import {chromium} from './node_modules/playwright/index.mjs';
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--use-angle=swiftshader']});
const page=await browser.newPage({viewport:{width:1440,height:1000}}),errors=[];
page.on('pageerror',e=>errors.push(e.message));
try {
  await page.goto('http://127.0.0.1:4192/');
  await page.getByRole('button',{name:'Como jogar'}).click();
  assert.match(await page.locator('#instrucoes').innerText(),/5 minutos/);
  assert.match(await page.locator('#instrucoes').innerText(),/canhoto/);
  assert.match(await page.locator('#instrucoes').innerText(),/até 10 vezes/);
  await page.getByRole('button',{name:'Entendi, vamos jogar'}).click();
  await page.waitForTimeout(2500);
  const frame=page.frames().find(f=>f.url().includes('/game/index.html'));
  await frame.waitForFunction(()=>Object.getOwnPropertyNames(window).some(k=>{try{const v=window[k];return v&&typeof v==='object'&&v.instance_find&&v.variable_instance_get&&v.jogo}catch{return false}}));
  await frame.evaluate(()=>{
    for(const k of Object.getOwnPropertyNames(window)){
      try {const v=window[k];if(v&&typeof v==='object'&&v.instance_find&&v.variable_instance_get&&v.jogo){window.qaMap=v;return}}catch{}
    }
    throw Error('Mapa de símbolos do GameMaker não encontrado');
  });
  const click=async(x,y)=>{const b=await frame.locator('#canvas').boundingBox();await page.mouse.click(b.x+x*b.width/1280,b.y+y*b.height/720,{delay:180});await page.waitForTimeout(250)};
  const key=async(k)=>{await page.keyboard.press(k,{delay:80});await page.waitForTimeout(180)};
  const state=()=>frame.evaluate(()=>{
    const m=qaMap,j=global[m.jogo],f=j[m.feira],ms=j[m.missoes];
    const id=window[m.instance_find](window[m.asset_get_index]('obj_exploracao'),0),has=window[m.instance_exists](id),get=window[m.variable_instance_get];
    const inv=a=>a?.map(i=>({id:i.id,q:i[m.quantidade]}));
    return {compras:j[m.compras]?.map(c=>({id:c.id,ingrediente:c[m.ingrediente_id],quantidade:c[m.quantidade],status:c[m.status],restante:c[m.entrega_restante],motoboy:c[m.via_motoboy]})),almoxarifado:inv(j[m.estoque]?.[m.materias_primas]),comprasPagas:j[m.financas][m.compras_centavos],entregasMoto:j[m.exploracao]?.[m.entregas_motoboy],avisoMoto:j[m.exploracao]?.[m.aviso_entrega],saidaMoto:j[m.exploracao]?.[m.saida_motoboy_segundos],fase:j[m.fase],naPartida:has,encerrado:j[m.encerrado],dia:j[m.dia],historia:!!ms,entregues:ms?.[m.entregues]?.length,meta:ms?.[m.meta],zerou:ms?.[m.concluida]&&ms?.[m.entregues]?.length>=ms?.[m.meta],oferta:j[m.pedidos]?.find(p=>p.id===ms?.[m.atual_id])?{id:ms[m.atual_id],status:j[m.pedidos].find(p=>p.id===ms[m.atual_id])[m.status],quantidade:j[m.pedidos].find(p=>p.id===ms[m.atual_id])[m.quantidade]}:null,decisaoEstoque:ms?.[m.fila]?.[ms[m.indice_fala]]?.[m.tipo]==='decisao',ativa:!!f,tempo:f?.[m.segundos],limite:f?.[m.limite_segundos],avisou:f?.[m.lembrete_exibido],lembrete:f?.[m.lembrete_segundos],venceu:f?.[m.venceu],concluida:f?.[m.concluida],pausado:j[m.pausado],setor:j[m.exploracao]?.[m.setor],cozinha:inv(j[m.cozinha]),mochila:inv(j[m.carregados]),painel:has?get(id,'painel')?.id:null,painelTipo:has?get(id,'painel')?.[m.tipo]:null,conferido:ms?.[m.estoque_consultado],decisoes:ms?.[m.decisoes]?.length,maquina:j[m.maquinas]?.[m.decisao],produzidos:j[m.producao][m.unidades_produzidas],vendas:j[m.financas][m.receitas_centavos],saldo:j[m.financas][m.saldo_centavos],bonusCaixa:j[m.financas][m.bonus_centavos],bonusTempo:f?.[m.bonus_tempo],resgates:f?.[m.resgates_usados],acertos:f?.[m.resgates_acertos],resgate:f?.[m.resgate]?{correta:f[m.resgate][m.correta],pergunta:f[m.resgate][m.pergunta]}:null,lote:has?get(id,'lote_em_curso'):null,progresso:has?get(id,'lote_frames'):null,quiz:ms?.[m.fila]?.[ms[m.indice_fala]]?.[m.tipo]==='pergunta'?{correta:ms[m.fila][ms[m.indice_fala]][m.correta],resposta:ms[m.resposta_atual]}:null};
  });
  const time=s=>frame.evaluate(s=>{const m=qaMap;global[m.jogo][m.feira][m.segundos]=s},s);
  const interact=async(id,u,v)=>{
    if((await state()).painel)await key('e');
    await frame.evaluate(({u,v})=>{
      const m=qaMap,a=window[m.instance_find](window[m.asset_get_index]('obj_cozinheiro'),0),set=window[m.variable_instance_set];
      for(const [k,value] of Object.entries({u,v,x:600+(u-v)*18,y:140+(u+v)*9}))set(a,k,value);
    },{u,v});
    await page.waitForTimeout(80);await key('e');
    const s=await state();if(!id.startsWith('porta')&&id!=='saida')assert.equal(s.painel,id);
  };
  const start=async(natural=false)=>{
    await click(220,355);
    if(!(await state()).ativa){
      console.log('Diagnóstico de entrada:',JSON.stringify({state:await state(),errors,mouse:await frame.evaluate(()=>{const m=qaMap;return {x:window[m.device_mouse_x_to_gui](0),y:window[m.device_mouse_y_to_gui](0),w:document.querySelector('canvas').width,h:document.querySelector('canvas').height}})}));
      await key('Enter');
    }
    assert.equal((await state()).limite,300);assert.equal((await state()).tempo,0);
    await page.waitForTimeout(1500);assert.equal((await state()).tempo,0);
    await key('Space');await page.waitForTimeout(350);assert.equal((await state()).tempo,0);await shot('introducao-sem-tempo');
    if(natural){for(let i=0;i<4;i++)await key('Space');}else await key('Escape');
  };
  const shot=name=>frame.locator('#canvas').screenshot({path:'.testes/browser/motoboy-'+name+'.png'});
  const until=async(predicate,ms=20000)=>{const limit=Date.now()+ms;while(Date.now()<limit){if(await predicate())return;await page.waitForTimeout(200)}throw Error('Tempo excedido: '+JSON.stringify(await state()));};
  const acknowledgement=()=>frame.evaluate(()=>{const m=qaMap,j=global[m.jogo],c=j[m.confirmacao];return c?{acao:c[m.acao],titulo:c[m.titulo]}:null});
  const ack=async(action,enter=false)=>{
    assert.equal((await acknowledgement())?.acao,action);
    const paused=(await state()).tempo;await page.waitForTimeout(450);assert.equal((await state()).tempo,paused);
    await shot('confirmacao-'+action);
    if(enter)await key('Enter');else await click(790,500);
    assert.equal(await acknowledgement(),null);
  };
  // Configuração feita pela UI: 40 porções de queijo para exigir reposição na terceira e quinta missões.
  await click(220,446);await click(300,644);await click(300,644);await click(1000,520);await page.keyboard.type('40',{delay:180});await click(845,474);await shot('configuracao-queijo');await click(1090,125);
  await until(async()=>(await state()).naPartida);assert.equal((await state()).almoxarifado.find(i=>i.id==='queijo').q,40);assert.equal((await state()).tempo,0);await key('Escape');await shot('piso-senai-hub');
  const go=async(setor)=>{const current=(await state()).setor;if(current===setor)return;if(current!=='corredor')await interact('saida',3,11);await interact('porta_'+setor,...({comercial:[7,2],estoque:[29,2],producao:[18,2]}[setor]));};
  const chegadas=[];
  for(let n=1;n<=5;n++){
    await go('comercial');await interact('vendas',10,5.2);const offered=(await state()).oferta;await click(740,510);await ack('aceitar',true);
    await go('estoque');await interact('compras',15.8,11.5);if((await state()).decisaoEstoque){await click(770,338);await key('e');}
    if(n===3||n===5){
      const before=await state(),needed=n===3?20:40;await shot('falta-queijo-'+n);await click(900,510);assert.equal((await acknowledgement())?.acao,'comprar_faltante');
      const purchased=await state(),shipment=purchased.compras.at(-1);assert.equal(shipment.quantidade,needed);assert.equal(shipment.ingrediente,'queijo');assert.equal(shipment.status,'em_transito');assert.equal(shipment.restante,12);assert.equal(purchased.saldo,before.saldo-needed*70);assert.equal(purchased.almoxarifado.find(i=>i.id==='queijo').q,0);
      await page.waitForTimeout(800);assert.equal((await state()).compras.at(-1).restante,12);await ack('comprar_faltante',true);assert.equal((await state()).painel,undefined);
      if(n===3){await key('Escape');const t=(await state()).compras.at(-1).restante;await page.waitForTimeout(700);assert.equal((await state()).compras.at(-1).restante,t);await key('Escape');}
      await page.waitForTimeout(5000);await shot('motoboy-chegando-'+n);assert.equal((await state()).compras.at(-1).status,'em_transito');
      await until(async()=>(await state()).compras.at(-1).status==='recebida',18000);const received=await state();await shot('motoboy-entregou-'+n);
      assert.equal(received.almoxarifado.find(i=>i.id==='queijo').q,needed);assert.equal(received.saldo,purchased.saldo);assert.equal(received.dia,1);assert(received.saidaMoto>0);assert.match(received.avisoMoto,/Motoboy entregou/);chegadas.push({missao:n,quantidade:needed,compra:received.compras.at(-1),saldo:received.saldo});
      await page.waitForTimeout(650);assert.equal((await state()).almoxarifado.find(i=>i.id==='queijo').q,needed);
      await interact('compras',15.8,11.5);
    }
    await click(900,510);await ack('separar_pedido',true);await go('producao');await interact('deposito',6.5,6.3);await click(900,510);await ack('depositar',true);
    const produced=(await state()).produzidos;await interact('bancada',11.4,7.2);await click(900,510);await ack('produzir',true);
    await until(async()=>{const a=await state();return a.maquina||a.produzidos===produced+offered.quantidade},45000);if((await state()).maquina){await click(780,404);await key('e');}
    await until(async()=>(await state()).produzidos===produced+offered.quantidade,45000);await ack('cozinhar',true);
    await go('comercial');await interact('entrega',15,8.2);await click(900,510);await ack('entregar',true);assert.equal((await state()).entregues,n);console.log('Missão '+n+'/5 concluída');
  }
  const win=await state();assert(win.zerou&&win.venceu);assert.equal(win.produzidos,120);assert.equal(win.vendas,62000);assert.equal(win.comprasPagas,4200);assert.equal(win.entregasMoto,2);assert(win.compras.every(c=>c.status==='recebida'));assert.deepEqual(errors,[]);await shot('final-com-reposicao');
  const result={ok:true,estoque_inicial_configurado_pela_ui:40,cinco_missoes_com_reposicao:true,duas_entregas_reais:chegadas,pausa_congela_entrega:true,confirmacao_congela_entrega:true,sem_cobranca_na_chegada:true,sem_virar_dia:true,win,errors};await writeFile('.testes/browser/motoboy-qa.json',JSON.stringify(result,null,2));console.log(JSON.stringify(result));
} catch(error){console.log('Erros JS:',JSON.stringify(errors));await page.screenshot({path:'.testes/browser/motoboy-falha.png'});throw error} finally {await browser.close()}
