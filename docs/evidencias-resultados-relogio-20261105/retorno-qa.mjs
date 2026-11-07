import {chromium} from './node_modules/playwright/index.mjs';
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--use-angle=swiftshader']});
const page=await browser.newPage({viewport:{width:1440,height:1000}}),errors=[];
page.on('pageerror',e=>errors.push(e.message));
try {
  await page.goto('http://127.0.0.1:4191/');
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
    return {fase:j[m.fase],naPartida:has,encerrado:j[m.encerrado],dia:j[m.dia],historia:!!ms,entregues:ms?.[m.entregues]?.length,meta:ms?.[m.meta],zerou:ms?.[m.concluida]&&ms?.[m.entregues]?.length>=ms?.[m.meta],oferta:j[m.pedidos]?.find(p=>p.id===ms?.[m.atual_id])?{id:ms[m.atual_id],status:j[m.pedidos].find(p=>p.id===ms[m.atual_id])[m.status],quantidade:j[m.pedidos].find(p=>p.id===ms[m.atual_id])[m.quantidade]}:null,decisaoEstoque:ms?.[m.fila]?.[ms[m.indice_fala]]?.[m.tipo]==='decisao',ativa:!!f,tempo:f?.[m.segundos],limite:f?.[m.limite_segundos],avisou:f?.[m.lembrete_exibido],lembrete:f?.[m.lembrete_segundos],venceu:f?.[m.venceu],concluida:f?.[m.concluida],pausado:j[m.pausado],setor:j[m.exploracao]?.[m.setor],cozinha:inv(j[m.cozinha]),mochila:inv(j[m.carregados]),painel:has?get(id,'painel')?.id:null,painelTipo:has?get(id,'painel')?.[m.tipo]:null,conferido:ms?.[m.estoque_consultado],decisoes:ms?.[m.decisoes]?.length,maquina:j[m.maquinas]?.[m.decisao],produzidos:j[m.producao][m.unidades_produzidas],vendas:j[m.financas][m.receitas_centavos],saldo:j[m.financas][m.saldo_centavos],bonusCaixa:j[m.financas][m.bonus_centavos],bonusTempo:f?.[m.bonus_tempo],resgates:f?.[m.resgates_usados],acertos:f?.[m.resgates_acertos],resgate:f?.[m.resgate]?{correta:f[m.resgate][m.correta],pergunta:f[m.resgate][m.pergunta]}:null,lote:has?get(id,'lote_em_curso'):null,progresso:has?get(id,'lote_frames'):null,quiz:ms?.[m.fila]?.[ms[m.indice_fala]]?.[m.tipo]==='pergunta'?{correta:ms[m.fila][ms[m.indice_fala]][m.correta],resposta:ms[m.resposta_atual]}:null};
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
  const shot=name=>frame.locator('#canvas').screenshot({path:'.testes/browser/retorno-'+name+'.png'});
  const until=async(predicate,ms=20000)=>{const limit=Date.now()+ms;while(Date.now()<limit){if(await predicate())return;await page.waitForTimeout(200)}throw Error('Tempo excedido: '+JSON.stringify(await state()));};
  const acknowledgement=()=>frame.evaluate(()=>{const m=qaMap,j=global[m.jogo],c=j[m.confirmacao];return c?{acao:c[m.acao],titulo:c[m.titulo]}:null});
  const ack=async(action,enter=false)=>{
    assert.equal((await acknowledgement())?.acao,action);
    const paused=(await state()).tempo;await page.waitForTimeout(450);assert.equal((await state()).tempo,paused);
    await shot('confirmacao-'+action);
    if(enter)await key('Enter');else await click(790,500);
    assert.equal(await acknowledgement(),null);
  };
  const returns=[];
  const results=async(method)=>{
    const before=await state();await click(320,674);await until(async()=>(await state()).fase===3);
    const paused=await state();assert(paused.pausado);assert(paused.ativa);assert.equal(paused.limite,before.limite);assert.equal(paused.entregues,before.entregues);
    await page.waitForTimeout(650);assert.equal((await state()).tempo,paused.tempo);await shot('resultados-missao-'+before.entregues+'-'+method);
    if(method==='topo')await click(1095,48);else if(method==='rodape')await click(160,670);else if(method==='Enter')await key('Enter');else await key('Escape');
    await until(async()=>(await state()).fase===2);const after=await state();assert(after.naPartida&&after.ativa&&!after.pausado&&!after.encerrado);assert.equal(after.limite,paused.limite);assert.equal(after.entregues,paused.entregues);assert.equal(after.oferta.id,paused.oferta.id);assert.equal(after.saldo,paused.saldo);assert.deepEqual(after.cozinha,paused.cozinha);assert.deepEqual(after.mochila,paused.mochila);assert(after.tempo>=paused.tempo&&after.tempo<paused.tempo+2);
    const t=after.tempo;await page.waitForTimeout(900);assert((await state()).tempo>t+.6);returns.push({metodo:method,entregues:after.entregues,tempo_pausado:paused.tempo,tempo_retomado:(await state()).tempo,limite:after.limite});
  };
  await start();await results('Esc');
  const go=async(setor)=>{
    const current=(await state()).setor;if(current===setor)return;
    if(current!=='corredor')await interact('saida',3,11);
    await interact('porta_'+setor,...({comercial:[7,2],estoque:[29,2],producao:[18,2]}[setor]));
  };
  const entregas=[];
  for(let n=1;n<=5;n++){
    await go('comercial');await interact('vendas',10,5.2);const offered=(await state()).oferta;assert.equal(offered.status,'ofertado');await click(740,510);await ack('aceitar',true);
    await go('estoque');await interact('compras',15.8,11.5);
    if((await state()).decisaoEstoque){await click(770,338);await key('e');}
    await click(900,510);await ack('separar_pedido',true);
    await go('producao');await interact('deposito',6.5,6.3);await click(900,510);await ack('depositar',true);
    const beforeCook=(await state()).produzidos;await interact('bancada',11.4,7.2);await click(900,510);await ack('produzir',true);
    await until(async()=>{const s=await state();return s.maquina||s.produzidos===beforeCook+offered.quantidade},45000);
    if((await state()).maquina){await click(780,404);await key('e');}
    await until(async()=>(await state()).produzidos===beforeCook+offered.quantidade,45000);await ack('cozinhar',true);
    await go('comercial');await interact('entrega',15,8.2);await click(900,510);assert.equal((await state()).entregues,n);await ack('entregar',true);
    const delivered=await state();assert(delivered.ativa);assert.equal(delivered.entregues,n);entregas.push({numero:n,tempo:delivered.tempo,limite:delivered.limite,vendas:delivered.vendas});await shot('entrega-'+n+'-relogio');
    if(n<5){
      assert(!delivered.encerrado&&!delivered.concluida);assert.equal(delivered.oferta.status,'ofertado');
      if(n===1){const oldLimit=delivered.limite;await click(650,49);assert((await state()).quiz);await click(770,337+(await state()).quiz.correta*70);assert.equal((await state()).limite,oldLimit+120);await key('e');}
      await results(['topo','rodape','Esc','Enter'][n-1]);
    }
    else assert(delivered.zerou&&delivered.venceu&&delivered.encerrado);
    console.log('Missão '+n+'/5: cronômetro preservado');
  }
  const win=await state();assert.equal(win.vendas,62000);assert.equal(win.produzidos,120);assert.equal(win.limite,420);await shot('zerou');
  await click(350,608);await click(220,446);await click(1090,125);await until(async()=>(await state()).naPartida);assert((await state()).ativa);assert.equal((await state()).limite,300);assert.equal((await state()).tempo,0);await key('Escape');await results('topo');
  assert.deepEqual(errors,[]);const result={ok:true,retornos:returns,cinco_entregas_relogio:entregas,historia_com_relogio:true,bonus_preservado:true,win,errors};
  await writeFile('.testes/browser/retorno-qa.json',JSON.stringify(result,null,2));console.log(JSON.stringify(result));
} catch(error){console.log('Erros JS:',JSON.stringify(errors));await page.screenshot({path:'.testes/browser/retorno-falha.png'});throw error} finally {await browser.close()}
